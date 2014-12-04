//
//  ShoppingViewController.h
//  Housemate
//
//  Created by Chelsea Pugh on 12/3/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShoppingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UINavigationItem *addButtonItem;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end
