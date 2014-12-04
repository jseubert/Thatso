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

+ (NSString *) buildTextStringForPlayersInGame: (NSArray *)playersInGame fullName:(BOOL) fullName
{
    NSString *nameType = UserFirstName;
    NSString *title = [[NSString alloc] init];
    NSString *lastName = @"";
    if(fullName)
    {
        nameType = UserFullName;
    }
    for(int i = 0; i < playersInGame.count; i ++)
    {
        //Don't add your own name
        if(![((NSString *)[playersInGame objectAtIndex:i]) isEqualToString:(NSString *)[[PFUser currentUser] objectForKey:UserFacebookID]])
        {
            if([lastName length] != 0)
            {
                title = [title stringByAppendingString:[NSString stringWithFormat:@"%@, ", lastName]];
            }
            if(fullName)
            {
                lastName = [DataStore getFriendFullNameWithID:[playersInGame objectAtIndex:i]];
            } else{
                lastName = [DataStore getFriendFirstNameWithID:[playersInGame objectAtIndex:i]];
            }
        }
    }
    if(playersInGame.count == 2)
    {
        title = [title stringByAppendingString:[NSString stringWithFormat:@"%@", lastName]];
    } else
    {
        title = [title stringByAppendingString:[NSString stringWithFormat:@"and %@", lastName]];
    }
    
    return title;
}


@end
