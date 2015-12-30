//
//  LeaveListTVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 4/8/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "LeaveListTVC.h"
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
#import "OutOfTheOfficeVC.h"
#import "LeaveBO.h"
@interface LeaveListTVC ()

@end

@implementation LeaveListTVC

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  50.0;
}



//#pragma mark NsOperation Queue group
//
//- (PendingOperations *)pendingOperations
//{
//    if (!_pendingOperations)
//    {
//        _pendingOperations = [[PendingOperations alloc] init];
//    }
//    return _pendingOperations;
//}
//
//
//
//- (void)startOperationsForPhotoRecord:(LeaveBO *)record atIndexPath:(NSIndexPath *)indexPath {
//    
//    // 2: You inspect it to see whether it has an image; if so, then ignore it.
//    if (!record.hasImage) {
//        
//        // 3: If it does not have an image, start downloading the image by calling startImageDownloadingForRecord:atIndexPath: (which will be implemented shortly). Youíll do the same for filtering operations: if the image has not yet been filtered, call startImageFiltrationForRecord:atIndexPath: (which will also be implemented shortly).
//        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
//        
//    }
//    
//    
//}
//
//
//- (void)startImageDownloadingForRecord:(ProjectRecord *)record atIndexPath:(NSIndexPath *)indexPath
//{
//    
//    // 1: First, check for the particular indexPath to see if there is already an operation in downloadsInProgress for it. If so, ignore it.
//    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath]) {
//        
//        // 2: If not, create an instance of FlyerDownloader by using the designated initializer, and set ListViewController as the delegate. Pass in the appropriate indexPath and a pointer to the instance of PhotoRecord, and then add it to the download queue. You also add it to downloadsInProgress to help keep track of things.
//        // Start downloading
//        ProjectDownloader *projectDownloader = [[ProjectDownloader alloc] initWithProjectRecord:record atIndexPath:indexPath delegate:self];
//        [self.pendingOperations.downloadsInProgress setObject:projectDownloader forKey:indexPath];
//        [self.pendingOperations.downloadQueue addOperation:projectDownloader];
//    }
//}
//
//
//- (void)projectDownloaderDidFinish:(ProjectDownloader *)downloader
//{
//    NSIndexPath *indexPath = downloader.indexPathInTableView;
//    ProjectRecord *theRecord = downloader.projectRecord;
//    
//    [self.arrayProjects replaceObjectAtIndex:indexPath.row withObject:theRecord];
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
//}
//

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
    self.navigationItem.title=[Language get:@"All Leaves" alter:@"!All Leaves"];
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
    
    
    
    LeaveBO *aRecord = [self.arrayProjects objectAtIndex:indexPath.row];
    
//    if (aRecord.hasImage)
//    {
//        cell.textLabel.text = [aRecord.projectName stringByConvertingHTMLToPlainText];
//        cell.imageView.image=[Helper maskImage:aRecord.projectImage withMask:[UIImage imageNamed:@"maskRect.png"]];
//    }
//    else if (aRecord.isFailed)
//    {
//        
//        cell.textLabel.text = [aRecord.projectName stringByConvertingHTMLToPlainText];
//        cell.imageView.image=[Helper maskImage:[UIImage imageNamed:@"your-photo.png"] withMask:[UIImage imageNamed:@"maskRect.png"]];
//        cell.imageView.image=[Helper maskImage:[UIImage imageNamed:@"NoArtwork.png"] withMask:[UIImage imageNamed:@"maskRect.png"]];
//        
//    }
//    else
//    {
        //  imageCell.image = [UIImage imageNamed:@"Placeholder.png"];
        cell.textLabel.text =  [aRecord.reason stringByConvertingHTMLToPlainText];
//        cell.imageView.image=aRecord.projectImage;
//        cell.imageView.image=[Helper maskImage:[UIImage imageNamed:@"NoArtwork.png"] withMask:[UIImage imageNamed:@"maskRect.png"]];
    
//    }
    
    NSString *stringFrom = [NSString stringWithFormat:@"%@", aRecord.from];
    
    NSString *stringTo = [NSString stringWithFormat:@"%@", aRecord.to];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *dateFrom = [dateFormatter dateFromString:stringFrom];
    
    NSDate *dateTo = [dateFormatter dateFromString:stringTo];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"dd-MM-yyyy"];
    NSString *newDateStringFrom = [dateFormatter2 stringFromDate:dateFrom];
    
    NSString *newDateStringTo = [dateFormatter2 stringFromDate:dateTo];
    
    
    cell.detailTextLabel.text=[NSString stringWithFormat:@"From %@ To %@", newDateStringFrom, newDateStringTo];
    
    cell.detailTextLabel.textColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
    
    
//    if ([aRecord.projectUnreadMsg isEqualToString:@"0"] )
//    {
//        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 16)];
//        imageView.image=[UIImage imageNamed:@"imageUnreadMsg@2x.png"];
//        cell.accessoryView=imageView;
//    }
//    else
//    {
//        cell.accessoryView=nil;
//        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
//    }
    
    return cell;
    
}





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LeaveBO *aRecord = [self.arrayProjects objectAtIndex:indexPath.row];
    
    OutOfTheOfficeVC *outOfc = [[OutOfTheOfficeVC alloc] init];
    
    outOfc.leaveBO = aRecord;
 
    [self.navigationController pushViewController:outOfc animated:YES];
}


-(void) DeleteTheLeave :(NSString *)leaveId
{
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
        [postDict setObject:leaveId forKey:@"leave_id"];
    }
    //    else
    //    {
    //        [postDict setObject:[PersistentStore getCustomerID] forKey:@"cust_id"];
    //    }
    
    
    
    if (APP_DELEGATE.isServerReachable) {
   
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PROJECTS_LIST]];
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        //urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PROJECTS_LIST]];
        urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://fieldo.se/api/deleteleave.php"]];//]@"http://fieldo.se/api/workerprojectlist.php"]];
        
    }
    //    else
    //    {
    //        urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PROJECTS_LIST_CUSTOMER]];
    //
    //    }
    //
    
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
//                 NSMutableArray *objEvents=object[@"data"];
//                 NSMutableArray *records = [@[] mutableCopy];
//                 for(NSMutableDictionary *objEvent in objEvents)
//                 {
//                     @autoreleasepool
//                     {
////                         LeaveBO *project=[[LeaveBO alloc] init];
////                         project.desc=objEvent[@"desc"];
////                         project.from=objEvent[@"from"];
////                         project.leave_id=objEvent[@"leave_id"];
////                         project.reason=objEvent[@"reason"];
////                         project.to=objEvent[@"to"];
////                         project.worker_id=objEvent[@"worker_id"];
////                         project.worker_name=objEvent[@"worker_name"];
////                         [records addObject:project];
////                         project=nil;
//                         
//                     }
//                     
//                     
//                     
//                 }
//                 self.arrayProjects=records;
//                 [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:NO];
                 
                 
                 //                 for (int i=0;i<[self.arrayProjects count];i++)
                 //                 {
                 //                     LeaveBO *projectRecord=[self.arrayProjects objectAtIndex:i];
                 //                     [self startOperationsForPhotoRecord:projectRecord atIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                 //                 }
                 
                 
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


-(void)postRequestWorkersProjects
{
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
    }
    //    else
    //    {
    //        [postDict setObject:[PersistentStore getCustomerID] forKey:@"cust_id"];
    //    }
    
    
    
    if (APP_DELEGATE.isServerReachable) {
      
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PROJECTS_LIST]];
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        //urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PROJECTS_LIST]];
        urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://fieldo.se/api/leavelist.php"]];//]@"http://fieldo.se/api/workerprojectlist.php"]];
        
    }
    //    else
    //    {
    //        urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PROJECTS_LIST_CUSTOMER]];
    //
    //    }
    //
    
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
                         LeaveBO *project=[[LeaveBO alloc] init];
                         project.desc=objEvent[@"desc"];
                         project.from=objEvent[@"from"];
                         project.leave_id=objEvent[@"leave_id"];
                         project.reason=objEvent[@"reason"];
                         project.to=objEvent[@"to"];
                         project.worker_id=objEvent[@"worker_id"];
                         project.worker_name=objEvent[@"worker_name"];
                         [records addObject:project];
                         project=nil;
                         
                     }
                     
                     
                     
                 }
                 self.arrayProjects=records;
                 [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:NO];
                 
                 
//                 for (int i=0;i<[self.arrayProjects count];i++)
//                 {
//                     LeaveBO *projectRecord=[self.arrayProjects objectAtIndex:i];
//                     [self startOperationsForPhotoRecord:projectRecord atIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//                 }
                 
                 
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

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        
        LeaveBO *leaveBo=[self.arrayProjects objectAtIndex:indexPath.row];
        [self DeleteTheLeave:leaveBo.leave_id];
        [self.arrayProjects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [tableView reloadData];
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
