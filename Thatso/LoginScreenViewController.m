//
//  LoginScreenViewController.m
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "LoginScreenViewController.h"
#import "SelectGameTableViewController.h"


@interface LoginScreenViewController ()

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
    [self.titleLabel setText:@"Thatso"];
    [self.view addSubview:self.titleLabel];
    [self.titleLabel setFont:[UIFont defaultAppFontWithSize:48.0f]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    //[[self.titleLabel layer] setBorderWidth:2.0f ];
    [[[self titleLabel] layer] setCornerRadius:10.0f];
    [[self.titleLabel layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.loginButton.frame = CGRectMake(20, self.view.frame.size.height - 70, self.view.frame.size.width -40, 50);
    [self.loginButton setTintColor:[UIColor blueColor]];
    [self.loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setTitle:@"Login to Facebook" forState:UIControlStateNormal];
    [self.loginButton setTintColor:[UIColor whiteColor]];
    [self.loginButton setBackgroundColor:[UIColor pinkAppColor]];
    [[self.loginButton layer] setBorderWidth:2.0f ];
    [[self.loginButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[[self loginButton] titleLabel] setFont:[UIFont defaultAppFontWithSize:18.0]];
    [[[self loginButton] layer] setCornerRadius:10.0f];
    [self.loginButton setClipsToBounds:YES];
    [self.view addSubview:self.loginButton];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.frame = CGRectMake(self.view.frame.size.width/2 - 40, self.view.frame.size.height/2 -40, 80, 80);
    [self.view addSubview:self.activityIndicator];
    
    [self.view setBackgroundColor:[UIColor blueAppColor]];
     

    
    
    
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

- (void) commsDidLogin:(BOOL)loggedIn {
    NSLog(@"commsDidLogin");
	// Re-enable the Login button
	[self.loginButton setEnabled:YES];
    
	// Stop the activity indicator
	[self.activityIndicator stopAnimating];
    
	// Did we login successfully ?
	if (loggedIn) {
		// Seque to the Image Wall
		SelectGameTableViewController *vc = [[SelectGameTableViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
	} else {
		// Show error alert
		[[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                    message:@"Facebook Login failed. Please try again"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
	}
}

@end
