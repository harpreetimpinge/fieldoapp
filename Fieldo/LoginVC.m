//
//  LoginVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 10/23/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "LoginVC.h"
#import "Helper.h"
#import "AppDelegate.h"
#import "PersistentStore.h"
#import "MBProgressHUD.h"
#import "Language.h"
#import "ChangeLanguageVC.h"
#import "CurrentLocationView.h"
#import <CoreLocation/CoreLocation.h>

@interface LoginVC ()<CLLocationManagerDelegate>{
    CLLocation *SearchedLocation;
    CLLocationManager *locationManager;
}

@end

@implementation LoginVC

-(void)showLoadingView
{
    //self.tableView.hidden=YES;
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = YES;
    hud.labelText = @"Loading...";
    hud.dimBackground = YES;
}

-(void)refreshTable
{
    [self hideLoadingView];
}

-(void)hideLoadingView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=YES;
     NSString *strNotification=@"LanguageChange";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DesignInterface) name:strNotification object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [self currentLocation];
}

#pragma mark - CLLocation For Current Location
-(void)currentLocation{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    if(IS_OS_8_OR_LATER){
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
#pragma mark -
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Failed to get your location." alter:@"!Failed to get your location."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        SearchedLocation = currentLocation;
        [locationManager stopUpdatingLocation];
        
        if ([[USER_LOGINID valueForKey:@"userLogin"] isEqualToString:@"0"]) {
            CurrentLocationView *currentView = [[CurrentLocationView alloc] init];
            currentView.longitude = [NSString stringWithFormat:@"%f",SearchedLocation.coordinate.longitude];
            currentView.latitude = [NSString stringWithFormat:@"%f",SearchedLocation.coordinate.latitude];
            [currentView userCurrentLocation:self.view];
        }
        
    }
}

-(void)DesignInterface
{
    UIView *view=[[UIView alloc] init];
    view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    
    UIImageView *imageview=[[UIImageView alloc] initWithFrame:CGRectMake(30, 130, 60, 40)];
    imageview.image=[UIImage imageNamed:@"imageUserIcon.png"];
    [view addSubview:imageview];
    
    imageview=[[UIImageView alloc] initWithFrame:CGRectMake(30,180,60,40)];
    imageview.image=[UIImage imageNamed:@"imagePasswordIcon.png"];
    [view addSubview:imageview];
    
    imageview=[[UIImageView alloc] initWithFrame:CGRectMake(90, 130,200,40)];
    imageview.image=[UIImage imageNamed:@"imageBackTextField.png"];
    [view addSubview:imageview];
    
    
    imageview=[[UIImageView alloc] initWithFrame:CGRectMake(90, 180,200,40)];
    imageview.image=[UIImage imageNamed:@"imageBackTextField.png"];
    [view addSubview:imageview];
    
    imageview=[[UIImageView alloc] initWithFrame:CGRectMake(10, 105,300,20)];
    imageview.image=[UIImage imageNamed:@"imageTopShadow.png"];
    [view addSubview:imageview];
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(60,70, 200, 30)];
    label.textColor=[UIColor lightGrayColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.backgroundColor=[UIColor clearColor];
    label.font=[UIFont boldSystemFontOfSize:25];
    label.text=[Language get:@"Login" alter:@"!Login"];
    [view addSubview:label];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(115,230, 260, 30)];
    label.textColor=[UIColor lightGrayColor];
    label.backgroundColor=[UIColor clearColor];
    label.text=[Language get:@"Remember Password?" alter:@"!Remember Password?"];
    [view addSubview:label];
    
    self.textFieldEmail =  [[UITextField alloc] initWithFrame:CGRectMake(95, 130, 190, 40)];
    self.textFieldEmail.placeholder=@"Enter Email";
    self.textFieldEmail.borderStyle=UITextBorderStyleNone;
    self.textFieldEmail.delegate = self;
    self.textFieldEmail.font = [UIFont systemFontOfSize:15];
    self.textFieldEmail.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textFieldEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textFieldEmail.keyboardType=UIKeyboardTypeEmailAddress;
    [view addSubview:self.textFieldEmail];
    
    self.textFieldPassword =[[UITextField alloc] initWithFrame:CGRectMake(95, 180, 190, 40)];
    self.textFieldPassword.placeholder=@"*************";
    self.textFieldEmail.font = [UIFont systemFontOfSize:15];
    self.textFieldPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textFieldPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textFieldPassword.delegate = self;
    self.textFieldPassword.secureTextEntry = YES;
    [view addSubview:self.textFieldPassword];
    
    self.switchRememberPassword = [[UISwitch alloc] initWithFrame:CGRectMake(30, 230, 0, 0)];
    [self.switchRememberPassword addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.switchRememberPassword.onTintColor=[UIColor colorWithRed:0.1608 green:0.3059 blue:0.5216 alpha:0.8];
    [view addSubview:self.switchRememberPassword];
    
    NSMutableArray *array=[[NSMutableArray alloc] init];
    [array addObject:[Language get:@"Worker" alter:@"!Worker"]];
    [array addObject:[Language get:@"Customer" alter:@"!Customer"]];
    
    
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:array];
    self.segmentControl.frame = CGRectMake(35, 280, 250, 30);
    [self.segmentControl addTarget:self action:@selector(segmentedControl_ValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentControl setSelectedSegmentIndex:0];
    [view addSubview:self.segmentControl];
    
    if(self.segmentControl.selectedSegmentIndex ==0)
    {
        if ([PersistentStore getLoginEmailWorker]!=nil)
        {
            self.textFieldEmail.text=[PersistentStore getLoginEmailWorker];
            self.textFieldPassword.text=[PersistentStore getLoginPasswordWorker];
            self.switchRememberPassword.on=YES;
        }
        
    }
    else
    {
        if ([PersistentStore getLoginEmailCustomer]!=nil)
        {
            self.textFieldEmail.text=[PersistentStore getLoginEmailCustomer];
            self.textFieldPassword.text=[PersistentStore getLoginPasswordCustomer];
            self.switchRememberPassword.on=YES;
        }
        
    }
    
    imageview=[[UIImageView alloc] initWithFrame:CGRectMake(10, 315,300,20)];
    imageview.image=[UIImage imageNamed:@"imageBottomShadow.png"];
    [view addSubview:imageview];
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(100, 350, 120, 37);
    button.titleLabel.font=[UIFont systemFontOfSize:14];
    [button setBackgroundImage:[UIImage imageNamed:@"login-button.png"] forState:UIControlStateNormal];
    [button setTitle:[Language get:@"Login" alter:@"!Login"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(loginButtonclicked) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(100, 395, 120, 30);
    button.titleLabel.font=[UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitle:[Language get:@"Lost Password" alter:@"!Lost Password"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(forgetPasswordButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(100, 430, 120, 37);
    button.titleLabel.font=[UIFont systemFontOfSize:14];
    [button setBackgroundImage:[UIImage imageNamed:@"login-button.png"] forState:UIControlStateNormal];
    [button setTitle:[Language get:@"Pick a Language" alter:@"Pick a Language"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pickButtonclicked) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    self.view=view;

}

-(void)segmentedControl_ValueChanged:(UISegmentedControl *)segment
{
    if(segment.selectedSegmentIndex == 0)
    {
        //action for the first button (Current)
    }
    if(segment.selectedSegmentIndex == 1)
    {
        //action for the first button (Current)
    }
}

-(void)loadView
{
    [self DesignInterface];
}

-(void)openSafari
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://fieldo.se"]];
}

- (void)pickButtonclicked
{
    ChangeLanguageVC *changeLanguageVC=[[ChangeLanguageVC alloc] init];
//    [self.navigationController pushViewController:changeLanguageVC animated:YES];
    
    [self presentViewController:changeLanguageVC animated:YES completion:nil];
}
- (void)changeSwitch:(id)sender
{
    if([sender isOn])
    {
        // Execute any code when the switch is ON
        NSLog(@"Switch is ON");
    } else
    {
        // Execute any code when the switch is OFF
        NSLog(@"Switch is OFF");
    }
}

-(void)forgetPasswordButtonClicked
{
    [self.textFieldEmail resignFirstResponder];
    [self.textFieldPassword resignFirstResponder];

    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    if ([emailTest evaluateWithObject:self.textFieldEmail.text] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Please enter a valid email address." alter:@"!Please enter a valid email address."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else
    {
    [self showLoadingView];
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:self.textFieldEmail.text forKey:@"email"];
    
    if (APP_DELEGATE.isServerReachable) {
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_FORGET_PASSWORD]];
    [urlRequest setTimeoutInterval:180];
    NSString *requestBody = [NSString stringWithFormat:@"JsonObject=%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
         NSLog(@"%@",object);
         if (error)
         {
             NSLog(@"Error: %@",[error description]);
         }
         if ([object isKindOfClass:[NSDictionary class]] == YES)
         {
             if ([object[@"CODE"] intValue]==1)
             {
                 [self performSelectorOnMainThread:@selector(alertAction:) withObject:@"Invalid Username" waitUntilDone:YES];
             }
             else
             {
                 [self performSelectorOnMainThread:@selector(alertAction:) withObject:@"Password Reset Successfully. Please check your email for new password." waitUntilDone:YES];
            }
         }
     }];
    }
    else
    {
        [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    }
}

-(void)loginButtonclicked
{
    [self.textFieldEmail resignFirstResponder];
    [self.textFieldPassword resignFirstResponder];
    

//#ifdef DEBUG_FACILITIES_ENABLED
//    self.textFieldEmail.text = @"gagan.joshi@impingeonline.com";
//    self.textFieldPassword.text = @"1234";
//#endif
    
    
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    if ([emailTest evaluateWithObject:self.textFieldEmail.text] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Please enter a valid email address." alter:@"!Please enter a valid email address."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if(![self.textFieldPassword.text length])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Please enter your password." alter:@"!Please enter your password."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else
    {
        [self postRequestLoginWithEmail:self.textFieldEmail.text andPassword:self.textFieldPassword.text];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.textFieldEmail resignFirstResponder];
    [self.textFieldPassword resignFirstResponder];
}

-(void)postRequestLoginWithEmail:(NSString *)email andPassword:(NSString *)password;
{
    
    [self showLoadingView];

    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:password forKey:@"password"];
    [postDict setObject:email forKey:@"username"];
    [postDict setObject:@"1" forKey:@"device_type"];
    
    if (self.segmentControl.selectedSegmentIndex==0)
    {
        [postDict setObject:@"0" forKey:@"user"];
        [USER_LOGINID setObject:@"0" forKey:@"userLogin"];
    }
    else{
        [postDict setObject:@"1" forKey:@"user"];
        [USER_LOGINID setObject:@"1" forKey:@"userLogin"];
    }
    
    [USER_LOGINID synchronize];
    
    if ([PersistentStore getDeviceToken])
       [postDict setObject:[PersistentStore getDeviceToken] forKey:@"token"];
    else
        [postDict setObject:@"abcdefghijklmnopqrstuvwxyz" forKey:@"token"];//for testing on stumulator
    if (APP_DELEGATE.isServerReachable) {
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_LOGIN]];
        
    [urlRequest setTimeoutInterval:180];
    NSString *requestBody = [NSString stringWithFormat:@"JsonObject=%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSLog(@"My request is %@", requestBody);
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (data == nil)
         {
             [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Data parameter is nil." alter:@"!Data parameter is nil."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
         }
         else
         {
             
             
         id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
         NSLog(@"%@",object);
         if (error)
         {
             NSLog(@"Error: %@",[error description]);
         }
         if ([object isKindOfClass:[NSDictionary class]] == YES)
         {
             
             if ([object[@"CODE"] intValue] == 1)
             {
                [self performSelectorOnMainThread:@selector(loginFailed) withObject:nil waitUntilDone:YES];
             }
             else
             {
                
                NSLog(@"%@",[[object valueForKey:@"ID"] valueForKey:@"worker_id"]);
                [Worker_ID setObject:[[object valueForKey:@"ID"] valueForKey:@"worker_id"] forKey:@"worker_id"];
                [Worker_ID synchronize];
                 
                 if (self.segmentControl.selectedSegmentIndex==0)
                 {
                     if (self.switchRememberPassword.on)
                     {
                         [PersistentStore setLoginEmailWorker:self.textFieldEmail.text];
                         [PersistentStore setLoginPasswordWorker:self.textFieldPassword.text];
                     }
                     else
                     {
                         [PersistentStore setLoginEmailWorker:nil];
                         [PersistentStore setLoginPasswordWorker:nil];
                     }
                     
                     [[NSUserDefaults standardUserDefaults] setObject:object[@"project_permission"] forKey:@"project_permission"];
                     [[NSUserDefaults standardUserDefaults]synchronize];
                     
                      NSArray *array=[NSArray arrayWithObjects:object[@"ID"][@"worker_id"],object[@"ID"][@"worker_name"],object[@"img_url"], nil];
                     [self performSelectorOnMainThread:@selector(goHomeViewAsWorker:) withObject:array waitUntilDone:YES];

                 }
                 else
                 {
                     if (self.switchRememberPassword.on)
                     {
                         [PersistentStore setLoginEmailCustomer:self.textFieldEmail.text];
                         [PersistentStore setLoginPasswordCustomer:self.textFieldPassword.text];
                     }
                     else
                     {
                         [PersistentStore setLoginEmailCustomer:nil];
                         [PersistentStore setLoginPasswordCustomer:nil];
                     }
                     
                     NSArray *array=[NSArray arrayWithObjects:object[@"ID"][@"cust_id"],object[@"ID"][@"cust_name"],object[@"cust_img_url"], nil];
                     [self performSelectorOnMainThread:@selector(goHomeViewAsCustomer:) withObject:array waitUntilDone:YES];

                 }
}
         }
         }
     }];
    }
    else
    {
        [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    
}

-(void) loginFailed
{
    [self hideLoadingView];
    [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Please enter a valid Username and Password. Please try again." alter:@"!Please enter a valid Username and Password. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}
-(void)alertAction:(NSString *)msg
{
    [self hideLoadingView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


-(void)goHomeViewAsWorker:(NSArray *)array
{
    [self hideLoadingView];
    [PersistentStore setWorkerID:array[0]];
    [PersistentStore setWorkerName:array[1]];
    [PersistentStore setWorkerImageUrl:array[2]];
    [PersistentStore setLoginStatus:@"Worker"];
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mainMenuVC.IsLogin=[NSNumber numberWithBool:YES];
    appDelegate.window.rootViewController=appDelegate.mainMenuVC;
}

-(void)goHomeViewAsCustomer:(NSArray *)array
{
    [self hideLoadingView];
    
    [PersistentStore setCustomerID:array[0]];
    [PersistentStore setCustomerName:array[1]];
    [PersistentStore setCustomerImageUrl:array[2]];
    [PersistentStore setLoginStatus:@"Customer"];
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mainMenuVC.IsLogin=[NSNumber numberWithBool:YES];
    appDelegate.window.rootViewController=appDelegate.mainMenuVC;
}




- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField canResignFirstResponder]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
