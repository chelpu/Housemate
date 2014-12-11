//
//  AddViewController.m
//  Housemate
//
//  Created by Chelsea Pugh on 12/11/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "AddViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "User.h"

@interface AddViewController ()

@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _defaults = [NSUserDefaults standardUserDefaults];
    self.assigneePicker.delegate = self;
    self.assigneePicker.dataSource = self;
    
    self.hud = [[MBProgressHUD alloc] init];
    self.hud.color = [UIColor HMpeachColor];
    [self.view addSubview:self.hud];
    
    self.view.backgroundColor = [UIColor HMlightTanColor];
    
    for(UIView *view in [self.view subviews]) {
        if([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            label.textColor = [UIColor HMcharcoalColor];
        } else if([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            button.backgroundColor = [UIColor HMtangerineColor];
            button.layer.cornerRadius = 5;
        }
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    self.assignees = [[NSMutableArray alloc] init];
    [self getAssignees];
}

- (void)getAssignees {
    PFQuery *query = [PFQuery queryWithClassName:kUserIdentifier];
    [query whereKey:kHouseIDKey equalTo:[self.defaults objectForKey:kHouseIDKey]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                User *u = [[User alloc] initWithDictionary:(NSDictionary *)object];
                if(![u.phoneNumber isEqualToString:[self.defaults objectForKey:@"id"]]) {
                    [self.assignees addObject:u.name];
                }
            }
            [self.assigneePicker reloadAllComponents];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    _defaults = [NSUserDefaults standardUserDefaults];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

# pragma picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _assignees.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _assignees[row];
}

- (void)resetFields {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            textField.text = @"";
        }
    }
}

- (void)dismissKeyboard {
    for(UIView *view in self.view.subviews) {
        if([view isKindOfClass:[UITextField class]]) {
            [view resignFirstResponder];
        }
    }
}

- (void)showIncompleteAlertWithMessage:(NSString *)message andTitle:(NSString *)title{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
