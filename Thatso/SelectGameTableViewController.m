//
//  SelectGameTableViewController.m
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "SelectGameTableViewController.h"
#import "NewGameTableViewController.h"

@interface SelectGameTableViewController () <CommsDelegate>

@end

@implementation SelectGameTableViewController

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
    // Create a re-usable NSDateFormatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MMM d, h:mm a"];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"New Game" style:UIBarButtonItemStyleBordered target:self action:@selector(newGame:)];
    self.navigationItem.rightBarButtonItem = barButton;
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    
    // If we are using iOS 6+, put a pull to refresh control in the table
    if (NSClassFromString(@"UIRefreshControl") != Nil) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
        [refreshControl addTarget:self action:@selector(refreshGames:) forControlEvents:UIControlEventValueChanged];
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
    if([[UserGames instance].games count] <= 0)
    {
        return 30;
    }else
    {
        Game* game = [[UserGames instance].games objectAtIndex:indexPath.row];
        NSArray *players = game.players;
        return game.players.count * 30;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([[UserGames instance].games count] > 0)
    {
        return (int)[[UserGames instance].games count];
    }else
    {
        return 1;
    }
}


    /*
 NSString *title = [[NSString alloc] init];
 Game* game = [[UserGames instance].games objectAtIndex:indexPath.row];
 NSArray *players = game.players;
 for(int i; i < players.count;i ++)
 {
     NSString *name = [[[DataStore instance].fbFriends objectForKey:[players objectAtIndex:i]] objectForKey:@"name"];
     title = [title stringByAppendingString:name];
 }
 
 
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if([[UserGames instance].games count] <= 0)
    {
        [cell.textLabel setText:@"No Games Found"];
    }else
    {
        NSString *title = [[NSString alloc] init];
        Game* game = [[UserGames instance].games objectAtIndex:indexPath.row];
        NSArray *players = game.players;
        for(int i = 0; i < players.count;i ++)
        {
            NSString *name = [[[DataStore instance].fbFriends objectForKey:[players objectAtIndex:i]] objectForKey:@"name"];
            title = [title stringByAppendingString:[NSString stringWithFormat:@"%@\n", name]];
        }
        [cell.textLabel setText:title];
        cell.textLabel.numberOfLines = players.count;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return cell;
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
		[refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Refreshing data..."]];
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
		[self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:lastUpdated]];
		[self.refreshControl endRefreshing];
	}
}

//Notificaiton call backs
- (void) gamesDownloaded:(NSNotification *)notification {
	[self.tableView reloadData];
}

@end
