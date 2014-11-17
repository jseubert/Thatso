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

@property (nonatomic, strong) UILabel *namesLabel;
@property (nonatomic, strong) UILabel *categoryLabel;

@end
