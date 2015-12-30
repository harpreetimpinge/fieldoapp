//
//  ProjectDownloader.h
//  Fieldo
//
//  Created by Gagan Joshi on 10/27/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//


#import <Foundation/Foundation.h>

// 1: Import ProjectRecord.h so that you can independently set the image property of a Project once it is successfully downloaded. If downloading fails, set its failed value to YES.
#import "ProjectRecord.h"

// 2: Declare a delegate so that you can notify the caller once the operation is finished.
@protocol ProjectDownloaderDelegate;

@interface ProjectDownloader : NSOperation

@property (nonatomic, assign) id <ProjectDownloaderDelegate> delegate;

// 3: Declare indexPathInTableView for convenience so that once the operation is finished, the caller has a reference to where this operation belongs to.
@property (nonatomic, readonly, strong) NSIndexPath   *indexPathInTableView;
@property (nonatomic, readonly, strong) ProjectRecord *projectRecord;

// 4: Declare a designated initializer.
- (id)initWithProjectRecord:(ProjectRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ProjectDownloaderDelegate>) theDelegate;

@end

@protocol ProjectDownloaderDelegate <NSObject>

// 5: In your delegate method, pass the whole class as an object back to the caller so that the caller can access both indexPathInTableView and Store. Because you need to cast the operation to NSObject and return it on the main thread, the delegate method canít have more than one argument.
- (void)projectDownloaderDidFinish:(ProjectDownloader *)downloader;


@end