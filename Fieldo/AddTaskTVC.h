//
//  AddTask.h
//  Fieldo
//
//  Created by Gagan Joshi on 3/14/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//



#import <UIKit/UIKit.h>

@interface AddTaskTVC : UITableViewController<UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,UIPickerViewDataSource,UIPickerViewDelegate>


@property(nonatomic,retain) NSString *stringProjectId;
@property (nonatomic,strong) NSMutableArray *arraySubProjects;

@end
