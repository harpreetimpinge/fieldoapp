//
//  addProjectViewController.h
//  Fieldo
//
//  Created by Vishal on 14/11/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldValidator.h"
@interface addProjectViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{
    BOOL includeVat;
    NSString *projectStartDate;
}
@property (strong, nonatomic) IBOutlet UIButton *doneBtn;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *vatLabel;
@property (strong, nonatomic) IBOutlet UILabel *costLabel;
@property (strong, nonatomic) IBOutlet UILabel *taxReductionLabel;
@property (strong, nonatomic) IBOutlet UILabel *startDateLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UILabel *workersNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *customerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *projectNameLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *projectNameField;

@property (strong, nonatomic) IBOutlet UIButton *customerButton;
@property (strong, nonatomic) IBOutlet UIButton *workersButton;
@property (strong, nonatomic) IBOutlet UIButton *dateButton;
@property (strong, nonatomic) IBOutlet UITextField *taxField;
@property (strong, nonatomic) IBOutlet UITextField *costField;
@property (strong, nonatomic) IBOutlet UITextField *descriptionField;
@property (strong, nonatomic) IBOutlet UITextView *workersTextview;

@property (strong, nonatomic) IBOutlet UILabel *commentLable;
@property (strong, nonatomic) IBOutlet UITextField *commentTextField;


- (IBAction)chooseCustomerAction:(id)sender;
- (IBAction)addWorkersAction:(id)sender;
- (IBAction)startDateAction:(id)sender;
- (IBAction)vatAction:(id)sender;
- (IBAction)captureAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)addCustomerAction:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UIView *pickerBackView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)changeDateAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *captureButton;
@property (strong, nonatomic) IBOutlet UIButton *vatButton;

- (IBAction)doneAction:(id)sender;

@end
