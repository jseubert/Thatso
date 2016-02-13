//
//  PushUtils.m
//  Thatso
//
//  Created by John  Seubert on 2/12/16.
//  Copyright © 2016 John Seubert. All rights reserved.
//

#import "PushUtils.h"
#import "User.h"

NSString * const PushParameterGameId = @"gameId";
NSString * const PushParameterPushType = @"pushType";

@implementation PushUtils

+ (NSString*) stringForPushType:(PushType) pushType {
    switch (pushType) {
        case PushTypeNewGame:
            return @"newGame";
            break;
        case PushTypeNewRound:
            return @"newRound";
            break;
        case PushTypePlayerAdded:
            return @"playerAdded";
            break;
        case PushTypePlayerLeft:
            return @"playerLeft";
            break;
        default:
            return @"unknown";
            break;
    }
}

+ (PushType) pushTypeForString:(NSString*)pushString {
    if([pushString isEqualToString:@"newGame"]) {
        return PushTypeNewGame;
    } else if([pushString isEqualToString:@"newRound"]) {
        return PushTypeNewRound;
    } else if([pushString isEqualToString:@"playerAdded"]) {
        return PushTypePlayerAdded;
    } else if([pushString isEqualToString:@"playerLeft"]) {
        return PushTypePlayerLeft;
    } else {
        return PushTypeUnknown;
    }
}

+ (void) sendNewRoundPushForGame:(Game *)game inRound:(Round*) round
{
    NSMutableArray *nonUserPlayersPushIDs = [[NSMutableArray alloc] init];
    for(User * user in game.players)
    {
        if(![user.objectId isEqualToString:[User currentUser].objectId])
        {
            [nonUserPlayersPushIDs addObject:[NSString stringWithFormat:@"c%@",user.fbId]];
        }
    }
    
    PFPush *push = [[PFPush alloc] init];
    NSDictionary *data = @{
                           @"alert" : [NSString stringWithFormat:@"New Round Starting in %@: \"%@\"", game.gameName, round.category],
                           @"sound" : @"woop.caf",
                           PushParameterPushType : [PushUtils stringForPushType:PushTypeNewRound],
                           PushParameterGameId : game.objectId,
                           @"content-available" : @1
                           };
    [push setChannels:nonUserPlayersPushIDs];
    [push setData:data];
    [push sendPushInBackground];
}

+ (void) sendNewRoundPushForGame:(Game *)game
{
    NSMutableArray *nonUserPlayersPushIDs = [[NSMutableArray alloc] init];
    for(User * user in game.players)
    {
        if(![user.objectId isEqualToString:[User currentUser].objectId])
        {
            [nonUserPlayersPushIDs addObject:[NSString stringWithFormat:@"c%@",user.fbId]];
        }
    }
    
    PFPush *push = [[PFPush alloc] init];
    NSDictionary *data = @{
                           @"alert" : [NSString stringWithFormat:@"%@ has added you to a game: %@", [User currentUser].first_name, game.gameName],
                           @"sound" : @"woop.caf",
                           PushParameterPushType : [PushUtils stringForPushType:PushTypeNewGame],
                           @"content-available" : @1
                           };
    
    [push setChannels:nonUserPlayersPushIDs];
    [push setData:data];
    [push sendPushInBackground];
}

+ (void) sendPlayerLeftPushForGame:(Game *)game
{
    NSMutableArray *nonUserPlayersPushIDs = [[NSMutableArray alloc] init];
    for(User * user in game.players)
    {
        if(![user.objectId isEqualToString:[User currentUser].objectId])
        {
            [nonUserPlayersPushIDs addObject:[NSString stringWithFormat:@"c%@",user.fbId]];
        }
    }
    
    PFPush *push = [[PFPush alloc] init];
    NSDictionary *data = @{
                           @"alert" : [NSString stringWithFormat:@"%@ has left the game: %@", [User currentUser].first_name, game.gameName],
                           @"sound" : @"woop.caf",
                           PushParameterPushType : [PushUtils stringForPushType:PushTypePlayerLeft],
                           PushParameterGameId : game.objectId,
                           @"content-available" : @1
                           };
    
    [push setChannels:nonUserPlayersPushIDs];
    [push setData:data];
    [push sendPushInBackground];
}

+ (void) sendPlayerAddedPushForGame:(Game *)game addedPlayers:(NSMutableArray *)fbFriendsAdded
{
    NSMutableArray *nonUserPlayersPushIDs = [[NSMutableArray alloc] init];
    for(User * user in game.players)
    {
        if(![user.objectId isEqualToString:[User currentUser].objectId])
        {
            [nonUserPlayersPushIDs addObject:[NSString stringWithFormat:@"c%@",user.fbId]];
        }
    }
    NSString *friendsAddedString = @"";
    if(fbFriendsAdded.count == 1) {
        User * user = [fbFriendsAdded firstObject];
        friendsAddedString = user.first_name;
    } else if(fbFriendsAdded.count == 2) {
        User * user = [fbFriendsAdded firstObject];
        User * user2 = [fbFriendsAdded lastObject];
        friendsAddedString = [NSString stringWithFormat:@"%@ and %@", user.first_name, user2.first_name];
    } else {
        for(int i = 0; i < fbFriendsAdded.count - 1; i ++) {
            User * user = [fbFriendsAdded objectAtIndex:i];
            friendsAddedString = [NSString stringWithFormat:@"%@ %@,", friendsAddedString, user.first_name];
        }
        User * last = [fbFriendsAdded lastObject];
        friendsAddedString = [NSString stringWithFormat:@"%@ and %@", friendsAddedString, last.first_name];
    }
    
    PFPush *push = [[PFPush alloc] init];
    NSDictionary *data = @{
                           @"alert" : [NSString stringWithFormat:@"%@ has added %@ to the game: %@", [User currentUser].first_name, friendsAddedString, game.gameName],
                           @"sound" : @"woop.caf",
                           PushParameterPushType : [PushUtils stringForPushType:PushTypePlayerAdded],
                           PushParameterGameId : game.objectId,
                           @"content-available" : @1
                           };
    
    [push setChannels:nonUserPlayersPushIDs];
    [push setData:data];
    [push sendPushInBackground];
}

@end
