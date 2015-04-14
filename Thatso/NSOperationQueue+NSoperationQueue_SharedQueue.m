//
//  NSOperationQueue+NSoperationQueue_SharedQueue.m
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "NSOperationQueue+NSoperationQueue_SharedQueue.h"

@implementation NSOperationQueue (NSoperationQueue_SharedQueue)
+ (NSOperationQueue *) pffileOperationQueue {
	static NSOperationQueue *pffileQueue = nil;
	if (pffileQueue == nil) {
		pffileQueue = [[NSOperationQueue alloc] init];
		[pffileQueue setName:@"com.seubjoh.pffilequeue"];
	}
	return pffileQueue;
}

+ (NSOperationQueue *) profilePictureOperationQueue {
	static NSOperationQueue *profilePictureQueue = nil;
	if (profilePictureQueue == nil) {
		profilePictureQueue = [[NSOperationQueue alloc] init];
		[profilePictureQueue setName:@"com.seubjoh.profilepicturequeue"];
	}
	return profilePictureQueue;
}

@end
