//
//  Game.m
//  Thatso
//
//  Created by John  Seubert on 11/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "Game.h"
#import <Parse/PFObject+Subclass.h>

@implementation Game
@dynamic displayName;
//@dynamic displayName;
//@dynamic displayName;
//@dynamic displayName;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Game";
}

@end