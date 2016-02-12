//
//  PreviousRoundsTableViewCell.h
//  Thatso
//
//  Created by John  Seubert on 12/3/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

@interface PreviousRoundsTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *namesLabel;
@property (nonatomic, strong) UILabel *categoryLabel;

-(void)setColorScheme:(NSInteger) code;
//-(void)adjustLabels;

@end
