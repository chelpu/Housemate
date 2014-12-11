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

static NSString *kChoreCellIdentifier = @"ChoreTableViewCell";

@interface ChoreViewController ()

@end

@implementation ChoreViewController 

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNewData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.noHousematesLabel.text = @"No housemates! Add some.";
    self.noResultsLabel.text = @"No chores to do!";
    [self.refreshControl addTarget:nil
                            action:@selector(getNewData)
                  forControlEvents:UIControlEventValueChanged];
    
    UINib *nib = [UINib nibWithNibName:kChoreCellIdentifier bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:kChoreCellIdentifier];
}

- (void)getNewData {
    if(![self.defaults objectForKey:kHouseIDKey]) {
        [self setToStateNoHousemates];
        return;
    } 
    
    PFQuery *query = [PFQuery queryWithClassName:kChoreIdentifier];
    [query whereKey:kHouseIDKey equalTo:[self.defaults objectForKey:kHouseIDKey]];
    [query includeKey:kAssigneeKey];
    [query orderByAscending:kDueDateKey];
    
    if(!self.refreshControl.isRefreshing) {
        [self.hud show:YES];
    }
    [self.list removeAllObjects];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if(![objects count]) {
                [self setToStateNoResults];
                return;
            } else {
                [self setToStateNormal];
            }
            for (PFObject *object in objects) {
                Chore *c = [[Chore alloc] initWithDictionary:(NSDictionary *)object objId:[object objectId]];
                PFObject *user = [object objectForKey:kAssigneeKey];
                c.assignee = [[User alloc] initWithDictionary:(NSDictionary *)user];
                [self.list addObject:c];
            }
            if (self.refreshControl) {
                [self.refreshControl endRefreshing];
            }
            [self.hud hide:YES];
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChoreTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:kChoreCellIdentifier];
    Chore *c = [self.list objectAtIndex:indexPath.row];

    cell.title.text = c.title;
    cell.assigneeName.text = c.assignee.name;
    cell.dueDate.text = [NSString stringWithFormat:@"Get done by %@", [self.formatter stringFromDate:c.dueDate]];
    
    if(![c.assignee.phoneNumber isEqualToString:[self.defaults objectForKey:@"id"]]) {
        [cell.completeButton setTitle:@"Remind" forState:UIControlStateNormal];
        [cell.completeButton removeTarget:self action:@selector(didCompleteChore:) forControlEvents:UIControlEventTouchUpInside];
        [cell.completeButton addTarget:self action:@selector(remindOfChore:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell.completeButton setTitle:@"Complete" forState:UIControlStateNormal];
        [cell.completeButton removeTarget:self action:@selector(remindOfChore:) forControlEvents:UIControlEventTouchUpInside];
        [cell.completeButton addTarget:self action:@selector(didCompleteChore:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (void)didCompleteChore:(id)sender {
    ChoreTableViewCell *cell = (ChoreTableViewCell *)[[sender superview] superview];
    PFQuery *assigneeQuery = [PFQuery queryWithClassName:kUserIdentifier];
    [assigneeQuery whereKey:kNameKey equalTo:cell.assigneeName.text];
    [assigneeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFQuery *query = [PFQuery queryWithClassName:kChoreIdentifier];
        [query whereKey:kHouseIDKey equalTo:[self.defaults objectForKey:kHouseIDKey]];
        [query whereKey:kAssigneeKey equalTo:objects[0]];
        [query whereKey:kTitleKey equalTo:cell.title.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [PFObject deleteAllInBackground:objects];
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }];
    
    if(![self.list count]) {
        [self setToStateNoResults];
    }
    
    NSIndexPath *ip = [self.tableView indexPathForCell:cell];
    NSArray *ips = @[ip];
    [self.list removeObjectAtIndex:ip.row];
    [self.tableView deleteRowsAtIndexPaths:ips withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)remindOfChore:(id)sender {
    ChoreTableViewCell *cell = (ChoreTableViewCell *)[[sender superview] superview];
    PFQuery *query = [PFQuery queryWithClassName:kUserIdentifier];
    [query whereKey:kNameKey equalTo:cell.assigneeName.text];
    [query whereKey:kHouseIDKey equalTo:[self.defaults objectForKey:kHouseIDKey]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                User *user = [[User alloc] initWithDictionary:(NSDictionary *)object];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                NSDictionary *params = @{@"number": user.phoneNumber,
                                         @"chore": cell.title.text,
                                         @"name": user.name};
                [manager GET:kChoreRemindBaseURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
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
