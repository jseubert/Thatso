//
//  NewGameTableViewController.h
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface NewGameTableViewController : BaseViewController <DidLoginDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIRefreshControl *refreshControl;

@property(nonatomic) NSArray* fbFriendsArray;
@property(nonatomic) NSString *gameName;
@property(nonatomic) BOOL familyFriendly;

@end
