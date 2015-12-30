//
//  LoginVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 10/23/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginVC : UIViewController <UITextFieldDelegate>

@property (nonatomic,retain) UITextField *textFieldEmail;
@property (nonatomic,retain) UITextField *textFieldPassword;
@property (nonatomic,retain) UISwitch    *switchRememberPassword;

@property(nonatomic,retain) UISegmentedControl *segmentControl;


@end
