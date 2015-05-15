//
//  AddExpenseViewController.m
//  Housemate
//
//  Created by Chelsea Pugh on 10/10/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "AddExpenseViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "Constants.h"

@interface AddExpenseViewController ()

@end

@implementation AddExpenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)addPayment:(id)sender {
    if(![self.assigneePicker numberOfRowsInComponent:0]) {
       [self showIncompleteAlertWithMessage:@"Please invite your housemates."
                                   andTitle:@"No housemates to pay you!"];
        return;
    }
    
    if(!(self.expenseName.text && self.expenseName.text.length > 0) ||
       !(self.amountField.text && ![self.amountField.text isEqualToString:@"$"]) ) {
        [self showIncompleteAlertWithMessage:@"Please fill out all fields." andTitle:@"Expense incomplete!"];
        return;
    }
    PFObject *expense = [PFObject objectWithClassName:kExpenseIdentifier];
    expense[kTitleKey] = self.expenseName.text;
    expense[kAmountKey] = [NSNumber numberWithFloat:[[self.amountField.text substringFromIndex:1] floatValue]];
    
    NSString *name = [self pickerView:self.assigneePicker titleForRow:[self.assigneePicker selectedRowInComponent:0] forComponent:0];
    
    PFQuery *query = [PFQuery queryWithClassName:kUserIdentifier];
    [query whereKey:kNameKey equalTo:name];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if(![objects count]) {
                return;
            }
            
            PFObject *obj = objects[0];
            expense[kAssigneeKey] = obj;
            expense[kHouseIDKey] = [self.defaults objectForKey:kHouseIDKey];
                        
            PFQuery *query = [PFQuery queryWithClassName:kUserIdentifier];
            [query whereKey:kPhoneNumberKey equalTo:[self.defaults objectForKey:kIDKey]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if(!error) {
                    PFObject *obj = objects[0];
                    expense[kChargerKey] = obj;
                    [expense saveInBackground];
                    [self resetFields];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    NSLog(@"Error");
                }
            }];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
