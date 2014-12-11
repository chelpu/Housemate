//
//  CommonTableViewController.h
//  Housemate
//
//  Created by Chelsea Pugh on 12/8/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "MBProgressHUD.h"

@interface CommonTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *list;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UILabel *noHousematesLabel;
@property (strong, nonatomic) UILabel *noResultsLabel;
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) MBProgressHUD *hud;

- (void)setToStateNoHousemates;
- (void)setToStateNoResults;
- (void)setToStateNormal;

@end
