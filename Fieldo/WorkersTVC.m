//
//  WorkersTVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 2/13/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "WorkersTVC.h"
#import "WorkerDetailTVC.h"
#import "ProjectReportTVC.h"
#import "MBProgressHUD.h"

#import "Language.h"

@interface WorkersTVC ()
@end



@implementation WorkersTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self postRequestWorkersList];
    self.tableView.rowHeight=50.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(void)showLoadingView
{
    //self.tableView.hidden=YES;
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = YES;
    hud.labelText = @"Loading...";
    hud.dimBackground = YES;
}
-(void)hideLoadingView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    //    [self.tableView reloadData];
    //self.tableView.hidden=NO;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayWorkers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
        // 1: To provide feedback to the user, create a UIActivityIndicatorView and set it as the cellís accessory view.
    }
    cell.backgroundColor=[UIColor clearColor];
    cell.textLabel.text=self.arrayWorkers[indexPath.row][@"worker_name"];
    cell.imageView.image=[UIImage imageNamed:@"imageProfile.png"];
    return cell;
}

-(void)postRequestWorkersList
{
    [self showLoadingView];
    
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:self.stringProjectId forKey:@"project_id"];
    if (APP_DELEGATE.isServerReachable) {
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_Customer_Project_Workers]];
    
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
                 [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:NO];
             }
             else
             {
                 self.arrayWorkers=object[@"data"];
                 [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:NO];

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






- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self.navigateFrom isEqualToString:@"Invoices"])
    {
        ProjectReportTVC *projectReportTVC=[[ProjectReportTVC alloc] initWithNibName:nil bundle:nil];
        projectReportTVC.stringProjectId=self.stringProjectId;
        projectReportTVC.stringWorkerId=self.arrayWorkers[indexPath.row][@"worker_id"];
        [self.navigationController pushViewController:projectReportTVC animated:YES];
    }
    else
    {
    WorkerDetailTVC *DetailVC=[[WorkerDetailTVC alloc] init];
    DetailVC.stringWorkerId=self.arrayWorkers[indexPath.row][@"worker_id"];
    [self.navigationController pushViewController:DetailVC animated:YES];
    }
}



-(void)refreshTable
{
    [self.tableView reloadData];
    [self hideLoadingView];
}






@end
