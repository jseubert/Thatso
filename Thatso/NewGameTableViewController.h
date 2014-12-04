//
//  NewGameTableViewController.h
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewGameTableViewController : UITableViewController <SINMessageClientDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) id<SINMessageClient> messageClient;
@property(nonatomic) NSArray* fbFriendsArray;
@property (nonatomic, strong) UIAlertView *alertView;

@end
