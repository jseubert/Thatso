//
//  GameHeaderView.h
//  Thatso
//
//  Created by John  Seubert on 12/5/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameHeaderView : UIView


@property (nonatomic, strong) IBOutlet UIImageView *profilePicture;
@property (nonatomic, strong) IBOutlet UILabel *roundLabel;
@property (nonatomic, strong) IBOutlet UILabel *caregoryLabel;

-(float) heightGivenWidth:(float) width;

@end
