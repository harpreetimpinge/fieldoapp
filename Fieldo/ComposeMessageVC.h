//
//  ComposeMessageVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/13/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>





@interface ComposeMessageVC : UITableViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,retain) NSMutableArray *arrayProjects;





@end
