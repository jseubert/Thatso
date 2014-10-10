//
//  StringUtils.m
//  Thatso
//
//  Created by John A Seubert on 10/9/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "StringUtils.h"


@implementation StringUtils

+ (NSAttributedString *) makeRefreshText:(NSString *) string
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, string.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont defaultAppFontWithSize:14.0] range:NSMakeRange(0, string.length)];
    
    return attributedString;
}

@end
