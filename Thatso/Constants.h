//
//  constants.h
//  Thatso
//
//  Created by John A Seubert on 11/5/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.

#pragma mark Notifications
extern NSString * const N_GamesDownloaded;
extern NSString * const N_ProfilePictureLoaded;
extern NSString * const N_CommentUploaded;
extern NSString * const N_CommentsDownloaded;
extern NSString * const N_VotedForComment;

#pragma mark Message Notifications
extern NSString * const NewGame;
extern NSString * const NewRound;
extern NSString * const NewComment;

#pragma mark Classes
extern NSString * const UserClass;
extern NSString * const CommentClass;
extern NSString * const GameClass;
extern NSString * const RoundClass;
extern NSString * const CompletedRoundClass;
extern NSString * const CategoryClass;

#pragma mark universal class fields
extern NSString * const UpdatedAt;
extern NSString * const CreatedAt;
extern NSString * const ID;
extern NSString * const ObjectID;

#pragma mark user fields
extern NSString * const UserFacebookID;
extern NSString * const UserFirstName;
extern NSString * const UserLastName;
extern NSString * const UserFullName;
extern NSString * const UserFacebookProfilePicture;

#pragma mark Game Fields
extern NSString * const GamePlayers;
extern NSString * const GameRounds;
extern NSString * const GameCurrentRound;

#pragma mark Round Fields
extern NSString * const RoundJudge;
extern NSString * const RoundSubject;
extern NSString * const RoundCategory;
extern NSString * const RoundNumber;
extern NSString * const RoundResponded; 

#pragma mark Comment Fields
extern NSString * const CommentGameID;
extern NSString * const CommentRoundID;
extern NSString * const CommentFrom;
extern NSString * const CommentResponse;

#pragma mark Completed Rounds Fields
extern NSString * const CompletedRoundJudge;
extern NSString * const CompletedRoundSubject;
extern NSString * const CompletedRoundCategory;
extern NSString * const CompletedRoundNumber;
extern NSString * const CompletedRoundGameID;
extern NSString * const CompletedRoundWinningResponse;
extern NSString * const CompletedRoundWinningResponseFrom;

#pragma mark Category Fields
extern NSString * const CategoryStartText;
extern NSString * const CategoryEndText;
extern NSString * const CategoryCount;
extern NSString * const CategoryVersionAdded;
extern NSString * const CategoryIsPG;
extern NSString * const CategoryIsAdult;
