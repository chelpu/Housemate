//
//  CommonTableViewController.m
//  Housemate
//
//  Created by Chelsea Pugh on 12/8/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "CommonTableViewController.h"

@interface CommonTableViewController ()

@end

@implementation CommonTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.list = [[NSMutableArray alloc] init];
    
    _formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateFormat:kDateFormat];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor HMpeachColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.tableView addSubview:self.refreshControl];
    
    _noHousematesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 60.0, 300.0, 45.0)];
    _noHousematesLabel.textColor = [UIColor HMcharcoalColor];
    _noHousematesLabel.textAlignment = NSTextAlignmentCenter;
    _noHousematesLabel.font = [UIFont fontWithName:@"Verdana" size:17.0];
    
    _noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 60.0, 300.0, 45.0)];
    _noResultsLabel.textColor = [UIColor HMcharcoalColor];
    _noResultsLabel.textAlignment = NSTextAlignmentCenter;
    _noResultsLabel.font = [UIFont fontWithName:@"Verdana" size:17.0];
    
    [_noHousematesLabel setHidden:YES];
    [_noResultsLabel setHidden:YES];
    
    [self.view addSubview:_noHousematesLabel];
    [self.view addSubview:_noResultsLabel];
    
    self.navigationBar.barTintColor = [UIColor HMbloodOrangeColorTranslucent];
    self.navigationBar.barStyle = UIBarStyleBlack;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor HMbloodOrangeColor];
    self.tableView.backgroundColor = [UIColor HMlightPeachColor];
    
    self.hud = [[MBProgressHUD alloc] init];
    [self.view addSubview:self.hud];
    self.hud.color = [UIColor HMpeachColor];
}

- (void)viewWillAppear:(BOOL)animated {
    _defaults = [NSUserDefaults standardUserDefaults];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    return cell;
}

- (void)setToStateNoHousemates {
    [_noResultsLabel setHidden:YES];
    [_noHousematesLabel setHidden:NO];
}

- (void)setToStateNoResults {
    [_noResultsLabel setHidden:NO];
    [_noHousematesLabel setHidden:YES];
}

- (void)setToStateNormal {
    [_noResultsLabel setHidden:YES];
    [_noHousematesLabel setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_list count];
}



@end
