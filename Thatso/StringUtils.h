//
//  StringUtils.h
//  Thatso
//
//  Created by John A Seubert on 10/9/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

@interface StringUtils : NSObject
+ (NSAttributedString *) makeRefreshText:(NSString *) string;
+ (NSString *) buildTextStringForPlayersInGame: (NSArray *)playersInGame fullName:(BOOL) fullName;
+ (CGSize) sizeWithFontAttribute:(UIFont *)font constrainedToSize:(CGSize)size withText: (NSString *)text;

@end
