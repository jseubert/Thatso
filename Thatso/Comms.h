//
//  Comms.h
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Game.h"
#import "GenericCategory.h"
#import "Round.h"
#import "Comment.h"
#import "CompletedRound.h"

@protocol DidLoginDelegate <NSObject>
- (void) didlogin:(BOOL)success info: (NSString *) info;
@end

@protocol CreateGameDelegate <NSObject>
- (void) newGameUploadedToServer:(BOOL)success info: (NSString *) info;
@end

@protocol GetGamesDelegate <NSObject>
- (void) didGetGamesDelegate:(BOOL)success info: (NSString *) info;
@end

@protocol DidAddCommentDelegate <NSObject>
- (void) didAddComment:(BOOL)success needsRefresh:(BOOL)refresh info: (NSString *) info;
@end

@protocol DidGetCommentsDelegate <NSObject>
- (void) didGetComments:(BOOL)success info: (NSString *) info;
@end

@protocol DidStartNewRound <NSObject>
- (void) didStartNewRound:(BOOL)success info: (NSString *) info previousWinner:(CompletedRound *)winningRound;
@end

@protocol DidGetPreviousRounds <NSObject>
- (void) didGetPreviousRounds:(BOOL)success info: (NSString *) info;
@end



@interface Comms : NSObject
+ (void) login:(id<DidLoginDelegate>)delegate;
+ (void) startNewGameWithUsers: (NSMutableArray *)fbFriendsInGame forDelegate:(id<CreateGameDelegate>)delegate;
+ (void) getUsersGamesforDelegate:(id<GetGamesDelegate>)delegate;
+ (void) addComment:(Comment*)comment forDelegate:(id<DidAddCommentDelegate>)delegate;
+ (void) getActiveCommentsForGame:(Game*)game inRound:(Round*)round forDelegate:(id<DidGetCommentsDelegate>)delegate;
+ (void) finishRound: (Round*)round inGame: (Game*)game withWinningComment: (Comment*)comment andOtherComments: (NSArray *)otherComments forDelegate:(id<DidStartNewRound>)delegate;
+ (void) getPreviousRoundsInGame: (Game*) game forDelegate:(id<DidGetPreviousRounds>)delegate;
+ (void) getCategories;
+ (void) getuser: (NSString *)fbId;
+ (void) getProfilePictureForUser: (PFUser*) user;
@end

