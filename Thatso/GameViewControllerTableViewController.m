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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor blueAppColor];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    self.navigationController.title = @"Category";
    
    // Create a re-usable NSDateFormatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MMM d, h:mm a"];
    
    //Back Button
    FratBarButtonItem *newGameButton= [[FratBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = newGameButton;
    
    // If we are using iOS 6+, put a pull to refresh control in the table
    if (NSClassFromString(@"UIRefreshControl") != Nil) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        
        
        refreshControl.attributedTitle = [StringUtils makeRefreshText:@"Pull to refresh"];
        [refreshControl addTarget:self action:@selector(refreshGame:) forControlEvents:UIControlEventValueChanged];
        [refreshControl setTintColor:[UIColor whiteColor]];
        
        self.refreshControl = refreshControl;
        
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
    
    //Remove yourself from the game's players
    nonUserPlayers = [[NSMutableArray alloc] initWithArray:self.currentGame.players];
    [nonUserPlayers removeObject:[[DataStore instance].user objectForKey:User_FacebookID]];

}

-(void)viewDidAppear:(BOOL)animated
{
    // Get any new Games
    [self refreshGame:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.currentGame.players count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray* commentsForId;
    
    //Current Users section
    int commentSection = 1;
    if(section == 0)
    {
        commentsForId = [self.comments objectForKey:[[DataStore instance].user objectForKey:User_FacebookID]];
        commentSection = 0;
    }else{
        commentsForId = [self.comments objectForKey:[nonUserPlayers objectAtIndex:section - 1]];
    }
    
    if(commentsForId == nil)
    {
        NSLog(@"Found none");
        return commentSection;
    }else{
        NSLog(@"Found: %lu",(unsigned long)commentsForId.count );
        return commentsForId.count + commentSection;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //check if regular comment cell or user enter table cell
    
        NSMutableArray* commentsForId;
        if(indexPath.section == 0)
        {
            commentsForId = [self.comments objectForKey:[[DataStore instance].user objectForKey:User_FacebookID]];
        }else{
            commentsForId = [self.comments objectForKey:[nonUserPlayers objectAtIndex:indexPath.section - 1]];
        }
        //get comment
    if(indexPath.row < commentsForId.count)
    {
        Comment *comment = [commentsForId objectAtIndex:indexPath.row];
        
        CGFloat width = tableView.frame.size.width - 10 - CommentTableViewCellIconSize - 10 - 10;
        CGSize labelSize = [CommentTableViewCell sizeWithFontAttribute:[UIFont defaultAppFontWithSize:16.0] constrainedToSize:(CGSizeMake(width, width)) withText:comment.comment];
        
        NSLog(@"heightForRowAtIndexPath: %f", labelSize.height);
        return 10 + labelSize.height + 10;
    }
    return UITableViewAutomaticDimension;
   
    

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
    
    //User's Section
    if(section == 0)
    {
        //Populate name and picture
        [cell.nameLabel setText:[[DataStore instance].user objectForKey:User_FullName]];
        UIImage *fbProfileImage = [[DataStore instance].user objectForKey:User_FacebookProfilePicture];
        [cell.profilePicture setImage:[fbProfileImage imageScaledToFitSize:CGSizeMake(cell.frame.size.height, cell.frame.size.height)]];


    } else{
        //Populate name and picture
        [cell.nameLabel setText:[[DataStore getFriendWithId:[nonUserPlayers objectAtIndex:section - 1]] objectForKey:User_FullName]];
        UIImage *fbProfileImage = [[DataStore getFriendWithId:[nonUserPlayers objectAtIndex:section - 1]] objectForKey:User_FacebookProfilePicture];
        [cell.profilePicture setImage:[fbProfileImage imageScaledToFitSize:CGSizeMake(cell.frame.size.height, cell.frame.size.height)]];
    }
    
    //set color
    [cell setColorScheme:section];
    
    return cell;
  
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check if regular comment cell or user enter table cell
    if(indexPath.section == 0)
    {
        return [self commentTableViewCell:tableView cellForRowAtIndexPath:indexPath];

    }else{
        if ([tableView numberOfRowsInSection:indexPath.section] == (indexPath.row + 1)) {
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
    
    //populate Cell info
    cell.toUser = [nonUserPlayers objectAtIndex:indexPath.section - 1];
    
    //WTF, figure out later
    // cell.roundNumber = [NSString stringWithFormat:@"%d", 1];
    cell.category = @"First";
    cell.gameID = self.currentGame.objectId;
    
    
    [cell.userCommentTextField setPlaceholder:@"Enter response"];
    // [cell.userCommentTextField setDelegate:self];
    // [cell.enterButton addTarget:self action:@selector(clickedSubmitComment:) forControlEvents:UIControlEventTouchUpInside];
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
    NSMutableArray* commentsForId;
    if(indexPath.section == 0)
    {
        commentsForId = [self.comments objectForKey:[[DataStore instance].user objectForKey:User_FacebookID]];
    }else{
        commentsForId = [self.comments objectForKey:[nonUserPlayers objectAtIndex:indexPath.section - 1]];
    }
    //get comment
    Comment *comment = [commentsForId objectAtIndex:indexPath.row];
    
    [cell setCommentLabelText:comment.comment];
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[CommentTableViewCell class]]) {
        CommentTableViewCell *cell  = (CommentTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell selectedTableCell:YES];
    }
    
    return;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[CommentTableViewCell class]]) {
        CommentTableViewCell *cell  = (CommentTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell selectedTableCell:NO];
    }

    return;
        //if([tableView cellForRowAtIndexPath:indexPath] isKindOfClass:<#(__unsafe_unretained Class)#>
    
}


- (void) commentUploaded:(NSNotification *)notification
{
    [self refreshGame:nil];
}

- (void) commentsDownloaded:(NSNotification *)notification
{


    self.comments = [CurrentRound instance].currentComments;
    NSLog(@"commentsDownloaded: %@", self.comments);
    [self.tableView reloadData];
}


//Call back delegate for comments Downloaded 

- (void) commsDidGetComments: (NSMutableDictionary *) comments {
    NSLog(@"commsDidGetComments: %@", comments);
    //Copy new comments over
   
    
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

//Pull to refresh method
- (void) refreshGame:(UIRefreshControl *)refreshControl
{
    if (refreshControl) {
        [refreshControl setAttributedTitle:[StringUtils makeRefreshText:@"Refreshing data..."]];
        [refreshControl setEnabled:NO];
    }
    NSLog(@"refreshGame: GameID: %@", self.currentGame.objectId);
    [Comms getCommentsForGameId:self.currentGame.objectId inRound:@"1" forDelegate:self];
    // Get any new Wall Images since the last update
    //[Comms getUsersGamesforDelegate:self];
}

@end
