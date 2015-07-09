//
//  SmallProfileView.h
//  Thatso
//
//  Created by John  Seubert on 4/3/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//


@interface SmallProfileView : UIView

@property UILabel *nameLabel;
@property UIImageView *profileImageView;
@property UILabel *scoreLabel;
@property UIActivityIndicatorView *activityIndicator; 

-(void) setFBId: (NSString*)fbId name:(NSString*)name andScore: (NSString*)score;

@end
