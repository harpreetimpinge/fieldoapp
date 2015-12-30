//
//  RatingTVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 2/20/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "RatingTVC.h"
#import "PersistentStore.h"
#import "RatingDetailTVC.h"
#import "AXRatingView.h"
#import "CustomTextViewCell.h"
#import "Language.h"
#import "MBProgressHUD.h"
#import "NSString+HTML.h"

@interface RatingTVC ()

@end

@implementation RatingTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=[Language get:@"Rating" alter:@"!Rating"];
    self.tableView.rowHeight=50.0;
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self postRequestWorkersList];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayRatingProjects count];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor=[UIColor clearColor];
    cell.textLabel.text=[self.arrayRatingProjects[indexPath.row][@"title"] stringByConvertingHTMLToPlainText];
    cell.detailTextLabel.text=[self.arrayRatingProjects[indexPath.row][@"com_name"] stringByConvertingHTMLToPlainText];
    cell.detailTextLabel.textColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];

    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;

    
    if ([self.arrayRatingProjects[indexPath.row][@"rating"] intValue])
    {
        AXRatingView *notEditableRatingView = [[AXRatingView alloc] initWithFrame:CGRectMake(0, 0, [self.arrayRatingProjects[indexPath.row][@"rating"] intValue]*16, 16)];
        //[notEditableRatingView sizeToFit];
        [notEditableRatingView setUserInteractionEnabled:NO];
        [notEditableRatingView setMarkFont:[UIFont systemFontOfSize:16.0]];
        [notEditableRatingView setNumberOfStar:[self.arrayRatingProjects[indexPath.row][@"rating"] intValue]];
        [notEditableRatingView setValue:[self.arrayRatingProjects[indexPath.row][@"rating"] floatValue]];
        cell.accessoryView=notEditableRatingView;
    }
    else
    {
        cell.accessoryView=nil;
 
    }
    
    
   

    
    return cell;
}



-(void)postRequestWorkersList
{
    [self showLoadingView];
    
    NSError *error;
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    [postDict setObject:[PersistentStore getCustomerID] forKey:@"cust_id"];
    if (APP_DELEGATE.isServerReachable) {
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://fieldo.se/api/project_to_be_rated.php"]];
    
    [urlRequest setTimeoutInterval:180];
    NSString *requestBody = [NSString stringWithFormat:@"JsonObject=%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPMethod:@"POST"];
    NSLog(@"req %@",requestBody);
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
                 [self performSelectorOnMainThread:@selector(showAlertRating) withObject:nil waitUntilDone:YES];
             }
             else
             {
                 self.arrayRatingProjects=object[@"data"];
             
                 [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
             }
         }
     }];
    }
    else
    {
        [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    
}


- (void) showAlertRating
{
    [self hideLoadingView];
    
    [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"No data found." alter:@"!No data found."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}

#pragma mark - UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshTable
{
    [self.tableView reloadData];
    [self hideLoadingView];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RatingDetailTVC *ratingDetailTVC=[[RatingDetailTVC alloc] initWithNibName:nil bundle:nil];
    ratingDetailTVC.dictRatingProject=self.arrayRatingProjects[indexPath.row];
    [self.navigationController pushViewController:ratingDetailTVC animated:YES];
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





@end
