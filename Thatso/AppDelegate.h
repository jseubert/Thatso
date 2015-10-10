//
//  AppDelegate.h
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <iAd/iAd.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, SINClientDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<SINClient> client;
@property (strong, nonatomic) ADBannerView *adView;

- (void)initSinchClientWithUserId:(NSString *)userId;
-(void)logoutSinchClient;
-(void)registerForNotifications;

@end
