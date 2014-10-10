//
//  SelectGameTableViewCell.m
//  Thatso
//
//  Created by John  Seubert on 10/3/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "SelectGameTableViewCell.h"

@implementation SelectGameTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
        self.namesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width -10, self.frame.size.height/2)];
        self.namesLabel.font = [UIFont defaultAppFontWithSize:16.0];
        self.namesLabel.text = @"";
        
        [self addSubview:self.namesLabel];
        
        self.categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.frame.size.height/2 + 10, self.frame.size.width-10, self.frame.size.height/2)];
        self.categoryLabel.font = [UIFont defaultAppFontWithSize:14.0];
        self.categoryLabel.text = @"";
        
        [self addSubview:self.categoryLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setColorScheme:(NSInteger) code
{
    switch(code%6)
    {
        case 0:
            self.backgroundColor = [UIColor whiteColor];
            self.namesLabel.textColor = [UIColor blueAppColor];
            self.categoryLabel.textColor = [UIColor pinkAppColor];
            break;
        case 1:
            self.backgroundColor = [UIColor lightBlueAppColor];
            self.namesLabel.textColor = [UIColor whiteColor];
            self.categoryLabel.textColor = [UIColor blueAppColor];
            break;
        case 2:
            self.backgroundColor = [UIColor blueAppColor];
            self.namesLabel.textColor = [UIColor pinkAppColor];
            self.categoryLabel.textColor = [UIColor whiteColor];
            break;
        case 3:
            self.backgroundColor = [UIColor whiteColor];
            self.namesLabel.textColor = [UIColor pinkAppColor];
            self.categoryLabel.textColor = [UIColor blueAppColor];
            break;
        case 4:
            self.backgroundColor = [UIColor lightBlueAppColor];
            self.namesLabel.textColor = [UIColor blueAppColor];
            self.categoryLabel.textColor = [UIColor whiteColor];
            break;
        case 5:
            self.backgroundColor = [UIColor blueAppColor];
            self.namesLabel.textColor = [UIColor whiteColor];
            self.categoryLabel.textColor = [UIColor pinkAppColor];
            break;
        default:
            self.backgroundColor = [UIColor whiteColor];
            self.namesLabel.textColor = [UIColor blueAppColor];
            self.categoryLabel.textColor = [UIColor pinkAppColor];
            break;
    }
    
}

@end
