//
//  TaskDetailsTVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/28/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "TaskDetailsTVC.h"
#import "Language.h"
#import "PersistentStore.h"
#import "Helper.h"
#import "MBProgressHUD.h"
#import "NSString+HTML.h"
#import <QuartzCore/QuartzCore.h>
#import "FloorPlanVC.h"

#import "AddCommentsViewController.h"

#import "AppDelegate.h"

@interface TaskDetailsTVC ()

@end

@implementation TaskDetailsTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    self.lblSlider.text=[NSString stringWithFormat:@"%i %%",[refreshedSliderValue intValue]];
    self.progressView.progress = [refreshedSliderValue floatValue]/100.0;
}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)hideLoadingView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.tableView reloadData];
    //self.tableView.hidden=NO;
}




- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *string=[self.dictTaskDetail[@"task_name"] stringByConvertingHTMLToPlainText];
    NSString *strNotificationName=@"CommentReload";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CommentsReload) name:strNotificationName object:nil];

    
    self.title=[NSString stringWithFormat:@"%@, %@",self.strHead,string];
    
    
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(addComments:)];
    }

    
    
   
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    
    UILabel  *labelKey = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 280, 25)];
    labelKey.textAlignment=NSTextAlignmentCenter;
    labelKey.text=[self.dictTaskDetail[@"description"] stringByConvertingHTMLToPlainText];
    labelKey.textColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
    labelKey.font=[UIFont systemFontOfSize:12];
    [view addSubview:labelKey] ;

  
    
    
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    // progressView.frame=CGRectMake(20, 28, 280, 2);
    CGRect frame=self.progressView.frame;
    frame.origin.x=20;
    frame.origin.y=40;
    frame.size.width=240.0;
    self.progressView.frame=frame;
    // progressView.center = cell.center;
    self.progressView.progress = [self.dictTaskDetail[@"per_of_complete"] floatValue]/100.0;
    [view addSubview:self.progressView];

    
    self.lblSlider=[[UILabel alloc] initWithFrame:CGRectMake(270, 30, 44, 20)];
    self.lblSlider.text=[NSString stringWithFormat:@"%@ %%",self.dictTaskDetail[@"per_of_complete"]];
    self.lblSlider.backgroundColor=[UIColor clearColor];
    self.lblSlider.font = [UIFont systemFontOfSize:14];
    [view addSubview:self.lblSlider];
    
    
   
    
    
    self.tableView.tableHeaderView = view;
    
    self.tableView.rowHeight=70.0;
    
    [self postRequestTaskCommentList];
}

-(void)addComments:(id)sender
{
    AddCommentsViewController *addCommentsVC=[[AddCommentsViewController alloc] initWithNibName:nil bundle:nil];
    addCommentsVC.dictTaskDetail=self.dictTaskDetail;
    addCommentsVC.stringProjectId=self.stringProjectId;
    addCommentsVC.stringHeadId=self.stringHeadId;
    addCommentsVC.stringPercentage=refreshedSliderValue;
    [self.navigationController pushViewController:addCommentsVC animated:YES];
}

- (void)sliderChanged:(UISlider *)sender
{
    
    if (lroundf(sender.value)<[self.dictTaskDetail[@"per_of_complete"] intValue])
    {
        self.sliderTaskProgress.value=[self.dictTaskDetail[@"per_of_complete"] intValue];
    }
    else
    {
    int progress = lroundf(sender.value);
    self.lblSlider.text = [NSString stringWithFormat:@"%d %%", progress];
    }
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



-(void)Send
{
  [self showLoadingView];

 NSData *imageData=UIImagePNGRepresentation(self.imageComment.image);
    NSString *base64EncodedString= [imageData base64EncodedStringWithOptions:0];
    
    if ([base64EncodedString length]<1)
    {
        base64EncodedString=@"";
    }
    
    
        NSError *error;
        
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
        [postDict setObject:self.stringProjectId forKey:@"project_id"];
        [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
        [postDict setObject:self.stringHeadId forKey:@"head_id"];
        [postDict setObject:self.dictTaskDetail[@"task_id"] forKey:@"task_id"];
        [postDict setObject:self.textField.text forKey:@"comment"];
        [postDict setObject:[NSString stringWithFormat:@"%f",self.sliderTaskProgress.value] forKey:@"percentageofcomplete"];
        [postDict setObject:base64EncodedString  forKey:@"img"];
               
        if (APP_DELEGATE.isServerReachable) {
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_WORKER_LOG]];
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
                     // [self performSelectorOnMainThread:@selector(alertLoginFailed) withObject:nil waitUntilDone:YES];
                 }
                 else
                 {
                        [self performSelectorOnMainThread:@selector(goBack) withObject:nil waitUntilDone:YES];
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

-(void)CommentsReload
{
    [self postRequestTaskCommentList];
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    
}



-(void)hitNext
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self postRequestTaskCommentList];
}


-(void)postRequestTaskCommentList
{
    [self showLoadingView];
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:self.stringProjectId forKey:@"project_id"];
    
    NSLog(@"%@",[PersistentStore getWorkerID]);
    
    [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
    
    [postDict setObject:self.stringHeadId forKey:@"head_id"];
    [postDict setObject:self.dictTaskDetail[@"task_id"] forKey:@"task_id"];
    if (APP_DELEGATE.isServerReachable) {
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_WORKER_MSG_IPhone]];
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
                 // [self performSelectorOnMainThread:@selector(alertLoginFailed) withObject:nil waitUntilDone:YES];
             }
             else
             {
                 
                 self.nameManeger=object[@"manager_name"];
                 refreshedSliderValue=([object[@"percentageofcomplete"] isKindOfClass:[NSString class]])?object[@"percentageofcomplete"]:@"";
                 NSMutableArray *objEvents=object[@"messsage"];
                 NSMutableArray *records = [@[] mutableCopy];
                 for(NSMutableDictionary *objEvent in objEvents)
                 {
                     @autoreleasepool
                     {
                         TaskCommentRecord *comment=[[TaskCommentRecord alloc] init];
                         comment.commentDate=objEvent[@"created_at"];
                         comment.commentId=objEvent[@"id"];
                         comment.commentImageURL=[NSURL URLWithString:objEvent[@"img"]];
                         comment.commentMessage=objEvent[@"msg_comment"];
                         comment.commentProjectId=objEvent[@"project_id"];
                         comment.commentWorkerId=objEvent[@"worker_id"];
                         comment.commentFrom=objEvent[@"worker_name"];
                         [records addObject:comment];
                         comment=nil;
                         
                     }
                 }
                 self.arrayComment=records;
                 [self hideLoadingView];
                 [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:NO];
                 
                 
                 for (int i=0;i<[self.arrayComment count];i++)
                 {
                     TaskCommentRecord *commentRecord=[self.arrayComment objectAtIndex:i];
                     [self startOperationsForPhotoRecord:commentRecord atIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                 }
                 
                 
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayComment count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"std"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    TaskCommentRecord *aRecord = [self.arrayComment objectAtIndex:indexPath.row];
    
    if (aRecord.hasImage)
    {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(0, 5, 60, 60);
        button.tag=100+indexPath.row;
        [button addTarget:self action:@selector(goDetailViewImage:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[Helper aspectScaleImage:aRecord.commentImage toSize:CGSizeMake(60, 60)] forState:UIControlStateNormal];
        cell.accessoryView=button;

    }
    else
    {
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    cell.textLabel.font=[UIFont systemFontOfSize:12];
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat: @"dd-MM-yyyy HH:mm:ss a"];
//    
//    NSDate *myDate = [dateFormatter dateFromString:aRecord.commentDate];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:aRecord.commentDate];

    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"dd-MM-yyyy, hh:mm a"];
    NSString *newDateString = [dateFormatter2 stringFromDate:date];

    
    /*
    NSString *str = [NSString stringWithFormat:@"%@", aRecord.commentDate];
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *currentDate = [dateFormater dateFromString:str];
    NSLog(@"currentDate: %@", currentDate);
    
    [dateFormater setDateFormat:@"dd-MM-yyyy HH:mm:ss a"];
    NSString *convertedDateString = [dateFormater stringFromDate:currentDate];
    NSLog(@"convertedDateString: %@", convertedDateString);
    
    [dateFormater setDateFormat:@"DD.MM.yyy HH:mm:DD"];
    NSString *germanDateString = [dateFormater stringFromDate:currentDate];
    NSLog(@"germanDateString: %@", germanDateString);
    */
    cell.textLabel.text = [[NSString stringWithFormat:@"%@", newDateString] stringByConvertingHTMLToPlainText];

    if ([aRecord.commentFrom length])
    {
        NSString *str1=[aRecord.commentMessage stringByConvertingHTMLToPlainText];
        NSString *str2=[aRecord.commentFrom stringByConvertingHTMLToPlainText];
        NSString *string=[NSString stringWithFormat:@"%@\n%@",str1,str2];
        cell.detailTextLabel.text=string;
    }
    else
    {
        NSString *str1=[aRecord.commentMessage stringByConvertingHTMLToPlainText];
        NSString *str2=[self.nameManeger stringByConvertingHTMLToPlainText];
        NSString *string=[NSString stringWithFormat:@"%@\n%@",str1,str2];
        cell.detailTextLabel.text=string;

    }
    
    cell.detailTextLabel.font=[UIFont systemFontOfSize:14];
    cell.detailTextLabel.numberOfLines=3;

    
    
    
    return cell;
    
}


-(void)goDetailViewImage:(id)sender
{
    TaskCommentRecord *record=[self.arrayComment objectAtIndex:[sender tag]-100];
    
    FloorPlanVC *floorPlanVC=[[FloorPlanVC alloc] initWithNibName:nil bundle:nil];
    floorPlanVC.imageUrl=record.commentImageURL;
    floorPlanVC.imageFloorPlan=record.commentImage;
    floorPlanVC.title=[Language get:@"View Image" alter:@"!View Image"];
    [self.navigationController pushViewController:floorPlanVC animated:YES];
   
    
  
}


#pragma mark UIImagePickerController Group Starts

-(void)getPhotoActionSheet   //Action sheet
{
    UIActionSheet *actionsheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"New Photo",@"Upload from Library", nil];
    [actionsheet showInView:self.view];
}

//ActionSheet Delegate Method
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [actionSheet cancelButtonIndex])
    {
        if(buttonIndex==0)
            [self methodGetImageFromCamera];
        else
            [self methodGetImageFromLibrary];
    }
    
}

-(void)methodGetImageFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        picker =[[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        // Insert the overlay:
        picker.delegate = self;
         picker.allowsEditing = YES;
        [self presentViewController:picker animated:YES completion:nil];
//        AppDelegate *appdelegateIns=(AppDelegate*)[[UIApplication sharedApplication] delegate];
//        [appdelegateIns.window addSubview:picker.view];

    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Device doesn't support that media source." alter:@"!Device doesn't support that media source."] delegate:nil cancelButtonTitle:@"Drat!" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)methodGetImageFromLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
           picker =[[UIImagePickerController alloc] init];
           picker.delegate = self;
           picker.allowsEditing = YES;
           picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
           AppDelegate *appdelegateIns=(AppDelegate*)[[UIApplication sharedApplication] delegate];
           [appdelegateIns.window addSubview:picker.view];

        
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Device doesn't support that media source." alter:@"!Device doesn't support that media source."] delegate:nil cancelButtonTitle:@"Drat!" otherButtonTitles:nil];
        [alert show];
    }
}

//UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker1
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *ActualImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *EditedImage=[info objectForKey:UIImagePickerControllerEditedImage];
    NSLog(@"Actual Image Image Width: %f,Height %f)",ActualImage.size.width,ActualImage.size.width);
 //   NSLog(@"Edited Image Image Width: %f,Height %f)",EditedImage.size.width,EditedImage.size.width);
    UIImage *newImage=[Helper aspectScaleImage:EditedImage toSize:CGSizeMake(120, 120)];
    self.imageComment.image=newImage;
    
    
    [self.btnImage setTitle:nil forState:UIControlStateNormal];
//    [picker.view removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker1
{
//    [picker.view removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIImagePickerController Group Ends


#pragma mark NsOperation Queue group

- (PendingOperations *)pendingOperations
{
    if (!_pendingOperations)
    {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}



- (void)startOperationsForPhotoRecord:(TaskCommentRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    
    if (!record.hasImage)
    {
        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
    }
    
    
}


- (void)startImageDownloadingForRecord:(TaskCommentRecord *)record atIndexPath:(NSIndexPath *)indexPath
{
    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath])
    {
        TaskCommentDownloader *commentDownloader = [[TaskCommentDownloader alloc] initWithCommentRecord:record atIndexPath:indexPath delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:commentDownloader forKey:indexPath];
        [self.pendingOperations.downloadQueue addOperation:commentDownloader];
    }
}


- (void)commentDownloaderDidFinish:(TaskCommentDownloader *)downloader
{
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    TaskCommentRecord *theRecord = downloader.commentRecord;
    [self.arrayComment replaceObjectAtIndex:indexPath.row withObject:theRecord];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
}



- (void)suspendAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:YES];
    
}

- (void)resumeAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:NO];
    
}

- (void)cancelAllOperations {
    [self.pendingOperations.downloadQueue cancelAllOperations];
    
}



-(void)dealloc
{
    [self cancelAllOperations];
}






@end
