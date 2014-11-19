//
//  ChoreViewController.h
//  Housemate
//
//  Created by Chelsea Pugh on 10/1/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

@interface ChoreViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableSet *cellsCurrentlyEditing;

@end
