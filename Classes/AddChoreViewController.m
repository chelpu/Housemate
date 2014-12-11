//
//  AddChoreViewController.m
//  Housemate
//
//  Created by Chelsea Pugh on 10/17/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "AddChoreViewController.h"
#import <Parse/Parse.h>
#import "User.h"

@interface AddChoreViewController ()

@end

@implementation AddChoreViewController {
    NSMutableArray *_assignees;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.view.backgroundColor = [UIColor HMlightPeachColor];
    
    self.navigationBar.barTintColor = [UIColor HMbloodOrangeColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    self.addChoreButton.layer.cornerRadius = 5;
    self.addChoreButton.backgroundColor = [UIColor HMtangerineColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    _assignees = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"houseID" equalTo:[defaults objectForKey:@"houseID"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                User *u = [[User alloc] initWithDictionary:(NSDictionary *)object];
                // user defaults
                if(![u.phoneNumber isEqualToString:[defaults objectForKey:@"id"]]) {
                    [_assignees addObject:u.name];
                } else {
                     [_assignees addObject:@"Me"];
                }
            }
            [self.assigneePicker reloadAllComponents];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

- (void)dismissKeyboard {
    [self.choreName resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addChore:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(!(self.choreName.text && self.choreName.text.length > 0)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Chore incomplete!"
                                                        message:@"Please fill out all fields."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    PFObject *chore = [PFObject objectWithClassName:@"Chore"];

    
    chore[@"dueDate"] = self.dateField.date;
    chore[@"title"] = self.choreName.text;
    
    NSString *name = [self pickerView:self.assigneePicker titleForRow:[self.assigneePicker selectedRowInComponent:0] forComponent:0];
    
    if([name isEqualToString:@"Me"]) {
        name = [defaults objectForKey:@"name"];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"name" equalTo:name];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFObject *obj = objects[0];
            chore[@"assignee"] = obj;
            chore[@"houseID"] = [defaults objectForKey:@"houseID"];
            [chore saveInBackground];
            [self resetFields];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetFields {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            textField.text = @"";
        }
    }
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
