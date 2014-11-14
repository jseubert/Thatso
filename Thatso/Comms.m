//
//  Comms.m
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "Comms.h"
#import "NSOperationQueue+NSoperationQueue_SharedQueue.h"

@implementation Comms


//Notifications 


+ (void) login:(id<CommsDelegate>)delegate
{
    // Reset the DataStore so that we are starting from a fresh Login
    // as we could have come to this screen from the Logout navigation
    [[DataStore instance] reset];
    [[UserGames instance] reset];
    
	// Basic User information and your friends are part of the standard permissions
	// so there is no reason to ask for additional permissions
	[PFFacebookUtils logInWithPermissions:[NSArray arrayWithObjects:@"user_friends", nil] block:^(PFUser *user, NSError *error) {
		// Was login successful ?
		if (!user) {
			if (!error) {
                NSLog(@"The user cancelled the Facebook login.");
            } else {
                NSLog(@"An error occurred: %@", error.localizedDescription);
            }
            
			// Callback - login failed
			if ([delegate respondsToSelector:@selector(commsDidLogin:)]) {
				[delegate commsDidLogin:NO];
			}
		} else {
			if (user.isNew) {
				NSLog(@"User signed up and logged in through Facebook!");
			} else {
				NSLog(@"User logged in through Facebook!");
			}
            
			// Callback - login successful
			[FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSDictionary<FBGraphUser> *me = (NSDictionary<FBGraphUser> *)result;
                    // Store the Facebook Id
                    [[PFUser currentUser] setObject:me.objectID forKey:User_ID];
                    NSLog(@"Added you: %@", me.name);
                    [[PFUser currentUser] saveInBackground];
                    
                    // Launch another thread to handle the download of the user's Facebook profile picture
                    [[NSOperationQueue profilePictureOperationQueue] addOperationWithBlock:^ {
                        // Build a profile picture URL from the user's Facebook user id
                        NSString *profilePictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", me.objectID];
                        NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]];
                        UIImage *profilePicture = [UIImage imageWithData:profilePictureData];
                        
                        // Set the profile picture into the user object
                        if (profilePicture) [me setObject:profilePicture forKey:User_FacebookProfilePicture];
                        
                        // Notify that the profile picture has been downloaded, using NSNotificationCenter
                        [[NSNotificationCenter defaultCenter] postNotificationName:N_ProfilePictureLoaded object:nil];
                    }];
                    
                    // Add the User to the list of friends in the DataStore
                    [[DataStore instance].fbFriends setObject:me forKey:me.objectID];
                    [DataStore instance].user = me;
                }
                // Callback - login successful
                // 1. Build a Facebook Request object to retrieve your friends from Facebook.
                FBRequest *friendsRequest = [FBRequest requestForMyFriends];
                [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                              NSDictionary* result,
                                                              NSError *error) {
                    NSLog(@"Friend Callback");
                    // 2 Loop through the array of FBGraphUser objects data returned from the Facebook request.
                    NSArray *friends = result[@"data"];
                    NSLog(@"Friend Callback: %@", friends);
                    for (NSDictionary<FBGraphUser>* friend in friends) {
                        NSLog(@"Found a friend: %@", friend.name);
                        // Launch another thread to handle the download of the friend's Facebook profile picture
                        [[NSOperationQueue profilePictureOperationQueue] addOperationWithBlock:^ {
                            // Build a profile picture URL from the friend's Facebook user id
                            NSString *profilePictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", friend.objectID];
                            NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]];
                            UIImage *profilePicture = [UIImage imageWithData:profilePictureData];
                            
                            // Set the profile picture into the user object
                            if (profilePicture) [friend setObject:profilePicture forKey:User_FacebookProfilePicture];
                            
                            // Notify that the profile picture has been downloaded, using NSNotificationCenter
                            //[[NSNotificationCenter defaultCenter] postNotificationName:N_ProfilePictureLoaded object:nil];
                        }];
                        // 3 Add each friend’s FBGraphUser object to the friends list in the DataStore.
                        // Add the friend to the list of friends in the DataStore
                        
                        [[DataStore instance].fbFriends setObject:friend forKey:friend.objectID];
                        [[DataStore instance].fbFriendsArray addObject:friend];
                    }
                    
                    // 4 The success callback to the delegate is now only called once the friends request has been made.
                    // Callback - login successful
                    if ([delegate respondsToSelector:@selector(commsDidLogin:)]) {
                        [delegate commsDidLogin:YES];
                    }
                }];
            }];
		}
	}];
  
}

+ (void) startNewGameWithUsers: (NSArray *)fbFriendsInGame forDelegate:(id<CreateGameDelegate>)delegate
{

    // Add Current User to the Game
    NSMutableArray *allPlayersInGame = [[NSMutableArray alloc] initWithArray:fbFriendsInGame];
    [allPlayersInGame addObject:[[PFUser currentUser] objectForKey:User_FacebookID]];
    //Must Have more than 3 users
    if(allPlayersInGame.count < 3)
    {
        //Return Error
        [delegate newGameUploadedToServer:NO info:@"Not Enough Players in Game!"];
        return;
    }
    
    //Check if this game already exists
    //Query returns all games that contain the players above
    PFQuery *checkIfGameExistsQuery = [PFQuery queryWithClassName:@"Game"];
    [checkIfGameExistsQuery whereKey:@"players" containsAllObjectsInArray:allPlayersInGame];
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
                if([allPlayersInGame count] == [[[objects objectAtIndex:i] objectForKey:@"players"] count])
                {
                    [delegate newGameUploadedToServer:NO info:@"A game with these users already exists!"];
                    return;
                }
            }
        }
        
        //Create the game
        PFObject *gameObject = [PFObject objectWithClassName:@"Game"];
        gameObject[@"rounds"] = @0;
        gameObject[@"players"] = allPlayersInGame;
        
        //Create the first round for this Game
        PFObject *roundObject = [PFObject objectWithClassName:@"CurrentRounds"];
        roundObject[@"judge"] = [[PFUser currentUser] objectForKey:User_FacebookID];
        roundObject[@"subject"] = [fbFriendsInGame objectAtIndex:0];
        roundObject[@"category"] = @"What would be the first thing they would fo after a one night stand?";
        gameObject[@"currentRound"] = roundObject;
        
        
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
    PFQuery *getGames = [PFQuery queryWithClassName:@"Game"];
    
    [getGames orderByAscending:@"createdAt"];
    NSArray *user =[[NSArray alloc] initWithObjects:[[PFUser currentUser] objectForKey:@"fbId"], nil];
    
    //find all games that have the current user as a player
    [getGames whereKey:@"players" containsAllObjectsInArray:user];
    
    [getGames findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [delegate didGetGamesDelegate:NO info: error.localizedDescription];
		} else {
            [[UserGames instance] reset];
            [[[UserGames instance] games] addObjectsFromArray:objects];
            
            // Notify that all the current games have been downloaded
            [delegate didGetGamesDelegate:YES info: nil];

          //  [[NSNotificationCenter defaultCenter] postNotificationName:N_GamesDownloaded object:nil];
            
        }
    }];
    /*
    // Callback
    if ([delegate respondsToSelector:@selector(commsDidGetUserGames)]) {
        [delegate didGetGamesDelegate:(BOOL)success info: (NSString *) info;];
    }*/
}

+ (void) getCommentsForGameId:(NSString *)gameId inRound:(NSString *)round forDelegate:(id<CommsDelegate>)delegate
{
    NSMutableDictionary* comments = [[NSMutableDictionary alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"gameID" equalTo:gameId];
    [query whereKey:@"round" equalTo:round];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
            
        } else {
           // [UserGames insta]
            [[CurrentRounds instance] reset];
            
            
            [[CurrentRounds instance] setComments:objects];

            
            // Notify - Image Downloaded from Parse
            [[NSNotificationCenter defaultCenter] postNotificationName:N_CommentsDownloaded object:nil];
            
        }
    }];
    // Callback
    if ([delegate respondsToSelector:@selector(commsDidGetComments:)]) {
        [delegate commsDidGetComments:comments];
    }
}


+ (void) addComment:(NSString *)comment to:(NSString *)toFBId toGameId:(NSString *)gameId inRound:(NSString *)round withCategory:(NSString *)category
{
  
    //Check to see if the comment exists already
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"toFBId" equalTo:toFBId];
    [query whereKey:@"fromFBId" equalTo:[[PFUser currentUser] objectForKey:@"fbId"]];
    [query whereKey:@"gameID" equalTo:gameId];
    [query whereKey:@"round" equalTo:@"1"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            NSLog(@"The getFirstObject request failed.");
            PFObject *commentObject = [PFObject objectWithClassName:@"Comment"];
            commentObject[@"toFBId"] = toFBId;
            commentObject[@"fromFBId"] = [[PFUser currentUser] objectForKey:@"fbId"];
            commentObject[@"comment"] = comment;
            commentObject[@"category"] = category;
            commentObject[@"gameID"] = gameId;
            commentObject[@"round"] = @"1";
            commentObject[@"votedFor"] = [[NSArray alloc] init];
            [commentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // Notify that the Comment has been uploaded, using NSNotificationCenter
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_CommentUploaded object:nil];
                    NSLog(@"Uploaded New comment");
                }
                else{
                    NSLog(@"Uploaded New comment failed: %@",error.localizedDescription);
                }
            }];
            
        } else {
            // The find succeeded.
            NSLog(@"Successfully retrieved the object.");
            object[@"comment"] = comment;
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // Notify that the Comment has been uploaded, using NSNotificationCenter
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_CommentUploaded object:nil];
                    NSLog(@"Updated comment");
                }
                else{
                     NSLog(@"Updated comment failed: %@",error.localizedDescription);
                }
            }];
        }
    }];
}

+ (void) user:(NSString *)userId DidUpvote:(BOOL)voted forComment:(NSString *)commentId forDelegate:(id<VoteForCommentDelegate>)delegate
{
    //Check to see if the comment exists already
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"objectId" equalTo: commentId];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        //No comment found
        if (!object) {
            [delegate votedForCommentNotFound];
        //Error with found comment
        } if (error) {
            [delegate errorGettingVoteComment:error];
        } else {
            // The query succeeded.
            NSMutableArray* votedFor = object[@"votedFor"];
            BOOL changed = false;
            if(voted)
            {
                if(![votedFor containsObject:userId])
                {
                    [votedFor addObject:userId];
                    changed = true;
                    
                }
            } else{
                if([votedFor containsObject:userId])
                {
                    [votedFor removeObject:userId];
                    changed = true;
                }
            }
            if(changed)
            {
                object[@"votedFor"] = votedFor;
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [delegate userSuccesffullyVotedForComment:voted];
                    }
                    else{
                        [delegate errorSavingVoteForComment:error];
                    }
                }];
            //Thes user did not change their vote, no update was made
            }else{
                [delegate userDidNotChangeVoteOnComment];
            }
        }
    }];
}



@end
