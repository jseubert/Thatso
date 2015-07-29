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
/*
@protocol CreateGameDelegate <NSObject>
- (void) newGameUploadedToServer:(BOOL)success game: (Game*)game info: (NSString *) info;
@end*/






@protocol DidGetPreviousRounds <NSObject>
- (void) didGetPreviousRounds:(BOOL)success info: (NSString *) info;
@end

@protocol DidGetCatgegory <NSObject>
- (void) didGetCatgegory:(BOOL)success info: (NSString *) info;
@end

@interface Comms : NSObject
+ (void) login:(id<DidLoginDelegate>)delegate;

+ (void) getPreviousRoundsInGame: (Game*) game forDelegate:(id<DidGetPreviousRounds>)delegate;
+ (void) getCategories;

+ (void) getNewCategoryWithSubjects: (NSMutableArray *)players inGame:(NSString *)gameId familyRated:(BOOL)familyRated reloadCategories:(BOOL)reloadCategories withBlock:(void (^)(GenericCategory*category, NSString* userId, BOOL success,  NSString* info))block;

@end

