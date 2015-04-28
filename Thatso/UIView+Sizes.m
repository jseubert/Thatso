//
//  UIView+Sizes.m
//  Thatso
//
//  Created by John  Seubert on 4/3/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//

#import "UIView+Sizes.h"

@implementation UIView(Sizes)
@dynamic bottom;
@dynamic end;
@dynamic height;
@dynamic width;
@dynamic originY;
@dynamic originX;

-(CGFloat) bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

-(CGFloat) end
{
    return self.frame.origin.x + self.frame.size.width;
}

-(CGFloat) width
{
    return self.frame.size.width;
}

-(CGFloat) height
{
    return self.frame.size.height;
}

-(CGFloat) originX
{
    return self.frame.origin.x;
}

-(CGFloat) originY
{
    return self.frame.origin.y;
}

@end
