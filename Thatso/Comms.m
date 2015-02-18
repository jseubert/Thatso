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
                [[User currentUser] setObject:[me objectForKey:ID] forKey:UserFacebookID];
                [[User currentUser] setObject:[me objectForKey:UserFirstName] forKey:UserFirstName];
                [[User currentUser] setObject:[me objectForKey:UserLastName] forKey:UserLastName];
                [[User currentUser] setObject:[me objectForKey:UserFullName] forKey:UserFullName];
                [[User currentUser] saveInBackground];
                
                // Launch another thread to handle the download of the user's Facebook profile picture
                [Comms getProfilePictureForUser:[user objectForKey:UserFacebookID] withBlock:nil];
                
                    
                // Add the User to the list of friends in the DataStore
                //[[DataStore instance].fbFriends setObject:user forKey:[user objectForKey:UserFacebookID]];
                
                //Now get all your friends and make sure theyre added
                [Comms getAllFacebookFriends:delegate];
            }
        }];
    }
    }];
}

+ (void) getAllFacebookFriends:(id<DidLoginDelegate>)delegate
{
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
             
             PFQuery *getFBFriends = [User query];
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
                         [Comms getProfilePictureForUser:[friend objectForKey:UserFacebookID] withBlock:nil];
                     }
                     
                     [Comms getCategories];
                     
                     [delegate didlogin:YES info: nil];
                 }
             }];
         }
     }];
}

+ (void) startNewGameWithUsers:(NSMutableArray *)fbFriendsInGame withName:(NSString*)gameName familyFriendly:(BOOL)familyFriendly forDelegate:(id<CreateGameDelegate>)delegate
{
    // Add Current User to the Game
    NSMutableArray *allPlayersInGame = [[NSMutableArray alloc] initWithArray:fbFriendsInGame];
    [allPlayersInGame addObject:[User currentUser]];
    //Must Have more than 3 users
    if(allPlayersInGame.count < 3)
    {
        //Return Error
       // [delegate newGameUploadedToServer:NO info:@"Not Enough Players in Game!"];
        //return;
    }
    
    
    
    /*
    //Check if this game already exists
    //Query returns all games that contain the players above
    PFQuery *checkIfGameExistsQuery = [PFQuery queryWithClassName:GameClass];
    [checkIfGameExistsQuery includeKey:GamePlayers];
    [checkIfGameExistsQuery whereKey:GamePlayers containsAllObjectsInArray:allPlayersInGame];
    [checkIfGameExistsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        //Error With Query
        if(error)
        {
            [delegate newGameUploadedToServer:NO game:nil info:error.fberrorUserMessage];
        }
        //Check if this game already exists
        else if(objects != NULL && [objects count] > 0)
        {
            //Check each game returned. If a game has a same amount of players as the original ID's passed, then it is a duplicate game
            for(int i = 0; i < [objects count]; i ++)
            {
                if([allPlayersInGame count] == [[[objects objectAtIndex:i] objectForKey:GamePlayers] count])
                {
                    [delegate newGameUploadedToServer:NO game:nil info:@"A game with these users already exists!"];
                    return;
                }
            }
        }
        
        //Create the game
        
        Game *gameObject = [Game object];
        gameObject.rounds = @1;
        gameObject.players = allPlayersInGame;
        gameObject.gameName = gameName;
        gameObject.familyFriendly = familyFriendly;
        
        //Create the first round for this Game
        Round *roundObject = [Round object];
        roundObject.judge = [User currentUser].fbId;
        roundObject.subject = ((User *)[fbFriendsInGame objectAtIndex:0]).fbId;
        roundObject.roundNumber = @1;
        roundObject.responded = [[NSArray alloc] init];
      
        //Get new category
        [Comms getCategories];
        GenericCategory *category = [[DataStore instance].categories objectAtIndex:(arc4random() % [DataStore instance].categories.count)];
        
        roundObject[RoundCategory] = [NSString stringWithFormat:@"%@ %@%@", category.startText, [gameObject playerWithfbId:roundObject.subject].first_name, category.endText];
        
        
        
        gameObject.currentRound = roundObject;
        
       
        [gameObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if (succeeded) {
                // 4 If the save was successful, save the comment in another new Parse object. Again, save the  user’s name and Facebook user ID along with the comment string.

                
                //Check to make sure that someone else didnt update at the exact same time. If so, delete this object
                //Don't know a better way to do this at the moment...
                PFQuery *checkIfGameExistsQuery = [PFQuery queryWithClassName:GameClass];
                [checkIfGameExistsQuery includeKey:GamePlayers];
                [checkIfGameExistsQuery whereKey:GamePlayers containsAllObjectsInArray:allPlayersInGame];
                [checkIfGameExistsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                 {
                     //Error With Query
                     if(error)
                     {
                         [delegate newGameUploadedToServer:NO game:nil info:error.fberrorUserMessage];
                     }
                     //Check if this game already exists
                     else if(objects != NULL && [objects count] > 1)
                     {
                         //Check each game returned. If a game has a same amount of players as the original ID's passed, then it is a duplicate game
                         for(int i = 0; i < [objects count]; i ++)
                         {
                             if([allPlayersInGame count] == [[[objects objectAtIndex:i] objectForKey:GamePlayers] count])
                             {
                                 [gameObject.currentRound deleteInBackground];
                                 [gameObject deleteInBackground];
                                 [delegate newGameUploadedToServer:NO game:nil info:@"An error occured creating this game. Someone else may be trying to start a game with these players too!"];
                                 return;
                             }
                         }
                     }
                     
                     //Everything looks good?
                     [[UserGames instance] addGame:gameObject];
                     [delegate newGameUploadedToServer:YES game:gameObject info:@"Success"];
                 }];
             
            } else {
                    // 6 If there was an error saving the new game object, report the error
                [delegate newGameUploadedToServer:NO game:nil info:error.fberrorUserMessage];
            }
        }];
        
    }];
    */
    //Create the game
    
    Game *gameObject = [Game object];
    gameObject.rounds = @1;
    gameObject.players = allPlayersInGame;
    gameObject.gameName = gameName;
    gameObject.familyFriendly = familyFriendly;
    
    //Create the first round for this Game
    Round *roundObject = [Round object];
    roundObject.judge = [User currentUser].fbId;
    roundObject.subject = ((User *)[fbFriendsInGame objectAtIndex:0]).fbId;
    roundObject.roundNumber = @1;
    roundObject.responded = [[NSArray alloc] init];
    
    //Get new category
    [Comms getCategories];
    GenericCategory *category = [[DataStore instance].categories objectAtIndex:(arc4random() % [DataStore instance].categories.count)];
    
    roundObject.category = [NSString stringWithFormat:@"%@ %@%@", category.startText, [gameObject playerWithfbId:roundObject.subject].first_name, category.endText];
    
    roundObject.categoryID = category.objectId;
    
    gameObject.currentRound = roundObject;
    
    
    [gameObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded) {
             // 4 If the save was successful, save the comment in another new Parse object. Again, save the  user’s name and Facebook user ID along with the comment string.
             //Everything looks good?
            [[UserGames instance] addGame:gameObject];
            [delegate newGameUploadedToServer:YES game:gameObject info:@"Success"];
             
         } else {
             // 6 If there was an error saving the new game object, report the error
             [delegate newGameUploadedToServer:NO game:nil info:error.fberrorUserMessage];
         }
     }];
}

+(void) getUsersGamesforDelegate:(id<GetGamesDelegate>)delegate
{
    PFQuery *getGames = [PFQuery queryWithClassName:GameClass];
    
    [getGames orderByDescending:UpdatedAt];
    [getGames includeKey:GameCurrentRound];
    [getGames includeKey:GamePlayers];
    
    NSArray *user =[[NSArray alloc] initWithObjects:[User currentUser], nil];
    //find all games that have the current user as a player
    [getGames whereKey:GamePlayers containsAllObjectsInArray:user];
    
    [getGames findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [delegate didGetGamesDelegate:NO info: error.localizedDescription];
		} else {
            [[UserGames instance] reset];
            for(int i = 0; i < objects.count; i ++)
            {
                [[UserGames instance] addGame:[objects objectAtIndex:i]];
            }
            
            // Notify that all the current games have been downloaded
            [delegate didGetGamesDelegate:YES info: nil];
        }
    }];
}


+ (void) addComment:(Comment*)comment toRound:(Round*)round forDelegate:(id<DidAddCommentDelegate>)delegate{
    //Check if this round is still active
    PFQuery *roundQuery = [PFQuery queryWithClassName:RoundClass];
    [roundQuery whereKey:ObjectID equalTo:comment.roundID];
    [roundQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
    {
        if(error)
        {
            //no game found, must be wrong round
             if(error.code == 101)
             {
                [delegate didAddComment:NO needsRefresh:YES addedComment:nil info:@"This round is over, getting new round!"];
             } else {
                [delegate didAddComment:NO needsRefresh:NO addedComment:nil info:error.localizedDescription];
             }
        
        }else{
            //round not active, need to refresh view
            if(!object)
            {
                [delegate didAddComment:NO needsRefresh:YES addedComment:nil info:@"This round is over, getting new round!"];
            }
            //active round
            else{
                //Check to see if the comment exists already
                PFQuery *query = [PFQuery queryWithClassName:CommentClass];
                
                [query whereKey:CommentGameID equalTo:comment.gameID];
                [query whereKey:CommentRoundID equalTo:comment.roundID];
                [query whereKey:CommentFrom equalTo:comment.from];
                [query includeKey:CommentFrom];
                //Check if
                
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    //Comment does not exist. Add it.
                    if(!object)
                    {
                        
                        [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                // Notify that the Comment has been uploaded
                                //Also add to round
                                NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:((Round*)round).responded];
                                [newArray addObject:comment.from.fbId];
                                round.responded = newArray;
                                [round saveInBackground];
                                
                                [delegate didAddComment:YES needsRefresh:NO addedComment:comment info:nil];
                            }
                            else{
                                [delegate didAddComment:NO needsRefresh:NO addedComment:nil info:error.localizedDescription];
                            }
                        }];
                        
                    } else {
                        object[CommentResponse] = comment.response;
                        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                // Notify that the Comment has been uploaded, using NSNotificationCenter
                                [delegate didAddComment:YES needsRefresh:NO addedComment:(Comment*)object info:@"Success"];
                            }
                            else{
                                [delegate didAddComment:NO needsRefresh:NO addedComment:nil info:error.localizedDescription];
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
    [query includeKey:CommentFrom];
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

    NSArray *players = game.players;
    
    //increment round number for game
    [game incrementKey:GameRounds];

    //Build a new round and update the game with it's current round
    Round *roundObject = [Round object];
    
    //Get new judge, next in array
    for(int i = 0; i < players.count; i ++)
    {
        if([((User*)players[i]).fbId isEqualToString:round.judge])
        {
            //last one so now cycle to first one
            if(i == players.count -1)
            {
                roundObject.judge = ((User*)players[0]).fbId;
            }else{
                roundObject.judge = ((User*)players[i + 1]).fbId;
            }
            break;
        }
    }
        
    //get new subject, make sure its not the judge
    NSMutableArray *nonJudgePlayers = [[NSMutableArray alloc] init];
    for (User* player in players)
    {
        if(![player.fbId isEqualToString:roundObject.judge])
        {
            [nonJudgePlayers addObject:player.fbId];
        }
    }
    roundObject.subject = [nonJudgePlayers objectAtIndex:(arc4random() % nonJudgePlayers.count)];
        
    //Get new category
    [Comms getCategories];
    GenericCategory *category = [[DataStore instance].categories objectAtIndex:(arc4random() % [DataStore instance].categories.count)];
    
    roundObject.category = [NSString stringWithFormat:@"%@ %@%@", category.startText, [game playerWithfbId:roundObject.subject].first_name, category.endText];
    
    roundObject.categoryID = category.objectId;
    
    //new round round
    roundObject.roundNumber = game.rounds;
    
    game.currentRound = roundObject;
    
    [game saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded)
        {
            //Build archivedRound object and save it
            CompletedRound *completedRound = [CompletedRound object];
            completedRound.judge = [game playerWithfbId:round.judge];
            completedRound.subject = [game playerWithfbId:round.subject];
            completedRound.category = round.category;
            completedRound.roundNumber = round.roundNumber;
            completedRound.gameID = game.objectId;
            completedRound.categoryID = round.categoryID;
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
                                    [[UserGames instance] addGame:game];
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

+(void) getNewCategoryWithSubjects: (NSMutableArray *)players inGame:(NSString *)gameId familyRated:(BOOL)familyRated withBlock:(void (^)(GenericCategory*category, NSString* userId, BOOL success,  NSString* info))block
{
    NSMutableArray *shuffledPlayers = [[NSMutableArray alloc] init];
    while(players.count > 0)
    {
        int randomIndex = arc4random()%players.count;
        [shuffledPlayers addObject:[players objectAtIndex:randomIndex]];
        [players removeObjectAtIndex:randomIndex];
    }
    
    NSMutableArray *shuffledCategories = [[NSMutableArray alloc] init];
    NSMutableArray *categoriesFrom;
    if(familyRated)
    {
        categoriesFrom = [[DataStore instance].familyCategories copy];
    }else{
        categoriesFrom = [[DataStore instance].categories copy];
    }
    while(categoriesFrom.count > 0)
    {
        int randomIndex = arc4random()%categoriesFrom.count;
        [shuffledCategories addObject:[categoriesFrom objectAtIndex:randomIndex]];
        [categoriesFrom removeObjectAtIndex:randomIndex];
    }
    
    PFQuery *getCompletedCategories = [PFQuery queryWithClassName:CompletedRoundCategory];
    [getCompletedCategories whereKey: CompletedRoundGameID equalTo:gameId];
    //[getCompletedCategories whereKey: CompletedRoundSubject equalTo:userId];
    [getCompletedCategories includeKey:CompletedRoundCategoryID];
    [getCompletedCategories includeKey:CompletedRoundJudge];
    [getCompletedCategories findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            block(nil, nil, NO, error.description);
        } else if(objects != NULL && [objects count] > 0)
        {
            block(shuffledCategories[0],shuffledPlayers[0],NO, @"");
        } else
        {
            BOOL categoryOK = false;
            for(GenericCategory *potentialCategory in shuffledCategories)
            {
                BOOL found = false;
                for(NSString *userID in shuffledPlayers)
                {
                    for(CompletedRound *completedRound in objects)
                    {
                        //This category was already done with this person
                        if([potentialCategory.objectId isEqualToString:completedRound.categoryID] && [userID isEqualToString:completedRound.subject.fbId])
                        {
                            found = true;
                            break;
                        }
                    }
                    if(found == true)
                    {
                        break;
                    }
                    //Category does not match user. use it!
                    else{
                        block(potentialCategory, userID, YES, @"");
                        return;
                    }
                }
                
            }
            block(nil, nil, NO, @"Blimey, every category has been played! Either start a new game or wait for an update with more categories!");
            return;
        }
    }];
    
}

    



+ (void) getPreviousRoundsInGame: (Game * ) game forDelegate:(id<DidGetPreviousRounds>)delegate
{
    PFQuery *getRounds = [PFQuery queryWithClassName:CompletedRoundClass];
    
    [getRounds orderByDescending:CompletedRoundNumber];
    [getRounds whereKey:CompletedRoundGameID equalTo:game.objectId];
    [getRounds includeKey:CompletedRoundJudge];
    [getRounds includeKey:CompletedRoundSubject];
    [getRounds includeKey:CompletedRoundWinningResponseFrom];
    
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
    
    PFQuery *getFamilyCategory = [PFQuery queryWithClassName:CategoryClass];
    [getFamilyCategory whereKey:CategoryIsPG equalTo:[NSNumber numberWithBool:YES]];
    [DataStore instance].familyCategories = [[NSMutableArray alloc] initWithArray:[getFamilyCategory findObjects]];
    
    NSLog(@"Categories: %@", [DataStore instance].categories);
    NSLog(@"FamilyCategoreis: %@", [DataStore instance].familyCategories);
}

+ (void) getuser: (NSString *)fbId
{
    PFQuery *getUser = [User query];
    [getUser whereKey:UserFacebookID containsString:fbId];
    
    User* user = (User *)[getUser getFirstObject];
    if(user != nil)
    {
        [[DataStore instance].fbFriends setObject:user forKey:fbId];
    
        [Comms getProfilePictureForUser:[user objectForKey:UserFacebookID] withBlock:nil];
    }
}


+ (void) getProfilePictureForUser: (NSString*) fbId withBlock:(void (^)(UIImage*))block
{
    [[NSOperationQueue profilePictureOperationQueue] addOperationWithBlock:^ {
        // Build a profile picture URL from the user's Facebook user id
        NSString *profilePictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", fbId];
        NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]];
        UIImage *profilePicture = [UIImage imageWithData:profilePictureData];
        // Set the profile picture into the user object
        if (profilePicture)
        {
            @synchronized(self){
                [[DataStore instance].fbFriendsProfilePictures setObject:profilePicture forKey:fbId];
            }
        }
        if(block != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
                 block(profilePicture);
            });
        }
    }];
}




@end
