//
//  MaterialExpenseVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/12/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaterialExpenseVC : UITableViewController<UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{
    UIImagePickerController* picker;
}
@property (nonatomic,retain) UIImage *imageMaterial;

@property(nonatomic,retain) NSString *stringProjectId;
@property (nonatomic,strong) NSMutableArray *arrayProjects;
@property(nonatomic,strong)  NSMutableArray *arrayStores;

@end
