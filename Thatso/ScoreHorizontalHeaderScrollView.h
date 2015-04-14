//
//  ScoreHorizontalHeaderScrollView.h
//  Thatso
//
//  Created by John  Seubert on 4/3/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreHorizontalHeaderScrollView : UIScrollView

@property(nonatomic) Game *currentGame;

@property (nonatomic, strong) NSMutableArray *profileViews;

@property (nonatomic, strong) UILabel *scoreLabel;


-(id)initWithGame: (Game*) currentGame;
-(void) setScoresForPlayers: (NSDictionary *)scores;
@end
