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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.barTintColor = [UIColor HMbloodOrangeColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    _chores = [[NSMutableArray alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"ChoreTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ChoreTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

- (void)viewWillAppear:(BOOL)animated {
    _chores = [[NSMutableArray alloc] init];
    [self getNewData];
}

// TODO: actually get ONLY new data
- (void)getNewData {
    PFQuery *query = [PFQuery queryWithClassName:@"Chore"];
    [query whereKey:@"houseID" equalTo:@"houseID"];
    [query includeKey:@"assignee"];
    [query orderByAscending:@"dueDate"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                Chore *c = [[Chore alloc] initWithDictionary:(NSDictionary *)object];
                PFObject *user = [object objectForKey:@"assignee"];
                c.assignee = [[User alloc] initWithDictionary:(NSDictionary *)user];
                [_chores addObject:c];
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
    ChoreTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"ChoreTableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    Chore *c = [_chores objectAtIndex:indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    cell.title.text = c.title;
    cell.assigneeName.text = c.assignee.name;
    cell.dueDate.text = [formatter stringFromDate:c.dueDate];
    
    cell.completeButton.backgroundColor = [UIColor HMtangerineColor];
    
    // Replace with id from user defaults
    if(![c.assignee.userID isEqualToString:@"10152791884095087"]) {
        [cell.completeButton setTitle:@"Remind" forState:UIControlStateNormal];
        [cell.completeButton addTarget:self action:@selector(remindOfChore:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell.completeButton addTarget:self action:@selector(didCompleteChore:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (void)didCompleteChore:(id)sender {
    ChoreTableViewCell *cell = (ChoreTableViewCell *)[[sender superview] superview];
    PFQuery *assigneeQuery = [PFQuery queryWithClassName:@"User"];
    [assigneeQuery whereKey:@"name" equalTo:cell.assigneeName.text];
    [assigneeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFQuery *query = [PFQuery queryWithClassName:@"Chore"];
        [query whereKey:@"houseID" equalTo:@"houseID"];
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
    ChoreTableViewCell *cell = (ChoreTableViewCell *)[[sender superview] superview];
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"name" equalTo:cell.assigneeName.text];
    [query whereKey:@"houseID" equalTo:@"houseID"];
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
