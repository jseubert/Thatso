//
//  FriendsManager.h
//  Thatso
//
//  Created by John  Seubert on 6/22/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//

//Notification names

@interface FriendsManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *fbFriends;
@property (nonatomic, strong) NSMutableDictionary *fbFriendsProfilePictures;

+ (FriendsManager *) instance;
- (void) clearData;

//Network Calls
- (void) getAllFacebooFriendsWithBlock:(void (^)(bool success, NSString *response))block;
- (void) getFriendProfilePictureWithID: (NSString *) fbId withBlock:(void (^)(UIImage*))block;
- (void) getuser: (NSString *)fbId;
@end