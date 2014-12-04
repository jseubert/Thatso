//
//  SelectGameTableViewController.h
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectGameTableViewController : UITableViewController <GetGamesDelegate, SINMessageClientDelegate>
{
    NSDateFormatter *_dateFormatter;
    BOOL initialLoad; 
}
@property (strong, nonatomic) id<SINMessageClient> messageClient;
@property (nonatomic, strong) UIAlertView *alertView;

@end
