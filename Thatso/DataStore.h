//
//  DataStore.h
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataStore : NSObject

@property (nonatomic, strong) NSMutableDictionary *fbFriends;
@property (nonatomic, strong) NSMutableArray *fbFriendsArray;
@property (nonatomic, strong) NSDictionary *user;

+ (DataStore *) instance;
- (void) reset;
+ (NSDictionary *) getFriendWithId: (NSString *) fbId;

@end
