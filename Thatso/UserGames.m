//
//  UserGames.m
//  Thatso
//
//  Created by John A Seubert on 8/25/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "UserGames.h"
@implementation Comment
- (id)copyWithZone:(NSZone *)zone
{
    Comment *comentCopy = [[Comment alloc] init];
    comentCopy.objectId = self.objectId;
    comentCopy.toUserID = self.toUserID;
    comentCopy.fromUserID = self.fromUserID;
    comentCopy.roundNumber = self.roundNumber;
    comentCopy.comment = self.comment;
    comentCopy.category = self.category;
    comentCopy.gameId = self.gameId;
    comentCopy.votedForBy = [self.votedForBy copyWithZone:zone];
    return comentCopy;
}
@end

@implementation Round

@end

@implementation Game
- (int) numberOfRounds
{
    return (int)[self.rounds count];
}

- (id)copyWithZone:(NSZone *)zone 
{
    Game *gameCopy = [[Game alloc] init];
    gameCopy.objectId = self.objectId;
    gameCopy.players = [self.players copyWithZone:zone];
   // [gameCopy.rounds addObjectsFromArray:self.rounds];
    return gameCopy;
}

@end

@implementation UserGames
static UserGames *instance = nil;
+ (UserGames *) instance
{
    @synchronized (self) {
        if (instance == nil) {
            instance = [[UserGames alloc] init];
        }
    }
    return instance;
}
- (id) init
{
    self = [super init];
    if (self) {
        _games = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) reset
{
    [_games removeAllObjects];
}

@end

@implementation CurrentRound
static CurrentRound *currentRound = nil;
+ (CurrentRound *) instance
{
    @synchronized (self) {
        if (currentRound == nil) {
            currentRound = [[CurrentRound alloc] init];
        }
    }
    return currentRound;
}
- (id) init
{
    self = [super init];
    if (self) {
        self.currentComments  = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) setComments: (NSMutableDictionary *)comments{

    self.currentComments= [[NSMutableDictionary alloc] init];
    self.currentComments = [comments copyWithZone:nil];
}

- (void) reset
{
    [self.currentComments removeAllObjects];
}

@end
