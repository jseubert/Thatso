//
//  GameManager.m
//  Thatso
//
//  Created by John  Seubert on 5/20/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//

#import "GameManager.h"
#import "User.h"

//Notifciation Codes
NSString * const GameManagerGameAdded = @"GameManagerGameAdded";
NSString * const GameManagerGameAddedError = @"GameManagerGameAddedError";

NSString * const GameManagerGamesLoaded = @"GameManagerGamesLoaded";
NSString * const GameManagerGamesLoadedError = @"GameManagerGamesLoadedError";


//Error Codes
NSString * const GameManagerGamesErrorNotEnoughFriends = @"Not enough players added to game.";

@implementation GameManager

static GameManager *sharedInstance = nil;

+ (GameManager *) instance {
    if (sharedInstance == nil) {
        @synchronized (self) {
            sharedInstance = [[GameManager alloc] init];
        }
    }
    
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.games = [[NSMutableArray alloc] init];
        
        self.sortedGames = [[NSMutableDictionary alloc] init];
        [self.sortedGames setObject:[[NSMutableArray alloc] init] forKey:@"Judge"];
        [self.sortedGames setObject:[[NSMutableArray alloc] init] forKey:@"CommentNeeded"];
        [self.sortedGames setObject:[[NSMutableArray alloc] init] forKey:@"Completed"];
    }
    
    return self;
}

- (void) clearData {
    @synchronized (self)
    {
        self.games = [[NSMutableArray alloc] init];
        
        self.sortedGames = [[NSMutableDictionary alloc] init];
        [self.sortedGames setObject:[[NSMutableArray alloc] init] forKey:@"Judge"];
        [self.sortedGames setObject:[[NSMutableArray alloc] init] forKey:@"CommentNeeded"];
        [self.sortedGames setObject:[[NSMutableArray alloc] init] forKey:@"Completed"];
    }
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
    //Remove the game if it needs to be removed from a dictionary
    bool found = false;
    NSMutableArray *gameArray;
    for (NSString *key in [self.sortedGames allKeys])
    {
        gameArray =[self.sortedGames objectForKey:key];
        
        for(Game* existingGame in gameArray)
        {
            if([existingGame.objectId isEqualToString:game.objectId])
            {
                found = true;
                break;
            }
        }
    }
    if(found)
    {
        [gameArray removeObject:game];
    }
    //Add the game to the correct category
    if([game.currentRound.judge isEqualToString: [[User currentUser] objectForKey:UserFacebookID]])
    {
        [[self.sortedGames objectForKey:@"Judge"] addObject:game];
    } else if([game.currentRound.responded containsObject:[[User currentUser] objectForKey:UserFacebookID]])
    {
        [[self.sortedGames objectForKey:@"Completed"] addObject:game];
    } else
    {
        [[self.sortedGames objectForKey:@"CommentNeeded"] addObject:game];
    }
    
    //remove/add the game from the default array
    found = false;
    
    for (Game *existingGame in self.games)
    {
        if([existingGame.objectId isEqualToString:game.objectId])
        {
            found = true;
            break;
        }
    }
    
    if(!found)
    {
        [self.games addObject:game];
    }
    
}

- (void) userDidRespondInGame: (Game*) game
{
    BOOL addGame = false;
    //Move the game in the game manager
    for (NSString *key in [self.sortedGames allKeys])
    {
        NSMutableArray *gameArray =[self.sortedGames objectForKey:key];
        
        for(Game* existingGame in gameArray)
        {
            if([existingGame.objectId isEqualToString:game.objectId])
            {
                if(![existingGame.currentRound.responded containsObject:game.objectId])
                {
                    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:existingGame.currentRound.responded];
                    [newArray addObject:[User currentUser].fbId];
                    existingGame.currentRound.responded = newArray;
                    [gameArray removeObject:existingGame];
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

-(NSInteger) gameCount
{
    return self.games.count;
}

- (void) startNewGameWithUsers:(NSMutableArray *)fbFriendsInGame withName:(NSString*)gameName familyFriendly:(BOOL)familyFriendly withDelegate:(id<GameCreatedDelegate>) gameCreatedDelegate
{    // Add Current User to the Game
    NSMutableArray *allPlayersInGame = [[NSMutableArray alloc] initWithArray:fbFriendsInGame];
    [allPlayersInGame addObject:[User currentUser]];
    //Must Have more than 3 users
    if(allPlayersInGame.count < 3)
    {
        //Return Error
        if(gameCreatedDelegate != nil)
        {
            if([gameCreatedDelegate respondsToSelector:@selector(newGameCreated:game:info:)])
            {
                [gameCreatedDelegate newGameCreated:NO game:nil info:GameManagerGamesErrorNotEnoughFriends];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:GameManagerGameAddedError object:nil userInfo:@{GameManagerGameAddedError: GameManagerGamesErrorNotEnoughFriends}];
        return;
    }
    
    //Create the game
    
    Game *gameObject = [Game object];
    gameObject.rounds = @1;
    gameObject.players = allPlayersInGame;
    gameObject.gameName = gameName;
    gameObject.familyFriendly = familyFriendly;
    
    //Create the first round for this Game
    Round *roundObject = [Round object];
    roundObject.judge = [User currentUser].fbId;
    roundObject.subject = ((User *)[fbFriendsInGame objectAtIndex:0]).fbId;
    roundObject.roundNumber = @1;
    roundObject.responded = [[NSArray alloc] init];
    
    //get new subject, make sure its not the judge
    NSMutableArray *nonJudgePlayers = [[NSMutableArray alloc] init];
    for (User* player in allPlayersInGame)
    {
        if(![player.fbId isEqualToString:roundObject.judge])
        {
            [nonJudgePlayers addObject:player.fbId];
        }
    }
    
    //Get new category
    if([DataStore instance].familyCategories.count == 0 || [DataStore instance].familyCategories.count == 0)
    {
        [Comms getCategories];
    }
    
    GenericCategory *category;
    if(familyFriendly)
    {
        category= [[DataStore instance].familyCategories objectAtIndex:(arc4random() % [DataStore instance].familyCategories.count)];
    }else{
        category= [[DataStore instance].categories objectAtIndex:(arc4random() % [DataStore instance].categories.count)];
    }
    
    roundObject.category = [NSString stringWithFormat:@"%@ %@%@", category.startText, [gameObject playerWithfbId:roundObject.subject].first_name, category.endText];
    
    roundObject.categoryID = category.objectId;
    
    gameObject.currentRound = roundObject;
    
    [gameObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded) {
             [self addGame:gameObject];
             if(gameCreatedDelegate != nil)
             {
                 if([gameCreatedDelegate respondsToSelector:@selector(newGameCreated:game:info:)])
                 {
                     [gameCreatedDelegate newGameCreated:YES game:gameObject info:nil];
                 }
             }
             [[NSNotificationCenter defaultCenter] postNotificationName:GameManagerGameAdded object:nil userInfo:@{GameManagerGameAdded: gameObject}];
             
         } else {
             if(gameCreatedDelegate != nil)
             {
                 if([gameCreatedDelegate respondsToSelector:@selector(newGameCreated:game:info:)])
                 {
                     [gameCreatedDelegate newGameCreated:NO game:nil info:error.description];
                 }
             }
             [[NSNotificationCenter defaultCenter] postNotificationName:GameManagerGameAddedError object:nil userInfo:@{GameManagerGameAddedError: error.description}];
         }
     }];
}

- (void) getUsersGamesWithCallback:(void (^)(BOOL))success
{
    PFQuery *getGames = [PFQuery queryWithClassName:GameClass];
    
    [getGames orderByDescending:UpdatedAt];
    [getGames includeKey:GameCurrentRound];
    [getGames includeKey:GamePlayers];
    
    NSArray *user =[[NSArray alloc] initWithObjects:[User currentUser], nil];
    //find all games that have the current user as a player
    [getGames whereKey:GamePlayers containsAllObjectsInArray:user];
    
    [getGames findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            if(success != nil)
            {
                success(NO);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:GameManagerGamesLoadedError object:nil userInfo:@{GameManagerGamesLoadedError: error.description}];
        } else {
            [self clearData];
            for(int i = 0; i < objects.count; i ++)
            {
                [self addGame:[objects objectAtIndex:i]];
            }
            
            if(success != nil)
            {
                success(YES);
            }
            // Notify that all the current games have been downloaded
            [[NSNotificationCenter defaultCenter] postNotificationName:GameManagerGamesLoaded object:nil];
        }
    }];
}


@end
