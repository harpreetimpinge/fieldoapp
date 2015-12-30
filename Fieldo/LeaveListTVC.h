//
//  LeaveListTVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 4/8/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectRecord.h"
#import "PendingOperations.h"
#import "ProjectDownloader.h"
@interface LeaveListTVC : UITableViewController<ProjectDownloaderDelegate>
{
    int flag;
}
@property (nonatomic,strong) NSMutableArray *arrayProjects;
@property (nonatomic,strong) PendingOperations *pendingOperations;
@end
