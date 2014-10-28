//
//  UIButton+CustomButtons.m
//  Thatso
//
//  Created by John A Seubert on 10/21/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIButton+CustomButtons.h"

@implementation UIButton (CustomButtons)

-(void) fratButtonWithBorderWidth:(float)borderWidth fontSize:(float)fontsize cornerRadius: (float)cornerRadius
{
    [self setTintColor:[UIColor whiteColor]];
    [self setBackgroundColor:[UIColor pinkAppColor]];
    [[self layer] setBorderWidth:borderWidth];
    [[self layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[self  titleLabel] setFont:[UIFont defaultAppFontWithSize:fontsize]];
    [[self  layer] setCornerRadius:cornerRadius];
    [self setClipsToBounds:YES];
}

@end