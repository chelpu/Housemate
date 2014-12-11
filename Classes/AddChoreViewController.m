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
#import "MBProgressHUD.h"
#import "Constants.h"

@interface AddChoreViewController ()

@end

@implementation AddChoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.assignees addObject:@"Me"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)addChore:(id)sender {
    if(!(self.choreName.text && self.choreName.text.length > 0)) {
        [self showIncompleteAlertWithMessage:@"Please fill out all fields." andTitle:@"Chore incomplete!"];
        return;
    }

    PFObject *chore = [PFObject objectWithClassName:kChoreIdentifier];
    
    chore[kDueDateKey] = self.dateField.date;
    chore[kTitleKey] = self.choreName.text;
    
    NSString *name = [self pickerView:self.assigneePicker titleForRow:[self.assigneePicker selectedRowInComponent:0] forComponent:0];
    
    if([name isEqualToString:@"Me"]) {
        name = [self.defaults objectForKey:kNameKey];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:kUserIdentifier];
    [query whereKey:kNameKey equalTo:name];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if(![objects count]) {
                return;
            }
            PFObject *obj = objects[0];
            chore[kAssigneeKey] = obj;
            chore[kHouseIDKey] = [self.defaults objectForKey:kHouseIDKey];
            [chore saveInBackground];
            [self resetFields];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
