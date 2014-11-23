//
//  Comms.h
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@protocol CommsDelegate <NSObject>
@optional
- (void) commsDidLogin:(BOOL)loggedIn;
- (void) newGameUploadedToServer:(BOOL)success info: (NSString *) info;
- (void) commsDidGetUserGames;
- (void) commsDidGetComments: (NSMutableDictionary *) comments;
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
- (void) didStartNewRound:(BOOL)success info: (NSString *) info previousWinner:(PFObject *)winningRound;
@end

@protocol DidGetPreviousRounds <NSObject>
- (void) didGetPreviousRounds:(BOOL)success info: (NSString *) info;
@end



@interface Comms : NSObject
+ (void) login:(id<CommsDelegate>)delegate;
+ (void) startNewGameWithUsers: (NSMutableArray *)fbFriendsInGame forDelegate:(id<CreateGameDelegate>)delegate;
+ (void) getUsersGamesforDelegate:(id<GetGamesDelegate>)delegate;
+ (void) addComment:(PFObject*)comment forDelegate:(id<DidAddCommentDelegate>)delegate;
+ (void) getActiveCommentsForGame:(PFObject*)game inRound:(PFObject*)round forDelegate:(id<DidGetCommentsDelegate>)delegate;
+ (void) finishRound: (PFObject *)round inGame: (PFObject *)game withWinningComment: (PFObject *)comment andOtherComments: (NSArray *)otherComments forDelegate:(id<DidStartNewRound>)delegate;
+ (void) getPreviousRoundsInGame: (PFObject * ) game forDelegate:(id<DidGetPreviousRounds>)delegate;
@end

