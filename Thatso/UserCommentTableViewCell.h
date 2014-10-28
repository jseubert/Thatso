//
//  UserCommentTableViewCell.h
//  Thatso
//
//  Created by John A Seubert on 10/21/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCommentTextField.h"

@interface UserCommentTableViewCell : UITableViewCell <UITextFieldDelegate>

@property(nonatomic) NSString * toUser;
@property(nonatomic) NSString *roundNumber;
@property(nonatomic) NSString *category;
@property(nonatomic) NSString *gameID;


@property (nonatomic, strong) UserCommentTextField *userCommentTextField;
@property (nonatomic, strong) UIButton *enterButton;

@end
