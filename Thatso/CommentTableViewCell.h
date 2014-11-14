//
//  CommentTableViewCell.h
//  Thatso
//
//  Created by John A Seubert on 10/10/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSInteger const CommentTableViewCellIconSize;

@interface CommentTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UIView *circle;
@property (nonatomic, strong) Comment *comment;

-(void) selectedTableCell: (BOOL) selected;
-(BOOL) setCommentLabelText: (Comment *) comment;
+ (CGSize) sizeWithFontAttribute:(UIFont *)font constrainedToSize:(CGSize)size withText: (NSString *)text;
@end
