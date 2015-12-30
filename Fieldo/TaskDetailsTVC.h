//
//  TaskDetailsTVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/28/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskCommentRecord.h"
#import "PendingOperations.h"
#import "TaskCommentDownloader.h"


@interface TaskDetailsTVC : UITableViewController<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,CommentDownloaderDelegate>
{
    NSString *refreshedSliderValue;
    UIImagePickerController *picker;
}


@property (nonatomic,retain) NSString *strHead;

@property (nonatomic,retain) UIImageView *imageComment;
@property(nonatomic,retain) UISlider *sliderTaskProgress;
@property(nonatomic,retain) NSDictionary *dictTaskDetail;
@property(nonatomic,retain) UILabel *lblSlider;


@property (nonatomic,strong) UIProgressView *progressView;


@property (strong,nonatomic) UIButton *btnImage;
@property (strong,nonatomic) UITextField *textField;

@property(strong,nonatomic) NSString *stringProjectId;
@property(strong,nonatomic) NSString *stringHeadId;

@property (strong,nonatomic) NSMutableArray *arrayComment;

@property(strong,nonatomic) NSString *nameManeger;


@property (nonatomic,strong) PendingOperations *pendingOperations;


@end


