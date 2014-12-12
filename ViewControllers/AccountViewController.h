//
//  AccountViewController.h
//  Housemate
//
//  Created by Chelsea Pugh on 12/2/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TSValidatedTextField/TSValidatedTextField.h>


@interface AccountViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *houseImageView;
@property (strong, nonatomic) IBOutlet UIButton *buttonOutlet;
@property (strong, nonatomic) IBOutlet TSValidatedTextField *phoneNumberField;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UILabel *nameHeader;
@property (strong, nonatomic) IBOutlet UILabel *phoneNumberHeader;
@property (strong, nonatomic) IBOutlet UIButton *createHouseButton;
@property (strong, nonatomic) IBOutlet UIButton *joinHouseButton;

@end
