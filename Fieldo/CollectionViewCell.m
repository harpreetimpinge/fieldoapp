//
//  CollectionViewCell.m
//  SnapAndSlide
//
//  Created by Gagan Joshi on 1/23/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

-(NSUInteger)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    
    return UIInterfaceOrientationPortrait;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            if (screenSize.height > 480.0f)
            {
                
                UIView *bgView2=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
                bgView2.layer.borderWidth = 1.0f;
                bgView2.layer.cornerRadius = 50.0f;
                bgView2.layer.masksToBounds = YES;
                bgView2.backgroundColor=[UIColor whiteColor];
                bgView2.layer.borderColor = [[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] CGColor];
                [self.contentView addSubview:bgView2];
                
                UIView *bgView=[[UIView alloc] initWithFrame:self.contentView.bounds];
                self.imageView =[[UIImageView alloc] initWithFrame: CGRectMake(20, 20, 60, 60)];
                self.imageView.contentMode=UIViewContentModeScaleToFill;
                self.imageView.userInteractionEnabled=YES;
                [bgView addSubview:self.imageView];
                
                self.labelTitle=[[UILabel alloc] initWithFrame:CGRectMake(0,25+75, 100, 20)];
                self.labelTitle.font= [UIFont systemFontOfSize:13.0];
                self.labelTitle.numberOfLines=2;
                self.labelTitle.textAlignment = NSTextAlignmentCenter;
                self.labelTitle.textColor =[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f] ;
                [bgView addSubview:self.labelTitle];
                
                self.labelDate=[[UILabel alloc] initWithFrame:CGRectMake(0,30, 100, 40)];
                self.labelDate.font= [UIFont systemFontOfSize:28.0];
                self.labelDate.textAlignment = NSTextAlignmentCenter;
                self.labelDate.textColor =[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f] ;
                [bgView addSubview:self.labelDate];
                
                self.labelDay=[[UILabel alloc] initWithFrame:CGRectMake(0,60, 100, 20)];
                self.labelDay.font= [UIFont systemFontOfSize:12.0];
                self.labelDay.textAlignment = NSTextAlignmentCenter;
                self.labelDay.textColor =[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f] ;
                [bgView addSubview:self.labelDay];
                
                [self.contentView addSubview:bgView];
                
            }
            else
            {
                UIView *bgView2=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
                bgView2.layer.borderWidth = 1.0f;
                bgView2.layer.cornerRadius = 40.0f;
                bgView2.layer.masksToBounds = YES;
                bgView2.backgroundColor=[UIColor whiteColor];
                bgView2.layer.borderColor = [[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] CGColor];
                [self.contentView addSubview:bgView2];
                
                UIView *bgView=[[UIView alloc] initWithFrame:self.contentView.bounds];
                self.imageView =[[UIImageView alloc] initWithFrame: CGRectMake(16, 16, 48, 48)];
                self.imageView.contentMode=UIViewContentModeScaleToFill;
                self.imageView.userInteractionEnabled=YES;
                [bgView addSubview:self.imageView];
                
                self.labelTitle=[[UILabel alloc] initWithFrame:CGRectMake(0,25+55, 80, 20)];
                self.labelTitle.font= [UIFont systemFontOfSize:13.0];
                self.labelTitle.numberOfLines=2;
                self.labelTitle.textAlignment = NSTextAlignmentCenter;
                self.labelTitle.textColor =[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f] ;
                [bgView addSubview:self.labelTitle];
                
                self.labelDate=[[UILabel alloc] initWithFrame:CGRectMake(0,20, 80, 40)];
                self.labelDate.font= [UIFont systemFontOfSize:22.0];
                self.labelDate.textAlignment = NSTextAlignmentCenter;
                self.labelDate.textColor =[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f] ;
                [bgView addSubview:self.labelDate];
                
                self.labelDay=[[UILabel alloc] initWithFrame:CGRectMake(0,45, 80, 20)];
                self.labelDay.font= [UIFont systemFontOfSize:12.0];
                self.labelDay.textAlignment = NSTextAlignmentCenter;
                self.labelDay.textColor =[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f] ;
                [bgView addSubview:self.labelDay];
                
                [self.contentView addSubview:bgView];
            }

        }
        
       
    }
    return self;
}



-(void)setImage:(UIImage *)image
{
    self.imageView.image=image;
    self.imageView.frame = self.contentView.bounds;
    
   
    
}



-(void)setFrameRect:(CGRect)frameRect
{
    NSLog(@"setter for ScrollView under cell");
    
    //[self.scrollView zoomToRect:frameRect animated:YES];
    
}





@end
