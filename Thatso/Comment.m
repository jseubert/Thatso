//
//  Comment.m
//  Thatso
//
//  Created by John  Seubert on 11/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "Comment.h"
#import <Parse/PFObject+Subclass.h>

@implementation Comment
@dynamic gameID;
@dynamic roundID;
@dynamic from;
@dynamic response;
+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return CommentClass;
}

@end