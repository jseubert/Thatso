//
//  GameViewControllerTableViewController.h
//  Thatso
//
//  Created by John A Seubert on 9/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface GameViewControllerTableViewController : UITableViewController <CommsDelegate, UITextFieldDelegate>
{
    NSDateFormatter *_dateFormatter;
    NSMutableArray* nonUserPlayers;
}

@property(nonatomic) Game *currentGame;
@property(nonatomic) NSMutableDictionary* comments;
@end
