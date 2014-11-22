//
//  CompletedRounds.m
//  Thatso
//
//  Created by John  Seubert on 11/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "CompletedRounds.h"
#import <Parse/PFObject+Subclass.h>

@implementation CompletedRounds
+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"CompletedRound";
}

@end