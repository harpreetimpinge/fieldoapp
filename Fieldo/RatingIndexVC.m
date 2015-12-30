//
//  RatingIndexVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 2/28/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "RatingIndexVC.h"
#import "MBProgressHUD.h"
#import "PersistentStore.h"
#import "Language.h"

#define URL_ENG @"http://fieldo.se/ratingindex.php?lang=en"
#define URL_NOR @"http://fieldo.se/ratingindex.php?lang=nb"
#define URL_SWE @"http://fieldo.se/ratingindex.php?lang=sw"

@interface RatingIndexVC ()

@end

@implementation RatingIndexVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     self.title=[Language get:@"Rating Index" alter:@"!Rating Index"];

    NSURL *url=[NSURL URLWithString:URL_ENG];

    
    if ([[PersistentStore getLocalLanguage] isEqualToString:@"nn"])
    {
        url=[NSURL URLWithString:URL_NOR];
    }
    else if ([[PersistentStore getLocalLanguage] isEqualToString:@"sv"])
    {
        url=[NSURL URLWithString:URL_SWE];
    }
    else
    {
        url=[NSURL URLWithString:URL_ENG];
    }
    
    NSURLRequest *requestAddress = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestAddress];
    
}


-(void)showLoadingView
{
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = YES;
    hud.labelText = @"Loading...";
    hud.dimBackground = YES;
}


-(void)hideLoadingView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showLoadingView];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideLoadingView];
}


-(void)loadView
{
    self.webView = [[UIWebView  alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.webView.autoresizesSubviews = YES;
    self.webView.autoresizingMask  =(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.webView setDelegate:self];
    
    self.view=self.webView ;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
