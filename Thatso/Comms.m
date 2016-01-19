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
                    
                    NSArray *nameArray = [[me objectForKey:UserFullName] componentsSeparatedByString:@" "];

                    
                    [[User currentUser] setObject:[nameArray objectAtIndex:0] forKey:UserFirstName];
                    [[User currentUser] setObject:[nameArray objectAtIndex:nameArray.count - 1] forKey:UserLastName];
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
}

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
