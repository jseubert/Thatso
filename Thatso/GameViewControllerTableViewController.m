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
#import "UserCommentTableViewCell.h"


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
    return [[[DataStore instance].user objectForKey:User_ID] isEqualToString:self.currentRound[@"judge"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.title = @"Category";
    
    //setup Subviews
    self.headerView = [[UILabel alloc] initWithFrame:CGRectMake(0,
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
    
    // Create a re-usable NSDateFormatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MMM d, h:mm a"];
    
    //Back Button
    FratBarButtonItem *newGameButton= [[FratBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = newGameButton;
    
    // If we are using iOS 6+, put a pull to refresh control in the table
    if (NSClassFromString(@"UIRefreshControl") != Nil) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        
        
        self.refreshControl.attributedTitle = [StringUtils makeRefreshText:@"Pull to refresh"];
        [self.refreshControl addTarget:self action:@selector(refreshGame:) forControlEvents:UIControlEventValueChanged];
        [self.refreshControl setTintColor:[UIColor whiteColor]];
        
        [self.tableView addSubview:self.refreshControl];
        
    }
    
    // Listen for uploaded comments so we can refresh the wall
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commentUploaded:)
                                                 name:N_CommentUploaded
                                               object:nil];
    
    // Listen for image downloads so that we can refresh the image wall
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commentsDownloaded:)
                                                 name:N_CommentsDownloaded
                                               object:nil];
    
    // Listen for image downloads so that we can refresh the image wall
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commentVotedFor:)
                                                 name:N_VotedForComment
                                               object:nil];
    
    //Remove yourself from the game's players
    
    nonUserPlayers = [[NSMutableArray alloc] initWithArray:self.currentGame[@"players"]];
    [nonUserPlayers removeObject:[[DataStore instance].user objectForKey:User_ID]];
    
    [self refreshGame:nil];

}

-(void) setupHeader
{
    self.currentRound = self.currentGame[@"currentRound"];
    [self.currentRound fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {

         [self.headerView setText:[NSString stringWithFormat:@"%@ : %@",[[DataStore getFriendWithId:self.currentRound[@"subject"]] objectForKey:User_FullName], self.currentRound[@"category"]]];
    }];
    [self.headerView setBackgroundColor:[UIColor pinkAppColor]];
    [self.headerView setNumberOfLines:0];
    [self.headerView setLineBreakMode:NSLineBreakByWordWrapping];
    [self.headerView setTextColor:[UIColor whiteColor]];
    [self.headerView setTextAlignment:NSTextAlignmentCenter];
    [[self.headerView  layer] setBorderWidth:2.0f];
    [[self.headerView  layer] setBorderColor:[UIColor whiteColor].CGColor];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    // Get any new Games
 //   [self refreshGame:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Check if the user is the judge
    int commentInputSection = 0;
    if([self isJudge])
    {
        commentInputSection = 0;
    } else{
        commentInputSection = 1;
    }
    
    return commentInputSection + self.comments.count;
    /*
    NSMutableArray* commentsForUserId;
    int commentSection;
    //Title Section
    if(section == 0)
    {
        return 0;
    }else{
        commentsForUserId = [self.comments objectForKey:[nonUserPlayers objectAtIndex:section - 1]];
        //need to add one for the user input comment cell
        commentSection = 1;
    }
    
    //No comments found
    if(commentsForUserId == nil)
    {
        return commentSection;
    }else{
        return commentsForUserId.count + commentSection;
    }*/
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //check if regular comment cell or user enter table cell
    /*
    NSMutableArray* commentsForId;
    //User Section
    if(indexPath.section == 0)
    {
        commentsForId = [self.comments objectForKey:[[DataStore instance].user objectForKey:User_ID]];
    }else{
        commentsForId = [self.comments objectForKey:[nonUserPlayers objectAtIndex:indexPath.section - 1]];
    }
    
    //get comment
    if(indexPath.row < commentsForId.count)
    {
        Comment *comment = [commentsForId objectAtIndex:indexPath.row];
        
        CGFloat width = tableView.frame.size.width
                        - 10    //left padding
                        - CommentTableViewCellIconSize
                        - 10    //padding between icon and text
                        - 10;   //padding on right
        
        //get the size of the label given the text
        CGSize labelSize = [CommentTableViewCell sizeWithFontAttribute:[UIFont defaultAppFontWithSize:16.0] constrainedToSize:(CGSizeMake(width, width)) withText:comment.comment];
        
        //1O padding on top and bottom
        return 10 + labelSize.height + 10;
    }*/
    if([self isJudge])
    {
        PFObject* comment = [self.comments objectAtIndex:indexPath.row];
        CGFloat width = tableView.frame.size.width
        - 10    //left padding
        - CommentTableViewCellIconSize
        - 10    //padding between icon and text
        - 10;   //padding on right
        
        //get the size of the label given the text
        CGSize labelSize = [CommentTableViewCell sizeWithFontAttribute:[UIFont defaultAppFontWithSize:16.0] constrainedToSize:(CGSizeMake(width, width)) withText:comment[@"comment"]];
        
        //1O padding on top and bottom
        return 10 + labelSize.height + 10;
    } else{
        //Last one
        if(self.comments.count == indexPath.row)
        {
            return UITableViewAutomaticDimension;
            
        }else{
            PFObject* comment = [self.comments objectAtIndex:indexPath.row];
            CGFloat width = tableView.frame.size.width
            - 10    //left padding
            - CommentTableViewCellIconSize
            - 10    //padding between icon and text
            - 10;   //padding on right
            
            //get the size of the label given the text
            CGSize labelSize = [CommentTableViewCell sizeWithFontAttribute:[UIFont defaultAppFontWithSize:16.0] constrainedToSize:(CGSizeMake(width, width)) withText:comment[@"comment"]];
            
            //1O padding on top and bottom
            return 10 + labelSize.height + 10;
        }
    }
   

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
        [cell.nameLabel setText:[NSString stringWithFormat:@"Judge: %@ (You)", [[DataStore instance].user objectForKey:User_FullName]]];
        UIImage *fbProfileImage = [[DataStore instance].user objectForKey:User_FacebookProfilePicture];
        [cell.profilePicture setImage:[fbProfileImage imageScaledToFitSize:CGSizeMake(cell.frame.size.height, cell.frame.size.height)]];

    } else{
        [cell.nameLabel setText:[NSString stringWithFormat:@"Judge: %@",[[DataStore getFriendWithId:self.currentRound[@"judge"]] objectForKey:User_FullName]]];
        UIImage *fbProfileImage = [[DataStore getFriendWithId:self.currentRound[@"judge"]] objectForKey:User_FacebookProfilePicture];
        [cell.profilePicture setImage:[fbProfileImage imageScaledToFitSize:CGSizeMake(cell.frame.size.height, cell.frame.size.height)]];
    }
    
    //set color
    [cell setColorScheme:section];
    
    return cell;
  
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isJudge])
    {
        return [self commentTableViewCell:tableView cellForRowAtIndexPath:indexPath];
    } else{
        //Last one
        if([tableView numberOfRowsInSection:indexPath.section] == indexPath.row + 1)
        {
            return [self userCommentTableViewCell:tableView cellForRowAtIndexPath:indexPath];

        }else{
            return [self commentTableViewCell:tableView cellForRowAtIndexPath:indexPath];
        }
    }

}

-(UserCommentTableViewCell *) userCommentTableViewCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *userCommmentCellIdentifier = @"UserCommentTableViewCell";
    UserCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:userCommmentCellIdentifier];
    if (cell == nil) {
        cell = [[UserCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userCommmentCellIdentifier];
    }
    
    [cell.userCommentTextField setDelegate:self];
    [cell.enterButton addTarget:self action:@selector(clickedSubmitComment:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(CommentTableViewCell *) commentTableViewCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *commentCellIdentifier = @"CommentCellIdentifier";
    
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
    if (cell == nil) {
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentCellIdentifier];
    }
    PFObject* comment = [self.comments objectAtIndex:indexPath.row];
    if([comment[@"from"] isEqualToString:[[DataStore instance].user objectForKey:User_ID]])
    {
        [cell setCommentLabelText:[NSString stringWithFormat:@"(Your Response) %@",comment[@"comment"]]];
    } else
    {
        [cell setCommentLabelText:comment[@"comment"]];
    }
    
    
    //get comment
   // Comment *comment = [commentsForId objectAtIndex:indexPath.row];
    
  //  if([cell setCommentLabelText:comment])
   // {
   //     [self.votedForComments setObject:indexPath forKey:[NSNumber numberWithInteger:indexPath.section]];
  //  }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
/*
- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    for (NSIndexPath* selectedIndexPath in tableView.indexPathsForSelectedRows ) {
        if (selectedIndexPath.section == indexPath.section )
        {
            [tableView deselectRowAtIndexPath:selectedIndexPath animated:YES] ;
        }
    }
    return indexPath ;
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
   if([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[CommentTableViewCell class]])
   {
       NSIndexPath *previouslySelectedIndex = [self.votedForComments objectForKey:[NSNumber numberWithInteger:indexPath.section]];
       //The user is deselecting their comment
       if(previouslySelectedIndex.row == indexPath.row && previouslySelectedIndex.section == indexPath.section)
       {
           [((CommentTableViewCell *)[tableView cellForRowAtIndexPath:previouslySelectedIndex]) selectedTableCell:NO];
           [self.votedForComments removeObjectForKey:[NSNumber numberWithInteger:indexPath.section]];
           return;
       }
       //the user already selected a comment and now likes a new one
       if(previouslySelectedIndex != nil)
       {
           [((CommentTableViewCell *)[tableView cellForRowAtIndexPath:previouslySelectedIndex]) selectedTableCell:NO];
           [self.votedForComments removeObjectForKey:[NSNumber numberWithInteger:previouslySelectedIndex.section]];
       }
       //if([self.votedForComments objectForKey:indexPath.section]
       [((CommentTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]) selectedTableCell:YES];
       [self.votedForComments setObject:indexPath forKey:[NSNumber numberWithInteger:indexPath.section]];
       
   }*/
}

/*
- (void) commentUploaded:(NSNotification *)notification
{
    [self refreshGame:nil];
}

- (void) commentVotedFor:(NSNotification *)notification
{
   // [self refreshGame:nil];
}

- (void) commentsDownloaded:(NSNotification *)notification
{


    self.comments = [CurrentRounds instance].currentComments;
    NSLog(@"commentsDownloaded: %@", self.comments);
    [self.tableView reloadData];
}*/

#pragma Submitting getting comments
//Call back delegate for comments Downloade

//Pull to refresh method
- (void) refreshGame:(UIRefreshControl *)refreshControl
{
    if (refreshControl) {
        [refreshControl setAttributedTitle:[StringUtils makeRefreshText:@"Refreshing data..."]];
        [refreshControl setEnabled:NO];
    }
    NSLog(@"refreshGame: GameID: %@", self.currentGame.objectId);
    [Comms getActiveCommentsForGame:self.currentGame inRound:self.currentRound forDelegate:self];
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
            NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [_dateFormatter stringFromDate:[NSDate date]]];
            [self.refreshControl setAttributedTitle:[StringUtils makeRefreshText:lastUpdated]];
            [self.refreshControl setTintColor:[UIColor whiteColor]];
            
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

-(IBAction)clickedSubmitComment:(id)sender
{
    [self uploadComment:((UITextField *)sender).text];
    [((UITextField *)sender) setText:@""];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self uploadComment: textField.text];
    [textField setText:@""];
    return YES;
}

-(void)uploadComment:(NSString *)commentText
{
    //ToO. Check comment is a ok.
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
    
    PFObject *comment;
    BOOL newObject = YES;
    for(int i = 0; i < self.comments.count; i ++)
    {
        comment = [self.comments objectAtIndex:i];
        if([comment[@"from"] isEqualToString:[[DataStore instance].user objectForKey:User_ID]])
        {
            self.previousComment = [NSString stringWithString:comment[@"comment"]];
            comment[@"comment"] = commentText;
            newObject = NO;
            break;
        }
    }
    if(newObject)
    {
        
        NSLog(@"Self.CurrentGame: %@", self.currentGame);
        comment = [PFObject objectWithClassName:@"ActiveComments"];
        comment[@"comment"] = commentText;
        comment[@"gameId"] = self.currentGame.objectId;
        comment[@"roundId"] = self.currentRound.objectId;
        comment[@"from"] = [[DataStore instance].user objectForKey:User_ID];
        
        [self.comments addObject:comment];
    }
    
    [self.tableView reloadData];
    
    [Comms addComment:comment forDelegate:self];
   
}

//callback
- (void) didAddComment:(BOOL)success info: (NSString *) info{
    if(!success)
    {
        PFObject *comment;
        for(int i = 0; i < self.comments.count; i ++)
        {
            comment = [self.comments objectAtIndex:i];
            if([comment[@"from"] isEqualToString:[[DataStore instance].user objectForKey:User_ID]])
            {
                if(self.previousComment.length > 0 && self.previousComment != nil)
                {
                    comment[@"comment"] = self.previousComment;
                    self.previousComment = nil;
                } else{
                    [self.comments removeObjectAtIndex:i];
                }
                break;
            }
        }
        [self.tableView reloadData];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:info
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


@end
