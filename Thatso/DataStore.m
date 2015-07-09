//
//  DataStore.m
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "DataStore.h"
#import "NSOperationQueue+NSoperationQueue_SharedQueue.h"

@implementation DataStore
static DataStore *instance = nil;
+ (DataStore *) instance
{
    @synchronized (self) {
        if (instance == nil) {
            instance = [[DataStore alloc] init];
        }
    }
    return instance;
}
- (id) init
{
    self = [super init];
    if (self) {
        self.categories = [[NSMutableArray alloc] init];
        self.familyCategories = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) reset
{
    [self.categories removeAllObjects];
    [self.familyCategories removeAllObjects];
}


@end
