//
//  AddPlayerViewController.h
//  Thatso
//
//  Created by John  Seubert on 2/12/16.
//  Copyright © 2016 John Seubert. All rights reserved.
//

#import "BaseViewController.h"

@interface AddPlayerViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property(nonatomic) NSMutableArray *fbFriendsArray;

@property(nonatomic, strong) Game *currentGame;

@end
