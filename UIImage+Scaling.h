//
//  UIImage+UIImage.h
//  Thatso
//
//  Created by John A Seubert on 10/3/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Scaling)

- (UIImage *) imageScaledToSize:(CGSize)size;
- (UIImage *) imageScaledToFitSize:(CGSize)size;

@end
