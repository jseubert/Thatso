//
//  SmallProfileView.m
//  Thatso
//
//  Created by John  Seubert on 4/3/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//

#import "SmallProfileView.h"
#import "StringUtils.h"
#import "UIImage+Scaling.h"

@implementation SmallProfileView

-(id)init
{
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];

        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [[self.profileImageView  layer] setCornerRadius:self.profileImageView.frame.size.height/2];
        [self.profileImageView setClipsToBounds:YES];
        [self.profileImageView setBackgroundColor:[UIColor blueAppColor]];
        [self addSubview:self.profileImageView];

        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:self.activityIndicator];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.nameLabel  setFont:[UIFont defaultAppFontWithSize:12.0]];
        [self.nameLabel  setTextAlignment:NSTextAlignmentCenter];
        [self.nameLabel  setTextColor:[UIColor blueAppColor]];
        [self.nameLabel setText:@""];
        [self addSubview:self.nameLabel ];
        
        self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.scoreLabel.font = [UIFont defaultAppFontWithSize:16.0];
        self.scoreLabel.text = @"";
        [self.scoreLabel setTextAlignment:NSTextAlignmentCenter];
        [self.scoreLabel setTextColor:[UIColor whiteColor]];
        self.scoreLabel.numberOfLines = 0;
        [[self.scoreLabel layer] setCornerRadius:20/2];
        [self.scoreLabel setClipsToBounds:YES];
        [self.scoreLabel setBackgroundColor:[UIColor blueAppColor]];
        [self addSubview:self.scoreLabel];
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    [self.profileImageView setFrame:CGRectMake(5, 10, 40, 40)];
    
      CGSize nameLabelSize = [StringUtils sizeWithFontAttribute:self.nameLabel.font constrainedToSize:self.frame.size withText:self.nameLabel.text];
    
    [self.nameLabel setFrame:CGRectMake(5,
                                        self.profileImageView.frame.size.height + self.profileImageView.frame.origin.y,
                                        nameLabelSize.width + 10,
                                        nameLabelSize.height + 10)];
    
    [self.profileImageView setCenter:(CGPointMake(self.nameLabel.center.x, self.profileImageView.center.y))];
    [self.activityIndicator setFrame:self.profileImageView.frame];
    
    CGSize scoreLabelSize = [StringUtils sizeWithFontAttribute:self.scoreLabel.font constrainedToSize:self.frame.size withText:self.scoreLabel.text];
    
    [self.scoreLabel setFrame:CGRectMake(self.profileImageView.end - scoreLabelSize.width,
                                         self.profileImageView.bottom - scoreLabelSize.height,
                                         scoreLabelSize.width + 10,
                                         scoreLabelSize.height)];
}

-(void) setFBId: (NSString*)fbId name:(NSString*)name andScore: (NSString*)score
{
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:NO];
    [DataStore getFriendProfilePictureWithID:fbId withBlock:^(UIImage *image) {
        [self.profileImageView setImage:[image imageScaledToFitSize:CGSizeMake(40, 40)]];
        self.profileImageView.frame = CGRectMake(self.profileImageView.frame.origin.x + 20, self.profileImageView.frame.origin.y + 20, 0, 0);
        [[self.profileImageView  layer] setCornerRadius:0];
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.profileImageView.frame = CGRectMake(self.profileImageView .frame.origin.x - 20, self.profileImageView.frame.origin.y -20, 40, 40);
                             [[self.profileImageView  layer] setCornerRadius:self.profileImageView .frame.size.height/2];
                         }
                         completion:^(BOOL finished){
                             // [theView removeFromSuperview];
                         }];
        [self.activityIndicator stopAnimating];
        [self.activityIndicator setHidden:YES];
    }];
    
    [self.scoreLabel setText:score];
    [self.nameLabel setText:name];
    [self setNeedsLayout];
}

@end
