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
        [self setBackgroundColor:[UIColor blueAppColor]];
        
        self.circle = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.height - 20, self.frame.size.height - 20)];
        self.circle.backgroundColor = [UIColor whiteColor];
        self.circle.layer.borderColor = [UIColor lightBlueAppColor].CGColor;
        self.circle.layer.borderWidth = 2;
        [self addSubview:self.circle];
                
                       
        self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 + self.circle.frame.size.width + self.circle.frame.origin.x, 10, self.frame.size.width - 10, self.frame.size.height - 20)];
        self.commentLabel.font = [UIFont defaultAppFontWithSize:16.0];
        self.commentLabel.textColor = [UIColor whiteColor];
        self.commentLabel.text = @"";
        [self addSubview:self.commentLabel];
        
    }
    return self;
}



@end
