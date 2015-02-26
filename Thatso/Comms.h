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

typedef void (^ImageResultBlock)(UIImage* image);

@protocol DidLoginDelegate <NSObject>
- (void) didlogin:(BOOL)success info: (NSString *) info;
@end

@protocol CreateGameDelegate <NSObject>
- (void) newGameUploadedToServer:(BOOL)success game: (Game*)game info: (NSString *) info;
@end

@protocol GetGamesDelegate <NSObject>
- (void) didGetGamesDelegate:(BOOL)success info: (NSString *) info;
@end

@protocol DidAddCommentDelegate <NSObject>
- (void) didAddComment:(BOOL)success needsRefresh:(BOOL)refresh addedComment:(Comment *)comment info:(NSString *) info;
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

@protocol DidGetCatgegory <NSObject>
- (void) didGetCatgegory:(BOOL)success info: (NSString *) info;
@end

@interface Comms : NSObject
+ (void) login:(id<DidLoginDelegate>)delegate;
+ (void) getAllFacebookFriends:(id<DidLoginDelegate>)delegate;
+ (void) startNewGameWithUsers:(NSMutableArray *)fbFriendsInGame withName:(NSString*)gameName familyFriendly:(BOOL)familyFriendly forDelegate:(id<CreateGameDelegate>)delegate;
+ (void) getUsersGamesforDelegate:(id<GetGamesDelegate>)delegate;
+ (void) addComment:(Comment*)comment toRound:(Round*)round forDelegate:(id<DidAddCommentDelegate>)delegate;
+ (void) getActiveCommentsForGame:(Game*)game inRound:(Round*)round forDelegate:(id<DidGetCommentsDelegate>)delegate;
+ (void) finishRound: (Round*)round inGame: (Game*)game withWinningComment: (Comment*)comment andOtherComments: (NSArray *)otherComments forDelegate:(id<DidStartNewRound>)delegate;
+ (void) getPreviousRoundsInGame: (Game*) game forDelegate:(id<DidGetPreviousRounds>)delegate;
+ (void) getCategories;
+ (void) getuser: (NSString *)fbId;
+ (void) getProfilePictureForUser: (NSString*) fbId withBlock:(void (^)(UIImage*))block;
+(void) getNewCategoryWithSubjects: (NSMutableArray *)players inGame:(NSString *)gameId familyRated:(BOOL)familyRated reloadCategories:(BOOL)reloadCategories withBlock:(void (^)(GenericCategory*category, NSString* userId, BOOL success,  NSString* info))block;

//+(void) getNewCategoryWithSubject: (NSString *)userId inGame:(NSString *)gameId  withBlock:(void (^)(Category*))block;
@end

