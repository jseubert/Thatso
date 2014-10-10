//
//  GameViewControllerTableViewController.m
//  Thatso
//
//  Created by John A Seubert on 9/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "GameViewControllerTableViewController.h"
#import "ProfileViewTableViewCell.h"
#import "FratBarButtonItem.h"
#import "StringUtils.h"
#import "UIImage+Scaling.h"
#import "CommentTableViewCell.h"


@implementation GameViewControllerTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor blueAppColor];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    self.navigationController.title = @"Category";
    
    // Create a re-usable NSDateFormatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MMM d, h:mm a"];
    
    //Back Button
    FratBarButtonItem *newGameButton= [[FratBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = newGameButton;
    
    // If we are using iOS 6+, put a pull to refresh control in the table
    if (NSClassFromString(@"UIRefreshControl") != Nil) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        
        
        refreshControl.attributedTitle = [StringUtils makeRefreshText:@"Pull to refresh"];
        [refreshControl addTarget:self action:@selector(refreshGame:) forControlEvents:UIControlEventValueChanged];
        [refreshControl setTintColor:[UIColor whiteColor]];
        
        self.refreshControl = refreshControl;
        
    }

}

-(void)viewDidAppear:(BOOL)animated
{
    // Get any new Games
    [self refreshGame:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.currentGame.players count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentGame.players count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //44
     return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString *cellIdentifier = @"ProfileViewTableViewCell";
    ProfileViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ProfileViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSLog(@"Section: %ld", (long)section);
    //Populate name and picture
    [cell.nameLabel setText:[[DataStore getFriendWithId:[self.currentGame.players objectAtIndex:section]] objectForKey:@"name"]];
    UIImage *fbProfileImage = [[DataStore getFriendWithId:[self.currentGame.players objectAtIndex:section]] objectForKey:@"fbProfilePicture"];
    [cell.profilePicture setImage:[fbProfileImage imageScaledToFitSize:CGSizeMake(cell.frame.size.height, cell.frame.size.height)]];
    
    //set color
    [cell setColorScheme:section];
    
    return cell;
  
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"CommentTableViewCell";
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell.commentLabel setText:@"Comment"];
    return cell;
}

//Call back delegate for new images finished
- (void) commsDidGetUserComments{
    
    // Refresh the table data to show the new games
    [self.tableView reloadData];
    
    // Update the refresh control if we have one
    if (self.refreshControl) {
        NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [_dateFormatter stringFromDate:[NSDate date]]];
        [self.refreshControl setAttributedTitle:[StringUtils makeRefreshText:lastUpdated]];
        [self.refreshControl setTintColor:[UIColor whiteColor]];
        
        [self.refreshControl endRefreshing];
    }
}

//Pull to refresh method
- (void) refreshGame:(UIRefreshControl *)refreshControl
{
    if (refreshControl) {
        [refreshControl setAttributedTitle:[StringUtils makeRefreshText:@"Refreshing data..."]];
        [refreshControl setEnabled:NO];
    }
    [self commsDidGetUserComments];
    // Get any new Wall Images since the last update
    //[Comms getUsersGamesforDelegate:self];
}

@end
