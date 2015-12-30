//
//  OutOfTheOfficeVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/18/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeaveBO.h"

@interface OutOfTheOfficeVC : UITableViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITextViewDelegate>

@property(nonatomic,retain)  NSMutableArray *arrayLeaveReason;

@property (nonatomic,retain) LeaveBO *leaveBO;


@end

