//
//  ViewController.m
//  Housemate
//
//  Created by Chelsea Pugh on 9/4/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "ViewController.h"
#import "FBGroup.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"user_groups", @"user_events"]];
    loginView.delegate = self;
    loginView.center = self.view.center;
    [self.view addSubview:loginView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    self.profilePictureView.profileID = user.objectID;
    self.nameLabel.text = user.name;
    
    NSString *userID = user.objectID;
    NSLog(@"Username: %@",userID);

    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/groups?fields=name,id", userID]
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Success! Include your code to handle the results here
                                  NSLog(@"user events: %@", result);
                                  
                                  NSArray *arr = [((FBGraphObject *)result) objectForKey:@"data"];
                                  
                                  FBGroup *group = [[FBGroup alloc] initWithDict:arr[0]];
                                  
                                  [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/members?fields=administrator", group.groupID]
                                                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                            if (!error) {
                                                                // Success! Include your code to handle the results here
                                                                NSLog(@"members: %@", result);
                                                            } else {
                                                                // An error occurred, we need to handle the error
                                                                // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                                                NSLog(@"error %@", error.description);
                                                            }
                                                        }];
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                          }];
    
    
}

// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    self.statusLabel.text = @"You're logged in as";
}

// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    self.profilePictureView.profileID = nil;
    self.nameLabel.text = @"";
    self.statusLabel.text= @"You're not logged in!";
}

// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

@end
