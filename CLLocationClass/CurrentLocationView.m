//
//  CurrentLocationView.m
//  Fieldo
//
//  Created by Anit Kumar on 13/02/15.
//  Copyright (c) 2015 Gagan Joshi. All rights reserved.
//

#import "CurrentLocationView.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "Language.h"

@implementation CurrentLocationView
@synthesize latitude,longitude;



#pragma mark - Show MBProgressHUD
-(void)showLoadingView:(UIView *)view
{
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = YES;
    hud.labelText = @"Loading...";
    hud.dimBackground = YES;
}
#pragma mark - Hidden MBProgressHUD
-(void)hideLoadingView:(UIView *)view
{
    [MBProgressHUD hideHUDForView:view animated:YES];
}

#pragma mark - Current Location API
-(void)userCurrentLocation:(UIView *)view{
    
    if (APP_DELEGATE.isServerReachable) {
        
        NSError *error;
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
        
        //Sent Paramerter
        [postDict setObject:[Worker_ID valueForKey:@"worker_id"] forKey:@"worker_id"];
        [postDict setObject:longitude forKey:@"long"];
        [postDict setObject:latitude forKey:@"lat"];
        
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        
        //Set Login URL For User Current Location.
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://fieldo.se/api/setLat_long.php"]];
        
        // Request Body.
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
                [self hideLoadingView:view];
                if ([object[@"CODE"] intValue]==1)
                 {
                     // [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:NO];
                 }
                 else
                 {
                     // NSMutableArray *objEvents=object[@"data"];
                     
                 }
             }
             
             
         }];
    }
    else
    {
        [self hideLoadingView:view];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    
}

@end
