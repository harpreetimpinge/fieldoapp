 //
//  MainMenuVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/21/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "AppDelegate.h"
#import "MainMenuVC.h"
#import "ProjectsVC.h"
#import "HomeCVC.h"

//In worker App
#import "CalendarVC.h"
#import "LogVC.h"
//In worker App

//In Customer App
#import "InvoiceTVC.h"
#import "RatingTVC.h"
//In Customer App


#import "PersistentStore.h"
#import "Language.h"

#import <CoreGraphics/CoreGraphics.h>


@interface MainMenuVC (){

    int flagIndex;

}

@end

@implementation MainMenuVC
@synthesize btnProject,btnCalOrRating,btnHome,btnLogOrInvoice;
@synthesize IsLogin;



- (id)init
{
    self = [super init];
    if (self)
    {
       
    }
    return self;
    
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    flagIndex = 0;
    NSLog(@"%i",flagIndex);
    
    UIView *viewBorder=[[UIView alloc] initWithFrame:CGRectMake(0, 20, 321, 80)];
    viewBorder.layer.borderWidth=0.5;
    viewBorder.layer.borderColor=[UIColor lightGrayColor].CGColor;
    [self.view addSubview:viewBorder];
    
    CGRect contentFrame = CGRectMake(0.0, 100.0, 320, self.view.frame.size.height-100);
    
    self.imageViewProfile=[[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 100, 80)];
    
//    self.imageViewProfile.layer.borderWidth=1.0;
//    self.imageViewProfile.layer.borderColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f].CGColor;
    [self.view addSubview:self.imageViewProfile];
    
    
    
    self.buttonAdvertise = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.buttonAdvertise.layer.borderWidth=0.5;
    self.buttonAdvertise.frame=CGRectMake(105, 21, 210, 78);
    [self.buttonAdvertise addTarget:self action:@selector(goToLink) forControlEvents:UIControlEventTouchUpInside];
//    self.buttonAdvertise.layer.borderColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f].CGColor;
    [self.view addSubview:self.buttonAdvertise];
    

    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(100, 0, 220, 100)];
    btnProject = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnProject setFrame:CGRectMake(10, 30, 100, 30)];
    [btnProject setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
    [btnProject setTitle:[Language get:@"Projects" alter:@"!Projects"] forState:UIControlStateNormal];
    btnProject.titleLabel.font=[UIFont systemFontOfSize:14];
    btnProject.tag = 1;
    [btnProject setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
    [btnProject addTarget:self action:@selector(changeBase:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:btnProject];
    
    btnCalOrRating = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCalOrRating setFrame:CGRectMake(115, 30, 100, 30)];
    [btnCalOrRating setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
    btnCalOrRating.titleLabel.font=[UIFont systemFontOfSize:14];
    btnCalOrRating.tag = 2;
    [btnCalOrRating setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
    [btnCalOrRating addTarget:self action:@selector(changeBase:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:btnCalOrRating];
    
    
    btnLogOrInvoice = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLogOrInvoice setFrame:CGRectMake(10, 65, 100, 30)];
    [btnLogOrInvoice setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
    btnLogOrInvoice.titleLabel.font=[UIFont systemFontOfSize:14];
    [btnLogOrInvoice setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
    btnLogOrInvoice.tag = 3;
    [btnLogOrInvoice addTarget:self action:@selector(changeBase:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:btnLogOrInvoice];
    
    btnHome = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnHome setFrame:CGRectMake(115, 65, 100, 30)];
    [btnHome setBackgroundImage:[UIImage imageNamed:@"SelectedTop"] forState:UIControlStateNormal];
    btnHome.titleLabel.font=[UIFont systemFontOfSize:14];
    [btnHome setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnHome setTitle:[Language get:@"Home" alter:@"!Home"] forState:UIControlStateNormal];
    btnHome.tag = 4;
    [btnHome addTarget:self action:@selector(changeBase:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:btnHome];
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        [btnCalOrRating setTitle:[Language get:@"Calendar" alter:@"!Calendar"] forState:UIControlStateNormal];
        [btnLogOrInvoice setTitle:[Language get:@"Log" alter:@"!Log"] forState:UIControlStateNormal];
    }
    else
    {
        [btnCalOrRating setTitle:[Language get:@"Ratings" alter:@"!Ratings"] forState:UIControlStateNormal];
        [btnLogOrInvoice setTitle:[Language get:@"Invoices" alter:@"!Invoices"] forState:UIControlStateNormal];
        
    }
    
    
    
    
    self.menuView.hidden=YES;
    
    [self.view addSubview:self.menuView];
    
    
    self.contentView = [[UIView alloc] initWithFrame:contentFrame] ;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.contentView.backgroundColor = [UIColor grayColor];
    [self.view insertSubview:self.contentView aboveSubview:self.menuView];
    
    
    
    [self postRequestAd];
}



-(void)viewWillAppear:(BOOL)animated
{
    if ([IsLogin boolValue])
    {
        [self addViewController];
        [self designMenu];
        IsLogin=[NSNumber numberWithBool:NO];
    }
}

-(void)designMenu
{
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        [btnCalOrRating setTitle:[Language get:@"Calendar" alter:@"!Calendar"] forState:UIControlStateNormal];
        [btnLogOrInvoice setTitle:[Language get:@"Log" alter:@"!Log"] forState:UIControlStateNormal];
    }
    else
    {
        [btnCalOrRating setTitle:[Language get:@"Ratings" alter:@"!Ratings"] forState:UIControlStateNormal];
        [btnLogOrInvoice setTitle:[Language get:@"Invoices" alter:@"!Invoices"] forState:UIControlStateNormal];
    }
}



-(void)goToLink
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.arrayAdvertiseLink[flagIndex-1]]];
}

- (void)changeBase:(UIButton*)button
{
    if (button.tag==1)
    {
        [btnProject setBackgroundImage:[UIImage imageNamed:@"SelectedTop"] forState:UIControlStateNormal];
        [btnProject setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [btnCalOrRating setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
        [btnCalOrRating setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];

        [btnLogOrInvoice setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
        [btnLogOrInvoice setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];

        [btnHome setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
        btnHome.titleLabel.textColor =[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
    }
    else if(button.tag==2)
    {
        [btnProject setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
        [btnProject setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
        
        [btnCalOrRating setBackgroundImage:[UIImage imageNamed:@"SelectedTop"] forState:UIControlStateNormal];
        [btnCalOrRating setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [btnLogOrInvoice setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
        [btnLogOrInvoice setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];

        
        [btnHome setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
        [btnHome setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
       // btnHome.titleLabel.textColor =[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
 
    }
    else if(button.tag==3)
    {
        [btnProject setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
        [btnProject setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
        
        [btnCalOrRating setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
        [btnCalOrRating setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
        
        [btnLogOrInvoice setBackgroundImage:[UIImage imageNamed:@"SelectedTop"] forState:UIControlStateNormal];
        [btnLogOrInvoice setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [btnHome setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
        // btnHome.titleLabel.textColor = [UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
        [btnHome setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
        
    }
    else
    {
        [btnProject setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
        [btnProject setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
        
        [btnCalOrRating setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
        [btnCalOrRating setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
        
        [btnLogOrInvoice setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
        [btnLogOrInvoice setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
        
        [btnHome setBackgroundImage:[UIImage imageNamed:@"SelectedTop"] forState:UIControlStateNormal];
        [btnHome setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    }
    [PersistentStore setFlagLog:@"YES"];
    
    UIViewController* controller = (UIViewController*)[self.childViewControllers objectAtIndex:button.tag-1];
    
    if ([_contentView.subviews objectAtIndex:0]==controller.view && button.tag<4)
    {
        NSLog(@"Same View");
    }
    else
    {
        for (UINavigationController *nav in self.childViewControllers)
        {
            [nav popToRootViewControllerAnimated:NO];
        }
      
        NSLog(@"%@",_contentView.subviews);
        if([_contentView.subviews count] == 1)
        {
            [[_contentView.subviews objectAtIndex:0] removeFromSuperview];
        }
        
        UIViewController* controller = (UIViewController *)[self.childViewControllers objectAtIndex:button.tag-1];
        controller.view.frame = self.contentView.bounds;
        // Prabhjot
        
        if([controller isKindOfClass:[LogVC class]])
        {
            LogVC *logVC = (LogVC*)controller;
            logVC.shouldSelectProjectBtn = NO;
        } else if([controller isKindOfClass:[UINavigationController class]]) {
            if ([[(UINavigationController*)controller topViewController] isKindOfClass:[LogVC class]]) {
                LogVC *logVC = (LogVC*)[(UINavigationController*)controller topViewController];
                logVC.shouldSelectProjectBtn = YES;
            }
        }
        
        // Stop
        [_contentView addSubview:controller.view];
    }
    
}



#pragma mark - View lifecycle


-(void)addViewController
{
    CGRect rect= CGRectMake(0, 0, 320, 380);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (screenSize.height > 480.0f)
            rect=CGRectMake(0, 0, 320, 468);
    }
    
    if ([self.childViewControllers count])
    {
        
        for (int i=0; i<4; i++)
        {
             [[self.childViewControllers objectAtIndex:0] removeFromParentViewController];
              NSLog(@"No %d    %@",i,self.childViewControllers);

        }
       
       

    }
    
    NSLog(@"%@",self.childViewControllers);
    
    ProjectsVC *projectsVC  = [[ProjectsVC alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navigationProjects = [[UINavigationController alloc] initWithRootViewController:projectsVC];
    navigationProjects.view.frame=rect;
    [self addChildViewController:navigationProjects];
    

    
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        CalendarVC  *calendarVC  = [[CalendarVC alloc] initWithNibName:nil bundle:nil];
    	UINavigationController *navigationCalendar = [[UINavigationController alloc] initWithRootViewController:calendarVC];
        navigationCalendar.view.frame=rect;
        
        LogVC *logVC = [[LogVC alloc] init];
        UINavigationController *navigationLog = [[UINavigationController alloc] initWithRootViewController:logVC];
        navigationLog.view.frame=rect;
        
        [self addChildViewController:navigationCalendar];
        [self addChildViewController:navigationLog];
    }
    else
    {
        RatingTVC  *ratingTVC  = [[RatingTVC alloc] initWithNibName:nil bundle:nil];
    	UINavigationController *navigationRating = [[UINavigationController alloc] initWithRootViewController:ratingTVC];
        navigationRating.view.frame=rect;
        
        InvoiceTVC *invoiceTVC = [[InvoiceTVC alloc] initWithNibName:nil bundle:nil];
        UINavigationController *navigationInvoice = [[UINavigationController alloc] initWithRootViewController:invoiceTVC];
        navigationInvoice.view.frame=rect;
        
        [self addChildViewController:navigationRating];
        [self addChildViewController:navigationInvoice];
    }
    
        HomeCVC *homeCVC = [[HomeCVC alloc] init];
        UINavigationController *navigationHome = [[UINavigationController alloc] initWithRootViewController:homeCVC];
        navigationHome.view.frame=rect;
 
       [self addChildViewController:navigationHome];
    
    
    if([self.contentView.subviews count] == 1)
    {
        [[_contentView.subviews objectAtIndex:0] removeFromSuperview];
    }
    [self.contentView addSubview:navigationHome.view];
    
    
    
}


-(void)postRequestAd
{
    
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    
    if (APP_DELEGATE.isServerReachable) {
  
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://fieldo.se/api/advertise.php"]];
    [urlRequest setTimeoutInterval:180];
    NSString *requestBody = [NSString stringWithFormat:@"JsonObject=%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
         NSLog(@"%@",object);
         
         self.arrayAdvertiseImages = [[NSMutableArray alloc] init];
         self.arrayAdvertiseLink = [[NSMutableArray alloc] init];
         for (NSDictionary *dict in object)
         {
             NSData * imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:dict[@"ad_image_ios"]]];
             UIImage * image = [[UIImage alloc] initWithData:imageData];
             
             [self.arrayAdvertiseImages addObject:image];
             [self.arrayAdvertiseLink addObject:dict[@"ad_link"]];
         }
//         [self performSelector:@selector(initializeTimer) withObject:nil];
             [self performSelectorOnMainThread:@selector(Spin) withObject:nil waitUntilDone:NO];
         
     }];
    }
    else
    {
//        [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }

}

-(void)initializeTimer
{
	if (theTimer==nil)
	{
		float theInterval=3.0;
		theTimer=[NSTimer scheduledTimerWithTimeInterval:theInterval target:self selector:@selector(Spin:) userInfo:nil repeats:YES];
	}
}


-(void)Spin
{
    
    if (flagIndex < [self.arrayAdvertiseImages count]) {
        [self.buttonAdvertise setBackgroundImage:[self imageWithImage:self.arrayAdvertiseImages[flagIndex] scaledToSize:CGSizeMake(210, 78)]    forState:UIControlStateNormal];
        flagIndex++;
    }else{
        flagIndex = 0;
    }
    theTimer=[NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(Spin) userInfo:nil repeats:NO];

}


// Change the Image size
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadView
{
    CGRect rect= CGRectMake(0, 100, 320, 480);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenSize.height > 480.0f)
            rect=CGRectMake(0, 100, 320, 568);
    }
    UIView *view=[[UIView alloc] initWithFrame:rect];
    view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    self.view=view;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
