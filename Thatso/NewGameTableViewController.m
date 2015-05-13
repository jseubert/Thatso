//
//  NewGameTableViewController.m
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "NewGameTableViewController.h"
#import "NewGameDetailsViewController.h"
#import "FratBarButtonItem.h"
#import "ProfileViewTableViewCell.h"
#import "UIImage+Scaling.h"
#import "AppDelegate.h"
#import "StringUtils.h"

@interface NewGameTableViewController () < CreateGameDelegate>

@end

@implementation NewGameTableViewController


#pragma mark ViewController setup
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     *ViewController Preferences/Appearance
     */
    self.navigationItem.title = @"Players";

    self.fbFriendsArray = [[DataStore instance].fbFriends allValues];
    
    /*
     * Subview initializations
     */
    //Finish Game Button
    FratBarButtonItem *startButton  = [[FratBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = startButton;
    
    //Friends table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor blueAppColor]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
      self.tableView.allowsMultipleSelection = YES;
    [self.view addSubview: self.tableView];

    
   // [self showLoadingAlert];
    [self showActivityIndicator];
    [Comms getAllFacebookFriends:self];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.adView.delegate = self;
    canShowBanner = YES;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.tableView setFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - [self bannerHeight]))];
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
   
    NSLog(@"Row count: %ld, %lu",(long)indexPath.row, (unsigned long)[DataStore instance].fbFriends.count);
    
    if([DataStore instance].fbFriends.count <= 0)
    {
        [cell.nameLabel setText:@"No Friends :("];
        [cell setUserInteractionEnabled:NO];
    }else if (indexPath.row < self.fbFriendsArray.count){
        [cell setUserInteractionEnabled:YES];
        User *user = [self.fbFriendsArray objectAtIndex:indexPath.row];
        [cell.nameLabel setText:user.name];
        [DataStore getFriendProfilePictureWithID:[user objectForKey:UserFacebookID] withBlock:^(UIImage *image) {
            [cell.profilePicture setImage:[image imageScaledToFitSize:CGSizeMake(cell.frame.size.height, cell.frame.size.height)]];
        }];
    }
    [cell setColorScheme:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < self.fbFriendsArray.count && [DataStore instance].fbFriends.count > 0)
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
    [self showLoadingAlertWithText:@"Starting New Game..."];
    if([self.tableView indexPathsForSelectedRows].count < 2) {
        [self showAlertWithTitle:@"Woah! You trying to be super exclusive?" andSummary:@"You have to choose at least 2 other players"];

    } else if([self.tableView indexPathsForSelectedRows].count > 9) {
        [self showAlertWithTitle:@"Wow someone is popular..." andSummary:@"The max players in a game is 10. Figure out who you like best."];
    } else {
        NSMutableArray* selectedFriends = [[NSMutableArray alloc] init];
        for(NSIndexPath * indexPath in [self.tableView indexPathsForSelectedRows])
        {
            [selectedFriends addObject:[self.fbFriendsArray objectAtIndex:indexPath.row]];
        }
        
        
        [Comms startNewGameWithUsers:selectedFriends withName:self.gameName familyFriendly:self.familyFriendly forDelegate:self];

    }
}

- (void) newGameUploadedToServer:(BOOL)success game:(Game *)game info:(NSString *)info{
    [self dismissAlert];    
    if (success) {
        //Send out that a new game was added so other users can download it.
        NSMutableArray *nonUserPlayers = [[NSMutableArray alloc] init];
        for (User* user in game.players)
        {
            if(![user.objectId isEqualToString:[User currentUser].objectId])
            {
                [nonUserPlayers addObject:[NSString stringWithFormat:@"c%@", user.fbId]];
            }
        }
        
        //Send push notification to other players
        PFPush *push = [[PFPush alloc] init];
        NSDictionary *data = @{
                               @"alert" : [NSString stringWithFormat:@"%@ has added you to a game: %@", [User currentUser].first_name, game.gameName],
                               @"badge" : @"Increment",
                               @"sounds" : @"woop.caf"
                               };
    
        [push setChannels:nonUserPlayers];
        [push setData:data];
        [push sendPushInBackground];
    
        NSUInteger ownIndex = [self.navigationController.viewControllers indexOfObject:self];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:ownIndex - 2] animated:YES];
    }else{
        [self showAlertWithTitle:@"Error!" andSummary:info];
    }
}

- (void) didlogin:(BOOL)success info: (NSString *) info
{
    [self hideActivityIndicator];
    if (success) {
        self.fbFriendsArray = [[DataStore instance].fbFriends allValues];
        [self.tableView reloadData];
    }else{
        [self showAlertWithTitle:@"Error!" andSummary:info];
    }

}

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
@end
