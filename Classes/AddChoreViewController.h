//
//  AddChoreViewController.h
//  Housemate
//
//  Created by Chelsea Pugh on 10/17/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "ViewController.h"

@interface AddChoreViewController : ViewController

- (IBAction)addChore:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *choreName;
@property (strong, nonatomic) IBOutlet UITextField *assigneeName;
@property (strong, nonatomic) IBOutlet UITextField *dateField;


@end
