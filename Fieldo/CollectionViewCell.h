//
//  CollectionViewCell.h
//  SnapAndSlide
//
//  Created by Gagan Joshi on 1/23/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *labelTitle;

@property (strong,nonatomic)  UIImageView *imageView;
@property (strong,nonatomic)  UIImage *image;

@property (strong, nonatomic) UILabel *labelDate;
@property (strong, nonatomic) UILabel *labelDay;



@end
