//
//  AccountViewController.m
//  Housemate
//
//  Created by Chelsea Pugh on 12/2/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "AccountViewController.h"
#import <Parse/Parse.h>

@interface AccountViewController ()

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.buttonOutlet.layer.cornerRadius = 5;
    self.createHouseButton.layer.cornerRadius = 5;
    self.joinHouseButton.layer.cornerRadius = 5;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _nameHeader.textColor = [UIColor HMcharcoalColor];
    _phoneNumberField.textColor = [UIColor HMcharcoalColor];
    
    _phoneNumberField.regexpPattern = @"\\(\\d{3}\\)-\\d{3}-\\d{4}";
    _phoneNumberField.regexpValidColor = [UIColor HMbloodOrangeColor];
    _phoneNumberField.regexpInvalidColor = [UIColor HMcharcoalColor];
    _phoneNumberField.delegate = self;
    
    if(![defaults objectForKey:@"id"]) {
        [self.buttonOutlet setTitle:@"Create Account" forState:UIControlStateNormal];
        [self.buttonOutlet addTarget:self action:@selector(createAccount:) forControlEvents:UIControlEventTouchUpInside];
        [self.createHouseButton setHidden:YES];
        [self.joinHouseButton setHidden:YES];

    } else if(![defaults objectForKey:@"houseID"]) {
        [self.buttonOutlet setHidden:YES];
        [_phoneNumberField setHidden:YES];
        [_nameField setHidden:YES];
        [_nameHeader setHidden:YES];
        [_phoneNumberHeader setHidden:YES];
        [self.createHouseButton setHidden:NO];
        [self.joinHouseButton setHidden:NO];
        [self.joinHouseButton addTarget:self action:@selector(joinHouse:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_phoneNumberField setHidden:YES];
        [_nameField setHidden:YES];
        [_nameHeader setHidden:YES];
        [_phoneNumberHeader setHidden:YES];
        [self.buttonOutlet setHidden:YES];
        [self.createHouseButton setHidden:YES];
        [_joinHouseButton removeTarget:self action:@selector(joinHouse:) forControlEvents:UIControlEventTouchUpInside];
        [_joinHouseButton setTitle:@"Add to House" forState:UIControlStateNormal];
        [self.joinHouseButton setHidden:NO];

    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *replacementString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    textField.text = [self addPhoneNumberBracesAndHiphensForString:replacementString];
    return NO;
}


// Method to return hippend and braced phone number....
- (NSString *)addPhoneNumberBracesAndHiphensForString:(NSString *)aString {
    
    aString = [aString stringByReplacingOccurrencesOfString:@"(" withString:@""];
    aString = [aString stringByReplacingOccurrencesOfString:@")" withString:@""];
    aString = [aString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSMutableString *hippenedString = [NSMutableString stringWithString:aString];
    //NSLog(@"Removed String %@",hippenedString);
    
    if (hippenedString.length > 0 && hippenedString.length < 4) {
        [hippenedString insertString:@"(" atIndex:0];
    }
    else if (hippenedString.length > 3 && hippenedString.length < 7) {
        [hippenedString insertString:@")-" atIndex:3];
        [hippenedString insertString:@"(" atIndex:0];
    }
    else if (hippenedString.length > 6) {
        [hippenedString insertString:@"-" atIndex:6];
        [hippenedString insertString:@")-" atIndex:3];
        [hippenedString insertString:@"(" atIndex:0];
    }
    
    return hippenedString;
}

- (IBAction)joinHouse:(id)sender {
    NSLog(@"joining house");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter house ID: " message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Join", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert show];
}

- (IBAction)createAccount:(id)sender {
    NSLog(@"Account Created!");
    PFObject *user =[PFObject objectWithClassName:@"User"];
    user[@"name"] = _nameField.text;
    user[@"phoneNumber"] = [NSString stringWithFormat:@"+1%@", _phoneNumberField.text];
    [user saveInBackground];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:_nameField.text forKey:@"name"];
    [defaults setObject:[NSString stringWithFormat:@"+1%@", _phoneNumberField.text] forKey:@"id"];
    
    [defaults synchronize];
    
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Join"])
    {
        UITextField *houseID = [alertView textFieldAtIndex:0];
        
        // get user
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        PFQuery *query = [PFQuery queryWithClassName:@"User"];
        [query whereKey:@"phoneNumber" equalTo:[defaults objectForKey:@"id"]];
        NSLog(@"%@", [defaults objectForKey:@"id"]);
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                PFObject *user = [objects objectAtIndex:0];
                user[@"houseID"] = houseID.text;
                [user saveInBackground];
                [_joinHouseButton removeTarget:self action:@selector(joinHouse:) forControlEvents:UIControlEventTouchUpInside];
                [_joinHouseButton setTitle:@"Add to House" forState:UIControlStateNormal];
                [defaults setObject:houseID.text forKey:@"houseID"];
            }
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
