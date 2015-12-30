//
//  ProjectVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 10/26/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//




#import <UIKit/UIKit.h>
#import "ProjectRecord.h"
#import "PendingOperations.h"
#import "ProjectDownloader.h"
#import <CoreLocation/CoreLocation.h>

@interface ProjectsVC : UITableViewController<ProjectDownloaderDelegate,CLLocationManagerDelegate>
{
    int flag;
    CLLocation *SearchedLocation;
    CLLocationManager *locationManager;

}
@property (nonatomic,strong) NSMutableArray *arrayProjects;
@property (nonatomic,strong) PendingOperations *pendingOperations;

@end