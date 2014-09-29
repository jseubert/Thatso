//
//  UIFont+AppFonts.m
//  Thatso
//
//  Created by John  Seubert on 9/28/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "UIFont+AppFonts.h"

NSString * const FONT_NAME =		@"Avenir-Roman";
NSString * const BOLD_FONT_NAME =	@"Avenir-Black";
NSString * const LIGHT_FONT_NAME =	@"Avenir-Roman";

@implementation UIFont (AppFonts)



+(UIFont *)defaultAppFontWithSize:(CGFloat) size
{
    return [UIFont fontWithName:FONT_NAME size:size];
}

@end
