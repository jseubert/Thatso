//
//  SelectGameTableViewCell.h
//  Thatso
//
//  Created by John  Seubert on 10/3/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectGameTableViewCell : UITableViewCell

-(void)setColorScheme:(NSInteger) code;
-(void) setGame: (Game*)game andRound: (Round*)round;

@property (nonatomic, strong) UILabel *gameNameLabel;
@property (nonatomic, strong) UILabel *roundLabel;
@property (nonatomic, strong) UILabel *roundNumberLabel;

@property (nonatomic, strong) NSMutableArray *nameLabels;
@property (nonatomic, strong) NSMutableArray *profileViews;
@property (nonatomic, strong) NSMutableArray *activityIndicators;
@property (nonatomic, strong) NSMutableArray *scoreLabels;

@property (nonatomic, strong) UILabel *end;
@property (nonatomic, strong) UIView *top;
@property (nonatomic, strong) UILabel *categoryLabel;

@end
