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
#import "User.h" 
#import "ConfigurationUtils.h"

#import "GameManager.h"
#import "RoundManager.h"




@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Reset User defaults - for testing
    //NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
    //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
     
    //Crashlytics
    [Fabric with:@[CrashlyticsKit]];
    [User registerSubclass];
    
    //Setup Parse
    [Parse setApplicationId:[ConfigurationUtils parseApplicationId] clientKey:[ConfigurationUtils parseClientId]];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Initialize Parse's Facebook Utilities singleton. This uses the FacebookAppID we specified in our App bundle's plist.
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    
    LoginScreenViewController *rootViewController = [[LoginScreenViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:rootViewController];
    
    //Configure navigation bar and window appearance here
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [navController.navigationBar  setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                       [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                       [UIFont defaultAppFontWithSize:21.0], NSFontAttributeName, nil]];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self.window addSubview:navController.view];
    self.window.rootViewController = navController;
    
    self.adView = [[ADBannerView alloc] init];
    
    return YES;
}

-(void)registerForNotifications {
    //Parse Push notifications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

//
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    
    AppDelegate *thisObject = self;
    [[GameManager instance] getUsersGamesWithCallback:^(BOOL success) {
        if(success) {
            [thisObject setNumberOfBadges:application];
        }
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self setNumberOfBadges:application];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

-(void) setNumberOfBadges: (UIApplication *)application {
    //The badge is set to the number of games a user is either The Judge of or needs to add a response
    NSUInteger numberOfGamesRequiringAction = [((NSMutableArray *)[[GameManager instance].sortedGames objectForKey:@"Judge"]) count] + [((NSMutableArray *)[[GameManager instance].sortedGames objectForKey:@"CommentNeeded"]) count];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != numberOfGamesRequiringAction) {
        currentInstallation.badge = numberOfGamesRequiringAction;
        [currentInstallation saveEventually];
    }
    application.applicationIconBadgeNumber = numberOfGamesRequiringAction;
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //[[PFFacebookUtils session] close];
    [self setNumberOfBadges:application];
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

//Push Notifications - background
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"didReceiveRemoteNotification:fetchCompletionHandler: %@", userInfo);
    NSString * type = userInfo[@"type"];
    application.applicationIconBadgeNumber = 69;
    if([type isEqualToString:@"newGame"]){
        [[GameManager instance] getUsersGamesWithCallback:^(BOOL success) {
            if(success) {
                [self setNumberOfBadges:application];
                [PFPush handlePush:userInfo];
                completionHandler(UIBackgroundFetchResultNewData);
            } else {
                [PFPush handlePush:userInfo];
                completionHandler(UIBackgroundFetchResultFailed);
            }
        }];
    } else if([type isEqualToString:@"newRound"]) {
        [[GameManager instance] getUsersGamesWithCallback:^(BOOL success) {
            if(success) {
                [self setNumberOfBadges:application];
                [PFPush handlePush:userInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:RoundManagerNewRoundStarted object:nil userInfo:nil];
                completionHandler(UIBackgroundFetchResultNewData);
            } else {
                [PFPush handlePush:userInfo];
                completionHandler(UIBackgroundFetchResultFailed);
            }
        }];
    }
}

- (void)initSinchClientWithUserId:(NSString *)userId {
    if (!_client) {
        NSString *appId = [ConfigurationUtils sinchApplicationId];
        NSString *appSecret = [ConfigurationUtils sinchApplicationSecret];
        NSString *enviornmentHost = [ConfigurationUtils sinchEnvironmentHost];
        _client = [Sinch clientWithApplicationKey:appId
                                applicationSecret:appSecret
                                  environmentHost:enviornmentHost
                                           userId:userId];
        
        
        _client.delegate = self;
        
        [_client setSupportMessaging:YES];
        
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
