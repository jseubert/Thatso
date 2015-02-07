//
//  GenericCategory.h
//  Thatso
//
//  Created by John  Seubert on 12/1/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Parse/Parse.h>

@interface GenericCategory : PFObject<PFSubclassing>
@property (retain) NSString *startText;
@property (retain) NSString *endText;
@property (retain) NSNumber *categoryCount;
@property (retain) NSNumber *versionAdded;
@property (retain) NSNumber *isPG;
@property (retain) NSNumber *isAdult;
+ (NSString *)parseClassName;
@end
