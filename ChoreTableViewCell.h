//
//  ChoreTableViewCell.h
//  Housemate
//
//  Created by Chelsea Pugh on 10/1/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChoreTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *dueDate;
@property (strong, nonatomic) IBOutlet UILabel *assigneeName;

@end
