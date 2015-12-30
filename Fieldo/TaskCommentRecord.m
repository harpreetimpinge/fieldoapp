//
//  TaskCommentRecord.m
//  Fieldo
//
//  Created by Gagan Joshi on 12/6/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "TaskCommentRecord.h"

@implementation TaskCommentRecord


@synthesize commentId=_commentId;
@synthesize commentMessage=_commentMessage;
@synthesize commentFrom=_commentFrom;
@synthesize commentProjectId=_commentProjectId;
@synthesize commentWorkerId=_commentWorkerId;
@synthesize commentDate=_commentDate;
@synthesize commentImage=_commentImage;
@synthesize commentImageURL=_commentImageURL;
@synthesize hasImage=_hasImage;
@synthesize failed=_failed;



- (BOOL)hasImage
{
    return _commentImage != nil;
}


- (BOOL)isFailed {
    return _failed;
}



@end
