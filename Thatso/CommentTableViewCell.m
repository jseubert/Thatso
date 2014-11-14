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
        [self.circle setCenter:(CGPointMake(self.circle.center.x, self.bounds.size.height/2))];
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

-(BOOL) setCommentLabelText: (Comment *) comment
{
    NSLog(@"Font: %f Width: %f", self.bounds.size.width, self.commentLabel.frame.size.width);
    BOOL isSelected = NO;
    self.comment = [comment copyWithZone:nil];
    CGSize labelSize = [CommentTableViewCell sizeWithFontAttribute:self.commentLabel.font constrainedToSize:(CGSizeMake(self.bounds.size.width - (10 + self.circle.frame.size.width + self.circle.frame.origin.x) -10, self.bounds.size.width - (10 + self.circle.frame.size.width + self.circle.frame.origin.x) -10)) withText:comment.comment];
    [self.commentLabel setText:comment.comment];
    [self.commentLabel setFrame:CGRectMake(self.commentLabel.frame.origin.x,
                                         10,
                                         labelSize.width,
                                         labelSize.height)];
    
    [self.circle setCenter:(CGPointMake(self.circle.center.x, (self.commentLabel.frame.size.height + 10 +10 )/2))];
    
    
    
    NSLog(@"Check if need to select: %@ user: %@", comment.votedForBy, [[DataStore instance].user objectForKey:User_ID]);

    if([comment.votedForBy containsObject:[[DataStore instance].user objectForKey:User_ID]] )
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        self.circle.backgroundColor = [UIColor whiteColor];
        self.circle.layer.borderColor = [UIColor lightBlueAppColor].CGColor;
        
        self.commentLabel.textColor = [UIColor blueAppColor];
        [self setSelected:YES];
        isSelected = YES;
    }else
    {
        [self setBackgroundColor:[UIColor blueAppColor]];
        
        self.circle.backgroundColor = [UIColor lightBlueAppColor];
        self.circle.layer.borderColor = [UIColor whiteColor].CGColor;
        
        self.commentLabel.textColor = [UIColor whiteColor];
        [self setSelected:NO];
    }
    return isSelected;
}


+ (CGSize) sizeWithFontAttribute:(UIFont *)font constrainedToSize:(CGSize)size withText: (NSString *)text{
    CGRect res = [text boundingRectWithSize:size
                                    options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{NSFontAttributeName : font}
                                    context:nil];
    return CGSizeMake(ceilf(res.size.width), ceilf(res.size.height));
}


-(void) selectedTableCell: (BOOL) selected
{
    if(selected)
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        self.circle.backgroundColor = [UIColor whiteColor];
        self.circle.layer.borderColor = [UIColor lightBlueAppColor].CGColor;
        
        self.commentLabel.textColor = [UIColor blueAppColor];
        
    }else{
        [self setBackgroundColor:[UIColor blueAppColor]];
        
        self.circle.backgroundColor = [UIColor lightBlueAppColor];
        self.circle.layer.borderColor = [UIColor whiteColor].CGColor;
        
        self.commentLabel.textColor = [UIColor whiteColor];
    }
    [self setSelected:selected];
    NSLog(@"About to voted with userId: %@", [DataStore instance].user);
    [Comms user: [[DataStore instance].user objectForKey:User_ID] DidUpvote:selected forComment:self.comment.objectId];
}



@end
