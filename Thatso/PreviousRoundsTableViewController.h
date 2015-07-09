//
//  PreviousRoundsTableViewController.h
//  Thatso
//
//  Created by John A Seubert on 11/15/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//
#import "BaseViewController.h"

@class ScoreHorizontalHeaderScrollView;

@interface PreviousRoundsTableViewController : BaseViewController <DidGetPreviousRounds, UITableViewDataSource, UITableViewDelegate>
{
    BOOL initialLoad; 
}

@property(nonatomic) Game *currentGame;
@property(nonatomic) NSMutableArray* previousRounds;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property(strong, nonatomic) ScoreHorizontalHeaderScrollView *headerView; 
@end
