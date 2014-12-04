//
//  Game.h
//  Thatso
//
//  Created by John  Seubert on 11/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Parse/Parse.h>
#import "Round.h"

@interface Game : PFObject<PFSubclassing>
+ (NSString *)parseClassName;
@property (retain) NSArray *players;
@property (retain) NSNumber *rounds;
@property (retain) Round *currentRound;
@end
