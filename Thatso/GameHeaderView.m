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

        [self setBackgroundColor:[UIColor lightBlueAppColor]];
        
        self.profilePicture = [[UIImageView alloc] initWithFrame:(CGRectZero)];
        [[self.profilePicture  layer] setCornerRadius:22];
        [self.profilePicture setClipsToBounds:YES];
        [self addSubview:self.profilePicture];
        
        self.roundLabel = [[UILabel alloc] initWithFrame:(CGRectZero)];
        self.roundLabel.font = [UIFont defaultAppFontWithSize:16.0];
        [self.roundLabel setTextColor:[UIColor blueAppColor]];
        [self.roundLabel setTextAlignment:NSTextAlignmentLeft];
       // [self.roundLabel setBackgroundColor:[UIColor redColor]];
        [self addSubview:self.roundLabel];
        
        self.caregoryLabel = [[UILabel alloc] initWithFrame:(CGRectZero)];
        self.caregoryLabel.font = [UIFont defaultAppFontWithSize:16.0];
        [self.caregoryLabel setTextColor:[UIColor whiteColor]];
        [self.caregoryLabel setTextAlignment:NSTextAlignmentLeft];
        [self.caregoryLabel setNumberOfLines:0];
        [self.caregoryLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.caregoryLabel setText:@"Test"];
       // [self.caregoryLabel setBackgroundColor:[UIColor redColor]];
        [self addSubview:self.caregoryLabel];
    
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    self.profilePicture.frame = (CGRectMake(5, 7.5, 44, 44));
    
    self.roundLabel.frame = (CGRectMake(5 + 44 + 10,
                                        5,
                                        self.bounds.size.width - self.profilePicture.frame.origin.x - self.profilePicture.frame.size.width - 10,
                                        [StringUtils sizeWithFontAttribute:self.roundLabel.font constrainedToSize:self.frame.size withText:@"Wg"].height));
    
    self.caregoryLabel.frame = (CGRectMake(self.profilePicture.frame.origin.x + self.profilePicture.frame.size.width + 10,
                                        self.roundLabel.frame.origin.y + self.roundLabel.frame.size.height,
                                        self.bounds.size.width - self.profilePicture.frame.origin.x - self.profilePicture.frame.size.width - 10,
                                        [StringUtils sizeWithFontAttribute:self.roundLabel.font constrainedToSize:CGSizeMake(self.bounds.size.width - self.profilePicture.frame.origin.x - self.profilePicture.frame.size.width - 15, self.frame.size.height) withText:self.caregoryLabel.text].height));
    
}

-(float) heightGivenWidth:(float) width
{
    CGSize roundHeight = [StringUtils sizeWithFontAttribute:self.roundLabel.font constrainedToSize:CGSizeMake(self.bounds.size.width - self.profilePicture.frame.origin.x - self.profilePicture.frame.size.width - 10, width) withText:self.roundLabel.text];
    CGSize categoryHeight = [StringUtils sizeWithFontAttribute:self.caregoryLabel.font constrainedToSize:CGSizeMake(self.bounds.size.width - self.profilePicture.frame.origin.x - self.profilePicture.frame.size.width - 10, width) withText:self.caregoryLabel.text];
    
    return 5 + roundHeight.height + 5 + categoryHeight.height + 5;
}

@end
