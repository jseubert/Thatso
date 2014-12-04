//
//  PreviousRoundsTableViewCell.h
//  Thatso
//
//  Created by John  Seubert on 12/3/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviousRoundsTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *namesLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UILabel *nextRoundLabel;

-(void)setColorScheme:(NSInteger) code;
-(void)adjustLabels;

@end
