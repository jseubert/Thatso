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
        [self setBackgroundColor:[UIColor whiteColor]];
        
        self.circle = [[UIView alloc] initWithFrame:CGRectZero];
        self.circle.backgroundColor = [UIColor whiteColor];
        self.circle.layer.borderColor = [UIColor pinkAppColor].CGColor;
        self.circle.layer.borderWidth = 2;
        [self.circle setClipsToBounds:YES];
        
        [self addSubview:self.circle];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [self.activityIndicator setHidden:YES];
        [self.activityIndicator stopAnimating];
        [self addSubview:self.activityIndicator];
                
                       
        self.commentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.commentLabel.font = [UIFont defaultAppFontWithSize:16.0];
        self.commentLabel.textColor = [UIColor blueAppColor];
        self.commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.text = @"";
        [self addSubview:self.commentLabel];
        
        self.top = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.top];
        self.top.hidden = YES;
        
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    [self.circle setFrame:CGRectMake(self.frame.size.width - CommentTableViewCellIconSize - 10,
                                     10,
                                     CommentTableViewCellIconSize,
                                     CommentTableViewCellIconSize)];
    [[self.circle layer] setCornerRadius:self.circle.frame.size.height/2];
    [self.activityIndicator setFrame:self.circle.frame];

    [self.commentLabel setFrame:CGRectMake(10,
                                           10,
                                           self.bounds.size.width - (10 + self.circle.frame.size.width + 10) -10,
                                           self.bounds.size.height - 20)];
    
    [self.top setFrame:CGRectMake(0, self.frame.size.height - 5, self.frame.size.width, 5)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.top.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0] CGColor], nil];
    [self.top.layer insertSublayer:gradient atIndex:0];
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
