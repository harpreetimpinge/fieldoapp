//
//  TaskCommentDownloader.m
//  Fieldo
//
//  Created by Gagan Joshi on 12/6/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "TaskCommentDownloader.h"



@interface TaskCommentDownloader ()
@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) TaskCommentRecord *commentRecord;
@end



@implementation TaskCommentDownloader
@synthesize delegate = _delegate;
@synthesize indexPathInTableView = _indexPathInTableView;
@synthesize commentRecord = _commentRecord;


- (id)initWithCommentRecord:(TaskCommentRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<CommentDownloaderDelegate>)theDelegate
{
    if (self = [super init])
    {
        // 2: Set the properties.
        self.delegate = theDelegate;
        self.indexPathInTableView = indexPath;
        self.commentRecord = record;
    }
    return self;
}

- (void)main
{
    @autoreleasepool
    {
        if (self.isCancelled)
            return;
        
        
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.commentRecord.commentImageURL];
        
        
        if (self.isCancelled)
        {
            imageData = nil;
            return;
        }
        
        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            self.commentRecord.commentImage = downloadedImage;
        }
        else {
            self.commentRecord.failed = YES;
        }
        
        imageData = nil;
        
        if (self.isCancelled)
            return;
        
        // 5: Cast the operation to NSObject, and notify the caller on the main thread.
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(commentDownloaderDidFinish:) withObject:self waitUntilDone:NO];
        
    }
}

@end