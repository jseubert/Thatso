//
//  BaseViewController.m
//  ThatSo
//
//  Created by John A Seubert on 12/11/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "BaseViewController.h"
#import "AppDelegate.h"
#import "StringUtils.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blueAppColor]];
    
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:(CGRectMake(0,
                                                                                        0,
                                                                                        150,
                                                                                        100))];
    canShowBanner = NO;
    
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setBackgroundColor:[UIColor blueAppColor]];
    [[self.activityIndicator  layer] setCornerRadius:40.0f];
    [self.activityIndicator setClipsToBounds:YES];
    [[self.activityIndicator  layer] setBorderWidth:2.0f];
    [[self.activityIndicator  layer] setBorderColor:[UIColor whiteColor].CGColor];
    
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

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.activityIndicator setCenter:[self.view center]];
    if(canShowBanner)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.adView setFrame:CGRectMake(0, self.view.frame.size.height - [self bannerHeight], self.view.frame.size.width, [self bannerHeight])];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(canShowBanner)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self.view addSubview:appDelegate.adView];
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

- (void) dismissAlert {
    if (self.alertView && self.alertView.visible) {
        [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

-(void) showLoadingAlert
{
    [self dismissAlert];
    self.alertView = [[UIAlertView alloc]
                      initWithTitle:@"Loading..." message:nil delegate:self  cancelButtonTitle:nil otherButtonTitles:nil];
    
    // Display Alert Message
    [self.alertView show];
}
- (void) showActivityIndicator
{
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:NO];
}

-(void) hideActivityIndicator
{
    [self.activityIndicator stopAnimating];
}

- (void) showLoadingAlertWithText: (NSString *)title
{
    [self dismissAlert];
    self.alertView = [[UIAlertView alloc]
                      initWithTitle:title message:nil delegate:self  cancelButtonTitle:nil otherButtonTitles:nil];
    
    // Display Alert Message
    [self.alertView show];
}


- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (canShowBanner)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        
        [UIView commitAnimations];
        
        [self.view setNeedsLayout];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve ad");
    if (canShowBanner)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        
        [UIView commitAnimations];
    }
    
}

- (CGFloat) bannerHeight
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.adView.isBannerLoaded && canShowBanner)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            return 66.0f;
        } else{
            return 50.0f;
        }
    } else{
        return 0.0f;
    }
}
@end
