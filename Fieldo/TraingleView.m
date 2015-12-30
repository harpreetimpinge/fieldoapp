//
//  TraingleView.m
//  Fieldo
//
//  Created by Gagan Joshi on 3/13/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "TraingleView.h"

@implementation TraingleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);


    if (_shapeType == kShapeClose)
    {
           CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // top left
           CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect));  // mid right
           CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));  // bottom left
    }
    else
    {
        CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // top left
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));  // mid right
        CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect));  // bottom left
     }
    
    
 
   
    
    
    
    CGContextClosePath(ctx);
    CGContextSetRGBFillColor(ctx, 0, 0.4, 1, 1);
    CGContextFillPath(ctx);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return nil;
}



@end
