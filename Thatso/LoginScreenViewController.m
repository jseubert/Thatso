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
    // Do any additional setup after loading the view.
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.loginButton.frame = CGRectMake(10, self.view.frame.size.height/2 - 60, self.view.frame.size.width - 20, 50);
    [self.loginButton setTintColor:[UIColor blueColor]];
    [self.loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setTitle:@"Login to Facebook" forState:UIControlStateNormal];
    [self.view addSubview:self.loginButton];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.frame = CGRectMake(self.view.frame.size.width/2 - 40, self.view.frame.size.height/2 -40, 80, 80);
    [self.view addSubview:self.activityIndicator];
     

    
    
    
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
