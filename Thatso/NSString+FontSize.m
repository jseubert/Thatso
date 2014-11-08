//
//  NSString_FontSize.h
//  Thatso
//
//  Created by John A Seubert on 11/8/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+FontSize.h"


@implementation NSString(FontSize)

- (CGSize) sizeWithFontAttribute:(UIFont *)font constrainedToSize:(CGSize)size {
    CGRect res = [self boundingRectWithSize:size
                                    options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{NSFontAttributeName : font}
                                    context:nil];
    return CGSizeMake(ceilf(res.size.width), ceilf(res.size.height));
}

- (CGSize) sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width {
    return [self sizeWithFontAttribute:font constrainedToSize:CGSizeMake(width, width)];
}

- (CGSize) sizeWithFontAttribute:(UIFont *)font {
    CGSize res = [self sizeWithAttributes:@{NSFontAttributeName : font}];
    return CGSizeMake(ceilf(res.width), ceilf(res.height));
}

- (CGFloat) widthWithFont:(UIFont *)font {
    CGSize size = [self sizeWithFontAttribute:font];
    return size.width;
}

@end
