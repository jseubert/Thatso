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


@interface LoginScreenViewController () <PHFComposeBarViewDelegate>

@end

@implementation LoginScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.barTintColor = [UIColor blueAppColor];
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.frame = CGRectMake(20, self.view.frame.size.height/2 - 60, self.view.frame.size.width -40, 50);
    [self.titleLabel setText:@"ThatSo"];
    [self.view addSubview:self.titleLabel];
    [self.titleLabel setFont:[UIFont defaultAppFontWithSize:48.0f]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [[[self titleLabel] layer] setCornerRadius:10.0f];
    [[self.titleLabel layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.loginButton.frame = CGRectMake(20, self.view.frame.size.height - 70, self.view.frame.size.width -40, 50);
    [self.loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton fratButtonWithBorderWidth:2.0f fontSize:18.0 cornerRadius:10.0];
    [self.loginButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    [self.view addSubview:self.loginButton];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.frame = CGRectMake(self.view.frame.size.width/2 - 40, self.view.frame.size.height/2 -30, 80, 80);
    [self.view addSubview:self.activityIndicator];

    
    [self.view setBackgroundColor:[UIColor blueAppColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [Comms getAllFacebookFriends:nil];
        
        //Start Sinch!
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate initSinchClientWithUserId:[[PFUser currentUser] objectForKey:UserFacebookID]];
        
        SelectGameTableViewController *vc = [[SelectGameTableViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)login:(id)sender
{
    NSLog(@"LoginButton Pressed");
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
        //Start Sinch!
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate initSinchClientWithUserId:[[PFUser currentUser] objectForKey:UserFacebookID]];
        
		// Seque to the Image Wall
		SelectGameTableViewController *vc = [[SelectGameTableViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
	} else {
		// Show error alert
		[[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                    message:info
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
	}
}

@end
