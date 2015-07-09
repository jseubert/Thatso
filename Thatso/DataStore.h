//
//  DataStore.h
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//


@interface DataStore : NSObject

@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableArray *familyCategories;

+ (DataStore *) instance;
- (void) reset;

@end
