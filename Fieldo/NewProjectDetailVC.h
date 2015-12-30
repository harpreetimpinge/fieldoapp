//
//  NewProjectDetailVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 4/7/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectRecord.h"
@interface NewProjectDetailVC : UIViewController<UITextFieldDelegate,UITextViewDelegate>

@property(nonatomic,retain) ProjectRecord *currentProject;
@property (strong,nonatomic) UITextField *textField;
@property (strong,nonatomic) UITextView *textView;
//Views For Notifications

@property(strong,nonatomic) UIDatePicker *datePicker;
@end
