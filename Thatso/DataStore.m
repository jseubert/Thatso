//
//  DataStore.m
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "DataStore.h"

@implementation DataStore
static DataStore *instance = nil;
+ (DataStore *) instance
{
    @synchronized (self) {
        if (instance == nil) {
            instance = [[DataStore alloc] init];
        }
    }
    return instance;
}
- (id) init
{
    self = [super init];
    if (self) {
        _fbFriends = [[NSMutableDictionary alloc] init];
        _user = [[NSDictionary alloc] init];
        _fbFriendsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) reset
{
    [_fbFriends removeAllObjects];
    _user = NULL;
    [_fbFriendsArray removeAllObjects];

}

+ (NSDictionary *) getFriendWithId: (NSString *) fbId
{
    return [[DataStore instance].fbFriends objectForKey:fbId];
}

@end
