//
//  PreviousRoundsTableViewController.h
//  Thatso
//
//  Created by John A Seubert on 11/15/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviousRoundsTableViewController : UITableViewController <DidGetPreviousRounds, SINMessageClientDelegate>
{
    NSDateFormatter *_dateFormatter;
    BOOL initialLoad; 
}

@property(nonatomic) Game *currentGame;
@property(nonatomic) NSMutableArray* previousRounds;
@property (strong, nonatomic) id<SINMessageClient> messageClient;

@end
