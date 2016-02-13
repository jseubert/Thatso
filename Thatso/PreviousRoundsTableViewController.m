//
//  PreviousRoundsTableViewController.m
//  Thatso
//
//  Created by John A Seubert on 11/15/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "PreviousRoundsTableViewController.h"
#import "FratBarButtonItem.h"
#import "StringUtils.h"
#import "CommentTableViewCell.h"
#import "PreviousRoundsTableViewCell.h"
#import "AppDelegate.h"
#import "User.h"
#import "ScoreHorizontalHeaderScrollView.h"
#import "RoundManager.h"
#import "GameManager.h"
#import "AddPlayerViewController.h"
#import "PushUtils.h"

@interface PreviousRoundsTableViewController ()

@end

@implementation PreviousRoundsTableViewController

NSString * const ViewedPreviousRoundsScreen = @"ViewedPreviousRoundsScreen";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    initialLoad = true;
    self.previousRounds = [[NSMutableArray alloc] init];
    
    self.navigationItem.title = @"Details";
    
    //Back Button
    FratBarButtonItem *backButton= [[FratBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    self.headerView = [[ScoreHorizontalHeaderScrollView alloc] initWithGame:self.currentGame];
    [self.view addSubview:self.headerView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor blueAppColor]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview: self.tableView];
    
    //Add Activity indicator
    [self.view addSubview:self.activityIndicator];
    
    //Refresh indicator for tableview
    self.refreshControl  = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [StringUtils makeRefreshText:@"Pull to refresh"];
    [self.refreshControl  addTarget:self action:@selector(refreshGames) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl  setTintColor:[UIColor whiteColor]];
    [self.refreshControl  setBackgroundColor:[UIColor blueAppColor]];
    [self.tableView addSubview:self.refreshControl];
    
    [self refreshGames];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.adView.delegate = self;
    canShowBanner = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newRoundNotification:)
                                                 name:RoundManagerNewRoundStarted
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerAddedNotification:)
                                                 name:RoundManagerPlayerAdded
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerLeftNotification:)
                                                 name:RoundManagerPlayerLeft
                                               object:nil];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:ViewedPreviousRoundsScreen])
    {
        
        UIAlertView *newAlertView = [[UIAlertView alloc] initWithTitle:@"Here you can see all the past rounds in this game and check who has won the most rounds." message:nil delegate:nil cancelButtonTitle:@"Kewl" otherButtonTitles: nil];
        [newAlertView show];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ViewedPreviousRoundsScreen];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.headerView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 135)];
    [self.tableView setFrame:(CGRectMake(0, self.headerView.bottom, self.view.width, self.view.height - [self bannerHeight] - self.headerView.height))];
}

# pragma mark
# pragma NSNotification callbacks
-(void) newRoundNotification:(NSNotification *) notification {
    NSString * gameId = notification.userInfo[PushParameterGameId];
    if([self.currentGame.objectId isEqualToString: gameId]){
        [self showActivityIndicator];
        [self.currentGame fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [self.currentGame.currentRound fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [self refreshGames];
            }];
        }];
    }
}

-(void) playerLeftNotification:(NSNotification *) notification {
    NSString * gameId = notification.userInfo[PushParameterGameId];
    if([self.currentGame.objectId isEqualToString: gameId]){
        [self showActivityIndicator];
        [self.currentGame fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [self.currentGame.currentRound fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [self.headerView removeFromSuperview];
                self.headerView = [[ScoreHorizontalHeaderScrollView alloc] initWithGame:self.currentGame];
                [self.view addSubview:self.headerView];
                [self refreshGames];
            }];
        }];
    }
}

-(void) playerAddedNotification:(NSNotification *) notification {
    NSString * gameId = notification.userInfo[PushParameterGameId];
    if([self.currentGame.objectId isEqualToString: gameId]){
        [self showActivityIndicator];
        [self.currentGame fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [self.currentGame.currentRound fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [self.headerView removeFromSuperview];
                self.headerView = [[ScoreHorizontalHeaderScrollView alloc] initWithGame:self.currentGame];
                [self.view addSubview:self.headerView];
                [self refreshGames];
            }];
        }];
    }
}

//Pull to refresh method
- (void) refreshGames
{
    [self showActivityIndicator];
    [self.refreshControl setAttributedTitle:[StringUtils makeRefreshText:@"Refreshing data..."]];
    [self.refreshControl setEnabled:NO];
    [Comms getPreviousRoundsInGame:self.currentGame forDelegate:self];

}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(initialLoad)
    {
        return 1;
    }else{
        return self.previousRounds.count + 2;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(self.previousRounds.count == 0)
    {
        return 45;
    } else
    {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(initialLoad){
        return UITableViewAutomaticDimension;
    } else{
        if(indexPath.row == 0 || indexPath.row == 1) {
            return 45;
        }
        CompletedRound* round = [self.previousRounds objectAtIndex:indexPath.row - 2];
        
        CGFloat width = tableView.frame.size.width
            - 10    //left padding
            - 10;   //padding on right
            
        //get the size of the label given the text
        CGSize topLabelSize = [StringUtils sizeWithFontAttribute:[UIFont defaultAppFontWithSize:16.0] constrainedToSize:(CGSizeMake(width, width)) withText:round.category];
        NSString *winner = round.winningResponseFrom.first_name;
        CGSize bottomeLabelSize = [StringUtils sizeWithFontAttribute:[UIFont defaultAppFontWithSize:14.0] constrainedToSize:(CGSizeMake(width, width)) withText:[NSString stringWithFormat:@"%@: %@", winner, round.winningResponse]];
        
        
        //1O padding on top and bottom
        return 10 + topLabelSize.height + 5 + bottomeLabelSize.height + 10;
        
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *cellIdentifier = @"SectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(self.previousRounds.count == 0)
    {
        cell.textLabel.text = @"No Past Rounds";
    }

    cell.textLabel.font = [UIFont defaultAppFontWithSize:16];
    cell.backgroundColor = [UIColor blueAppColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        NSString *cellIdentifier = @"AddPlayerCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"+ Add Player to %@", self.currentGame.gameName];
        return cell;
        
    } else if(indexPath.row == 1) {
        NSString *cellIdentifier = @"RemovePlayerCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
         cell.textLabel.text = [NSString stringWithFormat:@"-  Leave %@", self.currentGame.gameName];
        return cell;
    } else {
        NSString *cellIdentifier = @"PreviousCell";
        PreviousRoundsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[PreviousRoundsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        if(initialLoad)
        {
            cell.namesLabel.text = @"Loading rounds...";
        } else{
            CompletedRound* round = [self.previousRounds objectAtIndex:indexPath.row - 2];
            NSString *winner = round.winningResponseFrom.first_name;
            [cell.namesLabel setText:round.category];
            [cell.categoryLabel setText:[NSString stringWithFormat:@"%@: %@", winner, round.winningResponse]];
        }
        
        [cell setColorScheme:indexPath.row];
        
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //add player
    if(indexPath.row == 0) {
        AddPlayerViewController *vc = [[AddPlayerViewController alloc] init];
        vc.currentGame = self.currentGame;
        [self.navigationController pushViewController:vc animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    //Leave game
    else if (indexPath.row == 1) {
        if(self.currentGame.players.count <= 3) {
            UIAlertView *newAlertView = [[UIAlertView alloc] initWithTitle:@"Hey don't be selfish. If you leave this game now, there won't be enough players." message:@"Maybe we'll add this feature later. Maybe." delegate:nil cancelButtonTitle:@"Sorry" otherButtonTitles:nil];
            [newAlertView show];
        } else if([[[User currentUser] objectForKey:UserFacebookID] isEqualToString:self.currentGame.currentRound[RoundJudge]]){
            UIAlertView *newAlertView = [[UIAlertView alloc] initWithTitle:@"Hey, you can't leave a game while you are the judge, wait for the next round." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [newAlertView show];
        } else {
            UIAlertView *newAlertView = [[UIAlertView alloc] initWithTitle:@"YO! You really want to bail on this game?" message:nil delegate:self cancelButtonTitle:@"Oops, no" otherButtonTitles:@"Yeppers", nil];
            newAlertView.tag = 1;
            [newAlertView show];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
}

- (void) didGetPreviousRounds:(BOOL)success info: (NSString *) info
{
    [self hideActivityIndicator];
    initialLoad = false;
    if(success)
    {
        
        self.previousRounds = [[PreviousRounds instance].previousRounds objectForKey:self.currentGame.objectId];
        // Update the refresh control if we have one
        if (self.refreshControl) {
            NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [_dateFormatter stringFromDate:[NSDate date]]];
            [self.refreshControl setAttributedTitle:[StringUtils makeRefreshText:lastUpdated]];
            [self.refreshControl setTintColor:[UIColor whiteColor]];
            
            [self.refreshControl endRefreshing];
        }
        // Refresh the table data to show the new games
        [self.tableView reloadData];
        
        //Set scores
        NSDictionary *scores = [[NSMutableDictionary alloc] init];
        for(User* player in self.currentGame.players)
        {
            [scores setValue:@0 forKey:player.fbId];
        }
        for(CompletedRound* round in self.previousRounds)
        {
            NSNumber *score = [scores objectForKey: round.winningResponseFrom.fbId];
            [scores setValue:[NSNumber numberWithInteger:([score intValue] + 1)] forKey:round.winningResponseFrom.fbId];
        }
        [self.headerView setScoresForPlayers:scores];
        
        
    }else{
        [self showAlertWithTitle:@"Error!" andSummary:info];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        if(buttonIndex == 1) {
            NSLog(@"Yeppers");
            [self showActivityIndicator];
            [[GameManager instance] leaveGame:self.currentGame withCallback:^(BOOL success) {
                if(success) {
                    //Pop back two viewcontrollers to main viewcontroller
                    NSUInteger ownIndex = [self.navigationController.viewControllers indexOfObject:self];
                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:ownIndex - 2] animated:YES];
                } else {
                    UIAlertView *newAlertView = [[UIAlertView alloc] initWithTitle:@"Huh, there was a problem leaving the game. Try again." message:nil delegate:self cancelButtonTitle:@"Oh Ok" otherButtonTitles: nil];
                    [newAlertView show];
                }
            }];
        } else {
            NSLog(@"No");
        }
    }
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
@end
