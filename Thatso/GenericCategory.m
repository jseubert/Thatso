//
//  GenericCategory.m
//  Thatso
//
//  Created by John  Seubert on 12/1/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "GenericCategory.h"
#import <Parse/PFObject+Subclass.h>

@implementation GenericCategory
@dynamic startText;
@dynamic endText;
@dynamic categoryCount;
@dynamic versionAdded;
@dynamic isPG;
@dynamic isAdult;
+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return CategoryClass;
}

@end
