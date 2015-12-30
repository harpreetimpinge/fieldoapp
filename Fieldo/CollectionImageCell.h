//
//  CollectionImageCell.h
//  Fieldo
//
//  Created by Gagan Joshi on 2/18/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionImageCell : UICollectionViewCell


@property (strong, nonatomic) UILabel *label;
@property (strong,nonatomic) UIScrollView *scrollView;
@property (strong,nonatomic) UIImageView *imageView;
@property (strong,nonatomic) UIImage *image;
@property (strong,nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

