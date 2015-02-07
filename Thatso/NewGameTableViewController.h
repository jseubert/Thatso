//
//  NewGameTableViewController.h
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"

@interface NewGameTableViewController : BaseTableViewController

@property(nonatomic) NSArray* fbFriendsArray;
@property(nonatomic) NSString *gameName;
@property(nonatomic) BOOL familyFriendly;

@end
