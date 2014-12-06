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
    
    _noHousematesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 60.0, 300.0, 45.0)];
    _noHousematesLabel.textColor = [UIColor HMcharcoalColor];
    _noHousematesLabel.text = @"No housemates! Add some.";
    _noHousematesLabel.textAlignment = NSTextAlignmentCenter;
    _noHousematesLabel.font = [UIFont fontWithName:@"Verdana" size:17.0];
    
    _noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 60.0, 300.0, 45.0)];
    _noResultsLabel.textColor = [UIColor HMcharcoalColor];
    _noResultsLabel.text = @"You don't need anything!";
    _noResultsLabel.textAlignment = NSTextAlignmentCenter;
    _noResultsLabel.font = [UIFont fontWithName:@"Verdana" size:17.0];
    
    [self.view addSubview:_noHousematesLabel];
    [self.view addSubview:_noResultsLabel];
    
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
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    UINib *nib = [UINib nibWithNibName:@"NecessityTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"NecessityTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor HMpeachColor];
}

- (void)getNewData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults objectForKey:@"houseID"]) {
        // display no housemates
        [_noResultsLabel setHidden:YES];
        [_noHousematesLabel setHidden:NO];
        return;
    } else {
        [_noHousematesLabel setHidden:YES];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Necessity"];
    [query whereKey:@"houseID" equalTo:[defaults objectForKey:@"houseID"]];
    
    [_necessities removeAllObjects];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if(![objects count]) {
                // display no results
                [_noHousematesLabel setHidden:YES];
                [_noResultsLabel setHidden:NO];
            } else {
                [_noResultsLabel setHidden:YES];
            }
            
            for (PFObject *object in objects) {
                Necessity *n = [[Necessity alloc] initWithDictionary:(NSDictionary *)object objId:[object objectId]];
                [_necessities addObject:n];
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
    
    if(![_necessities count]) {
        [_noHousematesLabel setHidden:YES];
        [_noResultsLabel setHidden:NO];
    }
    [self.tableView deleteRowsAtIndexPaths:ips withRowAnimation:UITableViewRowAnimationAutomatic];
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

@end
