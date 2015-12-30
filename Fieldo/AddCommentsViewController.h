//
//  AddCommentsViewController.h
//  Fieldo
//
//  Created by Gagan Joshi on 3/20/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCommentsViewController : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate>

{
    UIImagePickerController *imagePicker;
}
@property (strong,nonatomic) UIButton *btnImage;
@property (strong,nonatomic) UITextField *textField;
@property (nonatomic,retain) UIImageView *imageComment;
@property(nonatomic,retain) UISlider *sliderTaskProgress;
@property(nonatomic,retain) UILabel *lblSlider;

@property(nonatomic,retain) NSDictionary *dictTaskDetail;
@property(strong,nonatomic) NSString *stringProjectId;
@property(strong,nonatomic) NSString *stringHeadId;

@property(strong,nonatomic) NSString *stringPercentage;


@end
