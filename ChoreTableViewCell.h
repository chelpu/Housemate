//
//  ChoreTableViewCell.h
//  Housemate
//
//  Created by Chelsea Pugh on 10/1/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMTableViewCell.h"

@interface ChoreTableViewCell : HMTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *dueDate;
@property (strong, nonatomic) IBOutlet UILabel *assigneeName;
@property (strong, nonatomic) IBOutlet UIButton *completeButton;

@end
