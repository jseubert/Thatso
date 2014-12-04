//
//  NewGameTableViewController.m
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "NewGameTableViewController.h"
#import "FratBarButtonItem.h"
#import "ProfileViewTableViewCell.h"
#import "UIImage+Scaling.h"
#import "AppDelegate.h"

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

-(void)viewDidAppear:(BOOL)animated
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Recieve messages
    self.messageClient = [appDelegate.client messageClient];
    self.messageClient.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor blueAppColor];
    [self.tableView setSeparatorColor:[UIColor clearColor]];

    
    //New Game Button
    FratBarButtonItem *startButton  = [[FratBarButtonItem alloc] initWithTitle:@"Start Game" style:UIBarButtonItemStyleBordered target:self action:@selector(startGame:)];
    self.navigationItem.rightBarButtonItem = startButton;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.frame = CGRectMake(self.view.frame.size.width/2 - 40, self.view.frame.size.height/2 -40, 80, 80);
    [self.view addSubview:self.activityIndicator];
    
    self.tableView.allowsMultipleSelection = YES;
}

-(void) enableUI: (BOOL)flag
{
    [self.view setUserInteractionEnabled:flag];
    [self.navigationItem.rightBarButtonItem setEnabled:flag];
    [self.navigationItem.leftBarButtonItem setEnabled:flag];
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
    }else if (indexPath.row < self.fbFriendsArray.count){
        PFUser *user = [self.fbFriendsArray objectAtIndex:indexPath.row];
        [cell.nameLabel setText:[DataStore getFriendFullNameWithID:[user objectForKey:UserFacebookID]]];
        [DataStore getFriendProfilePictureWithID:[user objectForKey:UserFacebookID] withBlock:^(UIImage *image) {
            [cell.profilePicture setImage:[image imageScaledToFitSize:CGSizeMake(cell.frame.size.height, cell.frame.size.height)]];
        }];
    }
    [cell setColorScheme:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < self.fbFriendsArray.count)
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

-(IBAction)startGame:(id)sender{
    NSLog(@"startGame");
    [self enableUI:NO];
   if([self.tableView indexPathsForSelectedRows].count < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not enough Friends Selected"
                                                        message:@"Must choose at least 2 other people."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
       [self enableUI:YES];
    } else {
        NSMutableArray* selectedFriends = [[NSMutableArray alloc] init];
        for(NSIndexPath * indexPath in [self.tableView indexPathsForSelectedRows])
        {
            NSLog(@"addingFreind: %ld", (long)indexPath.row);
            [selectedFriends addObject:[[self.fbFriendsArray objectAtIndex:indexPath.row] objectForKey:UserFacebookID]];
        }
        [self.activityIndicator startAnimating];
        [Comms startNewGameWithUsers:selectedFriends forDelegate:self];

    }
        
    
    
}

- (void) newGameUploadedToServer:(BOOL)success info:(NSString *)info{
    NSLog(@"newGameUploadedToServer: %d", success);
    [self enableUI:YES];
    [self.activityIndicator stopAnimating];
    if (success) {
        [self.navigationController popViewControllerAnimated:YES];
    
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

- (void)messageClient:(id<SINMessageClient>)messageClient didReceiveIncomingMessage:(id<SINMessage>)message {
    
    NSString *winner = [DataStore getFriendFirstNameWithID:[message.headers objectForKey:@"from"]];
    
    if([message.text isEqualToString:@"NewRound"])
    {
        NSString* summary = [NSString stringWithFormat:@"New round starting: %@ won previous.", winner];
        UILocalNotification* notification = [[UILocalNotification alloc] init];
        notification.alertBody = summary;
        /*
         if([[UserGames instance] isGameActive:self.currentGame.objectId])
         {
         notification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
         [[UserGames instance] markGame:self.currentGame.objectId active:NO];
         } else{
         notification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
         }
         */
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
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
