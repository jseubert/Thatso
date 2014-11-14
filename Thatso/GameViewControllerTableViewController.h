//
//  GameViewControllerTableViewController.h
//  Thatso
//
//  Created by John A Seubert on 9/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface GameViewControllerTableViewController : UIViewController <CommsDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSDateFormatter *_dateFormatter;
    NSMutableArray* nonUserPlayers;
}


@property (strong, nonatomic) IBOutlet UILabel *headerView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIRefreshControl *refreshControl;

@property(nonatomic) PFObject *currentGame;
@property(nonatomic) PFObject *currentRound;
@property(nonatomic) NSMutableDictionary* comments;
@property(nonatomic) NSMutableDictionary* votedForComments;
@end
