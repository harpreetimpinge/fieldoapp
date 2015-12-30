//
//  ImageRecord.h
//  Flyers
//
//  Created by Dinesh on 30/06/13.
//  Copyright (c) 2013 impinge. All rights reserved.
//



#import <UIKit/UIKit.h> // because we need UIImage

@interface ImageRecord : NSObject

@property (nonatomic, strong) UIImage *image; // To store the actual image
@property (nonatomic, strong) NSURL *imageURL; // To store the URL of the image
@property (nonatomic, readonly) BOOL hasImage; // Return YES if image is downloaded.
@property (nonatomic, getter = isFailed) BOOL failed; // Return Yes if image failed to be downloaded


@end
