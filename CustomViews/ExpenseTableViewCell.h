//
//  ExpenseTableViewCell.h
//  Housemate
//
//  Created by Chelsea Pugh on 10/7/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMTableViewCell.h"

@interface ExpenseTableViewCell : HMTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *assigneeName;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UIButton *actionButton;

@end
