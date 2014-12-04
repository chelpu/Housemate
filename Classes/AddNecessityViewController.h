//
//  AddNecessityViewController.h
//  Housemate
//
//  Created by Chelsea Pugh on 12/3/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNecessityViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UILabel *neededByLabel;
@property (strong, nonatomic) IBOutlet UILabel *needLabel;
@property (strong, nonatomic) IBOutlet UITextField *needTextField;
@property (strong, nonatomic) IBOutlet UIButton *addNecessityButton;
- (IBAction)addNecessity:(id)sender;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UINavigationItem *cancelButton;

@end
