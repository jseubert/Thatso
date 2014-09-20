//
//  NSOperationQueue+NSoperationQueue_SharedQueue.h
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (NSoperationQueue_SharedQueue)

+ (NSOperationQueue *) pffileOperationQueue;
+ (NSOperationQueue *) profilePictureOperationQueue;

@end
