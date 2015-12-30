//
//  InvoiceTVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 3/21/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//





#import <UIKit/UIKit.h>
#import "ProjectRecord.h"
#import "PendingOperations.h"
#import "ProjectDownloader.h"

@interface InvoiceTVC : UITableViewController<ProjectDownloaderDelegate>

@property (nonatomic,strong) NSMutableArray *arrayProjects;
@property (nonatomic,strong) PendingOperations *pendingOperations;

@end