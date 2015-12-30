//
//  WorkPlanVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/19/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkPlanVC : UITableViewController


@property (nonatomic,strong) NSMutableArray *arrayWork;

@property(nonatomic,retain) NSString *stringProjectId;

@property (nonatomic,strong) NSMutableArray *arrayIndexExpandedSections;

@property (nonatomic,strong) UIProgressView *progressView;
@property(nonatomic,retain) NSString *strProjectComplete;
@property(nonatomic,retain) UILabel *lblProgressView;






@end
