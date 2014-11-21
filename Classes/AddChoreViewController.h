//
//  AddChoreViewController.h
//  Housemate
//
//  Created by Chelsea Pugh on 10/17/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

@interface AddChoreViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

- (IBAction)addChore:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *choreName;
@property (strong, nonatomic) IBOutlet UIDatePicker *dateField;
@property (strong, nonatomic) IBOutlet UIPickerView *assigneePicker;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *navigationBarButton;


@end
