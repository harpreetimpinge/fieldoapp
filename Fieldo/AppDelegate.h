//
//  AppDelegate.h
//  Fieldo
//
//  Created by Gagan Joshi on 10/15/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMenuVC.h"
#import "LoginVC.h"

@class Reachability;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITextFieldDelegate,UITextViewDelegate>

{
    Reachability *serverReachability;
    NSMutableArray *m_workersArrayGlobal;
}

@property (nonatomic,retain) NSMutableArray *m_workersArrayGlobal;
@property (assign, nonatomic) BOOL isServerReachable;
@property (assign, nonatomic) BOOL isWAN;

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) BOOL checkLogView;

@property (strong,nonatomic) MainMenuVC *mainMenuVC;   //Worker's Main View
@property (strong,nonatomic) LoginVC *loginVC;         //LoginView For Both Worker And Customer

//Views For Notifications
@property(strong,nonatomic) UIView *viewNotification;
@property (strong,nonatomic) UITextField *textField;
@property (strong,nonatomic) UITextView *textView;
//Views For Notifications

@property(strong,nonatomic) NSDictionary *dictionaryProjectNotification;  //Assign Project data Recived after Notification by iphone.php webservice
@property(strong,nonatomic) UIDatePicker *datePicker;                     //Date picker for input date to start the Project  //some work left on it Prahaps













@end
