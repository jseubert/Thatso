//
//  NewGameTableViewController.h
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "BaseViewController.h"
#import "GameManager.h"

@interface NewGameTableViewController : BaseViewController  <UITableViewDataSource, UITableViewDelegate, GameCreatedDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property(nonatomic) NSArray* fbFriendsArray;
@property(nonatomic) NSString *gameName;
@property(nonatomic) BOOL familyFriendly;

@end
