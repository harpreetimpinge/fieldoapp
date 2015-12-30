//
//  ProjectDetailsTVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/23/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Annotation.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>



@interface ProjectDetailsTVC : UITableViewController<MKMapViewDelegate>
{
}



@property(nonatomic,retain) NSString *stringProjectId;
@property(nonatomic,retain) NSString *stringWorkerId;
@property(nonatomic,retain) NSDictionary *dictProject;
@property(nonatomic,retain) NSMutableArray *arrayCellKeys;

@property(nonatomic,retain) NSArray *arrayProject;



@end

