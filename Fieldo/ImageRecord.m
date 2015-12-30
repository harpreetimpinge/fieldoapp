//
//  ImageRecord.m
//  Flyers
//
//  Created by Dinesh on 30/06/13.
//  Copyright (c) 2013 impinge. All rights reserved.
//

#import "ImageRecord.h"

@implementation ImageRecord



@synthesize image=_image;
@synthesize imageURL=_imageURL;
@synthesize hasImage=_hasImage;
@synthesize failed=_failed;


- (BOOL)hasImage
{
    return _image != nil;
}


- (BOOL)isFailed {
    return _failed;
}



@end