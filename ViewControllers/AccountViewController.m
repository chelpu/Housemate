//
//  AccountViewController.m
//  Housemate
//
//  Created by Chelsea Pugh on 12/2/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "AccountViewController.h"
#import <Parse/Parse.h>
#import <AFHTTPRequestOperationManager.h>
#import "Constants.h"

@interface AccountViewController ()

@end

@implementation AccountViewController {
    NSUserDefaults *_defaults;
}

- (void)viewWillAppear:(BOOL)animated {
    _defaults = [NSUserDefaults standardUserDefaults];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _defaults = [NSUserDefaults standardUserDefaults];
    self.view.backgroundColor = [UIColor HMlightTanColor];
    for(UIView *view in self.view.subviews) {
        if([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            button.backgroundColor = [UIColor HMtangerineColor];
            button.layer.cornerRadius = 5;
        } else if([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            label.textColor = [UIColor HMcharcoalColor];
        }
    }
    
    _phoneNumberField.textColor = [UIColor HMcharcoalColor];
    _phoneNumberField.regexpPattern = @"\\(\\d{3}\\)-\\d{3}-\\d{4}";
    _phoneNumberField.regexpValidColor = [UIColor HMbloodOrangeColor];
    _phoneNumberField.regexpInvalidColor = [UIColor HMcharcoalColor];
    _phoneNumberField.delegate = self;
    
    [self.houseImageView setHidden:YES];
    
    [self.joinHouseButton addTarget:self action:@selector(joinHouse:) forControlEvents:UIControlEventTouchUpInside];
    [self.createHouseButton addTarget:self action:@selector(createHouse:) forControlEvents:UIControlEventTouchUpInside];
    
    if(![_defaults objectForKey:kIDKey]) {
        [self setToStateNoAccount];
    } else if(![_defaults objectForKey:kHouseIDKey]) {
        [self setToStateLoggedInWithoutHouse];
    } else {
        if(![_defaults objectForKey:@"houseName"]) {
            PFQuery *houseQ = [PFQuery queryWithClassName:@"Group"];
            [houseQ whereKey:@"objectId" equalTo:[_defaults objectForKey:kHouseIDKey]];
            [houseQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSDictionary *house = objects[0];
                NSString *houseName = house[@"houseName"];
                [_defaults setObject:houseName forKey:@"houseName"];
                [_defaults synchronize];
                [self setToStateLoggedInWithHouseName];
            }];
            
        } else {
            [self setToStateLoggedInWithHouseName];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *replacementString = [NSString stringWithFormat:@"%@",textField.text];
    textField.text = [self addPhoneNumberBracesAndHiphensForString:replacementString];
    return YES;
}

- (IBAction)createHouse:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter house name: " message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert show];
}

- (IBAction)addToHouse:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"What's their phone number?" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *avTextField = [alert textFieldAtIndex:0];
    avTextField.delegate = self;
    alert.delegate = self;
    [alert show];
}

- (NSString *)addPhoneNumberBracesAndHiphensForString:(NSString *)aString {
    
    aString = [aString stringByReplacingOccurrencesOfString:@"(" withString:@""];
    aString = [aString stringByReplacingOccurrencesOfString:@")" withString:@""];
    aString = [aString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSMutableString *hippenedString = [NSMutableString stringWithString:aString];
    
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter house ID: " message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Join", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert show];
}

- (IBAction)createAccount:(id)sender {
    PFObject *user =[PFObject objectWithClassName:kUserIdentifier];
    user[kNameKey] = _nameField.text;
    user[kPhoneNumberKey] = [NSString stringWithFormat:@"+1%@", _phoneNumberField.text];
    [user saveInBackground];
    
    [_defaults setObject:_nameField.text forKey:kNameKey];
    [_defaults setObject:[NSString stringWithFormat:@"+1%@", _phoneNumberField.text] forKey:kIDKey];
    [_defaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];

    if([title isEqualToString:@"Join"]) {
        UITextField *houseID = [alertView textFieldAtIndex:0];
        PFQuery *houseQ = [PFQuery queryWithClassName:@"Group"];
        [houseQ whereKey:@"objectId" equalTo:houseID.text];
        [houseQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(![objects count] || error) {
                return;
            }
            PFObject *house = objects[0];
            NSString *houseName = house[@"houseName"];
            [self addToHouseWithName:houseName andGroup:house];
        }];
        
    } else if([title isEqualToString:@"Send"]) {
        UITextField *phoneNumberField = [alertView textFieldAtIndex:0];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *params = @{@"number": phoneNumberField.text,
                                 @"house_id": [_defaults objectForKey:kHouseIDKey],
                                 @"name": [_defaults objectForKey:@"name"]};
        
        [manager GET:@"http://housem8.ngrok.com/invite" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    } else if([title isEqualToString:@"Create"]) {
        UITextField *houseNameField = [alertView textFieldAtIndex:0];
        PFObject *group = [PFObject objectWithClassName:@"Group"];
        group[@"houseName"] = houseNameField.text;
        [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error) {
                [self addToHouseWithName:houseNameField.text andGroup:group];
            }
        }];
    }
}

- (void)addToHouseWithName:(NSString *)houseName andGroup:(PFObject *)group {
    PFQuery *query = [PFQuery queryWithClassName:kUserIdentifier];
    [query whereKey:kPhoneNumberKey equalTo:[_defaults objectForKey:kIDKey]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFObject *user = [objects objectAtIndex:0];
            user[kHouseIDKey] = [group objectId];
            [user saveInBackground];
            
            [_defaults setObject:houseName forKey:@"houseName"];
            [_defaults setObject:[group objectId] forKey:kHouseIDKey];
            [_defaults synchronize];
            
            [self setToStateLoggedInWithHouseName];
        }
    }];
}

- (void)setToStateNoAccount {
    [_buttonOutlet setTitle:@"Create Account" forState:UIControlStateNormal];
    [_buttonOutlet addTarget:self action:@selector(createAccount:)
                forControlEvents:UIControlEventTouchUpInside];
    [_createHouseButton setHidden:YES];
    [_joinHouseButton setHidden:YES];
    [_houseImageView setHidden:YES];
}

- (void)setToStateLoggedInWithoutHouse {
    [self setToHasAccountWithLabel:_nameHeader];
    [_phoneNumberHeader setHidden:YES];
    [_houseImageView setHidden:YES];
}

- (void)setToStateLoggedInWithHouseName{
    [self setToHasAccountWithLabel:_phoneNumberHeader];
    [_nameHeader setHidden:YES];
    [_phoneNumberHeader setHidden:NO];
    [_houseImageView setHidden:NO];
    [_createHouseButton setTitle:[NSString stringWithFormat:@"Add to %@", [_defaults objectForKey:@"houseName"]]
                        forState:UIControlStateNormal];
    [_joinHouseButton setTitle:@"Switch Houses" forState:UIControlStateNormal];
    [_createHouseButton removeTarget:self action:@selector(createHouse:)
                    forControlEvents:UIControlEventTouchUpInside];
    [_createHouseButton addTarget:self action:@selector(addToHouse:)
                 forControlEvents:UIControlEventTouchUpInside];
}

- (void)setToHasAccountWithLabel:(UILabel *)label {
    label.text = [NSString stringWithFormat:@"Welcome, %@", [_defaults objectForKey:kNameKey]];
    [_buttonOutlet setHidden:YES];
    [_createHouseButton setHidden:NO];
    [_joinHouseButton setHidden:NO];
    [_phoneNumberField setHidden:YES];
    [_nameField setHidden:YES];
}

@end
