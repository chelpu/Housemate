//
//  HMTableViewCell.m
//  Housemate
//
//  Created by Chelsea Pugh on 12/12/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "HMTableViewCell.h"

@implementation HMTableViewCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor HMlightTanColor];
    for(UIView *view in self.contentView.subviews) {
        if([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            button.backgroundColor = [UIColor HMtangerineColor];
            button.layer.cornerRadius = 5;
        } else if([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            label.textColor = [UIColor HMcharcoalColor];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
