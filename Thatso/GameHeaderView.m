//
//  GameHeaderView.m
//  Thatso
//
//  Created by John  Seubert on 12/5/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "GameHeaderView.h"
#import "StringUtils.h"

@implementation GameHeaderView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self setBackgroundColor:[UIColor pinkAppColor]];
        [[self  layer] setBorderWidth:2.0f];
        [[self  layer] setBorderColor:[UIColor whiteColor].CGColor];
        [[self  layer] setCornerRadius:10.0f];
        [self setClipsToBounds:YES];
        
        self.profilePicture = [[UIImageView alloc] initWithFrame:(CGRectZero)];
        [[self.profilePicture  layer] setCornerRadius:22];
        [self.profilePicture setClipsToBounds:YES];
        [self addSubview:self.profilePicture];
        
        self.roundLabel = [[UILabel alloc] initWithFrame:(CGRectZero)];
        self.roundLabel.font = [UIFont defaultAppFontWithSize:16.0];
        [self.roundLabel setTextColor:[UIColor blueAppColor]];
        [self.roundLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.roundLabel];
        
        self.caregoryLabel = [[UILabel alloc] initWithFrame:(CGRectZero)];
        self.caregoryLabel.font = [UIFont defaultAppFontWithSize:16.0];
        [self.caregoryLabel setTextColor:[UIColor whiteColor]];
        [self.caregoryLabel setTextAlignment:NSTextAlignmentCenter];
        [self.caregoryLabel setNumberOfLines:0];
        [self.caregoryLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.caregoryLabel setText:@"Test"];
        [self addSubview:self.caregoryLabel];
    
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    self.profilePicture.frame = (CGRectMake(5, 7.5, 44, 44));
    
    self.roundLabel.frame = (CGRectMake(5 + 44 + 5,
                                        5,
                                        self.bounds.size.width - self.profilePicture.frame.origin.x - self.profilePicture.frame.size.width - 15,
                                        [StringUtils sizeWithFontAttribute:self.roundLabel.font constrainedToSize:self.frame.size withText:@"Wg"].height));
    
    self.caregoryLabel.frame = (CGRectMake(self.profilePicture.frame.origin.x + self.profilePicture.frame.size.width + 5,
                                        self.roundLabel.frame.origin.y + self.roundLabel.frame.size.height + 5,
                                        self.bounds.size.width - self.profilePicture.frame.origin.x - self.profilePicture.frame.size.width - 15,
                                        [StringUtils sizeWithFontAttribute:self.roundLabel.font constrainedToSize:CGSizeMake(self.bounds.size.width - self.profilePicture.frame.origin.x - self.profilePicture.frame.size.width - 15, self.frame.size.height) withText:self.caregoryLabel.text].height));
    
}

-(float) heightGivenWidth:(float) width
{
    CGSize roundHeight = [StringUtils sizeWithFontAttribute:self.roundLabel.font constrainedToSize:CGSizeMake(width - 44 - 5 - 5 - 5, width) withText:self.roundLabel.text];
    CGSize categoryHeight = [StringUtils sizeWithFontAttribute:self.caregoryLabel.font constrainedToSize:CGSizeMake(width - 44 - 5 - 5 - 5, width) withText:self.caregoryLabel.text];
    
    return 5 + roundHeight.height + 5 + categoryHeight.height + 5;
}

@end
