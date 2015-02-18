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
        _fbFriends = [[NSMutableDictionary alloc] init];
        self.fbFriendsProfilePictures = [[NSMutableDictionary alloc] init];
        self.categories = [[NSMutableArray alloc] init];
        self.familyCategories = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) reset
{
    [_fbFriends removeAllObjects];
    [self.categories removeAllObjects];
    [self.familyCategories removeAllObjects];
    [self.fbFriendsProfilePictures removeAllObjects];

}

+(NSString *) getFriendObjectForKey: (NSString *)key forFriendID: (NSString *) fbId
{
    //Download user if it doesnt exist
    NSDictionary *friend = [[DataStore instance].fbFriends objectForKey:fbId];
    if(friend == nil)
    {
        [Comms getuser:fbId];
    }
    return [[[DataStore instance].fbFriends objectForKey:fbId] objectForKey:key];
}

+ (NSString *) getFriendFirstNameWithID: (NSString *) fbId {
    return [self getFriendObjectForKey:UserFirstName forFriendID: fbId];
}

+ (NSString *) getFriendLastNameWithID: (NSString *) fbId {
    return [self getFriendObjectForKey:UserLastName forFriendID: fbId];
}

+ (NSString *) getFriendFullNameWithID: (NSString *) fbId {
    return [self getFriendObjectForKey:UserFullName forFriendID: fbId];
}

+ (void) getFriendProfilePictureWithID: (NSString *) fbId withBlock:(void (^)(UIImage*))block{
    UIImage * image = [[DataStore instance].fbFriendsProfilePictures objectForKey:fbId];
    if (image == nil)
    {
        [Comms getProfilePictureForUser:fbId withBlock:block];
    }else{
        if(block != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
                block([[DataStore instance].fbFriendsProfilePictures objectForKey:fbId]);
            });
        }
    }
}

@end
