//
//  Comms.m
//  Thatso
//
//  Created by John A Seubert on 8/22/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "NSOperationQueue+NSoperationQueue_SharedQueue.h"
#import "AppDelegate.h"
#import "GameManager.h"
#import "Comms.h"
#import "FriendsManager.h"
#import "RoundManager.h"
#import "User.h"





@implementation Comms

//Notifications 
+ (void) login:(id<DidLoginDelegate>)delegate
{
    // Reset the DataStore so that we are starting from a fresh Login
    // as we could have come to this screen from the Logout navigation
    [[DataStore instance] reset];
   // [[UserGames instance] reset];
    [[GameManager instance] clearData];
    [[FriendsManager instance] clearData];
    [[RoundManager instance] clearData];
    
  //  [[CurrentRounds instance] reset];
    [[PreviousRounds instance] reset];
    
	// Basic User information and your friends are part of the standard permissions
	// so there is no reason to ask for additional permissions
    
    NSArray *permissionsArray = @[ @"public_profile", @"user_friends"];

    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        // Was login successful ?
        if (!user) {
            if (!error) {
                [delegate didlogin:NO info:@"The Facebook login was cancelled."];
            } else {
                [delegate didlogin:NO info: [NSString stringWithFormat:@"An error occurred: %@", error.localizedDescription]];
            }
            return;
        }
        else
        {
                //Login Successful - Update user and find friends
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                           parameters:nil];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                // TODO: handle results or error of request.
                if (!error) {
                    NSDictionary *me = (NSDictionary *)result;
                    [[User currentUser] setObject:[me objectForKey:ID] forKey:UserFacebookID];
                    [[User currentUser] setObject:[me objectForKey:UserFirstName] forKey:UserFirstName];
                    [[User currentUser] setObject:[me objectForKey:UserLastName] forKey:UserLastName];
                    [[User currentUser] setObject:[me objectForKey:UserFullName] forKey:UserFullName];
                    [[User currentUser] saveInBackground];
                    
                    [[FriendsManager instance] getFriendProfilePictureWithID:[user objectForKey:UserFacebookID] withBlock:nil];
                    
                    //Now get all your friends and make sure theyre added
                    [[FriendsManager instance] getAllFacebooFriendsWithBlock:^(bool success, NSString *response) {
                        if(success)
                        {
                            [delegate didlogin:YES info: nil];
                        } else{
                            [delegate didlogin:NO info: response];
                        }
                    }];

                } else {
                    [delegate didlogin:NO info: @"Could not get Facebook info. Try again."];
                }

            }];
        }
    }];
            /*
	[PFFacebookUtils logInWithPermissions:[NSArray arrayWithObjects:@"user_friends", nil] block:^(PFUser *user, NSError *error) {
		// Was login successful ?
		if (!user) {
			if (!error) {
                [delegate didlogin:NO info:@"The Facebook login was cancelled."];
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
                //[Comms getProfilePictureForUser:[user objectForKey:UserFacebookID] withBlock:nil];
                [[FriendsManager instance] getFriendProfilePictureWithID:[user objectForKey:UserFacebookID] withBlock:nil];
                
                //Now get all your friends and make sure theyre added
                [[FriendsManager instance] getAllFacebooFriendsWithBlock:^(bool success, NSString *response) {
                    if(success)
                    {
                         [delegate didlogin:YES info: nil];
                    } else{
                        [delegate didlogin:NO info: response];
                    }
                }];
            }
        }];
    }
    }];*/
}

/*
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
            [[RoundManager instance] setComments:objects forGameId:game.objectId];
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
        
    //Get new category
    if([DataStore instance].familyCategories.count == 0 || [DataStore instance].familyCategories.count == 0)
    {
        [Comms getCategories];
    }
    
    [self getNewCategoryWithSubjects:nonJudgePlayers inGame:game.objectId familyRated:game.familyFriendly reloadCategories:YES withBlock:
     ^(GenericCategory *category, NSString *userId, BOOL success, NSString *info) {
         if(!success)
         {
             [delegate didStartNewRound:NO info:info previousWinner:nil];
         }else
         {
             //new round round
             roundObject.roundNumber = game.rounds;
             roundObject.subject = userId;
             roundObject.category = [NSString stringWithFormat:@"%@ %@%@", category.startText, [game playerWithfbId:roundObject.subject].first_name, category.endText];
             roundObject.categoryID = category.objectId;
             
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
                                             [[GameManager instance] addGame:game];
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
    }];
}*/

+(void) getNewCategoryWithSubjects: (NSMutableArray *)players inGame:(NSString *)gameId familyRated:(BOOL)familyRated reloadCategories:(BOOL)reloadCategories withBlock:(void (^)(GenericCategory*category, NSString* userId, BOOL success,  NSString* info))block
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
        categoriesFrom = [[NSMutableArray alloc] initWithArray:[DataStore instance].familyCategories];
    }else{
        categoriesFrom = [[NSMutableArray alloc] initWithArray:[DataStore instance].categories];
    }
    while(categoriesFrom.count > 0)
    {
        int randomIndex = arc4random()%categoriesFrom.count;
        [shuffledCategories addObject:[categoriesFrom objectAtIndex:randomIndex]];
        NSLog(@"%@",[categoriesFrom objectAtIndex:randomIndex]);
        [categoriesFrom removeObjectAtIndex:randomIndex];
    }
    
    PFQuery *getCompletedCategories = [PFQuery queryWithClassName:CompletedRoundClass];
    [getCompletedCategories whereKey: CompletedRoundGameID equalTo:gameId];
    //[getCompletedCategories whereKey: CompletedRoundSubject equalTo:userId];
    [getCompletedCategories includeKey:CompletedRoundSubject];
    [getCompletedCategories findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //Check for errors
        if (error) {
            block(nil, nil, NO, error.description);
        }
        //Check if no objects returned, that means anything can be added
        else if(objects == NULL || [objects count] == 0)
        {
            block(shuffledCategories[0],shuffledPlayers[0], YES, @"");
        } else
        {
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
            //No categories left. Try to reload the categories to see if there are any new ones
            if(reloadCategories)
            {
                //Try seeing if there are more categories
                [Comms getCategories];
                [self getNewCategoryWithSubjects:players inGame:gameId familyRated:familyRated reloadCategories:NO withBlock:^(GenericCategory *category, NSString *userId, BOOL success, NSString *info) {
                    block(category, userId, success, info);
                }];
                return;
            }else{
                block(nil, nil, NO, @"Blimey! Every category has been played! Either start a new game or wait for an update with more categories!");
                return;
            }
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
    //Get all categories
    PFQuery *getCategory = [PFQuery queryWithClassName:CategoryClass];
    [DataStore instance].categories = [[NSMutableArray alloc] initWithArray:[getCategory findObjects]];
    
    //Get family categories
    PFQuery *getFamilyCategory = [PFQuery queryWithClassName:CategoryClass];
    [getFamilyCategory whereKey:CategoryIsPG equalTo:[NSNumber numberWithBool:YES]];
    [DataStore instance].familyCategories = [[NSMutableArray alloc] initWithArray:[getFamilyCategory findObjects]];
}



@end
