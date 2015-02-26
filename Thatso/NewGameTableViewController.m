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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.fbFriendsArray = [[DataStore instance].fbFriends allValues];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor blueAppColor];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    self.navigationItem.title = @"Players";

    
    //New Game Button
    FratBarButtonItem *startButton  = [[FratBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(nextPressed:)];
    self.navigationItem.rightBarButtonItem = startButton;
    self.tableView.allowsMultipleSelection = YES;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.tableView setFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))];
    [self.tableView reloadData];
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

-(IBAction)nextPressed:(id)sender{
    NSLog(@"startGame");
    [self showLoadingAlertWithText:@"Starting New Game..."];
    if([self.tableView indexPathsForSelectedRows].count < 1) {
        [self showAlertWithTitle:@"Not enough Friends Selected" andSummary:@"Must choose at least 2 other people."];

    } else {
        NSMutableArray* selectedFriends = [[NSMutableArray alloc] init];
        for(NSIndexPath * indexPath in [self.tableView indexPathsForSelectedRows])
        {
            NSLog(@"addingFreind: %ld", (long)indexPath.row);
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
                [nonUserPlayers addObject:user.fbId];
            }
        }
    
        NSUInteger ownIndex = [self.navigationController.viewControllers indexOfObject:self];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:ownIndex - 2] animated:YES];
    }else{
        [self showAlertWithTitle:@"Error!" andSummary:info];
    }
}
@end
