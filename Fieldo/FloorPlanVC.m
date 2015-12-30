//
//  Plan.m
//  Fieldo
//
//  Created by Gagan Joshi on 10/26/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "FloorPlanVC.h"
#import "Language.h"
@interface FloorPlanVC ()

@end

@implementation FloorPlanVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
  
    NSLog(@"View frame is: %@", NSStringFromCGRect(self.view.bounds));
    //self.title=[Language get:@"Floor Plan" alter:@"!Floor Plan"];
    
    self.scrollView=[[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate=self;
    self.scrollView.showsVerticalScrollIndicator=NO;
    self.scrollView.showsHorizontalScrollIndicator=NO;
    [self.scrollView setMaximumZoomScale:4.0];
    [self.scrollView setMinimumZoomScale:1.0];
    [self.view addSubview:self.scrollView];

    
    self.imageView=[[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.image=self.imageFloorPlan;
    
    if (!self.imageView.image)
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(queue, ^
                       {
                           NSData *data=[NSData dataWithContentsOfURL:self.imageUrl];
                           dispatch_async(dispatch_get_main_queue(), ^
                            {
                            self.imageView.image=[UIImage imageWithData:data];
                           });

                       });

    }
    
    
    self.imageView.contentMode=UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.imageView];
    
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.delegate=self;
    
    [doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTap];

    
    
	// Do any additional setup after loading the view.
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


-(void)loadView
{
    CGRect rect= CGRectMake(0, 100, 320, 380);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (screenSize.height > 480.0f)
            rect=CGRectMake(0, 100, 320, 468);
    }
    UIView *view=[[UIView alloc] initWithFrame:rect];
    view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    self.view=view;
}
- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    
    CGPoint p = [gestureRecognizer locationInView:self.scrollView];
    
    
        if(self.scrollView.zoomScale > self.scrollView.minimumZoomScale)
        {
            CGPoint point=[gestureRecognizer locationInView:gestureRecognizer.view];
            NSLog(@"Point %f, %f",point.x,point.y);
            // [scrollViewImage setZoomScale:1.0];
            
            CGRect zoomRect = [self zoomRectForScale:1.0 withCenter:p];
            [self.scrollView zoomToRect:zoomRect animated:YES];
            //cell2.frameRect=zoomRect;
            
        }
        else
        {
            CGRect zoomRect = [self zoomRectForScale:4.0 withCenter:p];
            [self.scrollView zoomToRect:zoomRect animated:YES];
            
            
        }
    
}



- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = [self.scrollView frame].size.height / scale;
    zoomRect.size.width  = [self.scrollView frame].size.width  / scale;
    // choose an origin so as to get the right center.
    
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
