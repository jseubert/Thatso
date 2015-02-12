//
//  GameViewControllerTableViewController.h
//  Thatso
//
//  Created by John A Seubert on 9/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHFComposeBarView.h"
#import "GameHeaderView.h"
#import "CommentTableViewCell.h"
#import "BaseViewController.h"


@interface GameViewControllerTableViewController : BaseViewController <DidAddCommentDelegate, DidGetCommentsDelegate, DidStartNewRound, PHFComposeBarViewDelegate,UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, SINMessageClientDelegate>
{

    NSMutableArray* nonUserPlayers;
    NSInteger* winningIndex;
    BOOL uploadingComment; 
}

@property (strong, nonatomic) IBOutlet GameHeaderView *headerView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet PHFComposeBarView *composeBarView;

@property (strong, nonatomic) id<SINMessageClient> messageClient;

@property(nonatomic) Game *currentGame;
@property(nonatomic) Round *currentRound;
@property(nonatomic) NSMutableArray* comments;
@property(nonatomic) NSString* previousComment;
@property(nonatomic) UITapGestureRecognizer *singleTap;
@property(nonatomic) CommentTableViewCell *userCommentCell;


@property (strong, nonatomic) IBOutlet UIRefreshControl *refreshControl;
@end
