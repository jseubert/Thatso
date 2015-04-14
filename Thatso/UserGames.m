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

-(void) refreshGameID:(NSString *)gameId
{
    PFQuery *getGame = [PFQuery queryWithClassName:GameClass];
    [getGame includeKey:GameCurrentRound];
    [getGame includeKey:GamePlayers];
    [getGame getObjectInBackgroundWithId:gameId block:^(PFObject *object, NSError *error) {
        Game* game = (Game*)object;
        //Re-add the game
        [self addGame:game];
        
    }];
}

- (void) refreshGameID:(NSString *)gameId withBlock:(void (^)(Game*))block{
    PFQuery *getGame = [PFQuery queryWithClassName:GameClass];
    [getGame includeKey:GameCurrentRound];
    [getGame includeKey:GamePlayers];
    [getGame getObjectInBackgroundWithId:gameId block:^(PFObject *object, NSError *error) {
        Game* game = (Game*)object;
        //Re-add the game
        [self addGame:game];
        block(game);
    }];
}

-(void) addGame: (Game*) game
{
    //Remove the game if it needs to be removed
  //  Game *newgame = [game copy];
    bool found = false;
    NSMutableArray *gameArray;
    for (NSString *key in [self.games allKeys])
    {
        gameArray =[self.games objectForKey:key];
        
        for(Game* existingGame in gameArray)
        {
            if([existingGame.objectId isEqualToString:game.objectId])
            {
                found = true;
                //[gameArray removeObject:existingGame];

                break;
            }
        }
    }
    if(found)
    {
        [gameArray removeObject:game];
    }
    NSLog(@"%@", game.currentRound.judge);
    //User is the judge of this game
    if([game.currentRound.judge isEqualToString: [[User currentUser] objectForKey:UserFacebookID]])
    {
        [[self.games objectForKey:@"Judge"] addObject:game];
    } else if([game.currentRound.responded containsObject:[[User currentUser] objectForKey:UserFacebookID]])
    {
        [[self.games objectForKey:@"Completed"] addObject:game];
    } else
    {
        [[self.games objectForKey:@"CommentNeeded"] addObject:game];
    }
    
}

- (void) userDidRespondInGame: (Game*) game
{
    BOOL addGame = false;
    //Move the game to
    for (NSString *key in [self.games allKeys])
    {
        NSMutableArray *gameArray =[self.games objectForKey:key];
        
        for(Game* existingGame in gameArray)
        {
            if([existingGame.objectId isEqualToString:game.objectId])
            {
                if(![existingGame.currentRound.responded containsObject:game.objectId])
                {
                    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:existingGame.currentRound.responded];
                    [newArray addObject:[User currentUser].fbId];
                    existingGame.currentRound.responded = newArray;
                    addGame = true;
                    
                    break;
                }
            }
        }
    }
    if(addGame)
    {
        [self addGame:game];
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

-(void) addComment: (Comment *)comment
{

    NSMutableArray *comments =[self.currentComments objectForKey: comment.gameID];
    for(Comment* existingComment in comments)
    {
        if([comment.objectId isEqualToString:existingComment.objectId])
        {
            [comments removeObject:existingComment];
            break;
        }
    }
    [comments addObject:comment];
}

-(void) refreshCommentID:(NSString *)commentId
{
    PFQuery *getComment = [PFQuery queryWithClassName:CommentClass];
    [getComment includeKey:CommentFrom];
    [getComment getObjectInBackgroundWithId:commentId block:^(PFObject *object, NSError *error) {
        Comment* comment = (Comment*)object;
        //Re-add the game
        [self addComment: comment];
        
    }];
}

- (void) refreshCommentID:(NSString *)commentId withBlock:(void (^)(Comment*))block{
    PFQuery *getComment = [PFQuery queryWithClassName:CommentClass];
    [getComment includeKey:CommentFrom];
    [getComment getObjectInBackgroundWithId:commentId block:^(PFObject *object, NSError *error) {
        Comment* comment = (Comment*)object;
        //Re-add the game
        [self addComment: comment];
        block(comment);
    }];
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
