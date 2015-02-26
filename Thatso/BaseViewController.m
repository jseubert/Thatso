//
//  BaseViewController.m
//  ThatSo
//
//  Created by John A Seubert on 12/11/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "BaseViewController.h"
#import "AppDelegate.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blueAppColor]];
    
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:(CGRectMake(0,
                                                                                        0,
                                                                                        150,
                                                                                        100))];
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setBackgroundColor:[UIColor pinkAppColor]];
    [[self.activityIndicator  layer] setCornerRadius:40.0f];
    [self.activityIndicator setClipsToBounds:YES];
    [[self.activityIndicator  layer] setBorderWidth:2.0f];
    [[self.activityIndicator  layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    UILabel *loading = [[UILabel alloc] initWithFrame:CGRectMake(0, self.activityIndicator.frame.size.height - 30, self.activityIndicator.frame.size.width, 20)];
    [loading setTextColor:[UIColor whiteColor]];
    [loading setFont:[UIFont defaultAppFontWithSize:16.0f]];
    [loading setTextAlignment:NSTextAlignmentCenter];
    [loading setText:@"Loading..."];
    [self.activityIndicator addSubview:loading];
    
    // Create a re-usable NSDateFormatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MMM d, h:mm a"];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.activityIndicator setCenter:[self.view center]];
}

-(void) showAlertWithTitle: (NSString *)title andSummary:(NSString *)summary
{
    [self dismissAlert];
    self.alertView = [[UIAlertView alloc]
                      initWithTitle:title message:summary delegate:self  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    // Display Alert Message
    [self.alertView show];
}

- (void) dismissAlert {
    if (self.alertView && self.alertView.visible) {
        [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

-(void) showLoadingAlert
{
    [self dismissAlert];
    self.alertView = [[UIAlertView alloc]
                      initWithTitle:@"Loading..." message:nil delegate:self  cancelButtonTitle:nil otherButtonTitles:nil];
    
    // Display Alert Message
    [self.alertView show];
}

- (void) showLoadingAlertWithText: (NSString *)title
{
    [self dismissAlert];
    self.alertView = [[UIAlertView alloc]
                      initWithTitle:title message:nil delegate:self  cancelButtonTitle:nil otherButtonTitles:nil];
    
    // Display Alert Message
    [self.alertView show];
}

#pragma mark - SINMessageClientDelegate
/*
- (void)messageClient:(id<SINMessageClient>)messageClient didReceiveIncomingMessage:(id<SINMessage>)message {
    NSLog(@"didReceiveIncomingMessage: %@ %@", message.text, message.headers );
    //If user is inactive, send a notification
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground || [UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
        if([message.text isEqualToString:NewRound])
        {
            [self newRoundNotification:message inBackground:YES];
        }
        else if([message.text isEqualToString:NewComment])
        {
            [self newCommentNotification:message inBackground:YES];
        }
        else if([message.text isEqualToString:NewGame])
        {
            [self newGameNotification:message inBackground:YES];
        }
    } else {
        if([message.text isEqualToString:NewRound])
        {
            [self newRoundNotification:message inBackground:NO];
        }
        else if([message.text isEqualToString:NewComment])
        {
            [self newCommentNotification:message inBackground:NO];
        }
        else if([message.text isEqualToString:NewGame])
        {
            [self newGameNotification:message inBackground:NO];
        }
    }
}

- (void) newRoundNotification: (id<SINMessage>)message inBackground: (BOOL) inBackground
{
    if(inBackground)
    {
        [[UserGames instance] refreshGameID:[message.headers objectForKey:CompletedRoundGameID] withBlock:^(Game * game) {
            NSString *winner = [message.headers objectForKey:CompletedRoundWinningResponseFrom];
            NSString* summary = [NSString stringWithFormat:@"New round starting: %@ won previous.", winner];
            UILocalNotification* notification = [[UILocalNotification alloc] init];
            notification.alertBody = summary;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }];
    } else{
        //Show alert that a new game has started
        NSString *winner = [message.headers objectForKey:CompletedRoundWinningResponseFrom];
        NSString* summary = [NSString stringWithFormat:@"%@ won round %@ with: %@", winner, [message.headers objectForKey:CompletedRoundNumber], [message.headers objectForKey:CompletedRoundWinningResponse]];
        [self showAlertWithTitle:@"New Round Started" andSummary:summary];
        
        [[UserGames instance] refreshGameID:[message.headers objectForKey:CompletedRoundGameID]];
    }
}

- (void) newCommentNotification: (id<SINMessage>)message inBackground: (BOOL) inBackground
{
    if(inBackground)
    {
        [[CurrentRounds instance] refreshCommentID:[message.headers objectForKey:ObjectID]];
    } else{
        [[CurrentRounds instance] refreshCommentID:[message.headers objectForKey:ObjectID]];
    }
    
}

- (void) newGameNotification: (id<SINMessage>)message inBackground: (BOOL) inBackground
{
    if(inBackground)
    {
        [[UserGames instance] refreshGameID:[message.headers objectForKey:ObjectID] withBlock:^(Game * game) {
            //Build notification and send
            NSString* summary = [NSString stringWithFormat:@"You were added to a new game with: %@", [StringUtils buildTextStringForPlayersInGame:game.players fullName:YES]];
            UILocalNotification* notification = [[UILocalNotification alloc] init];
            notification.alertBody = summary;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            
        }];
    } else{
        [[UserGames instance] refreshGameID:[message.headers objectForKey:ObjectID] withBlock:^(Game * game) {
            //Build alert
            NSString *summary = [NSString stringWithFormat:@"First category is \"%@\" with %@", game.currentRound.category,[StringUtils buildTextStringForPlayersInGame:game.players fullName:YES]];
            [self showAlertWithTitle:@"You were added to a new game!" andSummary:summary];
            
        }];
    }
}

- (void)messageSent:(id<SINMessage>)message recipientId:(NSString *)recipientId {
    NSLog(@"messageSent: %@ to: %@", message, recipientId);
}

- (void)message:(id<SINMessage>)message shouldSendPushNotifications:(NSArray *)pushPairs {
    NSLog(@"Recipient not online. \
          Should notify recipient using push (not implemented in this demo app). \
          Please refer to the documentation for a comprehensive description.");
}

- (void)messageDelivered:(id<SINMessageDeliveryInfo>)info {
    NSLog(@"Message to %@ was successfully delivered", info.recipientId);
}

- (void)messageFailed:(id<SINMessage>)message info:(id<SINMessageFailureInfo>)failureInfo {
    NSLog(@"Failed delivering message to %@. Reason: %@", failureInfo.recipientId,
          [failureInfo.error description]);
}*/

@end
