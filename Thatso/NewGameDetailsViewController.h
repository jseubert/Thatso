//
//  NewGameDetailsViewController.h
//  ThatSo
//
//  Created by John A Seubert on 1/21/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//

#import "BaseViewController.h"

@interface NewGameDetailsViewController : BaseViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *gameNameTextField;

@property (strong, nonatomic) IBOutlet UILabel *adultContentLabel;
@property (strong, nonatomic) IBOutlet UISwitch *adultContentSwitch;


@end
