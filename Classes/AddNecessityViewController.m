//
//  AddNecessityViewController.m
//  Housemate
//
//  Created by Chelsea Pugh on 12/3/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <Parse/Parse.h>
#import "AddNecessityViewController.h"

@interface AddNecessityViewController ()

@end

@implementation AddNecessityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.addNecessityButton.layer.cornerRadius = 5;
    self.needTextField.delegate = self;
    
    self.neededByLabel.textColor = [UIColor HMcharcoalColor];
    self.needLabel.textColor = [UIColor HMcharcoalColor];
    
    self.navigationBar.barTintColor = [UIColor HMbloodOrangeColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)resetFields {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            textField.text = @"";
        }
    }
}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)addNecessity:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(!(self.needTextField.text && self.needTextField.text.length > 0)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Necessity incomplete!"
                                                        message:@"Please fill out all fields."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    PFObject *necessity = [PFObject objectWithClassName:@"Necessity"];
    
    
    necessity[@"dateNeeded"] = self.datePicker.date;
    necessity[@"name"] = self.needTextField.text;
    necessity[@"houseID"] = [defaults objectForKey:@"houseID"];
    [necessity saveInBackground];
    [self resetFields];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissKeyboard {
    [self.needTextField resignFirstResponder];
}

@end
