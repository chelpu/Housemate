//
//  ChoreTableViewCell.m
//  Housemate
//
//  Created by Chelsea Pugh on 10/1/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "ChoreTableViewCell.h"
#import <Parse/Parse.h>
#import "User.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@implementation ChoreTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.title.textColor = [UIColor HMcharcoalColor];
    self.dueDate.textColor = [UIColor HMcharcoalColor];
    self.assigneeName.textColor = [UIColor HMcharcoalColor];
    self.completeButton.backgroundColor = [UIColor HMtangerineColor];
    self.completeButton.layer.cornerRadius = 5;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor HMlightTanColor];
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

#pragma UIGesterRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


@end
