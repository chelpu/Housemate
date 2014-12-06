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

@interface ExpenseViewController ()

@end

@implementation ExpenseViewController {
    NSMutableArray *_expenses;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNewData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _noHousematesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 60.0, 300.0, 45.0)];
    _noHousematesLabel.textColor = [UIColor HMcharcoalColor];
    _noHousematesLabel.text = @"No housemates! Add some.";
    _noHousematesLabel.textAlignment = NSTextAlignmentCenter;
    _noHousematesLabel.font = [UIFont fontWithName:@"Verdana" size:17.0];
    
    _noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 60.0, 300.0, 45.0)];
    _noResultsLabel.textColor = [UIColor HMcharcoalColor];
    _noResultsLabel.text = @"No outstanding expenses!";
    _noResultsLabel.textAlignment = NSTextAlignmentCenter;
    _noResultsLabel.font = [UIFont fontWithName:@"Verdana" size:17.0];
    
    [self.view addSubview:_noHousematesLabel];
    [self.view addSubview:_noResultsLabel];
    
    _expenses = [[NSMutableArray alloc] init];
    
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
    
    UINib *nib = [UINib nibWithNibName:@"ExpenseTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ExpenseTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor HMpeachColor];
}

- (void)getNewData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults objectForKey:@"houseID"]) {
        [_noResultsLabel setHidden:YES];
        [_noHousematesLabel setHidden:NO];
        return;
    } else {
        [_noHousematesLabel setHidden:YES];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Expense"];
    [query whereKey:@"houseID" equalTo:[defaults objectForKey:@"houseID"]];
    [query includeKey:@"assignee"];
    [query includeKey:@"charger"];
    
    [_expenses removeAllObjects];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if(![objects count]) {
                [_noResultsLabel setHidden:NO];
                return;
            } else {
                [_noResultsLabel setHidden:YES];
            }
            for (PFObject *object in objects) {
                Expense *e = [[Expense alloc] initWithDictionary:(NSDictionary *)object objId:[object objectId]];
                PFObject *user = [object objectForKey:@"assignee"];
                PFObject *charger = [object objectForKey:@"charger"];
                e.payer = [[User alloc] initWithDictionary:(NSDictionary *)user];
                e.charger = [[User alloc] initWithDictionary:(NSDictionary *)charger];
                [_expenses addObject:e];
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
    return [_expenses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ExpenseTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"ExpenseTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Expense *e = [_expenses objectAtIndex:indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    cell.title.text = e.title;
    cell.assigneeName.text = e.payer.name;
    cell.dueDate.text = [formatter stringFromDate:e.dueDate];
    cell.price.text = [NSString stringWithFormat:@"$%.2f", e.amount];
    
    // replace with id from user defaults
    if([e.payer.phoneNumber isEqualToString:[defaults objectForKey:@"id"]]) {
        [cell.actionButton addTarget:self action:@selector(payForItem:) forControlEvents:UIControlEventTouchUpInside];
        [cell.actionButton setTitle:@"Pay" forState:UIControlStateNormal];
    } else {
        [cell.actionButton addTarget:self action:@selector(remind:) forControlEvents:UIControlEventTouchUpInside];
        [cell.actionButton setTitle:@"Remind" forState:UIControlStateNormal];

    }
    
    return cell;
}

- (void)remind:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    ExpenseTableViewCell *cell = (ExpenseTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Expense *e = [_expenses objectAtIndex:indexPath.row];
    
    NSString *fullURL = [NSString stringWithFormat:@"https://venmo.com/?txn=pay&amount=%f&note=%@&audience=public&recipients=%@", e.amount, e.title, e.charger.phoneNumber];
    NSString *encodedFull = [fullURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"name" equalTo:cell.assigneeName.text];
    [query whereKey:@"houseID" equalTo:[defaults objectForKey:@"houseID"]];
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
                    [manager GET:@"http://housem8.ngrok.com/expenseRemind" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    ExpenseTableViewCell *cell = (ExpenseTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Expense *e = [_expenses objectAtIndex:indexPath.row];
    NSString *fullURL = [NSString stringWithFormat:@"https://venmo.com/?txn=pay&amount=%f&note=%@&audience=public&recipients=%@", e.amount, e.title, e.charger.phoneNumber];
    NSLog(@"%@", fullURL);
    NSString *encoded = [fullURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encoded];
    KAWModalWebViewController *kaw = [[KAWModalWebViewController alloc] init];
    kaw.url = url;

    [self presentViewController:kaw animated:YES completion:^{
        
        PFQuery *assigneeQuery = [PFQuery queryWithClassName:@"User"];
        [assigneeQuery whereKey:@"name" equalTo:cell.assigneeName.text];
        [assigneeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            PFQuery *query = [PFQuery queryWithClassName:@"Expense"];
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
        
        NSArray *ips = @[indexPath];
        [_expenses removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:ips withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

@end
