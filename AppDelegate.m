//
//  AppDelegate.m
//
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "Secrets.h"
#import "UIColor+HMColor.h"
#import "MBProgressHUD.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UITabBar appearance] setTintColor:[UIColor HMbloodOrangeColor]];
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    [[MBProgressHUD appearance] setColor:[UIColor HMpeachColor]];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor HMbloodOrangeColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"Verdana" size:20.0]}];
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearance] setStyle:UIBarButtonItemStylePlain];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"Verdana" size:14.0]} forState:UIControlStateNormal];
    
    Secrets *secrets = [[Secrets alloc] init];
    [Parse setApplicationId:secrets.parseID
                  clientKey:secrets.parseKey];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(![defaults objectForKey:@"id"]) {
        [self showAccountViewController:YES];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)showAccountViewController:(BOOL)animated {
    // Get login screen from storyboard and present it
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    // "loginView" is the Storyboard Id for the Login ViewController
    UIViewController *viewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AccountViewController"];
    [self.window makeKeyAndVisible];
    [self.window.rootViewController presentViewController:viewController
                                                 animated:animated
                                               completion:nil];
}

@end
