//
//  UserGames.h
//  Thatso
//
//  Created by John A Seubert on 8/25/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject
@property (nonatomic, strong) NSString* objectId;
@property (nonatomic, strong) NSString* toUserID;
@property (nonatomic, strong) NSString* fromUserID;
@property (nonatomic, strong) NSString* roundNumber;
@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) NSString* category;
@property (nonatomic, strong) NSString* gameId;

@end

@interface Round : NSObject
@property int roundNumber;
@property id objectId;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSMutableArray *comments;

@end

@interface Game : NSObject
@property NSString* objectId;
@property (nonatomic, strong) NSMutableArray *players;
@property (nonatomic, strong) NSMutableArray *rounds;
- (int) numberOfRounds;

@end

@interface UserGames : NSObject
@property (nonatomic, strong) NSMutableArray *games;
+(UserGames *) instance;
- (void) reset;
@end

@interface CurrentRound : NSObject
@property (nonatomic, strong) NSMutableDictionary* currentComments;
+(CurrentRound *) instance;
-(void) setComments: (NSMutableDictionary *)comments;
-(void) reset;
@end
