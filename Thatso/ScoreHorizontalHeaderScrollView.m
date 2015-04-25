//
//  ScoreHorizontalHeaderScrollView.m
//  Thatso
//
//  Created by John  Seubert on 4/3/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//

#import "ScoreHorizontalHeaderScrollView.h"
#import "StringUtils.h"
#import "UIImage+Scaling.h"
#import "SmallProfileView.h"

@implementation ScoreHorizontalHeaderScrollView

-(id)initWithGame: (Game*) currentGame
{
    self = [super init];
    if (self) {
        self.profileViews = [[NSMutableArray alloc] init];
        self.currentGame = currentGame;
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
        
        [self setBackgroundColor:[UIColor lightBlueAppColor]];
        
        self.scoreLabel = [[UILabel alloc] initWithFrame:(CGRectZero)];
        self.scoreLabel.font = [UIFont defaultAppFontWithSize:16.0];
        [self.scoreLabel setTextColor:[UIColor blueAppColor]];
        [self.scoreLabel setTextAlignment:NSTextAlignmentLeft];
        [self.scoreLabel setText:@"Score:"];
        [self addSubview:self.scoreLabel];
        
        
        for(User *player in currentGame.players)
        {
            SmallProfileView* profileView = [[SmallProfileView alloc] init];
            [self addSubview:profileView];
            [self.profileViews addObject:profileView];
            [profileView setFBId:player.fbId name:player.first_name andScore:@"0"];
        }
    }
    return self;
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    
    CGSize scoreLabelSize = [StringUtils sizeWithFontAttribute:self.scoreLabel.font constrainedToSize:self.frame.size withText:self.scoreLabel.text];
    [self.scoreLabel setFrame:CGRectMake(10,
                                         10,
                                         scoreLabelSize.width,
                                         scoreLabelSize.height)];
    
    int x = self.scoreLabel.frame.origin.x + self.scoreLabel.frame.size.width + 10;
    for(SmallProfileView* profileView in self.profileViews)
    {
        
        CGSize nameSize = [StringUtils sizeWithFontAttribute:profileView.nameLabel.font constrainedToSize:self.frame.size withText:profileView.nameLabel.text];
        [profileView setFrame:CGRectMake(x,
                                         0,
                                         nameSize.width + 20,
                                         70)];

        x = x + profileView.width + 10;
    }
    self.contentSize = CGSizeMake(x, 70);
}

-(void) setScoresForPlayers: (NSDictionary *)scores
{
    ///This is gross and needs to be cleaned. Works for now
    int count = 0;
    for(User *player in self.currentGame.players)
    {
        SmallProfileView* profileView = self.profileViews[count];
        NSNumber *score =scores[player.fbId];
        [profileView setFBId:player.fbId name:player.first_name andScore:[score stringValue]];
        
        count ++;
    }
    [self setNeedsDisplay];
}

@end
