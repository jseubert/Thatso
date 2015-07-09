//
//  ProfileViewTableViewCell.h
//  Thatso
//
//  Created by John A Seubert on 9/19/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

extern NSInteger const ProfileViewTableViewCellHeight;

@interface ProfileViewTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView *profilePicture;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

-(void)setColorScheme:(NSInteger) code;
@end
