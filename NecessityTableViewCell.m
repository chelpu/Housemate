//
//  NecessityTableViewCell.m
//  Housemate
//
//  Created by Chelsea Pugh on 12/3/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "NecessityTableViewCell.h"

@implementation NecessityTableViewCell

- (void)awakeFromNib {
    self.nameLabel.textColor = [UIColor HMcharcoalColor];
    self.dueDateLabel.textColor = [UIColor HMcharcoalColor];
    self.boughtItButton.backgroundColor = [UIColor HMtangerineColor];
    self.boughtItButton.layer.cornerRadius = 5;
    self.selectionStyle = UITableViewCellSelectionStyleNone;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
