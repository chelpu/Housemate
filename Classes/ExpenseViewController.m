//
//  ExpenseViewController.m
//  Housemate
//
//  Created by Chelsea Pugh on 10/7/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "ExpenseViewController.h"
#import "ExpenseTableViewCell.h"
#import <Parse/Parse.h>
#import <KAWebViewController/KAWebViewController.h>
#import "Expense.h"
#import <AFHTTPRequestOperationManager.h>
#import "Secrets.h"

static NSString *kExpenseCellIdentifier = @"ExpenseTableViewCell";

@interface ExpenseViewController ()

@end

@implementation ExpenseViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNewData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.noHousematesLabel.text = @"No housemates! Add some.";
    self.noResultsLabel.text = @"No outstanding expenses!";
    
    UINib *nib = [UINib nibWithNibName:kExpenseCellIdentifier bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:kExpenseCellIdentifier];
}

- (void)getNewData {
    BOOL success = [self preQuerySetup];
    if (!success) {
        return;
    }
    PFQuery *query = [PFQuery queryWithClassName:kExpenseIdentifier];
    [query whereKey:kHouseIDKey equalTo:[self.defaults objectForKey:kHouseIDKey]];
    [query includeKey:kAssigneeKey];
    [query includeKey:kChargerKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if(![objects count]) {
                [self setToStateNoResults];
                return;
            } else {
                [self setToStateNormal];
            }
            for (PFObject *object in objects) {
                Expense *e = [[Expense alloc] initWithDictionary:(NSDictionary *)object objId:[object objectId]];
                PFObject *user = [object objectForKey:kAssigneeKey];
                PFObject *charger = [object objectForKey:kChargerKey];
                e.payer = [[User alloc] initWithDictionary:(NSDictionary *)user];
                e.charger = [[User alloc] initWithDictionary:(NSDictionary *)charger];
                [self.list addObject:e];
            }
            [self postQueryTakedown];
        } else {
            // Log details of the failure
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
    ExpenseTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:kExpenseCellIdentifier];
    Expense *e = [self.list objectAtIndex:indexPath.row];
    
    cell.title.text = e.title;
    cell.assigneeName.text = [NSString stringWithFormat:@"Payer: %@", e.payer.name];
    cell.dueDate.text = [self.formatter stringFromDate:e.dueDate];
    cell.price.text = [NSString stringWithFormat:@"$%.2f", e.amount];
    
    if([e.payer.phoneNumber isEqualToString:[self.defaults objectForKey:kIDKey]]) {
        [cell.actionButton addTarget:self action:@selector(payForItem:) forControlEvents:UIControlEventTouchUpInside];
        [cell.actionButton setTitle:@"Pay" forState:UIControlStateNormal];
    } else {
        [cell.actionButton addTarget:self action:@selector(remind:) forControlEvents:UIControlEventTouchUpInside];
        [cell.actionButton setTitle:@"Remind" forState:UIControlStateNormal];

    }
    
    return cell;
}

- (void)remind:(id)sender {
    ExpenseTableViewCell *cell = (ExpenseTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Expense *e = [self.list objectAtIndex:indexPath.row];
    
    NSString *fullURL = [NSString stringWithFormat:@"https://venmo.com/?txn=pay&amount=%f&note=%@&audience=public&recipients=%@", e.amount, e.title, e.charger.phoneNumber];
    NSString *encodedFull = [fullURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    PFQuery *query = [PFQuery queryWithClassName:kUserIdentifier];
    
    [query whereKey:kNameKey equalTo:e.payer.name];
    [query whereKey:kHouseIDKey equalTo:[self.defaults objectForKey:kHouseIDKey]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                User *user = [[User alloc] initWithDictionary:(NSDictionary *)object];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                Secrets *s = [[Secrets alloc] init];
                NSDictionary *bitlyParams = @{@"access_token": s.bitlyToken,
                                              @"longUrl": encodedFull};
                [manager GET:@"https://api-ssl.bitly.com/v3/shorten" parameters:bitlyParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSDictionary *data = (NSDictionary *)responseObject[@"data"];
                    NSString *shortUrlString = [NSString stringWithString:data[@"url"]];
                    NSString *encoded = [shortUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    NSDictionary *params = @{@"number": user.phoneNumber,
                                             @"expense": cell.title.text,
                                             @"name": user.name,
                                             @"requesterName": e.charger.name,
                                              @"url": encoded};
                    [manager GET:kExpenseRemindBaseURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error: %@", error);
                    }];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Bitly failed");
                }];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)payForItem:(id)sender {
    ExpenseTableViewCell *cell = (ExpenseTableViewCell *)[[sender superview] superview];
    NSIndexPath *ip = [self.tableView indexPathForCell:cell];
    Expense *e = [self.list objectAtIndex:ip.row];
    NSString *fullURL = [NSString stringWithFormat:@"https://venmo.com/?txn=pay&amount=%f&note=%@&audience=public&recipients=%@", e.amount, e.title, e.charger.phoneNumber];
    NSString *encoded = [fullURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encoded];
    KAWModalWebViewController *kaw = [[KAWModalWebViewController alloc] init];
    kaw.url = url;

    [self presentViewController:kaw animated:YES completion:^{
        
        PFQuery *assigneeQuery = [PFQuery queryWithClassName:kUserIdentifier];
        [assigneeQuery whereKey:kNameKey equalTo:e.payer.name];
        [assigneeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            PFQuery *query = [PFQuery queryWithClassName:kExpenseIdentifier];
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
    }];
    [self removeFromTableIndexPath:ip];
}

@end
