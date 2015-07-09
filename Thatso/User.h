//
//  User.h
//  ThatSo
//
//  Created by John A Seubert on 12/11/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

@interface User : PFUser <PFSubclassing>
@property (retain) NSString *fbId;
@property (retain) NSString *first_name;
@property (retain) NSString *last_name;
@property (retain) NSString *name;

+ (User *)user;
+ (BOOL)isLoggedIn;
+ (User* )currentUser;

@end
