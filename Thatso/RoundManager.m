//
//  RoundManager.m
//  Thatso
//
//  Created by John  Seubert on 6/29/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//

#import "RoundManager.h"
#import "Round.h"
#import "User.h"
#import "GameManager.h"

NSString * const RoundManagerNewRoundStarted = @"RoundManagerNewRoundStarted";

@implementation RoundManager

static RoundManager *instance = nil;
+ (RoundManager *) instance
{
    @synchronized (self) {
        if (instance == nil) {
            instance = [[RoundManager alloc] init];
        }
    }
    return instance;
}
- (id) init
{
    self = [super init];
    if (self) {
        self.currentComments = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) clearData
{
    self.currentComments = [[NSMutableDictionary alloc] init];
}

-(void) setComments: (NSArray*)comments forGameId: (NSString *) gameId{
    [self.currentComments setObject:comments forKey:gameId];
}

-(void) addComment: (Comment *)comment
{
    
    NSMutableArray *comments =[self.currentComments objectForKey: comment.gameID];
    for(Comment* existingComment in comments)
    {
        if([comment.objectId isEqualToString:existingComment.objectId])
        {
            [comments removeObject:existingComment];
            break;
        }
    }
    [comments addObject:comment];
}

-(void) refreshCommentID:(NSString *)commentId
{
    PFQuery *getComment = [PFQuery queryWithClassName:CommentClass];
    [getComment includeKey:CommentFrom];
    [getComment getObjectInBackgroundWithId:commentId block:^(PFObject *object, NSError *error) {
        Comment* comment = (Comment*)object;
        //Re-add the game
        [self addComment: comment];
        
    }];
}

- (void) refreshCommentID:(NSString *)commentId withBlock:(void (^)(Comment*))block{
    PFQuery *getComment = [PFQuery queryWithClassName:CommentClass];
    [getComment includeKey:CommentFrom];
    [getComment getObjectInBackgroundWithId:commentId block:^(PFObject *object, NSError *error) {
        Comment* comment = (Comment*)object;
        //Re-add the game
        [self addComment: comment];
        block(comment);
    }];
}

#pragma network calls
- (void) addComment:(Comment*)comment toRound:(Round*)round forDelegate:(id<DidAddCommentDelegate>)delegate
{
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
- (void) getActiveCommentsForGame:(Game*)game inRound:(Round*)round forDelegate:(id<DidGetCommentsDelegate>)delegate
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
            [[RoundManager instance] setComments:objects forGameId:game.objectId];
            [delegate didGetComments:YES info:nil];
        }
    }];
}
- (void) finishRound: (Round*)round inGame: (Game*)game withWinningComment: (Comment*)comment andOtherComments: (NSArray *)otherComments forDelegate:(id<DidStartNewRound>)delegate
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
    
    [Comms getNewCategoryWithSubjects:nonJudgePlayers inGame:game.objectId familyRated:game.familyFriendly reloadCategories:YES withBlock:
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
}
@end
