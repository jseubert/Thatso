//
//  GameManager.h
//  Thatso
//
//  Created by John  Seubert on 5/20/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//

//Notification names
extern NSString * const GameManagerGameAdded;
extern NSString * const GameManagerGameAddedError;

extern NSString * const GameManagerGamesLoaded;
extern NSString * const GameManagerGamesLoadedError;

//Delegate Callbacks
@protocol GameCreatedDelegate <NSObject>
- (void) newGameCreated:(BOOL)success game: (Game*)game info:(NSString *) info;
@end


@interface GameManager : NSObject

@property (nonatomic, strong) NSMutableArray *games;
@property (nonatomic, strong) NSMutableDictionary *sortedGames;

+ (GameManager *) instance;
- (void) userDidRespondInGame: (Game*) game;
- (void) refreshGameID:(NSString *)gameId;
- (void) refreshGameID:(NSString *)gameId withBlock:(void (^)(Game*))block;
- (void) addGame: (Game *) game;
- (NSInteger) gameCount;
- (void) clearData;


//Network Calls
- (void) startNewGameWithUsers:(NSMutableArray *)fbFriendsInGame withName:(NSString*)gameName familyFriendly:(BOOL)familyFriendly withDelegate:(id<GameCreatedDelegate>) gameCreatedDelegate;
- (void) getUsersGamesWithCallback:(void (^)(BOOL))success;

@end
