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

static CGFloat const kBounceValue = 20.0f;


@implementation ChoreTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.panRecognizer.delegate = self;
    [self.myContentView addGestureRecognizer:self.panRecognizer];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetConstraintContstantsToZero:NO notifyDelegateDidClose:NO];
}

- (void)panThisCell:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.panStartPoint = [recognizer translationInView:self.myContentView];
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView:self.myContentView];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            BOOL panningLeft = NO;
            if (currentPoint.x < self.panStartPoint.x) {  //1
                panningLeft = YES;
            }
            
            if (self.startingRightLayoutConstraintConstant == 0) { //2
                //The cell was closed and is now opening
                if (!panningLeft) {
                    CGFloat constant = MAX(-deltaX, 0); //3
                    if (constant == 0) { //4
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                    } else { //5
                        self.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    CGFloat constant = MIN(-deltaX, [self buttonTotalWidth]); //6
                    if (constant == [self buttonTotalWidth]) { //7
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    } else { //8
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
            } else {
                //The cell was at least partially open.
                CGFloat adjustment = self.startingRightLayoutConstraintConstant - deltaX; //1
                if (!panningLeft) {
                    CGFloat constant = MAX(adjustment, 0); //2
                    if (constant == 0) { //3
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                    } else { //4
                        self.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    CGFloat constant = MIN(adjustment, [self buttonTotalWidth]); //5
                    if (constant == [self buttonTotalWidth]) { //6
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    } else { //7
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
            }
            
            self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant;
            break;
        }
        case UIGestureRecognizerStateEnded:
            if (self.startingRightLayoutConstraintConstant == 0) { //1
                //Cell was opening
                CGFloat halfOfButtonOne = CGRectGetWidth(self.remindButton.frame) / 2; //2
                if (self.contentViewRightConstraint.constant >= halfOfButtonOne) { //3
                    //Open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Re-close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
            } else {
                //Cell was closing
                CGFloat buttonOnePlusHalfOfButton2 = CGRectGetWidth(self.remindButton.frame) + (CGRectGetWidth(self.completeButton.frame) / 2); //4
                if (self.contentViewRightConstraint.constant >= buttonOnePlusHalfOfButton2) { //5
                    //Re-open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
            }
            break;
        case UIGestureRecognizerStateCancelled:
            if (self.startingRightLayoutConstraintConstant == 0) {
                //Cell was closed - reset everything to 0
                [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
            } else {
                //Cell was open - reset to the open state
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
            }
            break;
        default:
            break;
    }
}

- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    float duration = 0;
    if (animated) {
        duration = 0.1;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:completion];
}

- (CGFloat)buttonTotalWidth {
    return CGRectGetWidth(self.frame) - CGRectGetMinX(self.remindButton.frame);
}

- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing
{
    if (self.startingRightLayoutConstraintConstant == 0 &&
        self.contentViewRightConstraint.constant == 0) {
        return;
    }
    
    self.contentViewRightConstraint.constant = -kBounceValue;
    self.contentViewLeftConstraint.constant = kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.contentViewRightConstraint.constant = -8;
        self.contentViewLeftConstraint.constant = 0;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{
    
    if (self.startingRightLayoutConstraintConstant == [self buttonTotalWidth] &&
        self.contentViewRightConstraint.constant == [self buttonTotalWidth]) {
        return;
    }
    self.contentViewLeftConstraint.constant = -[self buttonTotalWidth] - kBounceValue;
    self.contentViewRightConstraint.constant = [self buttonTotalWidth] + kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.contentViewLeftConstraint.constant = -[self buttonTotalWidth];
        self.contentViewRightConstraint.constant = [self buttonTotalWidth];
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

- (IBAction)remind:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"name" equalTo:self.assigneeName.text];
    [query whereKey:@"houseID" equalTo:@"houseID"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
                User *user = [[User alloc] initWithDictionary:(NSDictionary *)object];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                NSDictionary *params = @{@"number": user.phoneNumber,
                                         @"chore": self.title.text,
                                         @"name": user.name};
                [manager GET:@"http://housem8.ngrok.com/remind" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
                
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (IBAction)completeChore:(id)sender {
    PFQuery *assigneeQuery = [PFQuery queryWithClassName:@"User"];
    [assigneeQuery whereKey:@"name" equalTo:self.assigneeName.text];
    [assigneeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFQuery *query = [PFQuery queryWithClassName:@"Chore"];
        [query whereKey:@"houseID" equalTo:@"houseID"];
        [query whereKey:@"assignee" equalTo:objects[0]];
        [query whereKey:@"title" equalTo:self.title.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [PFObject deleteAllInBackground:objects];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }];
    
}

- (void)openCell {
    [self setConstraintsToShowAllButtons:NO notifyDelegateDidOpen:NO];
}

#pragma UIGesterRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


@end
