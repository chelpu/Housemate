//
//  AddExpenseViewController.h
//  Housemate
//
//  Created by Chelsea Pugh on 10/10/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "AddViewController.h"

@interface AddExpenseViewController : AddViewController
- (IBAction)addPayment:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *expenseName;
@property (strong, nonatomic) IBOutlet UITextField *amountField;
@property (strong, nonatomic) IBOutlet UIPickerView *assigneePicker;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButtonItem;
@property (strong, nonatomic) IBOutlet UIButton *addExpenseButton;

@end
