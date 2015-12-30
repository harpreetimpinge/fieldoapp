//
//  AppDelegate.m
//  Fieldo
//
//  Created by Gagan Joshi on 10/15/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "AppDelegate.h"
#import "PersistentStore.h"
#import "TheAPIKey.h"
#import "Language.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Reachability.h"
#import <SplunkMint-iOS/SplunkMint-iOS.h>

@implementation AppDelegate
@synthesize m_workersArrayGlobal;
@synthesize checkLogView;
static int showHide=1;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    if ([PersistentStore getLocalLanguage]==nil)
    {
        [PersistentStore setLocalLanguage:@"en"];
    }

    [Language setLanguage:[PersistentStore getLocalLanguage]];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
   
    if(IS_OS_8_OR_LATER)
    {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        UIUserNotificationSettings *settings=[UIUserNotificationSettings settingsForTypes:UIRemoteNotificationTypeBadge| UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    [GMSServices provideAPIKey:kAPIKey];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    m_workersArrayGlobal=[[NSMutableArray alloc]init];
    
    self.mainMenuVC= [[MainMenuVC alloc] init];
    self.loginVC = [[LoginVC alloc] initWithNibName:nil bundle:nil];
    
    [[Mint sharedInstance] initAndStartSession:@"43587421"];
        
    NSLog(@"Login Status %@",[PersistentStore getLoginStatus]);
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"]  || [[PersistentStore getLoginStatus] isEqualToString:@"Customer"] )
    {
        self.mainMenuVC.IsLogin=[NSNumber numberWithBool:YES];
        self.window.rootViewController = self.mainMenuVC;
    }
    else
    {
//      UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.loginVC];
        self.window.rootViewController = self.loginVC;
    }


    [self configureReachability];
    [self.window makeKeyAndVisible];
    
    return YES;
}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    NSString *tokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    [PersistentStore setDeviceToken:tokenString];
    
    NSLog(@"Push Notification Device Token :%@",tokenString);
    
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:tokenString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [alert show];
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    //self.mDeviceTokenString = @"55dfc29a 65ed1d70 91b0e02f f815f848 ea4ffbe5 1a2f16dd 1b64788d c9d8bf20";
  //  NSString* s=[[NSString alloc] initWithFormat:@"%@",error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Notification data  %@", userInfo);
    if ([userInfo[@"Data"][0][@"key"] intValue]==2)
    {
        NSLog(@"Notification data   %@", userInfo[@"Data"][0][@"msgkey"]);
        [self postRequestProjectAssignMessage:[NSString stringWithFormat:@"%d",[userInfo[@"Data"][0][@"msgkey"] intValue]]];
    }
    [self postRequestIconBadge];
 }

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
}

-(void)postRequestProjectAssignMessage:(NSString *)msgId
{
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:msgId forKey:@"id"];
    
    if (APP_DELEGATE.isServerReachable)
    {
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_Notification_Project_Assign_Message]];
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
             NSLog(@"Its NSDictionary Class");
             
             
             self.dictionaryProjectNotification=object;
             [self performSelectorOnMainThread:@selector(drawNotificationView:) withObject:object waitUntilDone:YES];
         }
         
     }];
    }
    else
    {
//      [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
}

-(void)postRequestIconBadge
{
    
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
    if (APP_DELEGATE.isServerReachable) {
    
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://fieldo.se/api/updateiphonebadge.php"]];
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
     }];
    }
    else
    {
//        [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
   if(showHide==0)
   {
       showHide=1;
       [self doneAction];
   }
    return YES;
}



-(void)drawNotificationView:(NSDictionary *)dict
{
    
    self.viewNotification=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    self.viewNotification.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    
    NSString *startDate =[dict[@"created_at"] substringToIndex:10];
    
    // Prepare an NSDateFormatter to convert to and from the string representation
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // ...using a date format corresponding to your date
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // Parse the string representation of the date
    NSDate *date = [dateFormatter dateFromString:startDate];
    
    // Write the date back out using the same format
    NSLog(@"Month %@",[dateFormatter stringFromDate:date]);
    
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(20, 100, 280, 260)];
    view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    [[view layer] setBorderColor:[[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] CGColor]];
    [[view layer] setBorderWidth:1];
    [[view layer] setCornerRadius:3.0];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 280, 30)];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=dict[@"title"];
    label.font = [UIFont fontWithName:@"Arial" size:16];
    [view addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0,40, 140, 30)];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=@"Start Date";
    label.font = [UIFont fontWithName:@"Arial" size:14];
    [view addSubview:label];
   

    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(120, 40, 100, 30)];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.font = [UIFont systemFontOfSize:15];
    self.textField.text = [dateFormatter stringFromDate:date];
    self.textField.delegate=self;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.keyboardType = UIKeyboardTypeDefault;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [view addSubview:self.textField];

    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(120, 40, 100, 30);
    [button addTarget:self action:@selector(displayExternalDatePickerForRowAtIndexPath) forControlEvents:UIControlEventTouchUpInside];
    [view  addSubview:button];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 80, 240, 80)];
    self.textView.font=[UIFont systemFontOfSize:16];
    self.textView.delegate=self;
    self.textView.text=dict[@"comment"];
    [[self.textView layer] setBorderColor:[[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.f] CGColor]];
    [[self.textView layer] setBorderWidth:1];
    [[self.textView layer] setCornerRadius:3.0];
    [view addSubview:self.textView];
    
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(10, 180, 80, 40);
    button.tag=100;
    [button setBackgroundImage:[UIImage imageNamed:@"btn_welcome_screen"] forState:UIControlStateNormal];
    [button setTitle:[Language get:@"Accept" alter:@"!Accept"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(postRequestProjectAssignReply:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font=[UIFont systemFontOfSize:14];
    [view addSubview:button];
    
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(100, 180, 80, 40);
    button.tag=102;
    [button setBackgroundImage:[UIImage imageNamed:@"btn_welcome_screen"] forState:UIControlStateNormal];
    [button setTitle:[Language get:@"Pending" alter:@"!Pending"]  forState:UIControlStateNormal];
    [button addTarget:self action:@selector(postRequestProjectAssignReply:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font=[UIFont systemFontOfSize:14];
    [view addSubview:button];
    
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(190, 180, 80, 40);
    button.tag=101;
    [button setBackgroundImage:[UIImage imageNamed:@"btn_welcome_screen"] forState:UIControlStateNormal];
    [button setTitle:[Language get:@"Decline" alter:@"!Decline"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(postRequestProjectAssignReply:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font=[UIFont systemFontOfSize:14];
    [view addSubview:button];
    
    [self.viewNotification addSubview:view];
    
    [self.window addSubview:self.viewNotification];
    
}



- (void)displayExternalDatePickerForRowAtIndexPath
{
  
    if (showHide==1)
    {
        NSString *startDate =self.textField.text;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormatter dateFromString:startDate];
        
        self.datePicker=[[UIDatePicker alloc] init];
        self.datePicker.datePickerMode=UIDatePickerModeDate;
        // first update the date picker's date value according to our model
        [self.datePicker setDate:date animated:YES];
        [self.datePicker addTarget:self action:@selector(dateAction:) forControlEvents:UIControlEventValueChanged];
        //the date picker might already be showing, so don't add it to our view
        if (self.datePicker.superview == nil)
        {
            CGRect startFrame = self.datePicker.frame;
            CGRect endFrame = self.datePicker.frame;
            
            // the start position is below the bottom of the visible frame
            startFrame.origin.y = self.viewNotification.frame.size.height;
            
            // the end position is slid up by the height of the view
            endFrame.origin.y = startFrame.origin.y - endFrame.size.height;
            
            self.datePicker.frame = startFrame;
            
            [self.viewNotification addSubview:self.datePicker];
            
            // animate the date picker into view
            [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.datePicker.frame = endFrame; }
                             completion:^(BOOL finished) {
                             }];
        }
 
        showHide=0;
    }
    else
    {
        [self doneAction];
        showHide=1;
    }
    
   }


- (void)dateAction:(UIDatePicker *)datePicker;
{
   
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.textField.text=[dateFormatter stringFromDate:datePicker.date];
}


/*! User chose to finish using the UIDatePicker by pressing the "Done" button, (used only for non-inline date picker), iOS 6.1.x or earlier
 
 @param sender The sender for this action: The "Done" UIBarButtonItem
 */
- (void)doneAction
{
    CGRect pickerFrame = self.datePicker.frame;
    pickerFrame.origin.y = self.viewNotification.frame.size.height;
    
    // animate the date picker out of view
    [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.datePicker.frame = pickerFrame; }
                     completion:^(BOOL finished) {
                         [self.datePicker removeFromSuperview];
                     }];
    
}



-(void)postRequestProjectAssignReply:(id)sender
{
    
    NSLog(@"%@",self.dictionaryProjectNotification);
    
    
    NSString *accept = [NSString stringWithFormat:@"%d",(int)[(UIButton*)sender tag] - 100];
    

    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:accept forKey:@"ISAccept"];
    [postDict setObject:self.dictionaryProjectNotification[@"worker_id"] forKey:@"worker_id"];
    [postDict setObject:self.dictionaryProjectNotification[@"work_id"] forKey:@"work_id"];
    [postDict setObject:self.textField.text forKey:@"start_date_by_worker"];
    [postDict setObject:self.dictionaryProjectNotification[@"project_id"] forKey:@"project_id"];
   
    if (APP_DELEGATE.isServerReachable) {
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_Project_Assign_Return]];
    [urlRequest setTimeoutInterval:180];
    NSString *requestBody = [NSString stringWithFormat:@"JsonObject=%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
         NSLog(@"%@",object);
         
          [self performSelectorOnMainThread:@selector(removeNotificationView) withObject:object waitUntilDone:YES];
         
     }];
    }
    else
    {
//        [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
}


-(void)removeNotificationView
{
    [self.viewNotification removeFromSuperview];
}




- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
  
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}






#pragma mark - Rechability..

-(void)configureReachability
{
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    NSString *str=[userDefaults valueForKey:@"Hit"];
    //    if([str isEqualToString:@"Yes"])
    //    {
    //    [userDefaults setValue:@"No" forKey:@"Hit"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    serverReachability = [Reachability reachabilityForInternetConnection];
    [serverReachability startNotifier];
    [self updateInterfaceWithReachability:serverReachability];
    //    }
    //    [userDefaults synchronize];
}

//this method will be called on reach of internet reachability change notification..
- (void)reachabilityChanged:(NSNotification*)note
{
    
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability:curReach];
}

//this method updates local variable responsible for internet checking in entire application
- (void)updateInterfaceWithReachability:(Reachability*)curReach
{
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	switch (netStatus)
    {
        case NotReachable:
			self.isServerReachable = NO;
			break;
		case ReachableViaWWAN:
			self.isServerReachable = YES;
            self.isWAN = YES;
			break;
		case ReachableViaWiFi:
			self.isServerReachable = YES;
            self.isWAN = NO;
			break;
	}
}








@end
