//
//  addCustomerViewController.h
//  Fieldo
//
//  Created by Vishal on 18/11/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Loader.h"
#import "MBProgressHUD.h"
@interface addCustomerViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *customerNameField;
@property (strong, nonatomic) IBOutlet UITextField *companyNameField;
@property (strong, nonatomic) IBOutlet UITextField *organizationNoField;
@property (strong, nonatomic) IBOutlet UITextField *phoneField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;

@property (strong, nonatomic) IBOutlet UIScrollView *m_scrollView;
- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *organisationNoLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;


@end
