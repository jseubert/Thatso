//
//  ProfileViewTableViewCell.m
//  Thatso
//
//  Created by John A Seubert on 9/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "ProfileViewTableViewCell.h"

NSInteger const ProfileViewTableViewCellHeight = 54;

@implementation ProfileViewTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.profilePicture = [[UIImageView alloc] initWithFrame:(CGRectMake(5, 5, self.frame.size.height, self.frame.size.height))];
        [[self.profilePicture  layer] setCornerRadius:self.profilePicture.frame.size.height/2];
        [self.profilePicture setClipsToBounds:YES];
        [self addSubview:self.profilePicture];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.profilePicture.frame.origin.x + self.profilePicture.frame.size.width + 10, 10, self.frame.size.width - self.profilePicture.frame.origin.x + self.profilePicture.frame.size.width + 10, self.frame.size.height - 10)];
        self.nameLabel.font = [UIFont defaultAppFontWithSize:16.0];
        [self addSubview:self.nameLabel];
        
        
    }
    
    
    
    return self;
}

-(void)setColorScheme:(NSInteger) code
{
    switch(code%6)
    {
        case 0:
            self.backgroundColor = [UIColor whiteColor];
            self.nameLabel.textColor = [UIColor blueAppColor];
            break;
        case 1:
            self.backgroundColor = [UIColor lightBlueAppColor];
            self.nameLabel.textColor = [UIColor whiteColor];
            break;
        case 2:
            self.backgroundColor = [UIColor blueAppColor];
            self.nameLabel.textColor = [UIColor pinkAppColor];
            break;
        case 3:
            self.backgroundColor = [UIColor whiteColor];
            self.nameLabel.textColor = [UIColor pinkAppColor];
            break;
        case 4:
            self.backgroundColor = [UIColor lightBlueAppColor];
            self.nameLabel.textColor = [UIColor blueAppColor];
            break;
        case 5:
            self.backgroundColor = [UIColor blueAppColor];
            self.nameLabel.textColor = [UIColor whiteColor];
            break;
        default:
            self.backgroundColor = [UIColor whiteColor];
            self.nameLabel.textColor = [UIColor blueAppColor];
            break;
    }
    
}


@end
