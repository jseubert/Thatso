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

@interface PreviousRoundsTableViewController ()

@end

@implementation PreviousRoundsTableViewController

-(void)viewDidAppear:(BOOL)animated
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Recieve messages
    self.messageClient = [appDelegate.client messageClient];
    self.messageClient.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setBackgroundColor:[UIColor blueAppColor]];
    
    initialLoad = true;
    self.previousRounds = [[NSMutableArray alloc] init];
    
    // Create a re-usable NSDateFormatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MMM d, h:mm a"];
    
    
    //Back Button
    FratBarButtonItem *backButton= [[FratBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    // If we are using iOS 6+, put a pull to refresh control in the table
    if (NSClassFromString(@"UIRefreshControl") != Nil) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        
        
        refreshControl.attributedTitle = [StringUtils makeRefreshText:@"Pull to refresh"];
        [refreshControl addTarget:self action:@selector(refreshGames:) forControlEvents:UIControlEventValueChanged];
        [refreshControl setTintColor:[UIColor whiteColor]];
        
        self.refreshControl = refreshControl;

    }
    
    [self refreshGames:nil];
}

//Pull to refresh method
- (void) refreshGames:(UIRefreshControl *)refreshControl
{
    if (refreshControl) {
        [refreshControl setAttributedTitle:[StringUtils makeRefreshText:@"Refreshing data..."]];
        [refreshControl setEnabled:NO];
    }
    [Comms getPreviousRoundsInGame:self.currentGame forDelegate:self];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(initialLoad)
    {
        return 1;
    }else{
        return self.previousRounds.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(initialLoad){
        return UITableViewAutomaticDimension;
    } else{
        CompletedRound* round = [self.previousRounds objectAtIndex:indexPath.row];
        
        CGFloat width = tableView.frame.size.width
            - 10    //left padding
            - 10;   //padding on right
            
        //get the size of the label given the text
        CGSize topLabelSize = [CommentTableViewCell sizeWithFontAttribute:[UIFont defaultAppFontWithSize:16.0] constrainedToSize:(CGSizeMake(width, width)) withText:round.category];
        NSString *winner = [DataStore getFriendFirstNameWithID:round.winningResponseFrom];
        CGSize bottomeLabelSize = [CommentTableViewCell sizeWithFontAttribute:[UIFont defaultAppFontWithSize:14.0] constrainedToSize:(CGSizeMake(width, width)) withText:[NSString stringWithFormat:@"%@: %@", winner, round.winningResponse]];
        
        
        //1O padding on top and bottom
        return 10 + topLabelSize.height + 5 + bottomeLabelSize.height + 10;
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"PreviousCell";
    PreviousRoundsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[PreviousRoundsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if(initialLoad)
    {
        cell.namesLabel.text = @"Loading rounds...";
    } else if(self.previousRounds.count == 0){
        cell.namesLabel.text = @"No previous rounds...";
    } else{
        CompletedRound* round = [self.previousRounds objectAtIndex:indexPath.row];
        NSString *winner = [DataStore getFriendFirstNameWithID:round.winningResponseFrom];
        [cell.namesLabel setText:round.category];
        [cell.categoryLabel setText:[NSString stringWithFormat:@"%@: %@", winner, round.winningResponse]];
    }
    
    [cell setColorScheme:indexPath.row];
    [cell adjustLabels];
    
    return cell;
    
}

- (void) didGetPreviousRounds:(BOOL)success info: (NSString *) info
{
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
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:info
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
}

#pragma mark - SINMessageClientDelegate
#pragma mark - SINMessageClientDelegate

- (void)messageClient:(id<SINMessageClient>)messageClient didReceiveIncomingMessage:(id<SINMessage>)message {
    //In background
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
            PFQuery *getGames = [PFQuery queryWithClassName:GameClass];
            NSString* gameId = [message.headers objectForKey:ObjectID];
            [getGames getObjectInBackgroundWithId:gameId block:^(PFObject *object, NSError *error) {
                Game* game = (Game*)object;
                //Add the game
                [[[UserGames instance] games] addObject:game];
                
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
    }
    //UserActive on this screen
    else
    {
        if([message.text isEqualToString:NewRound])
        {
            NSString *winner = [DataStore getFriendFirstNameWithID:[message.headers objectForKey:CompletedRoundWinningResponseFrom]];
            
            NSString* summary = [NSString stringWithFormat:@"%@ won round %@ with: %@", winner, [message.headers objectForKey:CompletedRoundNumber], [message.headers objectForKey:CompletedRoundWinningResponse]];
            [self showAlertWithTitle:@"New Round Started" andSummary:summary];
        }
        else if([message.text isEqualToString:NewGame])
        {
            PFQuery *getGame = [PFQuery queryWithClassName:GameClass];
            NSLog(@"GameID: %@",[message.headers objectForKey:ObjectID]);
            NSString* gameId = [message.headers objectForKey:ObjectID];
            [getGame getObjectInBackgroundWithId:gameId block:^(PFObject *object, NSError *error) {
                Game* game = (Game*)object;
                //Add the game
                [[[UserGames instance] games] addObject:game];
                
                [game.currentRound fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    //Build alert
                    NSString *summary = [NSString stringWithFormat:@"First category is \"%@\" with %@", game.currentRound.category,[StringUtils buildTextStringForPlayersInGame:game.players fullName:YES]];
                    [self showAlertWithTitle:@"You were added to a new game!" andSummary:summary];
                }];
                
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

//Alert Views
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


@end
