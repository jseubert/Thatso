//
//  SelectGameTableViewCell.m
//  Thatso
//
//  Created by John  Seubert on 10/3/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "SelectGameTableViewCell.h"
#import "CommentTableViewCell.h"
#import "DataStore.h"
#import "CommentTableViewCell.h"
#import "UIImage+Scaling.h"
#import "StringUtils.h"

@implementation SelectGameTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor lightBlueAppColor];
        [self setSelectedBackgroundView:bgColorView];
        
        //Initialize Views
        self.roundNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.roundNumberLabel.font = [UIFont defaultAppFontWithSize:16.0];
        self.roundNumberLabel.text = @"1";
        [self.roundNumberLabel setTextAlignment:NSTextAlignmentCenter];
        [self.roundNumberLabel setTextColor:[UIColor whiteColor]];
        self.roundNumberLabel.numberOfLines = 0;
        [[self.roundNumberLabel  layer] setCornerRadius:20/2];
        [self.roundNumberLabel setClipsToBounds:YES];
        [self.roundNumberLabel setBackgroundColor:[UIColor blueAppColor]];
        [self addSubview:self.roundNumberLabel];
        
        self.roundLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.roundLabel.font = [UIFont defaultAppFontWithSize:16.0];
        self.roundLabel.text = @"Round";
        self.roundLabel.numberOfLines = 0;
        [self.roundLabel setTextColor:[UIColor blueAppColor]];
        [self addSubview:self.roundLabel];
        
        self.gameNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.gameNameLabel.font = [UIFont defaultAppFontWithSize:16.0];
        self.gameNameLabel.text = @"";
        self.gameNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.gameNameLabel.numberOfLines = 1;
        [self.gameNameLabel setTextColor:[UIColor blueAppColor]];
        [self addSubview:self.gameNameLabel];
        
        self.categoryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.categoryLabel.font = [UIFont defaultAppFontWithSize:14.0];
        self.categoryLabel.text = @"";
        self.categoryLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.categoryLabel.numberOfLines = 0;
        [self.categoryLabel setTextColor:[UIColor blueAppColor]];
    
        [self addSubview:self.categoryLabel];

        self.nameLabels = [[NSMutableArray alloc] init];
        self.activityIndicators = [[NSMutableArray alloc] init];
        self.profileViews = [[NSMutableArray alloc] init];
        
        int x = 10;
        int count = 0;
        while (count < 6)
        {

                UIImageView* profileView = [[UIImageView alloc] initWithFrame:CGRectZero];
                [[profileView  layer] setCornerRadius:profileView.frame.size.height/2];
                [profileView setClipsToBounds:YES];
                [profileView setBackgroundColor:[UIColor blueAppColor]];
                [profileView setHidden:YES];
                [self addSubview:profileView];
            
                [self.profileViews addObject:profileView];
            
                UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
                [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                [activityIndicator setHidden:YES];
                [self addSubview:activityIndicator];
            
                [self.activityIndicators addObject:activityIndicator];

                
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                [nameLabel setFont:[UIFont defaultAppFontWithSize:12.0]];
                [nameLabel setTextAlignment:NSTextAlignmentCenter];
                [nameLabel setTextColor:[UIColor blueAppColor]];
                [self addSubview:nameLabel];
            
                [self.nameLabels addObject:nameLabel];
                x += 46;
            
            count ++;
        }
        
        self.end = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.end  setTextAlignment:NSTextAlignmentRight];
        [self.end  setNumberOfLines:1];
        [self.end  setFont:[UIFont defaultAppFontWithSize:20.0]];
        [self.end  setTextColor:[UIColor blueAppColor]];
        [self.end setHidden:YES];
        [self addSubview:self.end ];
    }
    
    self.top = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.top];
    
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    [self.top setFrame:CGRectMake(0, self.frame.size.height - 5, self.frame.size.width, 5)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.top.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0] CGColor], nil];
    [self.top.layer insertSublayer:gradient atIndex:0];
    
    
    int width = [StringUtils sizeWithFontAttribute:self.roundNumberLabel.font constrainedToSize:(CGSizeMake(self.frame.size.width, 20)) withText:self.roundNumberLabel.text].width +10;
    self.roundNumberLabel.frame = CGRectMake(self.frame.size.width - width - 10,
                                             5,
                                             width,
                                             20);
    
    [self.roundLabel setFrame:CGRectMake(self.frame.size.width - 10 - self.roundNumberLabel.frame.size.width - 2 - 50,
                                         5,
                                         50,
                                         20)];
    
    [self.gameNameLabel setFrame:CGRectMake(10,
                                            5,
                                            self.roundLabel.frame.origin.x - 10 - 5,
                                            20)];
    
    int x = 10;
    int count = 0;
    while (count < 6)
    {
        
        [self.profileViews[count] setFrame:CGRectMake(x,
                                                    self.gameNameLabel.frame.origin.y + self.gameNameLabel.frame.size.height + 5,
                                                    40,
                                                    40)];
        [[self.profileViews[count]  layer] setCornerRadius:[self.profileViews[count] frame].size.height/2];
        

        
        [self.activityIndicators[count] setFrame:CGRectMake(x,
                                                            self.gameNameLabel.frame.origin.y + self.gameNameLabel.frame.size.height + 5,
                                                            40,
                                                            40)];
        
        [self.nameLabels[count] setFrame:CGRectMake(x,
                                                                       [self.profileViews[count] frame].origin.y + [self.profileViews[count] frame].size.height,
                                                                       40,
                                                                       20)];
        x += 46;
        
        count ++;
    }
    
    CGSize categoryHeight = [StringUtils sizeWithFontAttribute:self.categoryLabel.font constrainedToSize:(CGSizeMake(self.frame.size.width -20, self.frame.size.width -20)) withText:self.categoryLabel.text];
    
    self.categoryLabel.frame = CGRectMake(10,
                                          [self.nameLabels[0] frame].size.height + [self.nameLabels[0] frame].origin.y,
                                          self.frame.size.width-20,
                                          categoryHeight.height);

    
    
    
}

-(void) setGame: (Game*)game andRound: (Round*)round
{
    //Start with everything hidden
    [self.end setHidden:YES];
    for(int i = 0; i < 6; i ++)
    {
        [[self.nameLabels objectAtIndex:i] setHidden:YES];
        [[self.profileViews objectAtIndex:i] setHidden:YES];
        [[self.activityIndicators objectAtIndex:i] setHidden:YES];
    }
    
    [self.gameNameLabel setText: game.gameName];
    [self.roundNumberLabel setText: [NSString stringWithFormat:@"%@",round.roundNumber]];
    [self.categoryLabel setText:round.category];
    
    int count = 0;
    int iconNumber = 0;
    
    int players = [game.players count] - 1;

    while (count < 6 && count < [game.players count])//[game.players count])
    {
        
        User *user = [game.players objectAtIndex:count];
        if(![((User*)[PFUser currentUser]).fbId isEqualToString:user.fbId])
        {
            UILabel *nameLabel = [self.nameLabels objectAtIndex:iconNumber];
            UIImageView *profileView = [self.profileViews objectAtIndex:iconNumber];
            UIActivityIndicatorView *activityIndicator = [self.activityIndicators objectAtIndex:iconNumber];
            
            [nameLabel setHidden:NO];
            [profileView setHidden:NO];
            [activityIndicator setHidden:NO];
        
            
            [activityIndicator startAnimating];
        
            [DataStore getFriendProfilePictureWithID:user.fbId withBlock:^(UIImage *image) {
                [profileView setImage:[image imageScaledToFitSize:CGSizeMake(40, 40)]];
                profileView.frame = CGRectMake(profileView.frame.origin.x + 20, profileView.frame.origin.y + 20, 0, 0);
                [[profileView  layer] setCornerRadius:0];
                [UIView animateWithDuration:0.5
                                 animations:^{
                                     profileView.frame = CGRectMake(profileView.frame.origin.x - 20, profileView.frame.origin.y -20, 40, 40);
                                     [[profileView  layer] setCornerRadius:profileView.frame.size.height/2];
                                 }
                                 completion:^(BOOL finished){
                                    // [theView removeFromSuperview];
                                     [activityIndicator stopAnimating];
                                     [activityIndicator setHidden:YES];
                                 }];
                    [activityIndicator stopAnimating];
                    [activityIndicator setHidden:YES];
            }];
        

            [nameLabel setText:user.first_name];
            
            iconNumber ++;
        }
        count ++;
    }
    UILabel *nameLabel = [self.nameLabels objectAtIndex:0];
    if(players > 6)
    {

        UILabel *end = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width -10 -40,
                                                            nameLabel.frame.origin.y + nameLabel.frame.size.height + 5,
                                                             40,
                                                             40)];
        [end setText:[NSString stringWithFormat:@"+%d", (players - 6)]];
        [end setTextAlignment:NSTextAlignmentRight];
        [end setNumberOfLines:1];
        [end setFont:[UIFont defaultAppFontWithSize:20.0]];
        [end setTextColor:[UIColor blueAppColor]];
        [self addSubview:end];
    }
    CGSize categoryHeight = [StringUtils sizeWithFontAttribute:self.categoryLabel.font constrainedToSize:(CGSizeMake(self.frame.size.width -20, self.frame.size.width -20)) withText:round.category];
    
    self.categoryLabel.frame = CGRectMake(10,
                                          nameLabel.frame.size.height + nameLabel.frame.origin.y,
                                          self.frame.size.width-20,
                                          categoryHeight.height);

    [self layoutSubviews];
    
}
-(void)setColorScheme:(NSInteger) code
{
    /*
    switch(code%6)
    {
        case 1:
            self.backgroundColor = [UIColor whiteColor];
            self.nameLabel.textColor = [UIColor blueAppColor];
            self.categoryLabel.textColor = [UIColor pinkAppColor];
            break;
        case 0:
            self.backgroundColor = [UIColor lightBlueAppColor];
            self.nameLabel.textColor = [UIColor whiteColor];
            self.categoryLabel.textColor = [UIColor blueAppColor];
            break;
        case 2:
            self.backgroundColor = [UIColor blueAppColor];
            self.nameLabel.textColor = [UIColor pinkAppColor];
            self.categoryLabel.textColor = [UIColor whiteColor];
            break;
        case 3:
            self.backgroundColor = [UIColor whiteColor];
            self.nameLabel.textColor = [UIColor pinkAppColor];
            self.categoryLabel.textColor = [UIColor blueAppColor];
            break;
        case 5:
            self.backgroundColor = [UIColor lightBlueAppColor];
            self.nameLabel.textColor = [UIColor blueAppColor];
            self.categoryLabel.textColor = [UIColor whiteColor];
            break;
        case 4:
            self.backgroundColor = [UIColor blueAppColor];
            self.nameLabel.textColor = [UIColor whiteColor];
            self.categoryLabel.textColor = [UIColor pinkAppColor];
            break;
        default:
            self.backgroundColor = [UIColor whiteColor];
            self.nameLabel.textColor = [UIColor blueAppColor];
            self.categoryLabel.textColor = [UIColor pinkAppColor];
            break;
    }
    */
    
}

@end
