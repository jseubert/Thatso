//
//  User.m
//  ThatSo
//
//  Created by John A Seubert on 12/11/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "User.h"
#import <Parse/PFObject+Subclass.h>

@implementation User
@dynamic fbId;
@dynamic first_name;
@dynamic last_name;
@dynamic name;

+ (User *)user {
    return (User *)[PFUser user];
}

+ (BOOL)isLoggedIn
{
    return [User currentUser] ? YES: NO;
}
+ (User* )currentUser
{
    return (User* )[PFUser currentUser];
}



@end
