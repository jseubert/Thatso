//
//  RoundManager.h
//  Thatso
//
//  Created by John  Seubert on 6/29/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//

//Delegate Callbacks
@protocol DidAddCommentDelegate <NSObject>
- (void) didAddComment:(BOOL)success needsRefresh:(BOOL)refresh addedComment:(Comment *)comment info:(NSString *) info;
@end

@protocol DidGetCommentsDelegate <NSObject>
- (void) didGetComments:(BOOL)success info: (NSString *) info;
@end

@interface RoundManager : NSObject

@property (nonatomic, strong) NSMutableDictionary* currentComments;

+ (RoundManager *) instance;
- (void) setComments: (NSArray*)comments forGameId: (NSString *) gameId;
- (void) addComment: (Comment *)comment;
- (void) refreshCommentID:(NSString *)gameId;
- (void) refreshCommentID:(NSString *)gameId withBlock:(void (^)(Comment*))block;
- (void) clearData;


//Network Calls
- (void) addComment:(Comment*)comment toRound:(Round*)round forDelegate:(id<DidAddCommentDelegate>)delegate;
- (void) getActiveCommentsForGame:(Game*)game inRound:(Round*)round forDelegate:(id<DidGetCommentsDelegate>)delegate;
- (void) finishRound: (Round*)round inGame: (Game*)game withWinningComment: (Comment*)comment andOtherComments: (NSArray *)otherComments forDelegate:(id<DidStartNewRound>)delegate;

@end