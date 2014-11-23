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
#import "SelectGameTableViewCell.h"

@interface PreviousRoundsTableViewController ()

@end

@implementation PreviousRoundsTableViewController

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
    return self.previousRounds.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(initialLoad){
        return UITableViewAutomaticDimension;
    } else{
        PFObject* round = [self.previousRounds objectAtIndex:indexPath.row];
        
        CGFloat width = tableView.frame.size.width
            - 10    //left padding
            - 10;   //padding on right
            
        //get the size of the label given the text
        CGSize topLabelSize = [CommentTableViewCell sizeWithFontAttribute:[UIFont defaultAppFontWithSize:16.0] constrainedToSize:(CGSizeMake(width, width)) withText:round[@"category"]];
        CGSize bottomeLabelSize = [CommentTableViewCell sizeWithFontAttribute:[UIFont defaultAppFontWithSize:14.0] constrainedToSize:(CGSizeMake(width, width)) withText:round[@"comment"]];
        
        
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
    SelectGameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SelectGameTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if(initialLoad)
    {
        cell.namesLabel.text = @"Loading rounds...";
    } else if(self.previousRounds.count == 0){
        cell.namesLabel.text = @"No previous rounds...";
    } else{
        PFObject* round = [self.previousRounds objectAtIndex:indexPath.row];
        NSString *winner = [[DataStore getFriendWithId:round[@"from"]] objectForKey:User_FirstName];
        [cell.namesLabel setText:round[@"category"]];
        [cell.categoryLabel setText:[NSString stringWithFormat:@"%@: %@", winner, round[@"comment"]]];
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


@end
