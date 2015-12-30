//
//  InvoiceProjectReportTVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 3/21/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//



#import <UIKit/UIKit.h>

@interface InvoiceProjectReportTVC : UITableViewController
{
    NSString *strCost;
    UILabel *lblProjectType;
    UILabel *lblProjectCost;
    UIView *viewHeader;
    UIView *viewFooter;

}
@property(nonatomic,retain) NSString *stringProjectId;
@property(nonatomic,retain) NSString *stringProjectType;
@property(nonatomic,retain) NSString *managerId;
@property(nonatomic,retain) NSString *managerEmail;


@property(nonatomic,retain) NSMutableArray *arrayTime;
@property(nonatomic,retain) NSMutableArray *arrayMaterial;
@property(nonatomic,retain) NSMutableArray *arrayTravel;

@property(nonatomic,retain) UISegmentedControl *segmentControl;
@property(nonatomic,retain) UISegmentedControl *segmentControlFooter;

@property (nonatomic,retain) NSString *custAccept;

@end
