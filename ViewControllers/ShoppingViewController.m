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
#import "User.h"

static NSString *kNecessityCellIdentifier = @"NecessityTableViewCell";

@interface ShoppingViewController ()

@end

@implementation ShoppingViewController {
    NSMutableArray *_assignees;
    PFObject *_me;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.noHousematesLabel.text = @"No housemates! Add some.";
    self.noResultsLabel.text = @"You don't need anything!";
    
    UINib *nib = [UINib nibWithNibName:kNecessityCellIdentifier bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:kNecessityCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNewData];
    _assignees = [[NSMutableArray alloc] init];
    if([self.defaults objectForKey:kHouseIDKey]) {
        [self getAssignees];
    }
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"How much did this cost?"
                                                    message:@"If this is a shared expense, enter the amount!"
                                                   delegate:self
                                          cancelButtonTitle:@"Submit"
                                          otherButtonTitles:@"Cancel", @"Not Shared", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    alert.tag = indexPath.row + 1;
    UITextField *amountField = [alert textFieldAtIndex:0];
    amountField.keyboardType = UIKeyboardTypeDecimalPad;
    amountField.text = @"$";
    [alert show];
}

# pragma mark AlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSIndexPath *path = [NSIndexPath indexPathForRow:alertView.tag - 1 inSection:0];
    UITextField *amountField = [alertView textFieldAtIndex:0];
    NecessityTableViewCell *cell = (NecessityTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
    NSLog(@"expense, %@", kTitleKey);
    NSLog(@"amount, %@", kAmountKey);
    if(buttonIndex == 0) {
        for(PFObject *u in _assignees) {
            PFObject *expense = [PFObject objectWithClassName:kExpenseIdentifier];
            expense[kTitleKey] = cell.nameLabel.text;
            expense[kAmountKey] = [NSNumber numberWithFloat:[[amountField.text substringFromIndex:1] floatValue] / (_assignees.count + 1)];
            expense[kAssigneeKey] = u;
            expense[kHouseIDKey] = [self.defaults objectForKey:kHouseIDKey];
            expense[kChargerKey] = _me;
            [expense saveInBackground];
        }
    }
    [self removeFromTableIndexPath:path];

}

- (void)getAssignees {
    PFQuery *query = [PFQuery queryWithClassName:kUserIdentifier];
    [query whereKey:kHouseIDKey equalTo:[self.defaults objectForKey:kHouseIDKey]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if(![objects count]) {
                return;
            }
            for (PFObject *object in objects) {
                User *u = [[User alloc] initWithDictionary:(NSDictionary *)object];
                if(![u.phoneNumber isEqualToString:[self.defaults objectForKey:kIDKey]]) {
                    [_assignees addObject:object];
                } else {
                    _me = object;
                }
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
