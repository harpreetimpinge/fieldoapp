//
//  ProjectDownloader.m
//  Fieldo
//
//  Created by Gagan Joshi on 10/27/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//



#import "ProjectDownloader.h"


// 1: Declare a private interface, so you can change the attributes of instance variables to read-write.
@interface ProjectDownloader ()
@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) ProjectRecord *projectRecord;
@end


@implementation ProjectDownloader
@synthesize delegate = _delegate;
@synthesize indexPathInTableView = _indexPathInTableView;
@synthesize projectRecord = _projectRecord;



#pragma mark -
#pragma mark - Life Cycle

- (id)initWithProjectRecord:(ProjectRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ProjectDownloaderDelegate>)theDelegate
{
    if (self = [super init])
    {
        // 2: Set the properties.
        self.delegate = theDelegate;
        self.indexPathInTableView = indexPath;
        self.projectRecord = record;
    }
    return self;
}

#pragma mark -
#pragma mark - Downloading image

// 3: Regularly check for isCancelled, to make sure the operation terminates as soon as possible.
- (void)main
{
    // 4: Apple recommends using @autoreleasepool block instead of alloc and init NSAutoreleasePool, because blocks are more efficient. You might use NSAuoreleasePool instead and that would be fine.
    @autoreleasepool
    {
        if (self.isCancelled)
            return;
        
        NSLog(@"%@",self.projectRecord.projectImageURL);
        
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.projectRecord.projectImageURL];
        
        
        if (self.isCancelled)
        {
            imageData = nil;
            return;
        }
        
        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            self.projectRecord.projectImage = downloadedImage;
        }
        else {
            self.projectRecord.failed = YES;
        }
        
        imageData = nil;
        
        if (self.isCancelled)
            return;
        
        // 5: Cast the operation to NSObject, and notify the caller on the main thread.
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(projectDownloaderDidFinish:) withObject:self waitUntilDone:NO];
        
    }
}

@end

