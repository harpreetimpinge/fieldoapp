//
//  InvoiceTVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 3/21/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//


#import "InvoiceTVC.h"
#import "ProjectOptionsVC.h"
#import "MBProgressHUD.h"
#import "Language.h"
#import "PersistentStore.h"
#import "NSString+HTML.h"
#import "Helper.h"
#import "ProjectOptionsVC.h"
#import "CustomerDetailsVC.h"
#import "ProjectDetailsTVC.h"
#import "WorkPlanVC.h"
#import "FloorPlanVC.h"
#import "AppDelegate.h"
#import "Language.h"
#import "PersistentStore.h"
#import "NSString+HTML.h"
#import "WorkersTVC.h"
#import "FloorPlanCVC.h"
#import "WorkersTVC.h"
#import "InvoiceProjectReportTVC.h"

@interface InvoiceTVC ()

@end

@implementation InvoiceTVC


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  50.0;
}



#pragma mark NsOperation Queue group

- (PendingOperations *)pendingOperations
{
    if (!_pendingOperations)
    {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}



- (void)startOperationsForPhotoRecord:(ProjectRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    
    // 2: You inspect it to see whether it has an image; if so, then ignore it.
    if (!record.hasImage) {
        
        // 3: If it does not have an image, start downloading the image by calling startImageDownloadingForRecord:atIndexPath: (which will be implemented shortly). Youíll do the same for filtering operations: if the image has not yet been filtered, call startImageFiltrationForRecord:atIndexPath: (which will also be implemented shortly).
        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
        
    }
    
    
}


- (void)startImageDownloadingForRecord:(ProjectRecord *)record atIndexPath:(NSIndexPath *)indexPath
{
    
    // 1: First, check for the particular indexPath to see if there is already an operation in downloadsInProgress for it. If so, ignore it.
    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath]) {
        
        // 2: If not, create an instance of FlyerDownloader by using the designated initializer, and set ListViewController as the delegate. Pass in the appropriate indexPath and a pointer to the instance of PhotoRecord, and then add it to the download queue. You also add it to downloadsInProgress to help keep track of things.
        // Start downloading
        ProjectDownloader *projectDownloader = [[ProjectDownloader alloc] initWithProjectRecord:record atIndexPath:indexPath delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:projectDownloader forKey:indexPath];
        [self.pendingOperations.downloadQueue addOperation:projectDownloader];
    }
}


- (void)projectDownloaderDidFinish:(ProjectDownloader *)downloader
{
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    ProjectRecord *theRecord = downloader.projectRecord;
    
    [self.arrayProjects replaceObjectAtIndex:indexPath.row withObject:theRecord];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
}


#pragma mark showHideView
-(void)showLoadingView
{
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = YES;
    hud.labelText = @"Loading...";
    hud.dimBackground = YES;
}

-(void)refreshTable
{
    [self.tableView reloadData];
    [self hideLoadingView];
    
}


-(void)hideLoadingView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent=NO;
    
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [self showLoadingView];
    self.title=[Language get:@"Invoices" alter:@"!Invoices"];

    [self postRequestWorkersProjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.arrayProjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    ProjectRecord *aRecord = [self.arrayProjects objectAtIndex:indexPath.row];
    
    if (aRecord.hasImage)
    {
        cell.textLabel.text = [aRecord.projectName stringByConvertingHTMLToPlainText];
        cell.imageView.image=[Helper maskImage:aRecord.projectImage withMask:[UIImage imageNamed:@"maskRect.png"]];
    }
    else if (aRecord.isFailed)
    {
        
        cell.textLabel.text = [aRecord.projectName stringByConvertingHTMLToPlainText];
        cell.imageView.image=[Helper maskImage:[UIImage imageNamed:@"your-photo.png"] withMask:[UIImage imageNamed:@"maskRect.png"]];
        cell.imageView.image=[Helper maskImage:[UIImage imageNamed:@"NoArtwork.png"] withMask:[UIImage imageNamed:@"maskRect.png"]];
        
    }
    else
    {
        //  imageCell.image = [UIImage imageNamed:@"Placeholder.png"];
        cell.textLabel.text =  [aRecord.projectName stringByConvertingHTMLToPlainText];
        cell.imageView.image=aRecord.projectImage;
        cell.imageView.image=[Helper maskImage:[UIImage imageNamed:@"NoArtwork.png"] withMask:[UIImage imageNamed:@"maskRect.png"]];
        
    }
    
    cell.detailTextLabel.text=aRecord.projectDescription;
    
    cell.detailTextLabel.textColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
    
    
    if ([aRecord.projectUnreadMsg isEqualToString:@"0"] )
    {
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 16)];
        imageView.image=[UIImage imageNamed:@"imageUnreadMsg@2x.png"];
        cell.accessoryView=imageView;
    }
    else
    {
        cell.accessoryView=nil;
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
    
}





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     ProjectRecord *aRecord = [self.arrayProjects objectAtIndex:indexPath.row];
    InvoiceProjectReportTVC *invoiceProjectReportTVC=[[InvoiceProjectReportTVC alloc] initWithStyle:UITableViewStyleGrouped];
     invoiceProjectReportTVC.stringProjectId=aRecord.projectId;
    invoiceProjectReportTVC.stringProjectType=aRecord.projectType;
    invoiceProjectReportTVC.managerId=aRecord.managerId;
    invoiceProjectReportTVC.managerEmail=aRecord.managerEmail;
    invoiceProjectReportTVC.custAccept=aRecord.custAccept;
    [self.navigationController pushViewController:invoiceProjectReportTVC animated:YES];
    
//    ProjectRecord *aRecord = [self.arrayProjects objectAtIndex:indexPath.row];
//    WorkersTVC *workersTVC=[[WorkersTVC alloc] init];
//    workersTVC.title=[Language get:@"Worker List" alter:@"!Worker List"];
//    workersTVC.stringProjectId=aRecord.projectId;
//    workersTVC.navigateFrom=@"Invoices";
//    [self.navigationController pushViewController:workersTVC animated:YES];
}




-(void)postRequestWorkersProjects
{
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
     [postDict setObject:[PersistentStore getCustomerID] forKey:@"cust_id"];
    
   
    
    
    
    if (APP_DELEGATE.isServerReachable) {

    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PROJECTS_LIST_CUSTOMER]];
    
    
        
    
    
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
                 [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:NO];
             }
             else
             {
                 NSMutableArray *objEvents=object[@"data"];
                 NSMutableArray *records = [@[] mutableCopy];
                 for(NSMutableDictionary *objEvent in objEvents)
                 {
                     @autoreleasepool
                     {
                         ProjectRecord *project=[[ProjectRecord alloc] init];
                         project.projectId=objEvent[@"project_id"];
                         project.projectName=objEvent[@"title"];
                         project.managerId=objEvent[@"manager_id"];
                         project.projectType=objEvent[@"project_type"];
                         project.projectDescription=objEvent[@"description"];
                         project.projectUnreadMsg=objEvent[@"unreadmsg"];
                         project.managerEmail=objEvent[@"email"];
                         project.custAccept=objEvent[@"invoice_status"];
                         project.projectImageURL=[NSURL URLWithString:objEvent[@"file_name"]];
                         [records addObject:project];
                         project=nil;
                         
                     }
                     
                     
                     
                 }
                 self.arrayProjects=records;
                 [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:NO];
                 
                 
                 for (int i=0;i<[self.arrayProjects count];i++)
                 {
                     ProjectRecord *projectRecord=[self.arrayProjects objectAtIndex:i];
                     [self startOperationsForPhotoRecord:projectRecord atIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
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


-(void)viewWillDisappear:(BOOL)animated
{
    [self cancelAllOperations];
}



#pragma mark - Cancelling, suspending, resuming queues / operations
- (void)suspendAllOperations
{
    [self.pendingOperations.downloadQueue setSuspended:YES];
    
}

- (void)resumeAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:NO];
    
}

- (void)cancelAllOperations {
    [self.pendingOperations.downloadQueue cancelAllOperations];
    
}





@end
