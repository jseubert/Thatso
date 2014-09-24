//
//  ProfileViewTableViewCell.m
//  Thatso
//
//  Created by John A Seubert on 9/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "ProfileViewTableViewCell.h"

@implementation ProfileViewTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _profilePicture = [[UIImageView alloc] initWithFrame:(CGRectMake(0, 0, 100, 100))];
        [self.contentView addSubview:_profilePicture];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, self.frame.size.width -100, 100)];
        _nameLabel.text = @"Name";
        _nameLabel.backgroundColor = [UIColor greenColor];
        [self.contentView addSubview:_nameLabel];
        
        [self setBackgroundColor:[UIColor redColor]];
        
    }
    
    
    
    return self;
}


@end
