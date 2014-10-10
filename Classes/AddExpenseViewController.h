//
//  AddExpenseViewController.h
//  Housemate
//
//  Created by Chelsea Pugh on 10/10/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "ViewController.h"

@interface AddExpenseViewController : ViewController
- (IBAction)addPayment:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *expenseName;
@property (strong, nonatomic) IBOutlet UITextField *assigneeName;
@property (strong, nonatomic) IBOutlet UITextField *amountField;

@end
