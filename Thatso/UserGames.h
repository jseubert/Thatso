//
//  UserGames.h
//  Thatso
//
//  Created by John A Seubert on 8/25/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserGames : NSObject
@property (nonatomic, strong) NSMutableArray *games;
+(UserGames *) instance;
- (void) reset;
@end

@interface CurrentRounds : NSObject
@property (nonatomic, strong) NSMutableDictionary* currentComments;
+(CurrentRounds *) instance;
-(void) setComments: (NSMutableDictionary *)comments;
-(void) reset;
@end
