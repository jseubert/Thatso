//
//  CompletedRounds.h
//  Thatso
//
//  Created by John  Seubert on 11/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

@interface CompletedRound : PFObject<PFSubclassing>
@property (retain) User *judge;
@property (retain) User *subject;
@property (retain) NSString *category;
@property (retain) NSNumber *roundNumber;
@property (retain) NSString *gameID;
@property (retain) NSString *categoryID;
@property (retain) NSString *winningResponse;
@property (retain) User *winningResponseFrom;
+ (NSString *)parseClassName;
@end