//
//  CommentTableViewCell.m
//  Thatso
//
//  Created by John A Seubert on 10/10/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "UIColor+AppColors.h"

@implementation CommentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
        self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width -10, self.frame.size.height-20)];
        self.commentLabel.font = [UIFont defaultAppFontWithSize:16.0];
        self.commentLabel.textColor = [UIColor whiteColor];
        self.commentLabel.text = @"";
        
        [self setBackgroundColor:[UIColor blueAppColor]];
        [self addSubview:self.commentLabel];
    }
    return self;
    
}

@end
