//
//  CompletedRounds.m
//  Thatso
//
//  Created by John  Seubert on 11/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "CompletedRound.h"
#import <Parse/PFObject+Subclass.h>

@implementation CompletedRound
@dynamic judge;
@dynamic subject;
@dynamic category;
@dynamic roundNumber;
@dynamic gameID;
@dynamic winningResponse;
@dynamic winningResponseFrom;
@dynamic categoryID;
+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return CompletedRoundClass;
}

@end