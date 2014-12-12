//
//  AddViewController.h
//  Housemate
//
//  Created by Chelsea Pugh on 12/11/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface AddViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) UIPickerView *assigneePicker;
@property (strong, nonatomic) NSMutableArray *assignees;
@property (strong, nonatomic) MBProgressHUD *hud;

- (void)resetFields;
- (void)getAssignees;
- (void)showIncompleteAlertWithMessage:(NSString *)message andTitle:(NSString *)title;
@end
