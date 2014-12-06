//
//  ExpenseViewController.h
//  Housemate
//
//  Created by Chelsea Pugh on 10/7/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//


@interface ExpenseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UINavigationItem *addButtonItem;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) UILabel *noResultsLabel;
@property (strong, nonatomic) UILabel *noHousematesLabel;

@end
