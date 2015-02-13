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


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [User registerSubclass];
    //Beta Testing
    //[Parse setApplicationId:@"Riu6PqKr6bUkHTPDqZ7l8Z9YKCCgPD9ginQbW5Bh" clientKey:@"RRLGVt4cvUEEv1o1pU1a4s78O9FdKS7TQk4A3lfv"];
    
    
    
    //Internal Testing
    [Parse setApplicationId:@"pSIZJTLx1s9w6TzozqIBMYeZGjQyk9XvbqyzoztM" clientKey:@"Xceuugh2wcGDs4bQ5mPt87gwJCuNl7tyUulWHWeV"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Initialize Parse's Facebook Utilities singleton. This uses the FacebookAppID we specified in our App bundle's plist.
    [PFFacebookUtils initializeFacebook];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
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
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    // Handle launching from a notification

    application.applicationIconBadgeNumber = 0;
    
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    application.applicationIconBadgeNumber = 0;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    //return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
    //return [FBAppCall handleOpenURL:url sourceApplication:nil];
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // get previously initiated Sinch client
    id<SINClient> client = _client;
    [client registerPushNotificationData:deviceToken];
}

- (void)initSinchClientWithUserId:(NSString *)userId {
    if (!_client) {
         NSLog(@"initSinchClientWithUserId: %@", userId);
        
        _client = [Sinch clientWithApplicationKey:@"dbc9af86-a638-4c44-a244-02f263c3e4a7"
                                applicationSecret:@"6mBCmMuQVk+XwssEuElGxQ=="
                                  environmentHost:@"sandbox.sinch.com"
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
