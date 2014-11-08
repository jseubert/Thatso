//
//  SelectGameTableViewController.m
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "SelectGameTableViewController.h"
#import "NewGameTableViewController.h"
#import "GameViewControllerTableViewController.h"
#import "SelectGameTableViewCell.h"
#import "FratBarButtonItem.h"
#import "StringUtils.h"
#import <math.h>

@interface SelectGameTableViewController () <CommsDelegate>

@end

@implementation SelectGameTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        initialLoad = true;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor blueAppColor];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationItem.title = @"Games";
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"mplus-1c-regular" size:50],
      NSFontAttributeName, nil]];
    
    // Create a re-usable NSDateFormatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MMM d, h:mm a"];
    
    //Back button - needed for pushed view controllers
    FratBarButtonItem *backButton= [[FratBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    
    //New Game Button
    FratBarButtonItem *newGameButton= [[FratBarButtonItem alloc] initWithTitle:@"New Game" style:UIBarButtonItemStyleBordered target:self action:@selector(newGame:)];
    self.navigationItem.rightBarButtonItem = newGameButton;
    
    //Logout Button
    FratBarButtonItem *logoutButton = [[FratBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    
    
    
    // If we are using iOS 6+, put a pull to refresh control in the table
    if (NSClassFromString(@"UIRefreshControl") != Nil) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        
        
        refreshControl.attributedTitle = [StringUtils makeRefreshText:@"Pull to refresh"];
        [refreshControl addTarget:self action:@selector(refreshGames:) forControlEvents:UIControlEventValueChanged];
        [refreshControl setTintColor:[UIColor whiteColor]];
    
        self.refreshControl = refreshControl;
        
    }
    
    // Listen for image downloads so that we can refresh the image wall
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gamesDownloaded:)
                                                 name:N_GamesDownloaded
                                               object:nil];
    
    

}

-(void)viewDidAppear:(BOOL)animated
{
    // Get any new Games
	[self refreshGames:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if([[UserGames instance].games count] > 0)
    {
        return (int)[[UserGames instance].games count];
    }else
    {
        return roundf(tableView.frame.size.height/60);
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    SelectGameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SelectGameTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if([[UserGames instance].games count] <= 0 && indexPath.row == 0)
    {
        if(initialLoad)
        {
            cell.namesLabel.text = @"Loading games...";
        } else
        {
             cell.namesLabel.text = @"No Games Found.";
        }

    }else if([[UserGames instance].games count] > 0)
    {
     
        Game* game = [[UserGames instance].games objectAtIndex:indexPath.row];
        NSMutableArray *players = game.players;
        NSString *title = [[NSString alloc] init];
        
        NSString *lastName = @"";
        for(int i = 0; i < players.count;i ++)
        {
            //Don't add your own name
            NSLog(@"Current:%@ User: %@",[players objectAtIndex:i], [[PFUser currentUser] objectForKey:@"fbId"] );
            if(![((NSString *)[players objectAtIndex:i]) isEqualToString:(NSString *)[[PFUser currentUser] objectForKey:@"fbId"]])
            {
                if([lastName length] != 0)
                {
                    title = [title stringByAppendingString:[NSString stringWithFormat:@"%@, ", lastName]];
                }
                lastName = [[[DataStore instance].fbFriends objectForKey:[players objectAtIndex:i]] objectForKey:@"first_name"];

            
            }
        }
        if(players.count == 2)
        {
            title = [title stringByAppendingString:[NSString stringWithFormat:@"%@", lastName]];
        } else
        {
             title = [title stringByAppendingString:[NSString stringWithFormat:@"and %@", lastName]];
        }
        [cell.namesLabel setText:title];
        
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [cell.categoryLabel setText:@"Category"];
    }
    
    [cell setColorScheme:indexPath.row];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GameViewControllerTableViewController *vc = [[GameViewControllerTableViewController alloc] init];
    vc.currentGame = [[[UserGames instance].games objectAtIndex:indexPath.row] copyWithZone:NULL];
    [self.navigationController pushViewController:vc animated:YES];
}


-(IBAction)logout:(id)sender{
    NSLog(@"Logout");
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)newGame:(id)sender{
    NSLog(@"newGame");
    // Seque to the Image Wall
    NewGameTableViewController *vc = [[NewGameTableViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


//Pull to refresh method
- (void) refreshGames:(UIRefreshControl *)refreshControl
{
	if (refreshControl) {
		[refreshControl setAttributedTitle:[StringUtils makeRefreshText:@"Refreshing data..."]];
		[refreshControl setEnabled:NO];
	}
    
	// Get any new Wall Images since the last update
	[Comms getUsersGamesforDelegate:self];
}

//Call back delegate for new images finished
- (void) commsDidGetUserGames{

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

//Notificaiton call backs
- (void) gamesDownloaded:(NSNotification *)notification {
    initialLoad = false;
	[self.tableView reloadData];
}

@end
