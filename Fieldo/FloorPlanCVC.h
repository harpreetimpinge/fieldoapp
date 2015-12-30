//
//  FloorPlanCVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 2/18/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageRecord.h"
#import "PendingOperations.h"
#import "ImageDownloader.h"

@interface FloorPlanCVC : UICollectionViewController<ImageDownloaderDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>


@property(nonatomic,retain) NSString *stringProjectId;

@property(nonatomic,strong) NSMutableArray *arrayImageRecords;
@property (nonatomic, strong) PendingOperations *pendingOperations;

@property(nonatomic,retain) NSIndexPath *indexPath;



@end
