//
//  AddChoreViewController.h
//  Housemate
//
//  Created by Chelsea Pugh on 10/17/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "AddViewController.h"

@interface AddChoreViewController : AddViewController

- (IBAction)addChore:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *choreName;
@property (strong, nonatomic) IBOutlet UIDatePicker *dateField;
@property (strong, nonatomic) IBOutlet UIPickerView *assigneePicker;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *navigationBarButton;
@property (strong, nonatomic) IBOutlet UIButton *addChoreButton;

@end
