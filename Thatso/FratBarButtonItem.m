//
//  FratBarButtonItem.m
//  Thatso
//
//  Created by John A Seubert on 10/3/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "FratBarButtonItem.h"

@implementation FratBarButtonItem

- (id)initWithTitle:(NSString *)title
                        style:(UIBarButtonItemStyle)style
                       target:(id)target
                       action:(SEL)action
{
    self = [super initWithTitle:(NSString *)title
                          style:(UIBarButtonItemStyle)style
                         target:(id)target
                         action:(SEL)action];
    if (self) {
        // Initialization code
        self.tintColor = [UIColor whiteColor];
        
        NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [UIFont defaultAppFontWithSize:18.0 ], NSForegroundColorAttributeName: [UIColor whiteColor]};
        [self setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
        
    }
    
    return self;
}

@end
