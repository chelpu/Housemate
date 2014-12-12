//
//  AddNecessityViewController.m
//  Housemate
//
//  Created by Chelsea Pugh on 12/3/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <Parse/Parse.h>
#import "AddNecessityViewController.h"
#import "Constants.h"

@interface AddNecessityViewController ()

@end

@implementation AddNecessityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addNecessity:(id)sender {
    if(!(self.needTextField.text && self.needTextField.text.length > 0)) {
        [self showIncompleteAlertWithMessage:@"Please fill out all fields." andTitle:@"Necessity incomplete!"];
        return;
    }
    
    PFObject *necessity = [PFObject objectWithClassName:kNecessityIdentifier];
    
    necessity[kDateNeededKey] = self.datePicker.date;
    necessity[kNameKey] = self.needTextField.text;
    necessity[kHouseIDKey] = [self.defaults objectForKey:kHouseIDKey];
    [necessity saveInBackground];
    [self resetFields];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
