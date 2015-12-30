//
//  ProjectOptionsVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 10/26/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectRecord.h"

@interface ProjectOptionsVC : UITableViewController



@property(nonatomic,retain) NSMutableArray *arrayProjectDetails;
@property(nonatomic,retain) NSMutableArray *arrayImages;
@property(nonatomic,retain) ProjectRecord *currentProject;

@end
