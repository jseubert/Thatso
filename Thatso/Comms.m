//
//  Comms.m
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "NSOperationQueue+NSoperationQueue_SharedQueue.h"
#import "AppDelegate.h"
#import "Comms.h"

@implementation Comms
//Notifications 
+ (void) login:(id<DidLoginDelegate>)delegate
{
    // Reset the DataStore so that we are starting from a fresh Login
    // as we could have come to this screen from the Logout navigation
    [[DataStore instance] reset];
    [[UserGames instance] reset];
    [[CurrentRounds instance] reset];
    [[PreviousRounds instance] reset];
    
	// Basic User information and your friends are part of the standard permissions
	// so there is no reason to ask for additional permissions
	[PFFacebookUtils logInWithPermissions:[NSArray arrayWithObjects:@"user_friends", nil] block:^(PFUser *user, NSError *error) {
		// Was login successful ?
		if (!user) {
			if (!error) {
                [delegate didlogin:NO info:@"The user cancelled the Facebook login."];
            } else {
                [delegate didlogin:NO info: [NSString stringWithFormat:@"An error occurred: %@", error.localizedDescription]];
            }
            return;
		}
        else
        {
			//Login Successful - Update user and find friends
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                //Update the user
                NSDictionary<FBGraphUser> *me = (NSDictionary<FBGraphUser> *)result;
                [[PFUser currentUser] setObject:[me objectForKey:ID] forKey:UserFacebookID];
                [[PFUser currentUser] setObject:[me objectForKey:UserFirstName] forKey:UserFirstName];
                [[PFUser currentUser] setObject:[me objectForKey:UserLastName] forKey:UserLastName];
                [[PFUser currentUser] setObject:[me objectForKey:UserFullName] forKey:UserFullName];
                [[PFUser currentUser] saveInBackground];
                
                // Launch another thread to handle the download of the user's Facebook profile picture
                [Comms getProfilePictureForUser:user];
                    
                // Add the User to the list of friends in the DataStore
                //[[DataStore instance].fbFriends setObject:user forKey:[user objectForKey:UserFacebookID]];
                    
                //Start Sinch!
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate initSinchClientWithUserId:[user objectForKey:UserFacebookID]];
                
                //Now get all your friends and make sure theyre added
                FBRequest *friendsRequest = [FBRequest requestForMyFriends];
                [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                              NSDictionary* result,
                                                              NSError *error)
                {
                    if(error)
                    {
                        [delegate didlogin:NO info: [NSString stringWithFormat:@"An error occurred: %@", error.localizedDescription]];
                        return;
                    }
                    else
                    {
                        NSArray *friends = result[@"data"];
                        NSMutableArray *friendsIDs = [[NSMutableArray alloc] init];
                        for (FBGraphObject* friend in friends) {
                            NSLog(@"Friend: %@", friend);
                            [friendsIDs addObject:[friend objectForKey:ID]];
                            NSLog(@"Friend: %@", [friend objectForKey:ID]);
                        }
                        
                        PFQuery *getFBFriends = [PFUser query];
                        [getFBFriends whereKey:UserFacebookID containedIn:friendsIDs];
                        //[getFBFriends whereKey:UserFacebookID containsString:@"1467121910205120"];
                        
                        
                        [getFBFriends findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if(error)
                            {
                                [delegate didlogin:NO info: [NSString stringWithFormat:@"An error occurred: %@", error.localizedDescription]];
                                return;
                            } else{
                                for (PFObject* friend in objects) {
                                    [[DataStore instance].fbFriends setObject:friend forKey:friend[UserFacebookID]];
                                    [Comms getProfilePictureForUser:(PFUser *)friend];
                                }
                                
                                [Comms getCategories];
                                
                                [delegate didlogin:YES info: nil];
                            }
                        }];
                    }
                }];
            }
        }];
    }
    }];
}

+ (void) startNewGameWithUsers: (NSArray *)fbFriendsInGame forDelegate:(id<CreateGameDelegate>)delegate
{
    // Add Current User to the Game
    NSMutableArray *allPlayersInGame = [[NSMutableArray alloc] initWithArray:fbFriendsInGame];
    [allPlayersInGame addObject:[[PFUser currentUser] objectForKey:UserFacebookID]];
    //Must Have more than 3 users
    if(allPlayersInGame.count < 3)
    {
        //Return Error
       // [delegate newGameUploadedToServer:NO info:@"Not Enough Players in Game!"];
        //return;
    }
    
    //Check if this game already exists
    //Query returns all games that contain the players above
    PFQuery *checkIfGameExistsQuery = [PFQuery queryWithClassName:GameClass];
    [checkIfGameExistsQuery whereKey:GamePlayers containsAllObjectsInArray:allPlayersInGame];
    [checkIfGameExistsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        //Error With Query
        if(error)
        {
            [delegate newGameUploadedToServer:NO info:error.fberrorUserMessage];
        }
        //Check if this game already exists
        else if(objects != NULL && [objects count] > 0)
        {
            //Check each game returned. If a game has a same amount of players as the original ID's passed, then it is a duplicate game
            for(int i = 0; i < [objects count]; i ++)
            {
                if([allPlayersInGame count] == [[[objects objectAtIndex:i] objectForKey:GamePlayers] count])
                {
                    [delegate newGameUploadedToServer:NO info:@"A game with these users already exists!"];
                    return;
                }
            }
        }
        
        //Create the game
        
        Game *gameObject = [Game object];
        gameObject.rounds = @1;
        gameObject.players = allPlayersInGame;
        
        //Create the first round for this Game
        Round *roundObject = [Round object];
        roundObject.judge = [[PFUser currentUser] objectForKey:UserFacebookID];
        roundObject.subject = [fbFriendsInGame objectAtIndex:0];
        roundObject.roundNumber = @1;
      
        //Get new category
        [Comms getCategories];
        GenericCategory *category = [[DataStore instance].categories objectAtIndex:(arc4random() % [DataStore instance].categories.count)];
        
        roundObject[RoundCategory] = [NSString stringWithFormat:@"%@ %@%@", category.startText, [DataStore getFriendFirstNameWithID:roundObject.subject], category.endText];
        
        
        
        gameObject.currentRound = roundObject;
        
        
        [gameObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if (succeeded) {
                // 4 If the save was successful, save the comment in another new Parse object. Again, save the  user’s name and Facebook user ID along with the comment string.
                    [delegate newGameUploadedToServer:YES info:@"Success"];
            } else {
                    // 6 If there was an error saving the new game object, report the error
                    [delegate newGameUploadedToServer:NO info:error.fberrorUserMessage];
            }
        }];
        
    }];
}

+(void) getUsersGamesforDelegate:(id<GetGamesDelegate>)delegate
{
    PFQuery *getGames = [PFQuery queryWithClassName:GameClass];
    
    [getGames orderByAscending:UpdatedAt];
    NSArray *user =[[NSArray alloc] initWithObjects:[[PFUser currentUser] objectForKey:UserFacebookID], nil];
    
    //find all games that have the current user as a player
    [getGames whereKey:GamePlayers containsAllObjectsInArray:user];
    
    [getGames findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [delegate didGetGamesDelegate:NO info: error.localizedDescription];
		} else {
            [[[UserGames instance] games] removeAllObjects];
            [[[UserGames instance] games] addObjectsFromArray:objects];
            
            // Notify that all the current games have been downloaded
            [delegate didGetGamesDelegate:YES info: nil];
        }
    }];

}


+ (void) addComment:(Comment*)comment forDelegate:(id<DidAddCommentDelegate>)delegate{
    //Check if this round is still active
    PFQuery *roundQuery = [PFQuery queryWithClassName:RoundClass];
    [roundQuery whereKey:ObjectID equalTo:comment.roundID];
    [roundQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(error)
        {
             [delegate didAddComment:NO needsRefresh:YES info:@"This round is over, getting new round!"];
        }else{
            //round not active, need to refresh view
            if(!object)
            {
                [delegate didAddComment:NO needsRefresh:YES info:@"This round is over, getting new round!"];
            }
            //active round
            else{
                //Check to see if the comment exists already
                PFQuery *query = [PFQuery queryWithClassName:CommentClass];
                
                [query whereKey:CommentGameID equalTo:comment.gameID];
                [query whereKey:CommentRoundID equalTo:comment.roundID];
                [query whereKey:CommentFrom equalTo:comment.from];
                //Check if
                
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    //Comment does not exist. Add it.
                    if(!object)
                    {
                        [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                // Notify that the Comment has been uploaded, using NSNotificationCenter
                                [delegate didAddComment:YES needsRefresh:NO info:nil];
                            }
                            else{
                                [delegate didAddComment:NO needsRefresh:NO info:error.localizedDescription];
                            }
                        }];
                        
                    } else {
                        object[CommentResponse] = comment.response;
                        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                // Notify that the Comment has been uploaded, using NSNotificationCenter
                                [delegate didAddComment:YES needsRefresh:NO info:@"Success"];
                            }
                            else{
                                [delegate didAddComment:NO needsRefresh:NO info:error.localizedDescription];
                            }
                        }];
                    }
                }];
            }
            
        }
    }];
}


+ (void) getActiveCommentsForGame:(Game*)game inRound:(Round*)round forDelegate:(id<DidGetCommentsDelegate>)delegate
{
    PFQuery *query = [PFQuery queryWithClassName:CommentClass];
    [query whereKey:CommentGameID equalTo:game.objectId];
    [query whereKey:CommentRoundID equalTo:round.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
            [delegate didGetComments:NO info:error.localizedDescription];
            
        } else {
            //[UserGames insta]
            //Should merge later but for now just copy over
            [[CurrentRounds instance] setComments:objects forGameId:game.objectId];
            [delegate didGetComments:YES info:nil];
        }
    }];
}

+ (void) finishRound: (Round *)round inGame: (Game *)game withWinningComment: (Comment *)comment andOtherComments: (NSArray *)otherComments forDelegate:(id<DidStartNewRound>)delegate
{
    NSString *previousJudge = round.judge;
    NSArray *players = game.players;
    
    //increment round number for game
    [game incrementKey:GameRounds];

    //Build a new round and update the game with it's current round
    Round *roundObject = [Round object];
    
    //Get new judge, next in array
    for(int i = 0; i < players.count; i ++)
    {
        if([players[i] isEqualToString:previousJudge])
        {
            //last one so now cycle to first one
            if(i == players.count -1)
            {
                roundObject.judge = players[0];
            }else{
                roundObject.judge = players[i + 1];
            }
            break;
        }
    }
        
    //get new subject, make sure its not the judge
    NSMutableArray *nonJudgePlayers = [[NSMutableArray alloc] initWithArray:players];
    [nonJudgePlayers removeObject:roundObject.judge];
    roundObject.subject = [nonJudgePlayers objectAtIndex:(arc4random() % nonJudgePlayers.count)];
        
    //Get new category
    [Comms getCategories];
    GenericCategory *category = [[DataStore instance].categories objectAtIndex:(arc4random() % [DataStore instance].categories.count)];
    
    roundObject.category = [NSString stringWithFormat:@"%@ %@%@", category.startText, [DataStore getFriendFirstNameWithID:roundObject.subject], category.endText];
        
    //new round round
    roundObject.roundNumber = game.rounds;
    
    game.currentRound = roundObject;
        
    [game saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded)
        {
            //Build archivedRound object and save it
            CompletedRound *completedRound = [CompletedRound object];
            completedRound.judge = round.judge;
            completedRound.subject = round.subject;
            completedRound.category = round.category;
            completedRound.roundNumber = round.roundNumber;
            completedRound.gameID = game.objectId;
            completedRound.winningResponse = comment.response;
            completedRound.winningResponseFrom = comment.from;
            
            [completedRound saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded)
                {
                    //Remove all comments for the current round
                    //Remove the current round
                    [PFObject deleteAllInBackground:otherComments block:^(BOOL succeeded, NSError *error) {
                        if(succeeded)
                        {
                            [round deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if(succeeded)
                                {
                                    [delegate didStartNewRound:YES info: error.localizedDescription previousWinner:completedRound];
                                }else{
                                    [delegate didStartNewRound:NO info: error.localizedDescription previousWinner:nil];
                                }
                            }];

                        }else{
                            [delegate didStartNewRound:NO info: error.localizedDescription previousWinner:nil];
                        }
                    }];
                }else{
                    [delegate didStartNewRound:NO info: error.localizedDescription previousWinner:nil];
                }
            }];
        }else{
            [delegate didStartNewRound:NO info: error.localizedDescription previousWinner:nil];
        }
    }];
}


+ (void) getPreviousRoundsInGame: (Game * ) game forDelegate:(id<DidGetPreviousRounds>)delegate
{
    PFQuery *getRounds = [PFQuery queryWithClassName:CompletedRoundClass];
    
    [getRounds orderByDescending:CompletedRoundNumber];
    [getRounds whereKey:CompletedRoundGameID equalTo:game.objectId];
    
    [getRounds findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [delegate didGetPreviousRounds:NO info:error.localizedDescription];
        } else {
            [[PreviousRounds instance] setPreviousRounds:objects forGameId:game.objectId];
            [delegate didGetPreviousRounds:YES info: nil];
        }
    }];
}

+ (void) getCategories
{

    PFQuery *getCategory = [PFQuery queryWithClassName:CategoryClass];
    
    [DataStore instance].categories = [[NSMutableArray alloc] initWithArray:[getCategory findObjects]];
    
    NSLog(@"Categories: %@", [DataStore instance].categories);
}

+ (void) getuser: (NSString *)fbId
{
    PFQuery *getUser = [PFUser query];
    [getUser whereKey:UserFacebookID containsString:fbId];
    
    PFUser* user = (PFUser *)[getUser getFirstObject];
    
    [[DataStore instance].fbFriends setObject:user forKey:fbId];
    
    [Comms getProfilePictureForUser:user];
}

+ (void) getProfilePictureForUser: (PFUser*) user
{
    [[NSOperationQueue profilePictureOperationQueue] addOperationWithBlock:^ {
        // Build a profile picture URL from the user's Facebook user id
        NSString *profilePictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", user[UserFacebookID]];
        NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]];
        UIImage *profilePicture = [UIImage imageWithData:profilePictureData];
        
        // Set the profile picture into the user object
        if (profilePicture) [[DataStore instance].fbFriendsProfilePictures setObject:profilePicture forKey:[user objectForKey:UserFacebookID]];
    }];
}




@end
