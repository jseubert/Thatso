//
//  Game.h
//  Thatso
//
//  Created by John  Seubert on 11/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

@class User;
@class Round;

@interface Game : PFObject<PFSubclassing>
+ (NSString *)parseClassName;
@property (retain) NSArray *players;
@property (retain) NSNumber *rounds;
@property (retain) NSString *gameName;
@property BOOL familyFriendly;
@property (retain) Round *currentRound;

- (User *) playerWithObjectId: (NSString *) objectId;

- (User *) playerWithfbId: (NSString *) fbId;

@end
