//
//  LogVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 10/30/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//




#import <UIKit/UIKit.h>
#import "ProjectRecord.h"

@interface LogVC : UITableViewController <UIPickerViewDataSource,UIPickerViewDelegate,UIAlertViewDelegate>
{
    NSString *m_ProjectName;
    NSString *m_ProjectId;
}

@property (nonatomic,strong) NSMutableArray *arrayProjects;

@property (nonatomic,strong) NSMutableArray *arrayIcons;

@property (assign,nonatomic) BOOL shouldSelectProjectBtn;

@end