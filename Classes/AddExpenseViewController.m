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

@interface AddExpenseViewController ()

@end

@implementation AddExpenseViewController {
    NSMutableArray *_assignees;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.view.backgroundColor = [UIColor HMlightPeachColor];
    
    self.addExpenseButton.backgroundColor = [UIColor HMtangerineColor];
    self.addExpenseButton.layer.cornerRadius = 5;
    
    self.navigationBar.barTintColor = [UIColor HMbloodOrangeColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    _assignees = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"houseID" equalTo:[defaults objectForKey:@"houseID"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            // Do something with the found objects
            for (PFObject *object in objects) {
                User *u = [[User alloc] initWithDictionary:(NSDictionary *)object];
                // user defaults
                if(![u.phoneNumber isEqualToString:[defaults objectForKey:@"id"]]) {
                    [_assignees addObject:u.name];
                }
            }
            [self.assigneePicker reloadAllComponents];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addPayment:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(![self.assigneePicker numberOfRowsInComponent:0]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No housemates to pay you!"
                                                        message:@"Please invite your housemates."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    PFObject *expense = [PFObject objectWithClassName:@"Expense"];
    if(!(self.expenseName.text && self.expenseName.text.length > 0) ||
       !(self.amountField.text && ![self.amountField.text isEqualToString:@"$"]) ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Expense incomplete!"
                                                        message:@"Please fill out all fields."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    expense[@"title"] = self.expenseName.text;
    expense[@"amount"] = [NSNumber numberWithFloat:[[self.amountField.text substringFromIndex:1] floatValue]];
    
    NSString *name = [self pickerView:self.assigneePicker titleForRow:[self.assigneePicker selectedRowInComponent:0] forComponent:0];
    
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"name" equalTo:name];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFObject *obj = objects[0];
            expense[@"assignee"] = obj;
            expense[@"houseID"] = [defaults objectForKey:@"houseID"];
            
            // replace with nsuserdefaults
            
            PFQuery *query = [PFQuery queryWithClassName:@"User"];
            [query whereKey:@"phoneNumber" equalTo:[defaults objectForKey:@"id"]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if(!error) {
                    PFObject *obj = objects[0];
                    expense[@"houseID"] = [defaults objectForKey:@"houseID"];
                    expense[@"charger"] = obj;
                    [expense saveInBackground];
                    [self resetFields];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    NSLog(@"Error here");
                }
            }];
            

        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
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

@end
