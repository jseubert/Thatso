//
//  NewGameDetailsViewController.h
//  ThatSo
//
//  Created by John A Seubert on 1/21/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//

#import "BaseViewController.h"

@interface NewGameDetailsViewController : BaseViewController <UITextFieldDelegate>

@property (strong, nonatomic) UILabel *gameNameLabel;
@property (strong, nonatomic) UITextField *gameNameTextField;

@property (strong, nonatomic) UILabel *adultContentLabel;
@property (strong, nonatomic) UISwitch *adultContentSwitch;


@end
