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
#import "PreviousRoundsTableViewController.h"
#import "AppDelegate.h"

@implementation GameViewControllerTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.comments = [[NSMutableArray alloc] init];
    }
    return self;
}


-(BOOL) isJudge
{
    return [[[User currentUser] objectForKey:UserFacebookID] isEqualToString:self.currentRound[RoundJudge]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshGame:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    uploadingComment = false;

    self.navigationItem.title = self.currentGame.gameName;
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
    
    [self.view addSubview:self.activityIndicator];
    
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [self.singleTap setNumberOfTapsRequired:1];
    [self.singleTap setNumberOfTouchesRequired:1];
    
    //Back Button
    FratBarButtonItem *newGameButton= [[FratBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = newGameButton;
    
    //New Game Button
    FratBarButtonItem *previousGames= [[FratBarButtonItem alloc] initWithTitle:@"Past Rounds" style:UIBarButtonItemStyleBordered target:self action:@selector(previousGames:)];
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
    [nonUserPlayers removeObject:[[User currentUser] objectForKey:UserFacebookID]];


}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self layoutSubviews];
}

-(void) setupHeader
{
    NSString *previousProfileId = self.currentRound.subject;
    self.currentRound = self.currentGame.currentRound;

    [self.headerView.roundLabel setText:[NSString stringWithFormat:@"Round %@",self.currentRound.roundNumber]];
    [self.headerView.caregoryLabel setText:[NSString stringWithFormat:@"%@",self.currentRound.category]];
    if(![previousProfileId isEqual:self.currentRound.subject])
    {
        [DataStore getFriendProfilePictureWithID:self.currentRound.subject withBlock:^(UIImage * image) {

            [self.headerView.profilePicture setImage:[image imageScaledToFitSize:CGSizeMake(40, 40)]];
            self.headerView.profilePicture.frame = CGRectMake(self.headerView.profilePicture.frame.origin.x + 20, self.headerView.profilePicture.frame.origin.y + 20, 0, 0);
            [UIView animateWithDuration:0.5
                         animations:^{
                             [[self.headerView.profilePicture  layer] setCornerRadius:20];
                             self.headerView.profilePicture.frame = CGRectMake(self.headerView.profilePicture.frame.origin.x - 20, self.headerView.profilePicture.frame.origin.y -20, 40, 40);
                         }
                         completion:^(BOOL finished){
                         }];
        
        }];
    }
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
    if([comment.from.objectId isEqualToString:[User currentUser].objectId])
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
        [cell.nameLabel setText:[NSString stringWithFormat:@"%@ picks the best answer", [self.currentGame playerWithfbId:self.currentRound.judge].first_name]];
    }
    
    [DataStore getFriendProfilePictureWithID:self.currentRound.judge withBlock:^(UIImage *image) {
        [cell.profilePicture setImage:[image imageScaledToFitSize:CGSizeMake(cell.frame.size.height, cell.frame.size.height)]];
        cell.profilePicture.frame = CGRectMake(cell.profilePicture.frame.origin.x + 20, cell.profilePicture.frame.origin.y + 20, 0, 0);
        [[cell.profilePicture  layer] setCornerRadius:0];
        [UIView animateWithDuration:0.5
                         animations:^{
                             cell.profilePicture.frame = CGRectMake(cell.profilePicture.frame.origin.x - 20, cell.profilePicture.frame.origin.y -20, 40, 40);
                             [[cell.profilePicture  layer] setCornerRadius:cell.profilePicture.frame.size.height/2];
                         }
                         completion:^(BOOL finished){
                         }];
    }];
    
    //set color
    [cell setColorScheme:4];
    
    return cell;
  
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.frame = CGRectMake(-cell.frame.size.width, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    [UIView animateWithDuration:0.5
                     animations:^{
                         cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);

                     }
                     completion:^(BOOL finished){
                     }];
    
    
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
    if([comment.from.objectId isEqualToString:[User currentUser].objectId])
    {
        [cell setCommentLabelText:[NSString stringWithFormat:@"(Your Response) %@",comment.response]];
        self.userCommentCell = cell;
        if(uploadingComment)
        {
            [cell.activityIndicator startAnimating];
            [cell.activityIndicator setHidden:NO];
            [self.userCommentCell.circle setHidden:YES];
        }
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
        [self showActivityIndicator];
        Comment* winningComment = [self.comments objectAtIndex:indexPath.row];
        NSString *title = [NSString stringWithFormat:@"%@'s comment wins!", winningComment.from.first_name];
        NSString *summary = [NSString stringWithFormat:@"Click OK to start the next round!"];
        
        
        [self showAlertWithTitle:title andSummary:summary];
        
        //Start next round
        
        [Comms finishRound:self.currentRound inGame:self.currentGame withWinningComment:winningComment andOtherComments:self.comments forDelegate:self];
    }
}

#pragma Submitting getting comments
//Call back delegate for comments Downloade

//Pull to refresh method
- (void) refreshGame:(UIRefreshControl *)refreshControl
{
    [self showActivityIndicator];
    
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
    //[self dismissAlert];
    [self hideActivityIndicator];
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
        [self showAlertWithTitle:@"Error!" andSummary:info];
        
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Recieve messages
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.messageClient = [appDelegate.client messageClient];
    self.messageClient.delegate = self;
}


#pragma Submitting a commment
-(void)uploadComment:(NSString *)commentText
{
    //Make sure the user entered a comment
    if(commentText == nil || commentText.length == 0)
    {
        [self showAlertWithTitle:@"Can't Enter Empty Comment" andSummary:@"Think of something hurtful to say."];
        return;
    }
    
    Comment *comment;
    BOOL newObject = YES;
    //find out if the user already submitted a comment
    for(int i = 0; i < self.comments.count; i ++)
    {
        comment = [self.comments objectAtIndex:i];
        if([comment.from.objectId isEqualToString:[User currentUser].objectId])
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
        comment.from = [User currentUser];
        
        [self.comments addObject:comment];
    }
    uploadingComment = true;
    [self.tableView reloadData];
    
    [Comms addComment:comment toRound:self.currentRound forDelegate:self];
   
}

//callback
- (void) didAddComment:(BOOL)success needsRefresh:(BOOL)refresh addedComment:(Comment*)comment info: (NSString *) info
{
    if(self.userCommentCell != nil)
    {
        [self.userCommentCell.activityIndicator setHidden:YES];
        [self.userCommentCell.activityIndicator stopAnimating];
        [self.userCommentCell.circle setHidden:NO];
    }
    uploadingComment = false;
    if(success)
    {
        //Update local
        [[UserGames instance] userDidRespondInGame: self.currentGame];
        
        NSMutableArray *nonUserPlayersIDs = [[NSMutableArray alloc] init];
        for(User * user in nonUserPlayers)
        {
            [nonUserPlayersIDs addObject:user.fbId];
        }
        SINOutgoingMessage *message = [SINOutgoingMessage messageWithRecipients:nonUserPlayersIDs text:NewComment];
        [message addHeaderWithValue:comment.objectId key:ObjectID];
        [message addHeaderWithValue:comment.roundID key:CommentRoundID];
        [message addHeaderWithValue:comment.gameID key:CommentGameID];
        [self.messageClient sendMessage:message];
        
    } else{
        [self showAlertWithTitle:@"Error!" andSummary:info];
        if(refresh)
        {
            [self refreshGame:nil];
        } else{
            Comment *comment;
            for(int i = 0; i < self.comments.count; i ++)
            {
                comment = [self.comments objectAtIndex:i];
                if([comment.from.objectId isEqualToString:[User currentUser].objectId])
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
    [self hideActivityIndicator];
    if(success)
    {
        self.comments = [[NSMutableArray alloc] init];
        [[CurrentRounds instance].currentComments  removeObjectForKey:self.currentGame.objectId];

        [self refreshGame:nil];
        NSMutableArray *nonUserPlayersIDs = [[NSMutableArray alloc] init];
        for(User * user in nonUserPlayers)
        {
            [nonUserPlayersIDs addObject:user.fbId];
        }
        SINOutgoingMessage *message = [SINOutgoingMessage messageWithRecipients:nonUserPlayersIDs text:NewRound];
        [message addHeaderWithValue:winningRound.category key:CompletedRoundCategory];
        [message addHeaderWithValue:[NSString stringWithFormat:@"%@",winningRound.roundNumber] key:CompletedRoundNumber];
        [message addHeaderWithValue:winningRound.winningResponse key:CompletedRoundWinningResponse];
        [message addHeaderWithValue:winningRound.winningResponseFrom.first_name key:CompletedRoundWinningResponseFrom];
        [message addHeaderWithValue:winningRound.gameID key:CompletedRoundGameID];
        NSLog(@"%@", message.headers);
        [self.messageClient sendMessage:message];
        
    }else{
        [self showAlertWithTitle:@"Error!" andSummary:info];
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

#pragma mark - SINMessageClientDelegate

 - (void)messageClient:(id<SINMessageClient>)messageClient didReceiveIncomingMessage:(id<SINMessage>)message {
 NSLog(@"didReceiveIncomingMessage: %@ %@", message.text, message.headers );

    if([message.text isEqualToString:NewRound])
    {
        [self newRoundNotification:message inBackground:NO];
    }
    else if([message.text isEqualToString:NewComment])
    {
        [self newCommentNotification:message inBackground:NO];
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

-(void) newRoundNotification: (id<SINMessage>)message inBackground: (BOOL) inBackground
{
    if([[message.headers objectForKey:CompletedRoundGameID] isEqualToString:self.currentGame.objectId])
    {
        [[UserGames instance] refreshGameID:[message.headers objectForKey:CompletedRoundGameID] withBlock:^(Game * game) {
            [self refreshGame:nil];
        }];
    }
}
- (void) newCommentNotification: (id<SINMessage>)message inBackground: (BOOL) inBackground
{
    if([[message.headers objectForKey:CommentRoundID] isEqualToString:self.currentRound.objectId])
    {
        [[CurrentRounds instance] refreshCommentID:[message.headers objectForKey:ObjectID] withBlock:^(Comment *comment) {
            self.comments = [[CurrentRounds instance].currentComments objectForKey:self.currentGame.objectId];
            [self.tableView reloadData];
        }];
    }
    else if([[message.headers objectForKey:CommentGameID] isEqualToString:self.currentGame.objectId]){
        [self showAlertWithTitle:@"New Round Started!" andSummary:@""];
        [self refreshGame:nil];
    }
}

- (void) showActivityIndicator
{
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:NO];
    [self.tableView setUserInteractionEnabled:NO];
    [self.composeBarView setUserInteractionEnabled:NO];
}

-(void) hideActivityIndicator
{
    
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
    [self.tableView setUserInteractionEnabled:YES];
    [self.composeBarView setUserInteractionEnabled:YES];
}
@end
