//
//  Game.m
//  Thatso
//
//  Created by John  Seubert on 11/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "Game.h"
#import <Parse/PFObject+Subclass.h>

@implementation Game
@dynamic players;
@dynamic rounds;
@dynamic currentRound;
@dynamic familyFriendly;
@dynamic gameName;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return GameClass;
}

- (User *) playerWithObjectId: (NSString *) objectId
{
    for (User* user in self.players)
    {
        if([objectId isEqualToString:user.objectId])
        {
            return user;
        }
    }
    return nil;
}

- (User *) playerWithfbId: (NSString *) fbId
{
    for (User* user in self.players)
    {
        if([fbId isEqualToString:user.fbId])
        {
            return user;
        }
    }
    return nil;
}

@end