//
//  BaseViewController.h
//  ThatSo
//
//  Created by John A Seubert on 12/11/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StringUtils.h"

@interface BaseViewController : UIViewController <UIAlertViewDelegate>
{
    NSDateFormatter *_dateFormatter;
}

- (void) dismissAlert;
- (void) showAlertWithTitle: (NSString *)title andSummary:(NSString *)summary;
- (void) showLoadingAlert;
- (void) showLoadingAlertWithText: (NSString *)title;

@property (nonatomic, strong) UIAlertView *alertView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end