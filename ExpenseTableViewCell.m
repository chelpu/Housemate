//
//  ExpenseTableViewCell.m
//  Housemate
//
//  Created by Chelsea Pugh on 10/7/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "ExpenseTableViewCell.h"

@implementation ExpenseTableViewCell

- (void)awakeFromNib {
    self.title.textColor = [UIColor HMcharcoalColor];
    self.price.textColor = [UIColor HMcharcoalColor];
    self.assigneeName.textColor = [UIColor HMcharcoalColor];
    self.actionButton.backgroundColor = [UIColor HMtangerineColor];
    self.actionButton.layer.cornerRadius = 5;
    self.selectionStyle = UITableViewCellSelectionStyleNone;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
