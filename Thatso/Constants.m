//
//  Constants.m
//  Thatso
//
//  Created by John A Seubert on 11/5/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "Constants.h"

#pragma mark Notifications
NSString * const N_GamesDownloaded = @"N_GamesDownloaded";
NSString * const N_ProfilePictureLoaded = @"N_ProfilePictureLoaded";
NSString * const N_CommentUploaded = @"N_CommentUploaded";
NSString * const N_CommentsDownloaded = @"N_CommentsDownloaded";
NSString * const N_VotedForComment = @"N_VotedForComment";

#pragma mark Classes
NSString * const UserClass = @"User";
NSString * const CommentClass = @"Comment";
NSString * const GameClass = @"Game";
NSString * const RoundClass = @"Round";
NSString * const CompletedRoundClass = @"CompletedRound";
NSString * const CategoryClass = @"Category";

#pragma mark universal class fields
NSString * const UpdatedAt = @"updatedAt";
NSString * const CreatedAt = @"createdAt";
NSString * const ID = @"id";
NSString * const ObjectID = @"objectId";

#pragma mark user fields
NSString * const UserFacebookID = @"fbId";
NSString * const UserFirstName = @"first_name";
NSString * const UserLastName = @"last_name";
NSString * const UserFullName = @"name";
NSString * const UserFacebookProfilePicture = @"fbProfilePicture";

#pragma mark Game Fields
NSString * const GamePlayers = @"players";
NSString * const GameRounds = @"rounds";
NSString * const GameCurrentRound = @"currentRound";

#pragma mark Round Fields
NSString * const RoundJudge = @"judge";
NSString * const RoundSubject = @"subject";
NSString * const RoundCategory = @"category";
NSString * const RoundNumber = @"roundNumber";

#pragma mark Comment Fields
NSString * const CommentGameID = @"gameID";
NSString * const CommentRoundID = @"roundID";
NSString * const CommentFrom = @"from";
NSString * const CommentResponse = @"response";

#pragma mark Completed Rounds Fields
NSString * const CompletedRoundJudge = @"judge";
NSString * const CompletedRoundSubject = @"subject";
NSString * const CompletedRoundCategory = @"category";
NSString * const CompletedRoundNumber = @"roundNumber";
NSString * const CompletedRoundGameID = @"gameID";
NSString * const CompletedRoundWinningResponse = @"winningResponse";
NSString * const CompletedRoundWinningResponseFrom = @"winningResponseFrom";

#pragma mark Category Fields
NSString * const CategoryStartText = @"startText";
NSString * const CategoryEndText = @"endText";
NSString * const CategoryCount = @"categoryCount";
NSString * const CategoryVersionAdded = @"versionAdded";
NSString * const CategoryIsPG = @"isPG";
NSString * const CategoryIsAdult = @"isAdult";
