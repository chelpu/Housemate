//
//  ExpenseViewController.h
//  Housemate
//
//  Created by Chelsea Pugh on 10/7/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "ViewController.h"

@interface ExpenseViewController : ViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end