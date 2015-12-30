//
//  CollectionImageCell.m
//  Fieldo
//
//  Created by Gagan Joshi on 2/18/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "CollectionImageCell.h"

@implementation CollectionImageCell
@synthesize scrollView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.scrollView=[[UIScrollView alloc] initWithFrame:self.contentView.bounds];
        self.scrollView.showsVerticalScrollIndicator=YES;
        self.scrollView.showsHorizontalScrollIndicator=YES;
        self.scrollView.minimumZoomScale=1.0;
        self.scrollView.maximumZoomScale=4.0;
        self.scrollView.contentSize=self.contentView.bounds.size;
        [self.contentView addSubview:self.scrollView];
        
        
        
        self.imageView =[[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.imageView.contentMode=UIViewContentModeScaleAspectFit;
        self.imageView.userInteractionEnabled=YES;
        [self.scrollView addSubview:self.imageView];
        
        
        self.activityIndicatorView= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicatorView.frame=self.contentView.bounds ;
        [self.contentView addSubview:self.activityIndicatorView];
        
    }
    return self;
}



-(void)setImage:(UIImage *)image
{
    NSLog(@"setter for image that to be set on imageView");
    self.imageView.image=image;
    self.imageView.frame = self.contentView.bounds;
    self.scrollView.frame=self.contentView.bounds;
    self.scrollView.contentSize=self.contentView.bounds.size;
    
    //  NSLog(@"ImageView Origin x=%f,Origin y=%f,Width=%f, Height=%f",self.imageView.frame.origin.x,self.imageView.frame.origin.y,self.imageView.frame.size.width,self.imageView.frame.size.height);
    //  NSLog(@"ScrollView Origin x=%f,Origin y=%f,Width=%f, Height=%f",self.scrollView.frame.origin.x,self.scrollView.frame.origin.y,self.scrollView.frame.size.width,self.scrollView.frame.size.height);
    
}




-(void)setFrameRect:(CGRect)frameRect
{
    NSLog(@"setter for ScrollView under cell");
    
    
}








@end
