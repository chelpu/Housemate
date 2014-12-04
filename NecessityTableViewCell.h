//
//  NecessityTableViewCell.h
//  Housemate
//
//  Created by Chelsea Pugh on 12/3/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NecessityTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (strong, nonatomic) IBOutlet UIButton *boughtItButton;


@end
