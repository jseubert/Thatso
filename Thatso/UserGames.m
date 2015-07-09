//
//  UserGames.m
//  Thatso
//
//  Created by John A Seubert on 8/25/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "UserGames.h"
@implementation PreviousRounds
static PreviousRounds *previousRounds = nil;
+ (PreviousRounds *) instance
{
    @synchronized (self) {
        if (previousRounds == nil) {
            previousRounds = [[PreviousRounds alloc] init];
        }
    }
    return previousRounds;
}
- (id) init
{
    self = [super init];
    if (self) {
        self.previousRounds  = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) setPreviousRounds: (NSArray*)rounds forGameId: (NSString *) gameId
{
    [self.previousRounds setObject:rounds forKey:gameId];
}

- (void) reset
{
    [self.previousRounds removeAllObjects];
}


@end
