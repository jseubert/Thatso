//
//  AppDelegate.m
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginScreenViewController.h"
#import "FratBarButtonItem.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>



@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Reset User defaults - for testing
    //NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
   // [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
     
    //Crashlytics
    [Fabric with:@[CrashlyticsKit]];
    [User registerSubclass];
    
    //Official Release
    [Parse setApplicationId:@"Riu6PqKr6bUkHTPDqZ7l8Z9YKCCgPD9ginQbW5Bh" clientKey:@"RRLGVt4cvUEEv1o1pU1a4s78O9FdKS7TQk4A3lfv"];
    
    //Internal Testing
   // [Parse setApplicationId:@"pSIZJTLx1s9w6TzozqIBMYeZGjQyk9XvbqyzoztM" clientKey:@"Xceuugh2wcGDs4bQ5mPt87gwJCuNl7tyUulWHWeV"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Initialize Parse's Facebook Utilities singleton. This uses the FacebookAppID we specified in our App bundle's plist.
    [PFFacebookUtils initializeFacebook];
    
    //Parse Push notifications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    LoginScreenViewController *rootViewController = [[LoginScreenViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:rootViewController];
    
    //Need to set navigation bar item color here. Since this is the big one i guess
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [navController.navigationBar  setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                       [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                       [UIFont defaultAppFontWithSize:21.0], NSFontAttributeName, nil]];
    
    [self.window makeKeyAndVisible];
    [self.window addSubview:navController.view];
    self.window.rootViewController = navController;

    
    self.adView = [[ADBannerView alloc] init];
    
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    application.applicationIconBadgeNumber = 0;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[PFFacebookUtils session] close];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation addUniqueObject:@"iOS" forKey:@"channels"];
    [currentInstallation saveInBackground];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)initSinchClientWithUserId:(NSString *)userId {
    if (!_client) {
         NSLog(@"initSinchClientWithUserId: %@", userId);
        
        _client = [Sinch clientWithApplicationKey:@"69afe682-76bb-4f1b-8801-e74e65ec2183"
                                applicationSecret:@"LOMXots80kuiW5ylT5rkcA=="
                                  environmentHost:@"clientapi.sinch.com"
                                           userId:userId];
        
        _client.delegate = self;
        
        [_client setSupportMessaging:YES];
        [_client setSupportPushNotifications:YES];
        
        [_client start];
        [_client startListeningOnActiveConnection];
    }
}

-(void)logoutSinchClient
{
    [_client stopListeningOnActiveConnection];
    [_client terminate];
    _client = nil;
}

#pragma mark - SINClientDelegate

- (void)clientDidStart:(id<SINClient>)client {
    NSLog(@"Sinch client started successfully (version: %@)", [Sinch version]);
}

- (void)clientDidStop:(id<SINClient>)client {
    NSLog(@"Sinch client stopped");
}

- (void)clientDidFail:(id<SINClient>)client error:(NSError *)error {
    NSLog(@"Error: %@", error);
}

- (void)client:(id<SINClient>)client
    logMessage:(NSString *)message
          area:(NSString *)area
      severity:(SINLogSeverity)severity
     timestamp:(NSDate *)timestamp {
    
    if (severity == SINLogSeverityCritical) {
        NSLog(@"%@", message);
    }
}

@end
