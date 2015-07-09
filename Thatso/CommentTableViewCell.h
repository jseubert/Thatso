//
//  CommentTableViewCell.h
//  Thatso
//
//  Created by John A Seubert on 10/10/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

extern NSInteger const CommentTableViewCellIconSize;

@interface CommentTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UIView *circle;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIView *top;

-(void) setCommentLabelText: (NSString *) comment;
@end
