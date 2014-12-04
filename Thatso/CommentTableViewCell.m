//
//  CommentTableViewCell.m
//  Thatso
//
//  Created by John A Seubert on 10/10/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "UIColor+AppColors.h"
#import "NSString+FontSize.h"

NSInteger const CommentTableViewCellIconSize = 20;

@implementation CommentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
        [self setBackgroundColor:[UIColor blueAppColor]];
        
        self.circle = [[UIView alloc] initWithFrame:CGRectMake(10,
                                                               10,
                                                               CommentTableViewCellIconSize,
                                                               CommentTableViewCellIconSize)];
       // [self.circle setCenter:(CGPointMake(self.circle.center.x, self.bounds.size.height/2))];
        self.circle.backgroundColor = [UIColor whiteColor];
        self.circle.layer.borderColor = [UIColor lightBlueAppColor].CGColor;
        self.circle.layer.borderWidth = 2;
        
        [self addSubview:self.circle];
                
                       
        self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 + self.circle.frame.size.width + self.circle.frame.origin.x,
                                                                      self.bounds.size.height/2,
                                                                      self.bounds.size.width - (10 + self.circle.frame.size.width + self.circle.frame.origin.x) -10,
                                                                      self.bounds.size.height - 20)];
        self.commentLabel.font = [UIFont defaultAppFontWithSize:16.0];
        self.commentLabel.textColor = [UIColor whiteColor];
        self.commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.text = @"";
        [self addSubview:self.commentLabel];
        
    }
    return self;
}

-(void) setCommentLabelText: (NSString *) comment
{
    CGFloat width = self.frame.size.width
    - 10    //left padding
    - 20    //New Button
    - 10    //right padding button
    - 10;   //padding on right
    
    CGSize labelSize = [CommentTableViewCell sizeWithFontAttribute:self.commentLabel.font constrainedToSize:CGSizeMake(width, width) withText:comment];
    
    [self.commentLabel setText:comment];
    [self.commentLabel setFrame:CGRectMake(self.commentLabel.frame.origin.x,
                                         10,
                                         labelSize.width,
                                         labelSize.height)];
    
}


+ (CGSize) sizeWithFontAttribute:(UIFont *)font constrainedToSize:(CGSize)size withText: (NSString *)text{
    CGRect res = [text boundingRectWithSize:size
                                    options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{NSFontAttributeName : font}
                                    context:nil];
    return CGSizeMake(ceilf(res.size.width), ceilf(res.size.height));
}




@end
