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
        self.games = [[NSMutableDictionary alloc] init];
        [self.games setObject:[[NSMutableArray alloc] init] forKey:@"Judge"];
        [self.games setObject:[[NSMutableArray alloc] init] forKey:@"CommentNeeded"];
        [self.games setObject:[[NSMutableArray alloc] init] forKey:@"Completed"];
        self.activeGames =[[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) addGame: (Game*) game
{
    //Remove the game if it needs to be removed
    for (NSString *key in [self.games allKeys])
    {
        NSMutableArray *gameArray =[self.games objectForKey:key];
        
        for(Game* existingGame in gameArray)
        {
            if([existingGame.objectId isEqualToString:game.objectId])
            {
                [gameArray removeObject:existingGame];
            }
        }
    }
  
    //User is the judge of this game
    if([game.currentRound.judge isEqualToString: [[PFUser currentUser] objectForKey:UserFacebookID]])
    {
        [[self.games objectForKey:@"Judge"] addObject:game];
    } else if([game.currentRound.responded containsObject:[[PFUser currentUser] objectForKey:UserFacebookID]])
    {
        [[self.games objectForKey:@"Completed"] addObject:game];
    } else
    {
        [[self.games objectForKey:@"CommentNeeded"] addObject:game];
    }
    
}

-(int) gameCount
{
    int count = 0;
    //Remove the game if it needs to be removed
    for (NSString *key in [self.games allKeys])
    {
        NSMutableArray *gameArray =[self.games objectForKey:key];
        count += gameArray.count;
    }
    
    return count;
}

- (void) reset
{
    [self.games removeAllObjects];
    [self.games setObject:[[NSMutableArray alloc] init] forKey:@"Judge"];
    [self.games setObject:[[NSMutableArray alloc] init] forKey:@"CommentNeeded"];
    [self.games setObject:[[NSMutableArray alloc] init] forKey:@"Completed"];
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
