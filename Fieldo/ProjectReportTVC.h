//
//  ProjectReportTVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/28/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectReportTVC : UITableViewController
{
    UILabel *labelData;
}
@property(nonatomic,retain) NSString *stringProjectId;
@property(nonatomic,retain) NSString *stringWorkerId;


@property(strong, nonatomic) NSMutableArray *arrayTime;

@property(nonatomic,retain) NSMutableArray *arrayMaterial;
@property(nonatomic,retain) NSMutableArray *arrayTravel;

@property(nonatomic,retain) UISegmentedControl *segmentControl;

@end