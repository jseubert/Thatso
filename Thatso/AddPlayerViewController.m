//
//  AddPlayerViewController.m
//  Thatso
//
//  Created by John  Seubert on 2/12/16.
//  Copyright © 2016 John Seubert. All rights reserved.
//

#import "AddPlayerViewController.h"
#import "FratBarButtonItem.h"
#import "ProfileViewTableViewCell.h"
#import "UIImage+Scaling.h"
#import "AppDelegate.h"
#import "StringUtils.h"
#import "GameManager.h"
#import "FriendsManager.h"
#import "User.h"
#import "PushUtils.h"

@interface AddPlayerViewController ()

@end

@implementation AddPlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     *ViewController Preferences/Appearance
     */
    self.navigationItem.title = @"Add Player";
    
    self.fbFriendsArray = [[NSMutableArray alloc] init];
    //self.fbFriendsArray = [[NSMutableArray alloc] init];
    
    /*
     * Subview initializations
     */
    //Finish Game Button
    FratBarButtonItem *startButton  = [[FratBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = startButton;
    
    //Friends table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor blueAppColor]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    self.tableView.allowsMultipleSelection = YES;
    [self.view addSubview: self.tableView];
    
    [self showActivityIndicator];
    [[FriendsManager instance] getAllFacebooFriendsWithBlock:^(bool success, NSString *response) {
        [self hideActivityIndicator];
        if (success) {
            self.fbFriendsArray = [[NSMutableArray alloc] initWithArray:[[FriendsManager instance].fbFriends allValues]];
            //Remove users in game
            for(User* player in self.currentGame.players) {
                User *userToRemove = nil;
                for(User *fbFriend in self.fbFriendsArray) {
                    if([player.fbId isEqualToString:fbFriend.fbId]) {
                        userToRemove = fbFriend;
                        break;
                    }
                }
                if(userToRemove != nil) {
                    [self.fbFriendsArray removeObject:userToRemove];
                }
            }
            [self.tableView reloadData];
        }else{
            [self showAlertWithTitle:@"Error!" andSummary:response];
        }
    }];
    
    //Add Activity indicator
    [self.view addSubview:self.activityIndicator];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.adView.delegate = self;
    canShowBanner = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.tableView setFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - [self bannerHeight]))];
}

#pragma mark - ACTIVITY INDICATOR FUNCTIONS
- (void) showActivityIndicator
{
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:NO];
    [self.tableView setUserInteractionEnabled:NO];
}

-(void) hideActivityIndicator
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
    [self.tableView setUserInteractionEnabled:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //return [DataStore instance].fbFriendsArray.count;
    return MAX(1,self.fbFriendsArray.count);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ProfileViewTableViewCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    ProfileViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ProfileViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSLog(@"Row count: %ld, %lu",(long)indexPath.row, (unsigned long)self.fbFriendsArray.count);
    
    if(self.fbFriendsArray <= 0)
    {
        [cell.nameLabel setText:@"No Friends :("];
        [cell setUserInteractionEnabled:NO];
    }else if (indexPath.row < self.fbFriendsArray.count){
        [cell setUserInteractionEnabled:YES];
        User *user = [self.fbFriendsArray objectAtIndex:indexPath.row];
        [cell.nameLabel setText:user.name];
        [[FriendsManager instance] getFriendProfilePictureWithID:[user objectForKey:UserFacebookID] withBlock:^(UIImage *image) {
            [cell.profilePicture setImage:[image imageScaledToFitSize:CGSizeMake(cell.frame.size.height, cell.frame.size.height)]];
        }];
    }
    [cell setColorScheme:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < self.fbFriendsArray.count && self.fbFriendsArray.count > 0)
    {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < self.fbFriendsArray.count)
    {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(IBAction)doneButtonPressed:(id)sender{
    NSLog(@"startGame");
    [self showLoadingAlertWithText:@"Adding Players..."];
    if([self.tableView indexPathsForSelectedRows].count == 0) {
        [self showAlertWithTitle:@"Huh, you didn't select anyone to add. Weird" andSummary:@""];
        
    } else if(([self.tableView indexPathsForSelectedRows].count + self.currentGame.players.count) > 10) {
        [self showAlertWithTitle:@"Wow someone is popular..." andSummary:@"The max players in a game is 10. Figure out who you like best."];
    } else {
        NSMutableArray* selectedFriends = [[NSMutableArray alloc] init];
        for(NSIndexPath * indexPath in [self.tableView indexPathsForSelectedRows])
        {
            [selectedFriends addObject:[self.fbFriendsArray objectAtIndex:indexPath.row]];
        }
        
        [[GameManager instance] addPlayers:selectedFriends toGame:self.currentGame withCallback:^(BOOL success) {
            [self dismissAlert];
            if(success) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self showAlertWithTitle:@"Error adding players. Try again" andSummary:@""];
            }
        }];
        
    }
}

#pragma mark - Notification Callbacks and Observer Initialization
- (void) newGameCreated:(BOOL)success game: (Game*)game info:(NSString *) info
{
    if(success)
    {
        [self dismissAlert];
        //Get game object from notification
        
        //add all the users to an array for a push notification
        NSMutableArray *nonUserPlayers = [[NSMutableArray alloc] init];
        for (User* user in game.players)
        {
            if(![user.objectId isEqualToString:[User currentUser].objectId])
            {
                [nonUserPlayers addObject:[NSString stringWithFormat:@"c%@", user.fbId]];
            }
        }
        
        //Send push notification to other players
        [PushUtils sendNewRoundPushForGame:game];
        
        //Pop back two viewcontrollers to main viewcontroller
        NSUInteger ownIndex = [self.navigationController.viewControllers indexOfObject:self];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:ownIndex - 2] animated:YES];
    } else
    {
        [self dismissAlert];
        [self showAlertWithTitle:@"Error!" andSummary:info];
    }
}


@end
