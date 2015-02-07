//
//  BaseViewController.h
//  ThatSo
//
//  Created by John A Seubert on 12/11/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StringUtils.h"

@interface BaseViewController : UIViewController <SINMessageClientDelegate, UIAlertViewDelegate>
{
    NSDateFormatter *_dateFormatter;
}

- (void) dismissAlert;
- (void) showAlertWithTitle: (NSString *)title andSummary:(NSString *)summary;
- (void) showLoadingAlert;
- (void) showLoadingAlertWithText: (NSString *)title;

- (void) newRoundNotification: (id<SINMessage>)message inBackground: (BOOL) inBackground;
- (void) newGameNotification: (id<SINMessage>)message inBackground: (BOOL) inBackground;
- (void) newCommentNotification: (id<SINMessage>)message inBackground: (BOOL) inBackground;

@property (strong, nonatomic) id<SINMessageClient> messageClient;

@property (nonatomic, strong) UIAlertView *alertView;
@end