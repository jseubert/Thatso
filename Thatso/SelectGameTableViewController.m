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
#import <Crashlytics/Crashlytics.h>

@interface SelectGameTableViewController ()

@end

NSString * const ViewedSelectGameScreen = @"ViewedSelectGameScreen";

@implementation SelectGameTableViewController

#pragma mark ViewController setup
- (void)viewDidLoad
{
    [super viewDidLoad];

    
    /*
     *ViewController Preferences/Appearance
     */
    [self.view setBackgroundColor:[UIColor blueAppColor]];
    self.navigationItem.title = @"Games";
   
    /*
     * Subview initializations
     */
    //Back button - needed for pushed view controllers
    FratBarButtonItem *backButton= [[FratBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    
    //New Game Button
    FratBarButtonItem *newGameButton= [[FratBarButtonItem alloc] initWithTitle:@"New Game" style:UIBarButtonItemStyleBordered target:self action:@selector(newGameButtonPressed:)];
    self.navigationItem.rightBarButtonItem = newGameButton;
    
    //Logout Button
    FratBarButtonItem *logoutButton = [[FratBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonPressed:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    
    //Main TableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor blueAppColor]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setHidden:YES];
    [self.view addSubview: self.tableView];
    
    //Empty Table View
    self.emptyTableView = [[UITextView alloc] initWithFrame:CGRectZero];
    [self.emptyTableView setText: @"No Games Found. Press \"New Game\"!"];
    [self.emptyTableView setFont:[UIFont defaultAppFontWithSize:20.0f]];
    [self.emptyTableView setTextColor:[UIColor whiteColor]];
    [self.emptyTableView setBackgroundColor:[UIColor clearColor]];
    [self.emptyTableView setTextAlignment:NSTextAlignmentCenter];
    [self.emptyTableView setSelectable:NO];
    
    //Add Activity indicator
    [self.view addSubview:self.activityIndicator];
    
    //Refresh indicator for tableview
    self.refreshControl  = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [StringUtils makeRefreshText:@"Pull to refresh"];
    [self.refreshControl  addTarget:self action:@selector(refreshGames) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl  setTintColor:[UIColor whiteColor]];
    [self.refreshControl  setBackgroundColor:[UIColor blueAppColor]];
    [self.tableView addSubview:self.refreshControl];
    
    //Tutorial Section - show tutorial screen if this is the first time the user has seen this screen
    if(![[NSUserDefaults standardUserDefaults] boolForKey:ViewedSelectGameScreen])
    {
        
        UIAlertView *newAlertView = [[UIAlertView alloc] initWithTitle:@"Awesome! This is the \"Games\" Screen. Here you can see all the games you are a part of. They are sorted by games you are the judge of and need to pick an answer, games you need to add a response to for the judge to pick, and games you have answered and are waiting on the judge to pick. Press \"New Game\" to create a game with your friends!" message:nil delegate:nil cancelButtonTitle:@"Kewl" otherButtonTitles: nil];
        [newAlertView show];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ViewedSelectGameScreen];
    }
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.tableView setFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-[self bannerHeight]))];
}

-(void)viewWillAppear:(BOOL)animated
{
    /*
     *Setup Ad support for this view controller
     */
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.adView.delegate = self;
    canShowBanner = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshGames];
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
    
    CGSize categoryHeight = [StringUtils sizeWithFontAttribute:[UIFont defaultAppFontWithSize:14.0] constrainedToSize:(CGSizeMake(self.tableView.frame.size.width -20, self.tableView.frame.size.width -20)) withText:currentRound.category];
    int height =    5 + //padding
                    20 + //roundlabel
                    5 + //padding
                    40 + //profile images height
                    20 + //name label
                    categoryHeight.height + //category label height
                    5 + 2; //padding + shadow
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //Make Variable size height
    if(section == 0)
    {
        return ([[[UserGames instance].games objectForKey:@"Judge"] count] == 0) ? 0 : 40;
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
        cell.textLabel.text = @"Your Turn to Pick";
        cell.backgroundColor = [UIColor lightBlueAppColor];
    } else if (section == 1)
    {
        cell.textLabel.text = @"Add Your Response";
        cell.backgroundColor = [UIColor blueAppColor];
    } else if (section ==2)
    {
        cell.textLabel.text = @"Waiting On Judge";
        cell.backgroundColor = [UIColor pinkAppColor];
    }
    
    cell.textLabel.font = [UIFont defaultAppFontWithSize:16];
    cell.textLabel.textColor = [UIColor whiteColor];
    
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

#pragma mark navigation bar button actions
-(IBAction)logoutButtonPressed:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate logoutSinchClient];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.channels = [NSArray array];
    [currentInstallation saveInBackground];
    [User logOut];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)newGameButtonPressed:(id)sender{
    NewGameDetailsViewController *vc = [[NewGameDetailsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


//Pull to refresh method
- (void) refreshGames
{
    [self showActivityIndicator];
    [self.refreshControl setAttributedTitle:[StringUtils makeRefreshText:@"Refreshing data..."]];
    [self.refreshControl  setEnabled:NO];
	[Comms getUsersGamesforDelegate:self];
}

#pragma mark Game Download
//Call back delegate for new images finished
- (void) didGetGamesDelegate:(BOOL)success info: (NSString *) info
{
    [self hideActivityIndicator];
     [self.tableView setHidden:NO];
	// Refresh the table data to show the new games
	[self.tableView reloadData];
    
    // Update the refresh control if we have one
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [_dateFormatter stringFromDate:[NSDate date]]];
    [self.refreshControl setAttributedTitle:[StringUtils makeRefreshText:lastUpdated]];
    [self.refreshControl setTintColor:[UIColor whiteColor]];
    [self.refreshControl endRefreshing];
    
    //Set background view for table view
    if(success) {
        if([[UserGames instance] gameCount] > 0)
        {
            [self.tableView setBackgroundView:nil];
        }else{
            [self.emptyTableView setText: @"No Games Found. Press \"New Game\"!"];
            [self.tableView setBackgroundView:self.emptyTableView];
        }
    } else{
        [self.emptyTableView setText:@"Error loading games\nPull to try again"];
        [self.tableView setBackgroundView:self.emptyTableView];
        [self showAlertWithTitle:@"Error loading gamesr!" andSummary:@"Pull to try again"];
    }
}

#pragma activity indicators
- (void) showActivityIndicator
{
    [super showActivityIndicator];
    [self.tableView setUserInteractionEnabled:NO];
}

-(void) hideActivityIndicator
{
    [super hideActivityIndicator];
    [self.tableView setUserInteractionEnabled:YES];
}

@end
