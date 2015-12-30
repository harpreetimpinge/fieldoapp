//
//  ConnectionManager.m
//  NearByPlaces
//
//  Created by Amit Kumar Singh on 3/19/14.
//  Copyright (c) 2014 Parveen Sharma. All rights reserved.
//

#import "ConnectionManager.h"
#import "Language.h"

#define MainURL @"https://maps.googleapis.com/maps"

@implementation ConnectionManager
@synthesize  currentTask;
@synthesize delegate;
@synthesize responseDictionary;
@synthesize responseError;

-(BOOL) getDataForFunction : (NSString *) functionName withCurrentTask : (CURRENT_TASK) inputTask andDelegate : (id)inputDelegate
{
    self.delegate = inputDelegate;
    self.currentTask = inputTask;
    NSString *StringURL=[NSString stringWithFormat:@"%@%@",MainURL,functionName];
    StringURL = [StringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:StringURL];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];
    
    NSLog(@"Request URL: %@",requestURL);
    
    NSURLRequest *theRequest =
    [NSURLRequest requestWithURL:[NSURL URLWithString:StringURL]
                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                 timeoutInterval:100.0];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        
    } else {
        
        
		UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Failed in viewDidLoad." alter:@"!Failed in viewDidLoad."] delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[connectFailMessage show];
        
    }
    return YES;
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Did Receive Response %@", response);
    responseData = [[NSMutableData alloc]init];
}
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    NSLog(@"Did Receive Data %@", data);
    [responseData appendData:data];
}
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    NSLog(@"Did Fail");
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFailWithError:)])
    {
        [self.delegate performSelector:@selector(didFailWithError:) withObject:self];
    }
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Did Finish");
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    self.responseDictionary=(NSMutableDictionary*)res;
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(responseReceived:)])
    {
        [self.delegate performSelector:@selector(responseReceived:) withObject:self];
    }
    // Do something with responseData
}
@end
