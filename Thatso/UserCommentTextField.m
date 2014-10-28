//
//  UserCommentTextField.m
//  Thatso
//
//  Created by John A Seubert on 10/21/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "UserCommentTextField.h"

@implementation UserCommentTextField
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 10, bounds.origin.y, bounds.size.width - 10*2, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
