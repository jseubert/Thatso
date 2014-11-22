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

@interface NewGameTableViewController () <CommsDelegate, CreateGameDelegate>

@end

@implementation NewGameTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor blueAppColor];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    self.navigationController.title = @"Category";
    
    //New Game Button
    FratBarButtonItem *startButton  = [[FratBarButtonItem alloc] initWithTitle:@"Start Game" style:UIBarButtonItemStyleBordered target:self action:@selector(startGame:)];
    self.navigationItem.rightBarButtonItem = startButton;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.frame = CGRectMake(self.view.frame.size.width/2 - 40, self.view.frame.size.height/2 -40, 80, 80);
    [self.view addSubview:self.activityIndicator];
    
    self.tableView.allowsMultipleSelection = YES;
}

-(void) disableUI: (BOOL)flag
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
    return [DataStore instance].fbFriendsArray.count;
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
   
    NSLog(@"Row count: %ld, %lu",(long)indexPath.row, (unsigned long)[DataStore instance].fbFriendsArray.count);
    
    if([DataStore instance].fbFriendsArray.count <= 0)
    {
        [cell.nameLabel setText:@"No Friends :("];
    }else if (indexPath.row < [DataStore instance].fbFriendsArray.count){
        NSLog(@"Inside");
        
        [cell.nameLabel setText:[[[DataStore instance].fbFriendsArray objectAtIndex:indexPath.row] objectForKey:@"name"]];
        UIImage *fbProfileImage = [[[DataStore instance].fbFriendsArray objectAtIndex:indexPath.row] objectForKey:@"fbProfilePicture"];
        [cell.profilePicture setImage:[fbProfileImage imageScaledToFitSize:CGSizeMake(cell.frame.size.height, cell.frame.size.height)]];
        NSLog(@"Done");
        
    }
    [cell setColorScheme:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < [DataStore instance].fbFriendsArray.count)
    {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < [DataStore instance].fbFriendsArray.count)
    {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }
}




// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)startGame:(id)sender{
NSLog(@"startGame");
    [self disableUI:YES];
   if([self.tableView indexPathsForSelectedRows].count < 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not enough Friends Selected"
                                                        message:@"Must choose at least 2 other people."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
       [self disableUI:NO];
    } else {
        NSMutableArray* selectedFriends = [[NSMutableArray alloc] init];
        for(NSIndexPath * indexPath in [self.tableView indexPathsForSelectedRows])
        {
            NSLog(@"addingFreind: %ld", (long)indexPath.row);
            [selectedFriends addObject:[[[DataStore instance].fbFriendsArray objectAtIndex:indexPath.row] objectForKey:@"id"]];
        }
        [self.activityIndicator startAnimating];
        [Comms startNewGameWithUsers:selectedFriends forDelegate:self];

    }
        
    
    
}

- (void) newGameUploadedToServer:(BOOL)success info:(NSString *)info{
    NSLog(@"newGameUploadedToServer: %d", success);
    [self disableUI:NO];
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

@end
