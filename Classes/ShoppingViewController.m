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

@implementation ShoppingViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNewData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.noHousematesLabel.text = @"No housemates! Add some.";
    self.noResultsLabel.text = @"You don't need anything!";
    
    [self.refreshControl addTarget:nil
                            action:@selector(getNewData)
                  forControlEvents:UIControlEventValueChanged];
    
    UINib *nib = [UINib nibWithNibName:@"NecessityTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"NecessityTableViewCell"];
}

- (void)getNewData {
    if(![self.defaults objectForKey:kHouseIDKey]) {
        [self setToStateNoHousemates];
        return;
    } 
    
    PFQuery *query = [PFQuery queryWithClassName:@"Necessity"];
    [query whereKey:kHouseIDKey equalTo:[self.defaults objectForKey:kHouseIDKey]];
    
    [self.list removeAllObjects];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if(![objects count]) {
                [self setToStateNoResults];
            } else {
                [self setToStateNormal];
            }
            
            for (PFObject *object in objects) {
                Necessity *n = [[Necessity alloc] initWithDictionary:(NSDictionary *)object objId:[object objectId]];
                [self.list addObject:n];
            }
            
            [self.tableView reloadData];
            
            if (self.refreshControl) {
                [self.refreshControl endRefreshing];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NecessityTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"NecessityTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Necessity *n = [self.list objectAtIndex:indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateFormat];
    
    cell.nameLabel.text = n.name;
    cell.dueDateLabel.text = [NSString stringWithFormat:@"Need by %@",[formatter stringFromDate:n.dateNeeded]];
    
    [cell.boughtItButton addTarget:self action:@selector(bought:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (void)bought:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NecessityTableViewCell *cell = (NecessityTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Necessity"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFQuery *query = [PFQuery queryWithClassName:@"Necessity"];
        [query whereKey:kHouseIDKey equalTo:[defaults objectForKey:kHouseIDKey]];
        [query whereKey:kNameKey equalTo:cell.nameLabel.text];
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
    [self.list removeObjectAtIndex:indexPath.row];
    
    if(![self.list count]) {
        [self setToStateNoResults];
    }
    [self.tableView deleteRowsAtIndexPaths:ips withRowAnimation:UITableViewRowAnimationAutomatic];
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

@end
