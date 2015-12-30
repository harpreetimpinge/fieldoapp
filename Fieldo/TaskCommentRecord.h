//
//  TaskCommentRecord.h
//  Fieldo
//
//  Created by Gagan Joshi on 12/6/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>    // because we need UIImage

@interface TaskCommentRecord : NSObject

@property(nonatomic,strong) NSString *commentId;
@property(nonatomic,strong) NSString *commentMessage;
@property(nonatomic,strong) NSString *commentFrom;
@property(nonatomic,strong) NSString *commentProjectId;
@property(nonatomic,strong) NSString *commentWorkerId;
@property(nonatomic,strong) NSString *commentDate;
@property (nonatomic, strong) UIImage *commentImage; // To store the actual image
@property (nonatomic, strong) NSURL *commentImageURL; // To store the URL of the image
@property (nonatomic, readonly) BOOL hasImage; // Return YES if image is downloaded.
@property (nonatomic, getter = isFailed) BOOL failed; // Return Yes if image failed to be downloaded



@end
