//
//  Round.m
//  Thatso
//
//  Created by John  Seubert on 11/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "Round.h"
#import <Parse/PFObject+Subclass.h>

@implementation Round
@dynamic judge;
@dynamic subject;
@dynamic category;
@dynamic roundNumber;
@dynamic responded;
@dynamic categoryID;
+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return RoundClass;
}

@end