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

@interface ExpenseViewController ()

@end

@implementation ExpenseViewController {
    NSMutableArray *_expenses;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _expenses = [[NSMutableArray alloc] init];
    
    [self getNewData];
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
    PFQuery *query = [PFQuery queryWithClassName:@"Expense"];
    [query whereKey:@"houseID" equalTo:@"houseID"];
    [query includeKey:@"assignee"];
    [query includeKey:@"charger"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu expenses.", (unsigned long)[objects count]);
            NSMutableArray *curExpenses = [[NSMutableArray alloc] init];
            for (PFObject *object in objects) {
                Expense *e = [[Expense alloc] initWithDictionary:(NSDictionary *)object objId:[object objectId]];
                PFObject *user = [object objectForKey:@"assignee"];
                PFObject *charger = [object objectForKey:@"charger"];
                e.payer = [[User alloc] initWithDictionary:(NSDictionary *)user];
                e.charger = [[User alloc] initWithDictionary:(NSDictionary *)charger];
                
                BOOL found = NO;
                for(Expense *existing in _expenses) {
                    if([existing.expenseID isEqualToString:e.expenseID]) {
                        found = YES;
                        NSLog(@" %@, %@", existing.expenseID, e.expenseID);
                    }
                }
                if(!found) {
                    [_expenses insertObject:e atIndex:0];
                }
                
                [curExpenses addObject:e];
            }
            
            NSMutableArray *removed = [[NSMutableArray alloc] initWithArray:_expenses];
            for(Expense *old in _expenses) {
                for(Expense *cur in curExpenses) {
                    if([old.expenseID isEqualToString: cur.expenseID]) {
                        [removed removeObject:old];
                    }
                }
            }
            
            for(Expense *remExpense in removed) {
                [_expenses removeObject:remExpense];
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
    if([e.payer.userID isEqualToString:@"10152791884095087"]) {
        [cell.actionButton addTarget:self action:@selector(payForItem:) forControlEvents:UIControlEventTouchUpInside];
        [cell.actionButton setTitle:@"Pay" forState:UIControlStateNormal];
    } else {
        [cell.actionButton addTarget:self action:@selector(remind:) forControlEvents:UIControlEventTouchUpInside];
        [cell.actionButton setTitle:@"Remind" forState:UIControlStateNormal];

    }
    
    return cell;
}

- (void)remind:(id)sender {
    
}

- (void)payForItem:(id)sender {
    ExpenseTableViewCell *cell = (ExpenseTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Expense *e = [_expenses objectAtIndex:indexPath.row];
    NSString *fullURL = [NSString stringWithFormat:@"https://venmo.com/?txn=pay&amount=%f&note=%@&audience=public&recipients=%@", e.amount, e.title, e.charger.phoneNumber];
    NSLog(@"%@", fullURL);
    NSString *encoded = [fullURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encoded];
    KAWModalWebViewController *kaw = [[KAWModalWebViewController alloc] init];
    kaw.url = url;

    [self presentViewController:kaw animated:YES completion:^{}];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

@end
