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
#import <math.h>
#import "Game.h"

@interface SelectGameTableViewController ()

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
    initialLoad = true;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newGamesAddedToDatabase:)
                                                 name:N_GamesDownloaded
                                               object:nil];
    
    [self refreshGames:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    //Recieve messages
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.messageClient = [appDelegate.client messageClient];
    self.messageClient.delegate = self;
    
    [self.tableView reloadData];
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
    
    if(initialLoad)
    {
        return 1;
    } else{
        return 3;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Make Variable size height
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //Make Variable size height
    if(initialLoad)
    {
        return 0;
    }
    else if(section == 0)
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
    if(initialLoad)
    {
        return 1;
    } else{
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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    SelectGameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SelectGameTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if([[UserGames instance] gameCount] <= 0 && indexPath.row == 0)
    {
        if(initialLoad)
        {
            cell.namesLabel.text = @"Loading games...";
        } else
        {
             cell.namesLabel.text = @"No Games Found.";
            
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }else if([[UserGames instance] gameCount] > 0)
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

        [cell.categoryLabel setText:[NSString stringWithFormat:@"Round %@: %@", currentRound[RoundNumber], currentRound[RoundCategory]]];

        [cell.namesLabel setText:[StringUtils buildTextStringForPlayersInGame:game.players fullName:NO]];
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
        cell.textLabel.text = @"Games You're The Judge";
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
    [[cell  layer] setCornerRadius:10.0f];
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
    [PFUser logOut];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate logoutSinchClient];
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
#pragma mark Game Download
- (void) newGamesAddedToDatabase:(NSNotification *)note {
    [self.tableView reloadData];
}

//Call back delegate for new images finished
- (void) didGetGamesDelegate:(BOOL)success info: (NSString *) info
{
    initialLoad = false;
    
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

- (void) dismissAlert {
    if (self.alertView && self.alertView.visible) {
        [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

-(void) showAlertWithTitle: (NSString *)title andSummary:(NSString *)summary
{
    [self dismissAlert];
    self.alertView = [[UIAlertView alloc]
                      initWithTitle:title message:summary delegate:self  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    // Display Alert Message
    [self.alertView show];
}

#pragma mark - SINMessageClientDelegate

- (void)messageClient:(id<SINMessageClient>)messageClient didReceiveIncomingMessage:(id<SINMessage>)message {
   
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground || [UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
        if([message.text isEqualToString:NewRound])
        {
            NSString *winner = [DataStore getFriendFirstNameWithID:[message.headers objectForKey:CompletedRoundWinningResponseFrom]];
            
            NSString* summary = [NSString stringWithFormat:@"New round starting: %@ won previous.", winner];
            UILocalNotification* notification = [[UILocalNotification alloc] init];
            notification.alertBody = summary;
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
        else if([message.text isEqualToString:NewGame])
        {
            PFQuery *getGame = [PFQuery queryWithClassName:GameClass];
            NSString* gameId = [message.headers objectForKey:ObjectID];
            [getGame includeKey:GameCurrentRound];
            [getGame getObjectInBackgroundWithId:gameId block:^(PFObject *object, NSError *error) {
                Game* game = (Game*)object;
                //Add the game
                [[UserGames instance] addGame:game];
                
                //Notify?
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:N_GamesDownloaded
                 object:self];
                
                //Build notification and send
                NSString* summary = [NSString stringWithFormat:@"You were added to a new game with: %@", [StringUtils buildTextStringForPlayersInGame:game.players fullName:YES]];
                UILocalNotification* notification = [[UILocalNotification alloc] init];
                notification.alertBody = summary;
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            }];
        }
    } else {
        // Update UI in-app
        if([message.text isEqualToString:NewRound])
        {
            NSString *winner = [DataStore getFriendFirstNameWithID:[message.headers objectForKey:CompletedRoundWinningResponseFrom]];
            
            NSString* summary = [NSString stringWithFormat:@"%@ won round %@ with: %@", winner, [message.headers objectForKey:CompletedRoundNumber], [message.headers objectForKey:CompletedRoundWinningResponse]];
            [self showAlertWithTitle:@"New Round Started" andSummary:summary];
        }
        else if([message.text isEqualToString:NewGame])
        {
            PFQuery *getGame = [PFQuery queryWithClassName:GameClass];
            [getGame includeKey:GameCurrentRound];
            NSLog(@"GameID: %@",[message.headers objectForKey:ObjectID]);
            NSString* gameId = [message.headers objectForKey:ObjectID];
            [getGame getObjectInBackgroundWithId:gameId block:^(PFObject *object, NSError *error) {
                Game* game = (Game*)object;
                //Add the game
                [[UserGames instance] addGame:game];
                
                //Build alert
                NSString *summary = [NSString stringWithFormat:@"First category is \"%@\" with %@", game.currentRound.category,[StringUtils buildTextStringForPlayersInGame:game.players fullName:YES]];
                [self showAlertWithTitle:@"You were added to a new game!" andSummary:summary];
                
                //Notify?
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:N_GamesDownloaded
                 object:self];
                
            }];
        }
    }
    
}

- (void)messageSent:(id<SINMessage>)message recipientId:(NSString *)recipientId {
    NSLog(@"messageSent: %@ to: %@", message, recipientId);
}

- (void)message:(id<SINMessage>)message shouldSendPushNotifications:(NSArray *)pushPairs {
    NSLog(@"Recipient not online. \
          Should notify recipient using push (not implemented in this demo app). \
          Please refer to the documentation for a comprehensive description.");
}

- (void)messageDelivered:(id<SINMessageDeliveryInfo>)info {
    NSLog(@"Message to %@ was successfully delivered", info.recipientId);
}

- (void)messageFailed:(id<SINMessage>)message info:(id<SINMessageFailureInfo>)failureInfo {
    NSLog(@"Failed delivering message to %@. Reason: %@", failureInfo.recipientId,
          [failureInfo.error description]);
}


@end
