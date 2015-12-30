//
//  Plan.h
//  Fieldo
//
//  Created by Gagan Joshi on 10/26/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FloorPlanVC : UIViewController<UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    CGFloat previousScale;
}

@property (nonatomic,retain) UIImage *imageFloorPlan;
@property(nonatomic,retain) UIImageView *imageView;
@property(nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,retain) NSURL *imageUrl;


@end
