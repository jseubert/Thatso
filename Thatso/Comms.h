//
//  Comms.h
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@protocol VoteForCommentDelegate <NSObject>
-(void) votedForCommentNotFound;
-(void) errorGettingVoteComment: (NSError *) error;
-(void) userDidNotChangeVoteOnComment;
-(void) userSuccesffullyVotedForComment: (BOOL)voted;
-(void) errorSavingVoteForComment: (NSError *) error;
@end


@interface Comms : NSObject
+ (void) login:(id<CommsDelegate>)delegate;
+ (void) startNewGameWithUsers: (NSMutableArray *)fbFriendsInGame forDelegate:(id<CommsDelegate>)delegate;
+ (void) getUsersGamesforDelegate:(id<CommsDelegate>)delegate;
+ (void) addComment:(NSString *)comment to:(NSString *)toFBId toGameId:(NSString *)gameId inRound:(NSString *)round withCategory:(NSString *)category;
+ (void) getCommentsForGameId:(NSString *)gameId inRound:(NSString *)round forDelegate:(id<CommsDelegate>)delegate;
+ (void) user:(NSString *)userId DidUpvote:(BOOL)voted forComment:(NSString *)commentId;
@end

