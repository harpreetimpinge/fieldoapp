//
//  TaskCommentDownloader.h
//  Fieldo
//
//  Created by Gagan Joshi on 12/6/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskCommentRecord.h"

@protocol CommentDownloaderDelegate;


@interface TaskCommentDownloader : NSOperation

@property (nonatomic, assign) id <CommentDownloaderDelegate> delegate;
@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readonly, strong) TaskCommentRecord *commentRecord;

- (id)initWithCommentRecord:(TaskCommentRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<CommentDownloaderDelegate>) theDelegate;

@end


@protocol CommentDownloaderDelegate <NSObject>
- (void)commentDownloaderDidFinish:(TaskCommentDownloader *)downloader;
@end






