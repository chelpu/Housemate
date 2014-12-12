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

static NSString *kNecessityCellIdentifier = @"NecessityTableViewCell";

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
    
    UINib *nib = [UINib nibWithNibName:kNecessityCellIdentifier bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:kNecessityCellIdentifier];
}

- (void)getNewData {
    BOOL success = [self preQuerySetup];
    if (!success) {
        return;
    }
    PFQuery *query = [PFQuery queryWithClassName:kNecessityIdentifier];
    [query whereKey:kHouseIDKey equalTo:[self.defaults objectForKey:kHouseIDKey]];
    [query orderByAscending:kDateNeededKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if(![objects count]) {
                [self setToStateNoResults];
                [self postQueryTakedown];
            } else {
                [self setToStateNormal];
            }
            
            for (PFObject *object in objects) {
                Necessity *n = [[Necessity alloc] initWithDictionary:(NSDictionary *)object objId:[object objectId]];
                [self.list addObject:n];
            }
            [self postQueryTakedown];
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
    NecessityTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:kNecessityCellIdentifier];
    Necessity *n = [self.list objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = n.name;
    cell.dueDateLabel.text = [NSString stringWithFormat:@"Need by %@",[self.formatter stringFromDate:n.dateNeeded]];
    
    [cell.boughtItButton addTarget:self action:@selector(bought:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)bought:(id)sender {
    NecessityTableViewCell *cell = (NecessityTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    PFQuery *query = [PFQuery queryWithClassName:kNecessityIdentifier];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFQuery *query = [PFQuery queryWithClassName:kNecessityIdentifier];
        [query whereKey:kHouseIDKey equalTo:[self.defaults objectForKey:kHouseIDKey]];
        [query whereKey:kNameKey equalTo:cell.nameLabel.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [PFObject deleteAllInBackground:objects];
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }];
    [self removeFromTableIndexPath:indexPath];
}

@end
