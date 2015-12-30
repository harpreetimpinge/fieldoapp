//
//  TimeLogVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/11/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLogVC : UITableViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITextViewDelegate>

@property(nonatomic,retain)  NSString *stringProjectId;
@property (nonatomic,retain) NSMutableArray *arrayLogTime;



@end
