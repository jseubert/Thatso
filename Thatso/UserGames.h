//
//  UserGames.h
//  Thatso
//
//  Created by John A Seubert on 8/25/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//
@interface PreviousRounds : NSObject
@property (nonatomic, strong) NSMutableDictionary* previousRounds;
+ (PreviousRounds *) instance;
- (void) setPreviousRounds: (NSArray*)rounds forGameId: (NSString *) gameId;
- (void) reset;
@end



