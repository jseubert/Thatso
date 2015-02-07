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
-(void)adjustLabels;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *roundLabel;
@property (nonatomic, strong) UILabel *roundNumberLabel;

@property (nonatomic, strong) UILabel *categoryLabel;

@end
