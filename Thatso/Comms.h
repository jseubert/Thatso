//
//  Comms.h
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const N_GamesDownloaded;
extern NSString * const N_ProfilePictureLoaded;

@protocol CommsDelegate <NSObject>
@optional
- (void) commsDidLogin:(BOOL)loggedIn;
- (void) newGameUploadedToServer:(BOOL)success info: (NSString *) info;
- (void) commsDidGetUserGames;
@end

@interface Comms : NSObject
+ (void) login:(id<CommsDelegate>)delegate;
+ (void) startNewGameWithUsers: (NSMutableArray *)fbFriendsInGame forDelegate:(id<CommsDelegate>)delegate;
+(void) getUsersGamesforDelegate:(id<CommsDelegate>)delegate;
@end

