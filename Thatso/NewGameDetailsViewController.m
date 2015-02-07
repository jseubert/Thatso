//
//  NewGameDetailsViewController.m
//  ThatSo
//
//  Created by John A Seubert on 1/21/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//

#import "NewGameDetailsViewController.h"
#import "FratBarButtonItem.h"
#import "NewGameTableViewController.h"

@interface NewGameDetailsViewController ()

@end

@implementation NewGameDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        self.navigationItem.title = @"New Game";
        
    
        //Back button - needed for pushed view controllers
        FratBarButtonItem *backButton= [[FratBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationItem setBackBarButtonItem: backButton];
    
        //New Game Button
        FratBarButtonItem *newGameButton= [[FratBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextClicked:)];
        self.navigationItem.rightBarButtonItem = newGameButton;

    self.gameNameLabel = [[UILabel alloc] initWithFrame:(CGRectMake(10,
                                                                    self.navigationController.navigationBar.frame.size.height + 20,
                                                                    self.view.frame.size.width-20,
                                                                    40))];
    [self.gameNameLabel setText:@"Game Name"];
    [self.gameNameLabel setFont:[UIFont defaultAppFontWithSize:16.0f]];
    [self.gameNameLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:self.gameNameLabel];
    
    self.gameNameTextField = [[UITextField alloc] initWithFrame:(CGRectMake(10,
                                                                            self.gameNameLabel.frame.origin.y + self.gameNameLabel.frame.size.height,
                                                                            self.view.frame.size.width-20,
                                                                            40))];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
    self.gameNameTextField.leftView = paddingView;
    self.gameNameTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.gameNameTextField setDelegate:self];
    [self.gameNameTextField setPlaceholder:@"What do you want to call this game?"];
    [self.gameNameTextField setBackgroundColor:[UIColor whiteColor]];
    [[self.gameNameTextField  layer] setCornerRadius:5.0f];
    [self.gameNameTextField setFont:[UIFont defaultAppFontWithSize:16.0f]];
    [self.gameNameTextField setTextColor:[UIColor blackColor]];
    [self.view addSubview:self.gameNameTextField];
    
    self.adultContentLabel = [[UILabel alloc] initWithFrame:(CGRectMake(10,
                                                                         self.gameNameTextField.frame.origin.y + self.gameNameTextField.frame.size.height + 10,
                                                                         self.view.frame.size.width-20,
                                                                         50))];
    [self.adultContentLabel setText:@"Family Friendly Topics Only"];
    [self.adultContentLabel setFont:[UIFont defaultAppFontWithSize:16.0f]];
    [self.adultContentLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:self.adultContentLabel];
    
    self.adultContentSwitch = [[UISwitch alloc] initWithFrame:(CGRectMake(self.view.frame.size.width -60,
                                                                          self.adultContentLabel.frame.origin.y +10,
                                                                          self.view.frame.size.width-20,
                                                                          50))];
    [self.view addSubview:self.adultContentSwitch];
    
}


-(IBAction)nextClicked:(id)sender{
    NSLog(@"newGame");
    // Seque to the Image Wall
    if ([self.gameNameTextField.text length] == 0 || self.gameNameTextField.text == nil || [self.gameNameTextField.text length] > 100)
    {
        [self showAlertWithTitle:@"Please enter a game name" andSummary:@""];
        return;
    }
    if(!self.adultContentSwitch.on)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You do not have the \"Family Friendly\" setting on. This game will contain mature themes suitable only for persons 18+ years old. Are you sure you want to continue?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [alert show];
    } else{
        [self nextStep];
    }
}

-(void)nextStep
{
    NewGameTableViewController *vc = [[NewGameTableViewController alloc] init];
    vc.familyFriendly = self.adultContentSwitch.on;
    vc.gameName = self.gameNameTextField.text;
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        [self nextStep];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]) {
            [txt resignFirstResponder];
        }
    }
}

@end
