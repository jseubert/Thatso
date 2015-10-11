//
//  FriendsManager.m
//  Thatso
//
//  Created by John  Seubert on 6/22/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//

#import "FriendsManager.h"
#import "NSOperationQueue+NSoperationQueue_SharedQueue.h"
#import "User.h"

@implementation FriendsManager

static FriendsManager *instance = nil;
+ (FriendsManager *) instance
{
    @synchronized (self) {
        if (instance == nil) {
            instance = [[FriendsManager alloc] init];
        }
    }
    return instance;
}
- (id) init
{
    self = [super init];
    if (self) {
        self.fbFriends = [[NSMutableDictionary alloc] init];
        self.fbFriendsProfilePictures = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) clearData
{
    self.fbFriends = [[NSMutableDictionary alloc] init];
    self.fbFriendsProfilePictures = [[NSMutableDictionary alloc] init];
}

- (void) getFriendProfilePictureWithID: (NSString *) fbId withBlock:(void (^)(UIImage*))block{
    UIImage * image = [self.fbFriendsProfilePictures objectForKey:fbId];
    if (image == nil)
    {
        //NSOperationQueue background thread?
        [[NSOperationQueue profilePictureOperationQueue] addOperationWithBlock:^ {
            // Build a profile picture URL from the user's Facebook user id
            NSString *profilePictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", fbId];
            NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]];
            UIImage *profilePicture = [UIImage imageWithData:profilePictureData];
            // Set the profile picture into the user object
            if (profilePicture)
            {
                @synchronized(self){
                    [self.fbFriendsProfilePictures setObject:profilePicture forKey:fbId];
                }
            }
            if(block != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    //Run UI Updates
                    block(profilePicture);
                });
            }
        }];
    }else{
        if(block != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
                block([[FriendsManager instance].fbFriendsProfilePictures objectForKey:fbId]);
            });
        }
    }
}

- (void) getAllFacebooFriendsWithBlock:(void (^)(bool success, NSString *response))block
{
    
    FBSDKGraphRequest *friendsRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/friends?limit=1000" parameters:nil];
    [friendsRequest startWithCompletionHandler: ^(FBSDKGraphRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if(error)
         {
             if(block != nil)
             {
                 block(false, error.localizedDescription);
             }
             return;
         }
         else
         {
             NSArray *friends = result[@"data"];
             NSMutableArray *friendsIDs = [[NSMutableArray alloc] init];
             for (NSDictionary* friend in friends) {
                 [friendsIDs addObject:[friend objectForKey:ID]];
             }
             
             PFQuery *getFBFriends = [User query];
             [getFBFriends whereKey:UserFacebookID containedIn:friendsIDs];
             
             [getFBFriends findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                 if(error)
                 {
                     if(block != nil)
                     {
                         block(false, error.localizedDescription);
                     }
                     return;
                 } else{
                     for (PFObject* friend in objects) {
                         [self.fbFriends setObject:friend forKey:friend[UserFacebookID]];
                         [self getFriendProfilePictureWithID:[friend objectForKey:UserFacebookID] withBlock:nil];
                     }
                     if(block != nil)
                     {
                         block(true, @"");
                     }
                     return;
                 }
             }];
         }
     }];
}

- (void) getuser: (NSString *)fbId
{
    PFQuery *getUser = [User query];
    [getUser whereKey:UserFacebookID containsString:fbId];
    
    User* user = (User *)[getUser getFirstObject];
    if(user != nil)
    {
        [self.fbFriends setObject:user forKey:fbId];
        [self getFriendProfilePictureWithID:[user objectForKey:UserFacebookID] withBlock:nil];
    }
}

@end

