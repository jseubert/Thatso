//
//  FontSize.h
//  Thatso
//
//  Created by John A Seubert on 11/8/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//


@interface NSString(FontSize)

// assuming line break mode is NSLineBreakWordwrap
- (CGSize) sizeWithFontAttribute:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGSize) sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
- (CGSize) sizeWithFontAttribute:(UIFont *)font;
- (CGFloat) widthWithFont:(UIFont *)font;

@end
