//
//  SelectGameTableViewCell.m
//  Thatso
//
//  Created by John  Seubert on 10/3/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "SelectGameTableViewCell.h"
#import "CommentTableViewCell.h"

@implementation SelectGameTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
        self.roundNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 20 - 10,
                                                                          10,
                                                                          20,
                                                                          20)];
        self.roundNumberLabel.font = [UIFont defaultAppFontWithSize:16.0];
        self.roundNumberLabel.text = @"1";
        [self.roundNumberLabel setTextAlignment:NSTextAlignmentCenter];
        [self.roundNumberLabel setTextColor:[UIColor whiteColor]];
        self.roundNumberLabel.numberOfLines = 0;
        [[self.roundNumberLabel  layer] setCornerRadius:self.roundNumberLabel.frame.size.height/2];
        [self.roundNumberLabel setClipsToBounds:YES];
        [self.roundNumberLabel setBackgroundColor:[UIColor blueAppColor]];
        [self addSubview:self.roundNumberLabel];
        
        self.roundLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 10 - self.roundNumberLabel.frame.size.width - 2 - 50,
                                                                    10,
                                                                    50,
                                                                    20)];
        self.roundLabel.font = [UIFont defaultAppFontWithSize:16.0];
       // self.roundLabel.backgroundColor = [UIColor blueColor];
        self.roundLabel.text = @"Round";
        self.roundLabel.numberOfLines = 0;
        [self addSubview:self.roundLabel];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                                   10,
                                                                   self.roundLabel.frame.origin.x - 10 - 5,
                                                                   20)];
        self.nameLabel.font = [UIFont defaultAppFontWithSize:16.0];
        self.nameLabel.text = @"";
        self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
       // self.nameLabel.backgroundColor = [UIColor redColor];
        self.nameLabel.numberOfLines = 0;
        [self addSubview:self.nameLabel];
        

        

        
        
        
        
        
        
        self.categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.frame.size.height/2 + 10, self.frame.size.width-20, self.frame.size.height/2)];
        self.categoryLabel.font = [UIFont defaultAppFontWithSize:14.0];
        self.categoryLabel.text = @"";
        self.categoryLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.categoryLabel.numberOfLines = 0;
        
        [self addSubview:self.categoryLabel];
        
        

    }
    return self;
}

-(void)adjustLabels
{
    
   /*
    CGFloat width = self.frame.size.width
    - 10    //left padding
    - 30    //New Button
    - 10;   //padding on right
    
    CGSize topLabelSize = [CommentTableViewCell sizeWithFontAttribute:[UIFont defaultAppFontWithSize:16.0] constrainedToSize:(CGSizeMake(width, width)) withText:self.namesLabel.text];
    CGSize bottomeLabelSize = [CommentTableViewCell sizeWithFontAttribute:[UIFont defaultAppFontWithSize:14.0] constrainedToSize:(CGSizeMake(width, width)) withText: self.categoryLabel.text];
    
    self.namesLabel.frame = CGRectMake(10, 10, self.frame.size.width -20, topLabelSize.height);
    self.categoryLabel.frame = CGRectMake(10, self.namesLabel.frame.origin.x + self.namesLabel.frame.size.height + 5, self.frame.size.width-20, bottomeLabelSize.height + 10);
    */
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setColorScheme:(NSInteger) code
{
    /*
    switch(code%6)
    {
        case 0:
            self.backgroundColor = [UIColor whiteColor];
            self.namesLabel.textColor = [UIColor blueAppColor];
            self.categoryLabel.textColor = [UIColor pinkAppColor];
            break;
        case 1:
            self.backgroundColor = [UIColor lightBlueAppColor];
            self.namesLabel.textColor = [UIColor whiteColor];
            self.categoryLabel.textColor = [UIColor blueAppColor];
            break;
        case 2:
            self.backgroundColor = [UIColor blueAppColor];
            self.namesLabel.textColor = [UIColor pinkAppColor];
            self.categoryLabel.textColor = [UIColor whiteColor];
            break;
        case 3:
            self.backgroundColor = [UIColor whiteColor];
            self.namesLabel.textColor = [UIColor pinkAppColor];
            self.categoryLabel.textColor = [UIColor blueAppColor];
            break;
        case 4:
            self.backgroundColor = [UIColor lightBlueAppColor];
            self.namesLabel.textColor = [UIColor blueAppColor];
            self.categoryLabel.textColor = [UIColor whiteColor];
            break;
        case 5:
            self.backgroundColor = [UIColor blueAppColor];
            self.namesLabel.textColor = [UIColor whiteColor];
            self.categoryLabel.textColor = [UIColor pinkAppColor];
            break;
        default:
            self.backgroundColor = [UIColor whiteColor];
            self.namesLabel.textColor = [UIColor blueAppColor];
            self.categoryLabel.textColor = [UIColor pinkAppColor];
            break;
    }
     */
    
}

@end
