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
    NSMutableArray* commentsForId = [self.comments objectForKey:[self.currentGame.players objectAtIndex:section]];
    //Current Users section
    int commentSection = 0;
    if(![self isSectionUsersSection:section])
    {
        commentSection = 1;
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

-(BOOL) isSectionUsersSection: (NSInteger) section
{
    return [((NSString *)[self.currentGame.players objectAtIndex:section]) isEqualToString:(NSString *)[[PFUser currentUser] objectForKey:@"fbId"]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //44
     return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString *cellIdentifier = @"ProfileViewTableViewCell";
    ProfileViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ProfileViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSLog(@"Section: %ld", (long)section);
    //Populate name and picture
    [cell.nameLabel setText:[[DataStore getFriendWithId:[self.currentGame.players objectAtIndex:section]] objectForKey:@"name"]];
    UIImage *fbProfileImage = [[DataStore getFriendWithId:[self.currentGame.players objectAtIndex:section]] objectForKey:@"fbProfilePicture"];
    [cell.profilePicture setImage:[fbProfileImage imageScaledToFitSize:CGSizeMake(cell.frame.size.height, cell.frame.size.height)]];
    
    //set color
    [cell setColorScheme:section];
    
    return cell;
  
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    //check if regular comment cell or user enter table cell
    if([self isSectionUsersSection:indexPath.section])
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
    cell.toUser = [self.currentGame.players objectAtIndex:indexPath.section];
    
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
    //get comment
    NSMutableArray* commentsForId = [self.comments objectForKey:[self.currentGame.players objectAtIndex:indexPath.section]];
    Comment *comment = [commentsForId objectAtIndex:indexPath.row];
    
    [cell.commentLabel setText:comment.comment];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
    //[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
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


//Call back delegate for new images finished
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
