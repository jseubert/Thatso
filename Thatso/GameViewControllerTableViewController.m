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

NSString * const ViewedGameScreenJudge = @"ViewedGameScreenJudge";
NSString * const ViewedGameScreenPlayer = @"ViewedGameScreenPlayer";

-(BOOL) isJudge
{
    return [[[User currentUser] objectForKey:UserFacebookID] isEqualToString:self.currentRound[RoundJudge]];
}

#pragma mark ViewController setup
- (id)init
{
    self = [super init];
    if (self) {
        self.comments = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     *ViewController Preferences/Appearance
     */
    self.navigationItem.title = self.currentGame.gameName;
    
    /*
     * Subview initializations
     */
    //Back button - needed for pushed view controllers
    FratBarButtonItem *backButton= [[FratBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    //Previous Rounds Navigation Button
    FratBarButtonItem *previousGames= [[FratBarButtonItem alloc] initWithTitle:@"Past Rounds" style:UIBarButtonItemStyleBordered target:self action:@selector(clickedPastGamesButton:)];
    self.navigationItem.rightBarButtonItem = previousGames;
    
    //Header View
    self.headerView = [[GameHeaderView alloc] initWithFrame:CGRectZero];
    [self setupHeader];
    [self.view addSubview:self.headerView];
    
    //TableView (comments table)
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.tableView.backgroundColor = [UIColor blueAppColor];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
    
    //Empty Table View
    self.emptyTableView = [[UITextView alloc] initWithFrame:CGRectZero];
    [self.emptyTableView setText: [self isJudge] ? @"\n\nNo one has answered yet": @"\n\nNo one has answered yet.\nAdd your answer below!"];
    [self.emptyTableView setFont:[UIFont defaultAppFontWithSize:20.0f]];
    [self.emptyTableView setTextColor:[UIColor whiteColor]];
    [self.emptyTableView setBackgroundColor:[UIColor clearColor]];
    [self.emptyTableView setTextAlignment:NSTextAlignmentCenter];
    [self.emptyTableView setSelectable:NO];
    
    //Comment box
    //self.composeBarView = [[PHFComposeBarView alloc] initWithFrame:CGRectZero];
    self.composeBarView = [[PHFComposeBarView alloc] initWithFrame:CGRectMake(0.0f,
                                           self.view.frame.size.height - PHFComposeBarViewInitialHeight,
                                           self.view.frame.size.width,
                                           PHFComposeBarViewInitialHeight)];
    [self.composeBarView  setMaxCharCount:140];
    [self.composeBarView  setMaxLinesCount:5];
    [self.composeBarView  setPlaceholder:@"Enter Response"];
    [self.composeBarView  setDelegate:self];
    [self.composeBarView setButtonTintColor:[UIColor pinkAppColor]];
    [self.composeBarView setButtonTitle:@"ThatSo"];
    [self.composeBarView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.composeBarView];
    
    //Add activity indicator
    [self.view addSubview:self.activityIndicator];

    
    //Refresh indicator for tableview
    self.refreshControl  = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [StringUtils makeRefreshText:@"Pull to refresh"];
    [self.refreshControl  addTarget:self action:@selector(refreshGame) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl  setTintColor:[UIColor whiteColor]];
    [self.refreshControl  setBackgroundColor:[UIColor blueAppColor]];
    [self.tableView addSubview:self.refreshControl];
    
    
    /*
     * Misc Setup
     */
    //Make a gesture recognizer for when a user taps outside of textfield to close keyboard
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [self.singleTap setNumberOfTapsRequired:1];
    [self.singleTap setNumberOfTouchesRequired:1];
    
    //Remove yourself from the game's players
    self.nonUserPlayers = [[NSMutableArray alloc] init];
    for (User* user in self.currentGame.players)
    {
        if(![user.objectId isEqualToString:[User currentUser].objectId])
        {
            [self.nonUserPlayers  addObject:user];
        }
    }
    
    //Show Tutorial Stuff
    if([self isJudge])
    {
        if(![[NSUserDefaults standardUserDefaults] boolForKey:ViewedGameScreenJudge])
        {
            
            UIAlertView *newAlertView = [[UIAlertView alloc] initWithTitle:@"In this game you are the judge. You pick the best response below submitted by the other players in the game. When you press one, the winner is announced and a new round will start with a new judge and topic." message:nil delegate:nil cancelButtonTitle:@"Kewl" otherButtonTitles: nil];
            [newAlertView show];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ViewedGameScreenJudge];
        }
    } else{
        if(![[NSUserDefaults standardUserDefaults] boolForKey:ViewedGameScreenPlayer])
        {
            
            UIAlertView *newAlertView = [[UIAlertView alloc] initWithTitle:@"In this game you need to submit your best response to the topic. Try to think of something the judge will pick!" message:nil delegate:nil cancelButtonTitle:@"Kewl" otherButtonTitles: nil];
            [newAlertView show];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ViewedGameScreenPlayer];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Setup delegate to receive messages with Sinch
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.messageClient = [appDelegate.client messageClient];
    self.messageClient.delegate = self;
    
    //Notifications for keyboard behavior
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:@"UIKeyboardWillShowNotification"
                                               object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:@"UIKeyboardWillHideNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillChangeFrame:)
                                                 name:@"UIKeyboardWillChangeFrameNotification"
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshGame];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark navigation bar button actions
-(IBAction)clickedPastGamesButton:(id)sender{
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
        labelSize = [StringUtils sizeWithFontAttribute:[UIFont defaultAppFontWithSize:16.0] constrainedToSize:(CGSizeMake(width, width)) withText:[NSString stringWithFormat:@"(Your Response) %@",comment.response]];
        
    } else
    {
        labelSize = [StringUtils sizeWithFontAttribute:[UIFont defaultAppFontWithSize:16.0] constrainedToSize:(CGSizeMake(width, width)) withText:comment.response];
    }
    //1O padding on top and bottom
    return 10 + labelSize.height + 10; //+ 5??

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
        [cell.nameLabel setText:[NSString stringWithFormat:@"Pick the best answer"]];
     
    } else{
        [cell.nameLabel setText:[NSString stringWithFormat:@"%@'s turn to pick", [self.currentGame playerWithfbId:self.currentRound.judge].first_name]];
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
    cell.backgroundColor = [UIColor pinkAppColor];
    cell.nameLabel.textColor = [UIColor whiteColor];
    
    return cell;
  
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
        ((CommentTableViewCell *) cell).top.hidden = YES;
        if(tableView.isDecelerating || tableView.isDragging)
        {
            cell.frame = CGRectMake(-cell.frame.size.width, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
            [UIView animateWithDuration:0.5
                             animations:^{
                                 cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);

                             }
                             completion:^(BOOL finished){
                                     ((CommentTableViewCell *) cell).top.hidden = NO;
                             }];
        } else{
            cell.frame = CGRectMake(-cell.frame.size.width, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
            [UIView animateWithDuration:0.5
                                  delay:indexPath.row * 0.05
                                options:UIViewAnimationOptionTransitionNone
                             animations:^{
                                    cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
                                    
                                }
                             completion:^(BOOL finished){
                                     ((CommentTableViewCell *) cell).top.hidden = NO;
                             }];
        }
    
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
    if([self isJudge])
    {
        if(self.comments.count < 2)
        {
            [self showAlertWithTitle:@"Hold on cowboy!" andSummary:@"Wait for there to be at least two responses before picking one."];
            return;
        }
        [self showActivityIndicator];
        Comment* winningComment = [self.comments objectAtIndex:indexPath.row];
        
        //Start next round
        
        [Comms finishRound:self.currentRound inGame:self.currentGame withWinningComment:winningComment andOtherComments:self.comments forDelegate:self];
    }
}

#pragma Submitting getting comments
- (void) refreshGame
{
    [self showActivityIndicator];
    [self.refreshControl setAttributedTitle:[StringUtils makeRefreshText:@"Refreshing data..."]];
    [self.refreshControl setEnabled:NO];
    
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
        // Update the refresh control
        NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [_dateFormatter stringFromDate:[NSDate date]]];
        [self.refreshControl setAttributedTitle:[StringUtils makeRefreshText:lastUpdated]];
        [self.refreshControl setTintColor:[UIColor whiteColor]];
    
        [self.refreshControl endRefreshing];
        // Refresh the table data to show the new games
        [self setTableBackgroundView];
        [self.tableView reloadData];
    
    }else{
        [self.emptyTableView setText:@"\n\nError loading comments\nPull to refresh"];
        [self.tableView setBackgroundView:self.emptyTableView];
        [self.refreshControl endRefreshing];

        [self showAlertWithTitle:@"Error!" andSummary:info];
        
    }
}

-(void) setTableBackgroundView
{
    if(self.comments.count > 0)
    {
        [self.tableView setBackgroundView:nil];
    } else{
        [self.emptyTableView setText: [self isJudge] ? @"\n\nNo one has answered yet": @"\n\nNo one has answered yet.\nAdd your answer below!"];
        [self.tableView setBackgroundView:self.emptyTableView];
    }
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
    [self setTableBackgroundView];
    [self.tableView reloadData];
    
    [Comms addComment:comment toRound:self.currentRound forDelegate:self];
   
}

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
        for(User * user in self.nonUserPlayers)
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
            [self refreshGame];
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
                    [self setTableBackgroundView];
                    [self.tableView reloadData];
                    break;
                }
            }
        }
    }
}

#pragma starting new round
- (void) didStartNewRound:(BOOL)success info: (NSString *) info previousWinner:(CompletedRound *)winningRound;
{
    [self hideActivityIndicator];
    if(success)
    {
        //Show an alert to the user who won and that a new round is starting
        NSString *title = [NSString stringWithFormat:@"%@ wins!", winningRound.winningResponseFrom.first_name];
        NSString *summary = [NSString stringWithFormat:@"Press OK to start the next round!"];
        [self showAlertWithTitle:title andSummary:summary];
        
        //Clear all comments for this round
        self.comments = [[NSMutableArray alloc] init];
        [[CurrentRounds instance].currentComments  removeObjectForKey:self.currentGame.objectId];

        //Reload the game
        [self refreshGame];
        
        //Send out a Sinch Message to other players
        NSMutableArray *nonUserPlayersIDs = [[NSMutableArray alloc] init];
        NSMutableArray *nonUserPlayersPushIDs = [[NSMutableArray alloc] init];
        for(User * user in self.nonUserPlayers)
        {
            [nonUserPlayersIDs addObject:user.fbId];
            [nonUserPlayersPushIDs addObject:[NSString stringWithFormat:@"c%@",user.fbId]];
        }
        SINOutgoingMessage *message = [SINOutgoingMessage messageWithRecipients:nonUserPlayersIDs text:NewRound];
        [message addHeaderWithValue:winningRound.category key:CompletedRoundCategory];
        [message addHeaderWithValue:[NSString stringWithFormat:@"%@",winningRound.roundNumber] key:CompletedRoundNumber];
        [message addHeaderWithValue:winningRound.winningResponse key:CompletedRoundWinningResponse];
        [message addHeaderWithValue:winningRound.winningResponseFrom.first_name key:CompletedRoundWinningResponseFrom];
        [message addHeaderWithValue:winningRound.gameID key:CompletedRoundGameID];
        [self.messageClient sendMessage:message];
        
        //Send push notification to other players
        PFPush *push = [[PFPush alloc] init];
        NSDictionary *data = @{
                               @"alert" : [NSString stringWithFormat:@"New Round Starting in %@: \"%@\"", self.currentGame.gameName, self.currentRound.category],
                               @"badge" : @"Increment",
                               @"sounds" : @"woop.caf"
                               };
        [push setChannels:nonUserPlayersPushIDs];
        [push setData:data];
        [push sendPushInBackground];
        
    }else{
        [self showAlertWithTitle:@"Error!" andSummary:info];
    }
}


#pragma mark keyboard and comment bar notifications
- (void) keyBoardWillChangeFrame:(NSNotification *)notification {
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardBeginFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] integerValue];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = self.composeBarView.frame;
    CGRect keyboardFrameEnd = [self.view convertRect:keyboardEndFrame toView:nil];
    CGRect keyboardFrameBegin = [self.view convertRect:keyboardBeginFrame toView:nil];
    
    newFrame.origin.y -= (keyboardFrameBegin.origin.y - keyboardFrameEnd.origin.y);
    self.composeBarView.frame = newFrame;
    
    [UIView commitAnimations];
}
- (void) keyboardWillShow:(NSNotification *)note {
    [self.view addGestureRecognizer:self.singleTap];
}

- (void) keyboardWillHide:(NSNotification *)note {
    [self.view removeGestureRecognizer:self.singleTap];
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
}
 
- (void)message:(id<SINMessage>)message shouldSendPushNotifications:(NSArray *)pushPairs {
}
 
- (void)messageDelivered:(id<SINMessageDeliveryInfo>)info {
}

- (void)messageFailed:(id<SINMessage>)message info:(id<SINMessageFailureInfo>)failureInfo {
}

-(void) newRoundNotification: (id<SINMessage>)message inBackground: (BOOL) inBackground
{
    if([[message.headers objectForKey:CompletedRoundGameID] isEqualToString:self.currentGame.objectId])
    {
        [[UserGames instance] refreshGameID:[message.headers objectForKey:CompletedRoundGameID] withBlock:^(Game * game) {
            [self refreshGame];
        }];
    }
}
- (void) newCommentNotification: (id<SINMessage>)message inBackground: (BOOL) inBackground
{
    if([[message.headers objectForKey:CommentRoundID] isEqualToString:self.currentRound.objectId])
    {
        [[CurrentRounds instance] refreshCommentID:[message.headers objectForKey:ObjectID] withBlock:^(Comment *comment) {
            self.comments = [[CurrentRounds instance].currentComments objectForKey:self.currentGame.objectId];
            [self setTableBackgroundView];
            [self.tableView reloadData];
        }];
    }
    else if([[message.headers objectForKey:CommentGameID] isEqualToString:self.currentGame.objectId]){
        [self showAlertWithTitle:@"New Round Started!" andSummary:@""];
        [self refreshGame];
    }
}

#pragma mark activity indicator methods
- (void) showActivityIndicator
{
    [super showActivityIndicator];
    [self.tableView setUserInteractionEnabled:NO];
    [self.composeBarView setUserInteractionEnabled:NO];
}

-(void) hideActivityIndicator
{
    [super hideActivityIndicator];
    [self.tableView setUserInteractionEnabled:YES];
    [self.composeBarView setUserInteractionEnabled:YES];
}
@end
