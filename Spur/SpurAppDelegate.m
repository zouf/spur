//
//  SpurAppDelegate.m
//  Spur
//
//  Created by Mike Verderese on 1/18/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import "SpurAppDelegate.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>



@implementation SpurAppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    MSClient *client = [MSClient clientWithApplicationURLString:@"https://spurmobile.azure-mobile.net/"
                                             withApplicationKey:@"DakthyzRTUISjPLyzrlEAAYLixozDx13"];
    // Register for remote notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    
    
    
    
    
    return YES;
}



// We are registered, so now store the device token (as a string) on the AppDelegate instance
// taking care to remove the angle brackets first.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:
(NSData *)deviceToken {
    NSCharacterSet *angleBrackets = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    self.deviceToken = [[deviceToken description] stringByTrimmingCharactersInSet:angleBrackets];
}

// Handle any failure to register. In this case we set the deviceToken to an empty
// string to prevent the insert from failing.
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:
(NSError *)error {
    NSLog(@"Failed to register for remote notifications: %@", error);
    self.deviceToken = @"";
}

// Because toast alerts don't work when the app is running, the app handles them.
// This uses the userInfo in the payload to display a UIAlertView.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:
(NSDictionary *)userInfo {
    NSLog(@"%@", userInfo);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification" message:
                          [userInfo objectForKey:@"inAppMessage"] delegate:nil cancelButtonTitle:
                          @"OK" otherButtonTitles:nil, nil];
    [alert show];
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

#pragma mark - deal with username password

-(NSString*)getUserId
{
    NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:@"userid"];
    return user;
}

-(void)setUserId:(NSString*)theID
{
    [[NSUserDefaults standardUserDefaults] setObject:theID forKey:@"userid"];
    
    
}
@end
