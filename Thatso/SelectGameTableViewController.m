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
#import "AppDelegate.h"
#import "UserGames.h"
#import "NewGameDetailsViewController.h"
#import <math.h>
#import "Game.h"
#import "CommentTableViewCell.h"

@interface SelectGameTableViewController ()

@end

@implementation SelectGameTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blueAppColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationItem.title = @"Games";

    //self.navigationController.navigationBar.translucent = NO;
   
    [self.navigationController.navigationBar  setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                       [UIFont defaultAppFontWithSize:21.0], NSFontAttributeName, nil]];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor blueAppColor]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview: self.tableView];
    
    //Back button - needed for pushed view controllers
    FratBarButtonItem *backButton= [[FratBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    
    //New Game Button
    FratBarButtonItem *newGameButton= [[FratBarButtonItem alloc] initWithTitle:@"New Game" style:UIBarButtonItemStyleBordered target:self action:@selector(newGame:)];
    self.navigationItem.rightBarButtonItem = newGameButton;
    
    //Logout Button
    FratBarButtonItem *logoutButton = [[FratBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    
    [self.view addSubview:self.activityIndicator];
    
    // If we are using iOS 6+, put a pull to refresh control in the table
    if (NSClassFromString(@"UIRefreshControl") != Nil) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        
        
        refreshControl.attributedTitle = [StringUtils makeRefreshText:@"Pull to refresh"];
        [refreshControl addTarget:self action:@selector(refreshGames:) forControlEvents:UIControlEventValueChanged];
        [refreshControl setTintColor:[UIColor whiteColor]];
        [refreshControl setBackgroundColor:[UIColor blueAppColor]];
    
        self.refreshControl = refreshControl;
        [self.tableView addSubview:self.refreshControl];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newGamesAddedToDatabase:)
                                                 name:N_GamesDownloaded
                                               object:nil];
    
    [self.tableView setHidden:YES];
    
    [self.tableView setShowsVerticalScrollIndicator:NO];
    
   /// [self refreshGames:nil];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.tableView setFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    [self refreshGames:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Make Variable size height
    Game* game;
    if(indexPath.section == 0)
    {
        game = [[[UserGames instance].games objectForKey:@"Judge"] objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1)
    {
        game = [[[UserGames instance].games objectForKey:@"CommentNeeded"] objectAtIndex:indexPath.row];
    } else if (indexPath.section == 2)
    {
        game = [[[UserGames instance].games objectForKey:@"Completed"] objectAtIndex:indexPath.row];
    }
    Round *currentRound = game.currentRound;
    
    CGSize categoryHeight = [CommentTableViewCell sizeWithFontAttribute:[UIFont defaultAppFontWithSize:14.0] constrainedToSize:(CGSizeMake(self.tableView.frame.size.width -20, self.tableView.frame.size.width -20)) withText:currentRound.category];
    int height =    5 +
                    20 + //roundlabel
                    5 +
                    40 + //profile images height
                    20 + //name label
                    categoryHeight.height +
                    5 + 2;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //Make Variable size height
    if(section == 0)
    {
        if([[UserGames instance] gameCount] == 0) {
            return 42;
        } else
        {
            return ([[[UserGames instance].games objectForKey:@"Judge"] count] == 0) ? 0 : 40;
        }
    } else if (section == 1)
    {
        return ([[[UserGames instance].games objectForKey:@"CommentNeeded"] count] == 0) ? 0 : 40;
    } else if (section == 2)
    {
        return ([[[UserGames instance].games objectForKey:@"Completed"] count] == 0) ? 0 : 40;
    } else
    {
        return 0;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        if(section == 0)
        {
            return [[[UserGames instance].games objectForKey:@"Judge"] count];
        } else if (section == 1)
        {
            return [[[UserGames instance].games objectForKey:@"CommentNeeded"] count];
        } else if (section == 2)
        {
            return [[[UserGames instance].games objectForKey:@"Completed"] count];
        } else
        {
            return 0;
        }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    SelectGameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SelectGameTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if([[UserGames instance] gameCount] > 0)
    {
        
        Game* game;
        if(indexPath.section == 0)
        {
            game = [[[UserGames instance].games objectForKey:@"Judge"] objectAtIndex:indexPath.row];
        } else if (indexPath.section == 1)
        {
            game = [[[UserGames instance].games objectForKey:@"CommentNeeded"] objectAtIndex:indexPath.row];
        } else if (indexPath.section == 2)
        {
            game = [[[UserGames instance].games objectForKey:@"Completed"] objectAtIndex:indexPath.row];
        }
        Round *currentRound = game.currentRound;
        
        CGSize categoryHeight = [CommentTableViewCell sizeWithFontAttribute:[UIFont defaultAppFontWithSize:14.0] constrainedToSize:(CGSizeMake(self.tableView.frame.size.width -20, self.tableView.frame.size.width -20)) withText:currentRound.category];
        int height =    5 +
        20 + //roundlabel
        5 +
        40 + //profile images height
        20 + //name label
        categoryHeight.height +
        5 + 2;
        
        UIView *viewLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, height)];
        viewLeft.backgroundColor = [UIColor blueAppColor];
        //[cell.contentView addSubview:viewLeft];
        
        
        UIView *viewRight = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 5, 0, 5, height)];
        viewRight.backgroundColor = [UIColor blueAppColor];
      //  [cell.contentView addSubview:viewRight];
        
        [cell setGame:game andRound:currentRound];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
    
    [cell setColorScheme:indexPath.row];
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
       
    NSString *cellIdentifier = @"SectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(section == 0)
    {
        if([[UserGames instance] gameCount] == 0) {
            cell.textLabel.text = @"No Games Found";
        } else
        {
            cell.textLabel.text = @"Games You're The Judge";
        }
    } else if (section == 1)
    {
        cell.textLabel.text = @"Games You Need To Add A Response";
    } else if (section ==2)
    {
        cell.textLabel.text = @"Games Waiting For Judge";
    }
    
    cell.textLabel.font = [UIFont defaultAppFontWithSize:16];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor pinkAppColor];
    [[cell  layer] setBorderWidth:2.0f];
    [[cell  layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[cell  layer] setCornerRadius:5.0f];
    [cell setClipsToBounds:YES];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([UserGames instance].games != nil && [UserGames instance].games.count > 0)
    {
        GameViewControllerTableViewController *vc = [[GameViewControllerTableViewController alloc] init];
        Game* game;
        if(indexPath.section == 0)
        {
            game = [[[UserGames instance].games objectForKey:@"Judge"] objectAtIndex:indexPath.row];
        } else if (indexPath.section == 1)
        {
            game = [[[UserGames instance].games objectForKey:@"CommentNeeded"] objectAtIndex:indexPath.row];
        } else if (indexPath.section == 2)
        {
            game = [[[UserGames instance].games objectForKey:@"Completed"] objectAtIndex:indexPath.row];
        }
        [game.currentRound fetchIfNeeded];
        vc.currentGame = game;
        
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}


-(IBAction)logout:(id)sender{
    NSLog(@"Logout");
    [User logOut];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate logoutSinchClient];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)newGame:(id)sender{
    NSLog(@"newGame");
    // Seque to the Image Wall
    NewGameDetailsViewController *vc = [[NewGameDetailsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


//Pull to refresh method
- (void) refreshGames:(UIRefreshControl *)refreshControl
{
    [self showActivityIndicator];
	if (refreshControl) {
		[refreshControl setAttributedTitle:[StringUtils makeRefreshText:@"Refreshing data..."]];
		[refreshControl setEnabled:NO];
	}
    
	// Get any new Wall Images since the last update
	[Comms getUsersGamesforDelegate:self];
}
#pragma mark Game Download
- (void) newGamesAddedToDatabase:(NSNotification *)note {
    [self.tableView reloadData];
}

//Call back delegate for new images finished
- (void) didGetGamesDelegate:(BOOL)success info: (NSString *) info
{
    [self hideActivityIndicator];
     [self.tableView setHidden:NO];
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
