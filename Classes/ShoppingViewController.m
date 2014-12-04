//
//  ShoppingViewController.m
//  Housemate
//
//  Created by Chelsea Pugh on 12/3/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "ShoppingViewController.h"
#import "NecessityTableViewCell.h"
#import "Necessity.h"
#import <Parse/Parse.h>

@interface ShoppingViewController ()


@end

@implementation ShoppingViewController {
    NSMutableArray *_necessities;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNewData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _necessities = [[NSMutableArray alloc] init];
    
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
    
    UINib *nib = [UINib nibWithNibName:@"NecessityTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"NecessityTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor HMpeachColor];
}

- (void)getNewData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults objectForKey:@"houseID"]) {
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Necessity"];
    [query whereKey:@"houseID" equalTo:[defaults objectForKey:@"houseID"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSMutableArray *curNecessities = [[NSMutableArray alloc] init];
            for (PFObject *object in objects) {
                Necessity *n = [[Necessity alloc] initWithDictionary:(NSDictionary *)object objId:[object objectId]];
                
                BOOL found = NO;
                for(Necessity *existing in _necessities) {
                    if([existing.necID isEqualToString:n.necID]) {
                        found = YES;
                        NSLog(@" %@, %@", existing.necID, n.necID);
                    }
                }
                if(!found) {
                    [_necessities insertObject:n atIndex:0];
                }
                
                [curNecessities addObject:n];
            }
            
            NSMutableArray *removed = [[NSMutableArray alloc] initWithArray:_necessities];
            for(Necessity *old in _necessities) {
                for(Necessity *cur in curNecessities) {
                    if([old.necID isEqualToString: cur.necID]) {
                        [removed removeObject:old];
                    }
                }
            }
            
            for(Necessity *remNec in removed) {
                [_necessities removeObject:remNec];
            }
            
            [self.tableView reloadData];
            
            if (self.refreshControl) {
                [self.refreshControl endRefreshing];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_necessities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NecessityTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"NecessityTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Necessity *n = [_necessities objectAtIndex:indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    cell.nameLabel.text = n.name;
    cell.dueDateLabel.text = [NSString stringWithFormat:@"Needed by: %@",[formatter stringFromDate:n.dateNeeded]];
    
    [cell.boughtItButton addTarget:self action:@selector(bought:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (void)bought:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NecessityTableViewCell *cell = (NecessityTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Necessity"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFQuery *query = [PFQuery queryWithClassName:@"Chore"];
        [query whereKey:@"houseID" equalTo:[defaults objectForKey:@"houseID"]];
        [query whereKey:@"name" equalTo:cell.nameLabel.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [PFObject deleteAllInBackground:objects];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }];
    NSArray *ips = @[indexPath];
    [_necessities removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:ips withRowAnimation:UITableViewRowAnimationAutomatic];
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

@end
