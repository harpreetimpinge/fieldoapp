//
//  Helper.h
//  Fieldo
//
//  Created by Gagan Joshi on 10/23/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject <UITextFieldDelegate>




+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize;
+ (UIImage *)aspectScaleImage:(UIImage *)image toSize:(CGSize)size;


+(UIView *)navigationBarTitle:(NSString *)str;

+(UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;


@end
