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

@implementation AddChoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addChore:(id)sender {
    PFObject *chore = [PFObject objectWithClassName:@"Chore"];
    chore[@"dueDate"] = self.dateField.date;
    chore[@"title"] = self.choreName.text;

    // Will grab user from database eventually...
    PFObject *user = [PFObject objectWithClassName:@"User"];
    user[@"name"] = self.assigneeName.text;
    user[@"phoneNumber"] = @"555-123-4567";

    chore[@"assignee"] = user;
    [chore saveInBackground];
}

@end
