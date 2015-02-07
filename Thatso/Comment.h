//
//  Comment.h
//  Thatso
//
//  Created by John  Seubert on 11/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Parse/Parse.h>

@interface Comment : PFObject<PFSubclassing>
@property (retain) NSString *gameID;
@property (retain) NSString *roundID;
@property (retain) User *from;
@property (retain) NSString *response;

+ (NSString *)parseClassName;
@end
