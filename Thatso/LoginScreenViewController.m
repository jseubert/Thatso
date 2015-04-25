//
//  LoginScreenViewController.m
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "LoginScreenViewController.h"
#import "SelectGameTableViewController.h"
#import "UIButton+CustomButtons.h"
#import "AppDelegate.h"
#import "LoginPageViewController.h"
#import <Crashlytics/Crashlytics.h>


@interface LoginScreenViewController () <PHFComposeBarViewDelegate>

@end

@implementation LoginScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.barTintColor = [UIColor blueAppColor];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.titleLabel setText:@"ThatSo™"];
    [self.view addSubview:self.titleLabel];
    [self.titleLabel setFont:[UIFont defaultAppFontWithSize:48.0f]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [[[self titleLabel] layer] setCornerRadius:10.0f];
    [[self.titleLabel layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    self.loginButton = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
    [self.loginButton addTarget:self action:@selector(loginPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton fratButtonWithBorderWidth:2.0f fontSize:18.0 cornerRadius:10.0];
    [self.loginButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    [self.view addSubview:self.loginButton];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:self.activityIndicator];
    
    [self.view setBackgroundColor:[UIColor blueAppColor]];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
     self.titleLabel.frame = CGRectMake(20, self.view.frame.size.height/2 - 60, self.view.frame.size.width -40, 50);
    self.loginButton.frame = CGRectMake(20, self.view.frame.size.height - 70, self.view.frame.size.width -40, 50);
    self.activityIndicator.frame = CGRectMake(self.view.frame.size.width/2 - 40, self.view.frame.size.height/2 -30, 80, 80);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([User currentUser] && [PFFacebookUtils isLinkedWithUser:[User currentUser]]) {
        [Comms getAllFacebookFriends:nil];
        [Comms getProfilePictureForUser:[[User currentUser] objectForKey:UserFacebookID] withBlock:nil];

        [self setupUserAndMoveToHomeScreen];
    }
}

-(IBAction)loginPressed:(id)sender
{
    // Disable the Login button to prevent multiple touches
    [self.loginButton setEnabled:NO];
    [self.activityIndicator startAnimating];
    
    // Do the login
    [Comms login:self];

}

- (void) didlogin:(BOOL)success info: (NSString *) info {
    NSLog(@"commsDidLogin");
	// Re-enable the Login button
	[self.loginButton setEnabled:YES];
    
	// Stop the activity indicator
	[self.activityIndicator stopAnimating];
    
	// Did we login successfully ?
	if (success) {
        [self setupUserAndMoveToHomeScreen];
        
	} else {
		// Show error alert
		[[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                    message:info
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
	}
}

-(void) setupUserAndMoveToHomeScreen
{
    //Start Sinch!
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate initSinchClientWithUserId:[[User currentUser] objectForKey:UserFacebookID]];
    
    //Register for push notifications
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:[NSString stringWithFormat:@"c%@",[User currentUser].fbId] forKey:@"channels"];
    [currentInstallation saveInBackground];
    
    //Move to Fist Screen
    SelectGameTableViewController *vc = [[SelectGameTableViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma Mark pageViewController datasource delegate
-(LoginPageViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    LoginPageViewController *childViewController = [[LoginPageViewController alloc] init];
    childViewController.index = index;
    
    return childViewController;
    
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(LoginPageViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(LoginPageViewController *)viewController index];
    
    
    index++;
    
    if (index == 5) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

@end
