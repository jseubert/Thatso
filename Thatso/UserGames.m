//
//  UserGames.m
//  Thatso
//
//  Created by John A Seubert on 8/25/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "UserGames.h"

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
        self.activeGames =[[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) reset
{
    [self.activeGames removeAllObjects];
    [_games removeAllObjects];
}

- (void) markGame:(NSString*)gameId active:(BOOL)active
{
    [self.activeGames setObject:[NSNumber numberWithBool:active] forKey:gameId];
}

-(BOOL) isGameActive:(NSString*)gameId
{
    if([self.activeGames objectForKey:gameId] == nil)
    {
        [self.activeGames setObject:[NSNumber numberWithBool:YES] forKey:gameId];
    }
    return [[self.activeGames objectForKey:gameId] boolValue];
}

@end

@implementation CurrentRounds
static CurrentRounds *currentRound = nil;
+ (CurrentRounds *) instance
{
    @synchronized (self) {
        if (currentRound == nil) {
            currentRound = [[CurrentRounds alloc] init];
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

-(void) setComments: (NSArray*)comments forGameId: (NSString *) gameId{
    [self.currentComments setObject:comments forKey:gameId];
}

- (void) reset
{
    [self.currentComments removeAllObjects];
}

@end

@implementation PreviousRounds
static PreviousRounds *previousRounds = nil;
+ (PreviousRounds *) instance
{
    @synchronized (self) {
        if (previousRounds == nil) {
            previousRounds = [[PreviousRounds alloc] init];
        }
    }
    return previousRounds;
}
- (id) init
{
    self = [super init];
    if (self) {
        self.previousRounds  = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) setPreviousRounds: (NSArray*)rounds forGameId: (NSString *) gameId
{
    [self.previousRounds setObject:rounds forKey:gameId];
}

- (void) reset
{
    [self.previousRounds removeAllObjects];
}


@end
