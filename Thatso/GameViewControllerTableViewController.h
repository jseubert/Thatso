//
//  GameViewControllerTableViewController.h
//  Thatso
//
//  Created by John A Seubert on 9/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface GameViewControllerTableViewController : UIViewController <CommsDelegate,DidAddCommentDelegate, DidGetCommentsDelegate, DidStartNewRound, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    NSDateFormatter *_dateFormatter;
    NSMutableArray* nonUserPlayers;
    NSInteger* winningIndex;
}


@property (strong, nonatomic) IBOutlet UILabel *headerView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIRefreshControl *refreshControl;

@property(nonatomic) PFObject *currentGame;
@property(nonatomic) PFObject *currentRound;
@property(nonatomic) NSMutableArray* comments;
@property(nonatomic) NSString* previousComment;
@property(nonatomic) NSMutableArray* votedForComments;
@end
