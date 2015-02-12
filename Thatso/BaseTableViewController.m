//
//  BaseTableViewController.m
//  ThatSo
//
//  Created by John A Seubert on 12/12/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "BaseTableViewController.h"
#import "StringUtils.h"
#import "AppDelegate.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blueAppColor]];
    [self.tableView setBackgroundColor:[UIColor blueAppColor]];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:(CGRectMake(0,
                                                                                        0,
                                                                                        150,
                                                                                        100))];
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setBackgroundColor:[UIColor pinkAppColor]];
    [[self.activityIndicator  layer] setCornerRadius:40.0f];
    [self.activityIndicator setClipsToBounds:YES];
    [[self.activityIndicator  layer] setBorderWidth:2.0f];
    [[self.activityIndicator  layer] setBorderColor:[UIColor whiteColor].CGColor];
    [self.activityIndicator setCenter:CGPointMake(self.view.center.x, 250)];
    
    UILabel *loading = [[UILabel alloc] initWithFrame:CGRectMake(0, self.activityIndicator.frame.size.height - 30, self.activityIndicator.frame.size.width, 20)];
    [loading setTextColor:[UIColor whiteColor]];
    [loading setFont:[UIFont defaultAppFontWithSize:16.0f]];
    [loading setTextAlignment:NSTextAlignmentCenter];
    [loading setText:@"Loading..."];
    [self.activityIndicator addSubview:loading];
    
    // Create a re-usable NSDateFormatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MMM d, h:mm a"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dismissAlert {
    if (self.alertView && self.alertView.visible) {
        [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

-(void) showAlertWithTitle: (NSString *)title andSummary:(NSString *)summary
{
    [self dismissAlert];
    self.alertView = [[UIAlertView alloc]
                      initWithTitle:title message:summary delegate:self  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    // Display Alert Message
    [self.alertView show];
}

-(void) showLoadingAlert
{
    [self dismissAlert];
    self.alertView = [[UIAlertView alloc]
                      initWithTitle:@"Loading..." message:nil delegate:self  cancelButtonTitle:nil otherButtonTitles:nil];
    
    // Display Alert Message
    [self.alertView show];
}

- (void) showLoadingAlertWithText: (NSString *)title
{
    [self dismissAlert];
    self.alertView = [[UIAlertView alloc]
                      initWithTitle:title message:nil delegate:self  cancelButtonTitle:nil otherButtonTitles:nil];
    
    // Display Alert Message
    [self.alertView show];
}

@end
