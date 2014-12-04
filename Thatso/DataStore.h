//
//  DataStore.h
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataStore : NSObject

@property (nonatomic, strong) NSMutableDictionary *fbFriends;
@property (nonatomic, strong) NSMutableDictionary *fbFriendsProfilePictures;
@property (nonatomic, strong) NSMutableArray *categories;

+ (DataStore *) instance;
- (void) reset;
+ (NSString *) getFriendFirstNameWithID: (NSString *) fbId;
+ (NSString *) getFriendLastNameWithID: (NSString *) fbId;
+ (NSString *) getFriendFullNameWithID: (NSString *) fbId;
+ (void) getFriendProfilePictureWithID: (NSString *) fbId withBlock:(void (^)(UIImage*))block;

@end
