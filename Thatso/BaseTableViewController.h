//
//  BaseTableViewController.h
//  ThatSo
//
//  Created by John A Seubert on 12/12/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewController : UITableViewController <SINMessageClientDelegate, UIAlertViewDelegate>
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
@property (strong, nonatomic) IBOutlet UIRefreshControl *refreshControl;
@end