//
//  ChoreTableViewCell.h
//  Housemate
//
//  Created by Chelsea Pugh on 10/1/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChoreTableViewCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *dueDate;
@property (strong, nonatomic) IBOutlet UILabel *assigneeName;
@property (strong, nonatomic) IBOutlet UIView *myContentView;
@property (strong, nonatomic) IBOutlet UIButton *completeButton;

- (void)openCell;

- (IBAction)completeChore:(id)sender;

// Gesture recognizer
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;

@end
