//
//  ChoreViewController.m
//  Housemate
//
//  Created by Chelsea Pugh on 10/1/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "ChoreViewController.h"
#import "ChoreTableViewCell.h"
#import <Parse/Parse.h>
#import "Chore.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface ChoreViewController ()

@end

@implementation ChoreViewController {
    NSMutableArray *_chores;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNewData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor HMpeachColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:nil
                            action:@selector(getNewData)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.navigationBar.barTintColor = [UIColor HMbloodOrangeColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    _chores = [[NSMutableArray alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"ChoreTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ChoreTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor HMpeachColor];

}

- (void)getNewData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults objectForKey:@"houseID"]) {
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Chore"];
    [query whereKey:@"houseID" equalTo:[defaults objectForKey:@"houseID"]];
    [query includeKey:@"assignee"];
    [query orderByAscending:@"dueDate"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                Chore *c = [[Chore alloc] initWithDictionary:(NSDictionary *)object objId:[object objectId
                                                                                           ]];
                PFObject *user = [object objectForKey:@"assignee"];
                c.assignee = [[User alloc] initWithDictionary:(NSDictionary *)user];
                
                BOOL found = NO;
                for(Chore *existing in _chores) {
                    if([existing.choreID isEqualToString:c.choreID]) {
                        found = YES;
                    }
                }
                if(!found) {
                    [_chores insertObject:c atIndex:0];
                }
            }
            if (self.refreshControl) {
                [self.refreshControl endRefreshing];
            }
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_chores count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ChoreTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"ChoreTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    Chore *c = [_chores objectAtIndex:indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    cell.title.text = c.title;
    cell.assigneeName.text = c.assignee.name;
    cell.dueDate.text = [NSString stringWithFormat:@"Get done by: %@", [formatter stringFromDate:c.dueDate]];
    
    cell.completeButton.backgroundColor = [UIColor HMtangerineColor];
    
    // Replace with id from user defaults
    if(![c.assignee.phoneNumber isEqualToString:[defaults objectForKey:@"id"]]) {
        [cell.completeButton setTitle:@"Remind" forState:UIControlStateNormal];
        [cell.completeButton addTarget:self action:@selector(remindOfChore:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell.completeButton addTarget:self action:@selector(didCompleteChore:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (void)didCompleteChore:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ChoreTableViewCell *cell = (ChoreTableViewCell *)[[sender superview] superview];
    PFQuery *assigneeQuery = [PFQuery queryWithClassName:@"User"];
    [assigneeQuery whereKey:@"name" equalTo:cell.assigneeName.text];
    [assigneeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFQuery *query = [PFQuery queryWithClassName:@"Chore"];
        [query whereKey:@"houseID" equalTo:[defaults objectForKey:@"houseID"]];
        [query whereKey:@"assignee" equalTo:objects[0]];
        [query whereKey:@"title" equalTo:cell.title.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [PFObject deleteAllInBackground:objects];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }];
    NSIndexPath *ip = [self.tableView indexPathForCell:cell];
    NSArray *ips = @[ip];
    [_chores removeObjectAtIndex:ip.row];
    [self.tableView deleteRowsAtIndexPaths:ips withRowAnimation:UITableViewRowAnimationAutomatic];

}

- (void)remindOfChore:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ChoreTableViewCell *cell = (ChoreTableViewCell *)[[sender superview] superview];
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"name" equalTo:cell.assigneeName.text];
    [query whereKey:@"houseID" equalTo:[defaults objectForKey:@"houseID"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
                User *user = [[User alloc] initWithDictionary:(NSDictionary *)object];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                NSDictionary *params = @{@"number": user.phoneNumber,
                                         @"chore": cell.title.text,
                                         @"name": user.name};
                [manager GET:@"http://housem8.ngrok.com/remind" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
                
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
