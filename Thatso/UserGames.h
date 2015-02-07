//
//  UserGames.h
//  Thatso
//
//  Created by John A Seubert on 8/25/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserGames : NSObject
@property (nonatomic, strong) NSMutableDictionary *games;
@property (nonatomic, strong) NSMutableDictionary *activeGames;
+(UserGames *) instance;
- (void) reset;
- (void) markGame:(NSString*)gameId active:(BOOL)active;
- (void) refreshGameID:(NSString *)gameId;
- (void) refreshGameID:(NSString *)gameId withBlock:(void (^)(Game*))block;
- (void) addGame: (Game *) game;
- (int) gameCount;
- (void) userDidRespondInGame: (Game*) game;

@end

@interface CurrentRounds : NSObject
@property (nonatomic, strong) NSMutableDictionary* currentComments;
+ (CurrentRounds *) instance;
- (void) setComments: (NSArray*)comments forGameId: (NSString *) gameId;
- (void) addComment: (Comment *)comment;
- (void) refreshCommentID:(NSString *)gameId;
- (void) refreshCommentID:(NSString *)gameId withBlock:(void (^)(Comment*))block;
- (void) reset;
@end

@interface PreviousRounds : NSObject
@property (nonatomic, strong) NSMutableDictionary* previousRounds;
+ (PreviousRounds *) instance;
- (void) setPreviousRounds: (NSArray*)rounds forGameId: (NSString *) gameId;
- (void) reset;
@end



