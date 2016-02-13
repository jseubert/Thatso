//
//  PushUtils.h
//  Thatso
//
//  Created by John  Seubert on 2/12/16.
//  Copyright © 2016 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const PushParameterGameId;
extern NSString * const PushParameterPushType;

typedef NS_ENUM(NSInteger, PushType) {
    PushTypeNewGame,
    PushTypeNewRound,
    PushTypePlayerAdded,
    PushTypePlayerLeft,
    PushTypeUnknown
};

@interface PushUtils : NSObject

+ (NSString*) stringForPushType:(PushType) pushType;
+ (PushType) pushTypeForString:(NSString*)pushString;

+ (void) sendNewRoundPushForGame:(Game *)game inRound:(Round*) round;
+ (void) sendNewRoundPushForGame:(Game *)game;
+ (void) sendPlayerLeftPushForGame:(Game *)game;
+ (void) sendPlayerAddedPushForGame:(Game *)game addedPlayers:(NSMutableArray *)fbFriendsAdded;



@end
