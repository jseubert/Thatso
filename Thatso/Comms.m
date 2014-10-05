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

NSString * const N_GamesDownloaded = @"N_GamesDownloaded";
NSString * const N_ProfilePictureLoaded = @"N_ProfilePictureLoaded";

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
                    [[PFUser currentUser] setObject:me.objectID forKey:@"fbId"];
                    NSLog(@"Added you: %@", me.name);
                    [[PFUser currentUser] saveInBackground];
                    
                    // Launch another thread to handle the download of the user's Facebook profile picture
                    [[NSOperationQueue profilePictureOperationQueue] addOperationWithBlock:^ {
                        // Build a profile picture URL from the user's Facebook user id
                        NSString *profilePictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", me.objectID];
                        NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]];
                        UIImage *profilePicture = [UIImage imageWithData:profilePictureData];
                        
                        // Set the profile picture into the user object
                        if (profilePicture) [me setObject:profilePicture forKey:@"fbProfilePicture"];
                        
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
                            if (profilePicture) [friend setObject:profilePicture forKey:@"fbProfilePicture"];
                            
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
    
    //Offline Testing
    //[delegate commsDidLogin:YES];
}

+ (void) startNewGameWithUsers: (NSMutableArray *)fbFriendsInGame forDelegate:(id<CommsDelegate>)delegate
{
    NSLog(@"startNewGameWithUsers: " );
    // 1 Add this user to the players
    [fbFriendsInGame addObject:[[PFUser currentUser] objectForKey:@"fbId"]];
    NSLog(@"fbFriendsInGame: %@", fbFriendsInGame );
    
    //Check if this game already exists
    //Query returns all games that contain the players above
    PFQuery *checkIfGameExistsQuery = [PFQuery queryWithClassName:@"Game"];
    [checkIfGameExistsQuery whereKey:@"players" containsAllObjectsInArray:fbFriendsInGame];
    [checkIfGameExistsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if(error)
        {
            if ([delegate respondsToSelector:@selector(newGameUploadedToServer:info:)]) {
                [delegate newGameUploadedToServer:NO info:error.fberrorUserMessage];
            }
        }
        //Check if this game already exists
        else if(objects != NULL && [objects count] > 0)
        {
            if([objects count] == 1)
            {
                if([fbFriendsInGame count] == [[[objects objectAtIndex:0] objectForKey:@"players"] count])
                {
                    if ([delegate respondsToSelector:@selector(newGameUploadedToServer:info:)]) {
                        [delegate newGameUploadedToServer:NO info:@"A game with these users already exits!"];
                    }
                    return;
                }
            }else{
                if ([delegate respondsToSelector:@selector(newGameUploadedToServer:info:)]) {
                    [delegate newGameUploadedToServer:NO info:@"A game with these users already exits!"];
                }
                return;
            }
        }
        
        PFObject *gameObject = [PFObject objectWithClassName:@"Game"];
        gameObject[@"rounds"] = [NSNumber numberWithInt:0];
        gameObject[@"players"] = fbFriendsInGame;
        [gameObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if (succeeded) {
                // 4 If the save was successful, save the comment in another new Parse object. Again, save the  user’s name and Facebook user ID along with the comment string.
                if ([delegate respondsToSelector:@selector(newGameUploadedToServer:info:)]) {
                    [delegate newGameUploadedToServer:YES info:@"Success"];
                }
            } else {
                    // 6 If there was an error saving the Wall Image Parse object, report the failure back to the delegate class.
                if ([delegate respondsToSelector:@selector(newGameUploadedToServer:info:)]) {
                    [delegate newGameUploadedToServer:NO info:error.fberrorUserMessage];
                }
            }
        }];
        
    }];
}

+(void) getUsersGamesforDelegate:(id<CommsDelegate>)delegate
{
    NSLog(@"getUsersGamesforDelegate");
    PFQuery *getGames = [PFQuery queryWithClassName:@"Game"];
    [getGames orderByAscending:@"createdAt"];

    NSArray *user =[[NSArray alloc] initWithObjects:[[PFUser currentUser] objectForKey:@"fbId"], nil];
    
    [getGames whereKey:@"players" containsAllObjectsInArray:user];
    
    NSLog(@"getUsersGamesforDelegate: %@", user);
    [getGames findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
			NSLog(@"Objects error: %@", error.localizedDescription);
		} else {
            [[UserGames instance] reset];
            [objects enumerateObjectsUsingBlock:^(PFObject *game, NSUInteger idx, BOOL *stop) {
                Game *newGame = [[Game alloc] init];
                newGame.players = game[@"players"];
               // newGame.rounds = game[@"rounds"];
                newGame.objectId = game.objectId;
                NSLog(@"Found Game: %@", newGame.players);
                
                [[UserGames instance].games addObject:newGame];
                
                
            }];
            
            // Notify - Image Downloaded from Parse
            [[NSNotificationCenter defaultCenter] postNotificationName:N_GamesDownloaded object:nil];
            
        }
    }];
    // Callback
    if ([delegate respondsToSelector:@selector(commsDidGetUserGames)]) {
        [delegate commsDidGetUserGames];
    }
     
    

}



@end
