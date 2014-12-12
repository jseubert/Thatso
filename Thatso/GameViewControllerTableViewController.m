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
#import "PreviousRoundsTableViewController.h"
#import "AppDelegate.h"

@implementation GameViewControllerTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.comments = [[NSMutableArray alloc] init];
        self.votedForComments = [[NSMutableArray alloc] init];
    }
    return self;
}


-(BOOL) isJudge
{
    return [[[PFUser currentUser] objectForKey:UserFacebookID] isEqualToString:self.currentRound[RoundJudge]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self refreshGame:nil];
    [[UserGames instance] markGame:self.currentGame.objectId active:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Recieve messages
    self.messageClient = [appDelegate.client messageClient];
    self.messageClient.delegate = self;
    
    //self.navigationController.title = @"Category";
    [self.view setBackgroundColor:[UIColor blueAppColor]];
    //setup Subviews
    self.headerView = [[GameHeaderView alloc] initWithFrame:CGRectMake(0,
                                                                self.navigationController.navigationBar.frame.size.height + 20 ,
                                                                self.view.bounds.size.width,
                                                                ProfileViewTableViewCellHeight)];
    [self setupHeader];
    [self.view addSubview:self.headerView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                   self.headerView.frame.size.height + self.headerView.frame.origin.y,
                                                                   self.view.bounds.size.width,
                                                                   self.view.bounds.size.height - self.headerView.frame.size.height - self.headerView.frame.origin.y)];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.tableView.backgroundColor = [UIColor blueAppColor];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
    
    CGRect viewBounds = [[self view] bounds];
    CGRect frame = CGRectMake(0.0f,
                              viewBounds.size.height - PHFComposeBarViewInitialHeight,
                              viewBounds.size.width,
                              PHFComposeBarViewInitialHeight);
    
    
    self.composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
    [self.composeBarView  setMaxCharCount:140];
    [self.composeBarView  setMaxLinesCount:5];
    [self.composeBarView  setPlaceholder:@"Enter Response"];
    [self.composeBarView  setDelegate:self];
    [self.composeBarView setButtonTintColor:[UIColor pinkAppColor]];
    [self.composeBarView setButtonTitle:@"ThatSo"];
    [self.composeBarView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.composeBarView];
    
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [self.singleTap setNumberOfTapsRequired:1];
    [self.singleTap setNumberOfTouchesRequired:1];

    
    // Create a re-usable NSDateFormatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MMM d, h:mm a"];
    
    //Back Button
    FratBarButtonItem *newGameButton= [[FratBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = newGameButton;
    
    //New Game Button
    FratBarButtonItem *previousGames= [[FratBarButtonItem alloc] initWithTitle:@"Previous Games" style:UIBarButtonItemStyleBordered target:self action:@selector(previousGames:)];
    self.navigationItem.rightBarButtonItem = previousGames;
    
    // If we are using iOS 6+, put a pull to refresh control in the table
    if (NSClassFromString(@"UIRefreshControl") != Nil) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        
        
        self.refreshControl.attributedTitle = [StringUtils makeRefreshText:@"Pull to refresh"];
        [self.refreshControl addTarget:self action:@selector(refreshGame:) forControlEvents:UIControlEventValueChanged];
        [self.refreshControl setTintColor:[UIColor whiteColor]];
        
        [self.tableView addSubview:self.refreshControl];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:@"UIKeyboardWillShowNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:@"UIKeyboardDidHideNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:@"UIKeyboardWillHideNotification"
                                               object:nil];
    
    //Remove yourself from the game's players
    
    nonUserPlayers = [[NSMutableArray alloc] initWithArray:self.currentGame.players];
    [nonUserPlayers removeObject:[[PFUser currentUser] objectForKey:UserFacebookID]];
    
    [self refreshGame:nil];

}

-(void) setupHeader
{
    self.currentRound = self.currentGame.currentRound;

    [self.headerView.roundLabel setText:[NSString stringWithFormat:@"Round %@",self.currentRound.roundNumber]];
    [self.headerView.caregoryLabel setText:[NSString stringWithFormat:@"%@",self.currentRound.category]];
    [DataStore getFriendProfilePictureWithID:self.currentRound.subject withBlock:^(UIImage * image) {
        [self.headerView.profilePicture setImage:image];
    }];
    [self layoutSubviews];

}

-(void)layoutSubviews
{
    
    self.headerView.frame = CGRectMake(0,
                                       self.navigationController.navigationBar.frame.size.height + 20 ,
                                       self.view.bounds.size.width ,
                                       [self.headerView heightGivenWidth:self.view.bounds.size.width + 10] );
    [self.headerView layoutSubviews];
    if([self isJudge])
    {
        [self.composeBarView setHidden:YES];
        self.tableView.frame = CGRectMake(0,
                                          self.headerView.frame.size.height + self.headerView.frame.origin.y,
                                          self.view.bounds.size.width,
                                          self.view.bounds.size.height - self.headerView.frame.size.height - self.headerView.frame.origin.y);
    }else{
        [self.composeBarView setHidden:NO];
        self.tableView.frame = CGRectMake(0,
                                          self.headerView.frame.size.height + self.headerView.frame.origin.y,
                                          self.view.bounds.size.width,
                                          self.view.bounds.size.height - self.headerView.frame.size.height - self.headerView.frame.origin.y - (self.view.bounds.size.height - self.composeBarView.frame.origin.y));
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)previousGames:(id)sender{
    // Seque to the Image Wall
    PreviousRoundsTableViewController *vc = [[PreviousRoundsTableViewController alloc] init];
    vc.currentGame = self.currentGame;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment* comment = [self.comments objectAtIndex:indexPath.row];
    CGFloat width = tableView.frame.size.width
    - 10    //left padding
    - CommentTableViewCellIconSize
    - 10    //padding between icon and text
    - 10;   //padding on right
    
    //get the size of the label given the text
    CGSize labelSize;
    if([comment.from isEqualToString:[[PFUser currentUser] objectForKey:UserFacebookID]])
    {
        labelSize = [CommentTableViewCell sizeWithFontAttribute:[UIFont defaultAppFontWithSize:16.0] constrainedToSize:(CGSizeMake(width, width)) withText:[NSString stringWithFormat:@"(Your Response) %@",comment.response]];
        
    } else
    {
        labelSize = [CommentTableViewCell sizeWithFontAttribute:[UIFont defaultAppFontWithSize:16.0] constrainedToSize:(CGSizeMake(width, width)) withText:comment.response];        
    }
    //1O padding on top and bottom
    return 10 + labelSize.height + 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ProfileViewTableViewCellHeight;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString *cellIdentifier = @"ProfileViewTableViewCell";
    ProfileViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ProfileViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if([self isJudge])
    {
        [cell.nameLabel setText:[NSString stringWithFormat:@"You pick the best answer"]];
     
    } else{
        [cell.nameLabel setText:[NSString stringWithFormat:@"%@ picks the best answer",[DataStore getFriendFirstNameWithID:self.currentRound.judge]]];
    }
    
    [DataStore getFriendProfilePictureWithID:self.currentRound.judge withBlock:^(UIImage *image) {
        [cell.profilePicture setImage:[image imageScaledToFitSize:CGSizeMake(cell.frame.size.height, cell.frame.size.height)]];
    }];
    
    //set color
    [cell setColorScheme:4];
    
    return cell;
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self commentTableViewCell:tableView cellForRowAtIndexPath:indexPath];
}

-(CommentTableViewCell *) commentTableViewCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *commentCellIdentifier = @"CommentCellIdentifier";
    
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
    if (cell == nil) {
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentCellIdentifier];
    }
    Comment* comment = [self.comments objectAtIndex:indexPath.row];
    if([comment.from isEqualToString:[[PFUser currentUser] objectForKey:UserFacebookID]])
    {
        [cell setCommentLabelText:[NSString stringWithFormat:@"(Your Response) %@",comment.response]];
    } else
    {
        [cell setCommentLabelText:comment.response];
    }
    if([self isJudge])
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }else
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didSelectRowAtIndexPath");
    if([self isJudge])
    {
        Comment* winningComment = [self.comments objectAtIndex:indexPath.row];
        NSString *title = [NSString stringWithFormat:@"%@'s comment wins!", [DataStore getFriendFirstNameWithID:winningComment[@"from"]]];
        NSString *summary = [NSString stringWithFormat:@"Click OK to start the next round!"];
        
        
        [self showAlertWithTitle:title andSummary:summary];
        
        //Start next round
        [Comms finishRound:self.currentRound inGame:self.currentGame withWinningComment:winningComment andOtherComments:self.comments forDelegate:self];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 1)
    {
      //Do something
        [self refreshGame:nil];
    }
}



#pragma Submitting getting comments
//Call back delegate for comments Downloade

//Pull to refresh method
- (void) refreshGame:(UIRefreshControl *)refreshControl
{
    if (self.refreshControl) {
        [self.refreshControl setAttributedTitle:[StringUtils makeRefreshText:@"Refreshing data..."]];
        [self.refreshControl setEnabled:NO];
    }
    NSLog(@"refreshGame: GameID: %@", self.currentGame.objectId);
    [self.currentGame fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.currentRound = self.currentGame.currentRound;
        [self.currentRound fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            [Comms getActiveCommentsForGame:self.currentGame inRound:self.currentRound forDelegate:self];
            [self setupHeader];
        }];
    }];
}

- (void) didGetComments:(BOOL)success info: (NSString *) info{
    if(success)
    {
    
        self.comments = [[CurrentRounds instance].currentComments objectForKey:self.currentGame.objectId];
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
        if (self.refreshControl) {
            [self.refreshControl endRefreshing];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:info
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
}


#pragma Submitting a commment
-(void)uploadComment:(NSString *)commentText
{
    //Make sure the user entered a comment
    if(commentText == nil || commentText.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Enter Empty Comment"
                                                        message:@"Think of something hurtful to say."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    Comment *comment;
    BOOL newObject = YES;
    //find out if the user already submitted a comment
    for(int i = 0; i < self.comments.count; i ++)
    {
        comment = [self.comments objectAtIndex:i];
        if([comment.from isEqualToString:[[PFUser currentUser] objectForKey:UserFacebookID]])
        {
            //check if they just submitted the same thing
            self.previousComment = [NSString stringWithString:comment.response];
            comment.response = commentText;
            newObject = NO;
            break;
        }
    }
    if(newObject)
    {
        
        NSLog(@"Self.CurrentGame: %@", self.currentGame);
        comment = [Comment object];
        comment.response = commentText;
        comment.gameID = self.currentGame.objectId;
        comment.roundID = self.currentRound.objectId;
        comment.from = [[PFUser currentUser] objectForKey:UserFacebookID];
        
        [self.comments addObject:comment];
    }
    
    [self.tableView reloadData];
    
    [Comms addComment:comment toRound:self.currentRound forDelegate:self];
   
}

//callback
- (void) didAddComment:(BOOL)success needsRefresh:(BOOL)refresh info: (NSString *) info
{
    if(success)
    {
        SINOutgoingMessage *message = [SINOutgoingMessage messageWithRecipients:nonUserPlayers text:NewComment];
        [self.messageClient sendMessage:message];
        
    } else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:info
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        if(refresh)
        {
            [self refreshGame:nil];
        } else{
            Comment *comment;
            for(int i = 0; i < self.comments.count; i ++)
            {
                comment = [self.comments objectAtIndex:i];
                if([comment.from isEqualToString:[[PFUser currentUser] objectForKey:UserFacebookID]])
                {
                    if(self.previousComment.length > 0 && self.previousComment != nil)
                    {
                        comment.response = self.previousComment;
                        self.previousComment = nil;
                    } else{
                        [self.comments removeObjectAtIndex:i];
                    }
                    [self.tableView reloadData];
                    break;
                }
            }
        }
    }
}

#pragma staring new round
- (void) didStartNewRound:(BOOL)success info: (NSString *) info previousWinner:(CompletedRound *)winningRound;
{
    if(success)
    {
        self.comments = [[NSMutableArray alloc] init];
        [[CurrentRounds instance].currentComments  removeObjectForKey:self.currentGame.objectId];

        [self refreshGame:nil];
        
        SINOutgoingMessage *message = [SINOutgoingMessage messageWithRecipients:nonUserPlayers text:NewRound];
        [message addHeaderWithValue:winningRound.category key:CompletedRoundCategory];
        [message addHeaderWithValue:[NSString stringWithFormat:@"%@",winningRound.roundNumber] key:CompletedRoundNumber];
        [message addHeaderWithValue:winningRound.winningResponse key:CompletedRoundWinningResponse];
        [message addHeaderWithValue:winningRound.winningResponseFrom key:CompletedRoundWinningResponseFrom];
        [message addHeaderWithValue:winningRound.gameID key:CompletedRoundGameID];
        [self.messageClient sendMessage:message];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:info
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) keyboardWillShow:(NSNotification *)note {
    [self.view addGestureRecognizer:self.singleTap];
    NSDictionary *userInfo = [note userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    self.composeBarView.frame = CGRectMake(self.composeBarView .frame.origin.x, (self.composeBarView.frame.origin.y - kbSize.height), self.composeBarView.frame.size.width, self.composeBarView.frame.size.height);
    [self layoutSubviews];
    [UIView commitAnimations];
}

- (void) keyboardWillHide:(NSNotification *)note {
    [self.view removeGestureRecognizer:self.singleTap];
    NSDictionary *userInfo = [note userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    self.composeBarView.frame = CGRectMake(self.composeBarView .frame.origin.x, (self.composeBarView.frame.origin.y + kbSize.height), self.composeBarView.frame.size.width, self.composeBarView.frame.size.height);
    [self layoutSubviews];
    [UIView commitAnimations];
}

- (void) keyboardDidHide:(NSNotification *)note {
    self.composeBarView.frame = CGRectMake(self.composeBarView.frame.origin.x, (self.view.bounds.size.height - self.composeBarView.frame.size.height), self.composeBarView.frame.size.width, self.composeBarView.frame.size.height);
    [self layoutSubviews];
}

- (void)resignOnTap:(id)sender {
    [self.composeBarView resignFirstResponder];
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView
{
    [composeBarView resignFirstResponder];
    [self uploadComment: composeBarView.text];
    [composeBarView setText:@""];
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
   willChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
              duration:(NSTimeInterval)duration
        animationCurve:(UIViewAnimationCurve)animationCurve
{
    
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
    didChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
{
    [self layoutSubviews];
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
    NSLog(@"didReceiveIncomingMessage: %@", message );
    //If user is inactive, send a notification
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground || [UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
        if([message.text isEqualToString:NewRound])
        {
            NSString *winner = [DataStore getFriendFirstNameWithID:[message.headers objectForKey:CompletedRoundWinningResponseFrom]];
            
            NSString* summary = [NSString stringWithFormat:@"New round starting: %@ won previous.", winner];
            UILocalNotification* notification = [[UILocalNotification alloc] init];
            notification.alertBody = summary;

            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
        else if([message.text isEqualToString:NewComment])
        {
           // [self refreshGame:nil];
        }
        else if([message.text isEqualToString:NewGame])
        {
            PFQuery *getGame = [PFQuery queryWithClassName:GameClass];
            [getGame includeKey:GameCurrentRound];
            NSString* gameId = [message.headers objectForKey:ObjectID];
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
            if([[message.headers objectForKey:CompletedRoundGameID] isEqualToString:self.currentGame.objectId])
            {
                [self refreshGame:nil];
            }
        }
        else if([message.text isEqualToString:NewComment])
        {
            [self refreshGame:nil];
        }
        else if([message.text isEqualToString:NewGame])
        {
            PFQuery *getGame = [PFQuery queryWithClassName:GameClass];
            [getGame includeKey:GameCurrentRound];
            NSLog(@"GameID: %@",[message.headers objectForKey:ObjectID]);
            NSString* gameId = [message.headers objectForKey:ObjectID];
            [getGame includeKey:GameCurrentRound];
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
