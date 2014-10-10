//
//  UserGames.h
//  Thatso
//
//  Created by John A Seubert on 8/25/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject
@property id objectId;
@property int toUserID;
@property int fromUserID;
@property int roundNumber;
@property (nonatomic, strong) NSString *comment;

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
