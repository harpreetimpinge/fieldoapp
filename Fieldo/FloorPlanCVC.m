//
//  FloorPlanCVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 2/18/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "FloorPlanCVC.h"
#import "CollectionImageCell.h"
#import "Language.h"

@interface FloorPlanCVC () <UIAlertViewDelegate>
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center withIndexPath:(NSIndexPath *)indexPath;

@end

@implementation FloorPlanCVC


@synthesize arrayImageRecords = _arrayImageRecords;
@synthesize pendingOperations = _pendingOperations;


- (PendingOperations *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}




-(NSMutableArray *)arrayImageRecords
{
    if (!_arrayImageRecords)
    {
        NSError *error;
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
        [postDict setObject:self.stringProjectId forKey:@"project_id"];
        if (APP_DELEGATE.isServerReachable) {
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://fieldo.se/api/getallfloorimages.php"]];
        
        
        [urlRequest setTimeoutInterval:180];
        NSString *requestBody = [NSString stringWithFormat:@"JsonObject=%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
        [urlRequest setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
        [urlRequest setHTTPMethod:@"POST"];
        
     //   NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
            NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
            
             
             id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
             NSLog(@"%@",object);
            
            NSString *str = [object objectForKey:@"MSG"];
            
            NSLog(@"str = %@", str);
             if (error)
             {
                 NSLog(@"Error: %@",[error description]);
             }
             if ([object isKindOfClass:[NSDictionary class]] == YES)
             {
                 
                     NSMutableArray *objEvents=object[@"data"][@"img"];
                     NSMutableArray *records = [@[] mutableCopy];
                     for(NSMutableDictionary *objEvent in objEvents)
                     {
                         @autoreleasepool
                         {
                             ImageRecord *record = [[ImageRecord alloc] init];
                             record.imageURL=[NSURL URLWithString:objEvent[@"file_name"]];
                             [records addObject:record];
                             record = nil;

                             
                         }
                     }
                 
                     
                     self.arrayImageRecords=records;
                     
                     
                     for (int i=0;i<[self.arrayImageRecords count];i++)
                     {
                         ImageRecord *imageRecord=[self.arrayImageRecords objectAtIndex:i];
                         [self startOperationsForPhotoRecord:imageRecord atIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                     }
                 
                 if ([str isEqualToString:@"Fail"])
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"No data in this category." alter:@"!No data in this category."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];

                     alert.tag = 1;
                     
                     [alert show];
                 }
                 else
                 {
                     [self performSelectorOnMainThread:@selector(refreashCollectionView) withObject:nil waitUntilDone:NO];
                 }
                 
             }
//         }];
    }
    else
    {
//        [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    
    
    }
    return _arrayImageRecords;
    
}


#pragma mark - UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)refreashCollectionView
{
    [self.collectionView reloadData];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.title=[NSString stringWithFormat:@"%d of %lu",1,(unsigned long)[self.arrayImageRecords count]];

}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)receivedRotate:(NSNotification *)notification
{
    //Obtaining the current device orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(UIDeviceOrientationIsPortrait(orientation))
    {
        return;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView=[[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flow];
    [self.collectionView registerClass:[CollectionImageCell class] forCellWithReuseIdentifier:@"CONTENT"];
    self.collectionView.pagingEnabled=YES;
    self.collectionView.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    
    
    [flow setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    
    flow.minimumLineSpacing = 10;
    
    self.collectionView.pagingEnabled=YES;
    
    // flow.minimumInteritemSpacing=5.0;
    
   
    
    flow.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    flow.itemSize = self.collectionView.frame.size;
    
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.delegate=self;
    
    [doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTap];
    
	// Do any additional setup after loading the view.
}



-(NSUInteger)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
    
}




- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    
    return UIInterfaceOrientationPortrait;
    
}


- (void)loadView
{
    UIView* view = [[UIView alloc] init];
    self.view = view;
}

#pragma mark CollectionViewDelegate starts
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [self.arrayImageRecords count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionImageCell *cell =(CollectionImageCell *) [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CONTENT" forIndexPath:indexPath];
    
    ImageRecord *imageRecord=[self.arrayImageRecords objectAtIndex:indexPath.row];
    
    
    // 3: Inspect the PhotoRecord. If its image is downloaded, display the image, the image name, and stop the activity indicator.
    if (imageRecord.hasImage)
    {
        cell.scrollView.autoresizesSubviews = YES;
        cell.scrollView.multipleTouchEnabled =YES;
        cell.scrollView.maximumZoomScale = 4.0;
        cell.scrollView.minimumZoomScale = 1.0;
        cell.scrollView.clipsToBounds = YES;
        cell.scrollView.delegate = self;
        cell.imageView.image=imageRecord.image;
      //  cell.image =imageRecord.image;
        [((UIActivityIndicatorView *)cell.activityIndicatorView) stopAnimating];
        
    }
    // 4: If downloading the image has failed, display a placeholder to display the failure, and stop the activity indicator.
    else if (imageRecord.isFailed)
    {
        cell.scrollView.autoresizesSubviews = YES;
        cell.scrollView.multipleTouchEnabled =YES;
        cell.scrollView.maximumZoomScale = 4.0;
        cell.scrollView.minimumZoomScale = 1.0;
        cell.scrollView.clipsToBounds = YES;
        cell.scrollView.delegate = self;
        
        cell.imageView.image = [UIImage imageNamed:@"Failed.png"];
        [((UIActivityIndicatorView *)cell.activityIndicatorView) stopAnimating];
        
        
    }
    // 5: Otherwise, the image has not been downloaded yet. Start the download and filtering operations (theyíre not yet implemented), and display a placeholder that indicates you are working on it. Start the activity indicator to show user something is going on.
    else {
        
        cell.scrollView.autoresizesSubviews = YES;
        cell.scrollView.multipleTouchEnabled =YES;
        cell.scrollView.maximumZoomScale = 4.0;
        cell.scrollView.minimumZoomScale = 1.0;
        cell.scrollView.clipsToBounds = YES;
        cell.scrollView.delegate = self;
        
        cell.imageView.image= [UIImage imageNamed:@"Placeholder.png"];
        [((UIActivityIndicatorView *)cell.activityIndicatorView) startAnimating];
        
    }
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *layout = (id) self.collectionView.collectionViewLayout;
    layout.itemSize = self.collectionView.frame.size;
    
    CGSize size2 = CGSizeMake(self.collectionView.frame.size.width-10.0, self.collectionView.frame.size.height-10.0);
    
    
    return size2;
    
}






- (void)didReceiveMemoryWarning {
    [self cancelAllOperations];
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark - UITableView data source and delegate methods



#pragma mark -
#pragma mark - Operations

// 1: To keep it simple, you pass in an instance of PhotoRecord that requires operations, along with its indexPath.
- (void)startOperationsForPhotoRecord:(ImageRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    
    // 2: You inspect it to see whether it has an image; if so, then ignore it.
    if (!record.hasImage) {
        
        // 3: If it does not have an image, start downloading the image by calling startImageDownloadingForRecord:atIndexPath: (which will be implemented shortly). Youíll do the same for filtering operations: if the image has not yet been filtered, call startImageFiltrationForRecord:atIndexPath: (which will also be implemented shortly).
        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
        
    }
    
}


- (void)startImageDownloadingForRecord:(ImageRecord *)record atIndexPath:(NSIndexPath *)indexPath
{
    
    // 1: First, check for the particular indexPath to see if there is already an operation in downloadsInProgress for it. If so, ignore it.
    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath]) {
        
        // 2: If not, create an instance of ImageDownloader by using the designated initializer, and set ListViewController as the delegate. Pass in the appropriate indexPath and a pointer to the instance of PhotoRecord, and then add it to the download queue. You also add it to downloadsInProgress to help keep track of things.
        // Start downloading
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageRecord:record atIndexPath:indexPath delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:indexPath];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
    }
}




#pragma mark -
#pragma mark - ImageDownloader delegate


- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader
{
    
    // 1: Check for the indexPath of the operation, whether it is a download, or filtration.
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    
    // 2: Get hold of the PhotoRecord instance.
    ImageRecord  *theRecord = downloader.imageRecord;
    
    // 3: Replace the updated PhotoRecord in the main data source (Photos array).
    [self.arrayImageRecords replaceObjectAtIndex:indexPath.row withObject:theRecord];
    
    // 4: Update UI.
    //[self.collectionView reloadData];
    
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    // 5: Remove the operation from downloadsInProgress (or filtrationsInProgress).
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
}


#pragma mark -
#pragma mark - ImageFiltration delegate

-(void)viewWillDisappear:(BOOL)animated
{
    [self cancelAllOperations];
}



#pragma mark -
#pragma mark - UIScrollView delegate


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSIndexPath *indexpath=[[self.collectionView indexPathsForVisibleItems] objectAtIndex:0];
    self.indexPath=indexpath;
    self.title=[NSString stringWithFormat:@"%d of %lu",(int)indexpath.row + 1,(unsigned long)[self.arrayImageRecords count]];
}



#pragma mark -
#pragma mark - Cancelling, suspending, resuming queues / operations


- (void)suspendAllOperations
{
    [self.pendingOperations.downloadQueue setSuspended:YES];
    
}


- (void)resumeAllOperations
{
    [self.pendingOperations.downloadQueue setSuspended:NO];
    
}


- (void)cancelAllOperations
{
    [self.pendingOperations.downloadQueue cancelAllOperations];
    
}


#pragma mark ScrollView Zoom function

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    //  NSLog(@"View for zooming in scrollview");
    
    NSIndexPath *indexpath=[[self.collectionView indexPathsForVisibleItems] objectAtIndex:0];
    
   // NSIndexPath *indexpath=[NSIndexPath indexPathForRow:0 inSection:0];

  //  NSIndexPath *indexpath=[[self.collectionView indexPathsForVisibleItems] objectAtIndex:[[self.collectionView indexPathsForVisibleItems] count]-1];
    NSLog(@"indexpath %ld",(long)indexpath.row);
    
    CollectionImageCell *cell =(CollectionImageCell *) [self.collectionView cellForItemAtIndexPath:indexpath];
    
    UIScrollView *scroll=(UIScrollView *)cell.scrollView;
    for (UIView *v in scroll.subviews)
    {
        if ([v isKindOfClass:[UIImageView class]]) {
            return v;
        }
    }
    return nil;
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    NSIndexPath *indexpath=[[self.collectionView indexPathsForVisibleItems] objectAtIndex:0];

  //  NSIndexPath *indexpath=[[self.collectionView indexPathsForVisibleItems] objectAtIndex:[[self.collectionView indexPathsForVisibleItems] count]-1];
    CollectionImageCell *cell =(CollectionImageCell *)[self.collectionView cellForItemAtIndexPath:indexpath];
    
    
    //  NSLog(@"%i",cell.scrollView.subviews.count);
    UIScrollView *scroll=(UIScrollView *)cell.scrollView;
    
    
    if(scroll.zoomScale > scroll.minimumZoomScale)
    {
        self.collectionView.scrollEnabled=NO;
    }
    else
    {
        self.collectionView.scrollEnabled=YES;
    }
}

#pragma mark TapDetectingImageViewDelegate methods


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    //[self centerScrollViewContents];
}

- (void)centerScrollViewContents
{
    NSIndexPath *indexpath=[[self.collectionView indexPathsForVisibleItems] objectAtIndex:0];

  //  NSIndexPath *indexpath=[[self.collectionView indexPathsForVisibleItems] objectAtIndex:[[self.collectionView indexPathsForVisibleItems] count]-1];
    
    
    CollectionImageCell *cell =(CollectionImageCell *)[self.collectionView cellForItemAtIndexPath:indexpath];
    
    NSLog(@"%lu",(unsigned long)cell.scrollView.subviews.count);
    UIScrollView *scrollView=(UIScrollView *)cell.scrollView;
    UIImageView *imageView=(UIImageView *)cell.imageView;
    for (UIView *v in scrollView.subviews)
    {
        if ([v isKindOfClass:[UIImageView class]]) {
            //    imageView=(UIImageView *)v;
        }
    }
    
    CGSize boundsSize = scrollView.bounds.size;
    CGRect contentsFrame = imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    imageView.frame=  contentsFrame;
}


- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    CollectionImageCell *cell = (CollectionImageCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if ((UIScrollView *)cell.scrollView)
    {
        UIScrollView* scrollViewImage =(UIScrollView *)cell.scrollView;
        NSLog(@"Current Zoom %f,Minimum Zoom %f ,Maximum Zoom %f",scrollViewImage.zoomScale, scrollViewImage.minimumZoomScale,scrollViewImage.maximumZoomScale);
        
        if(scrollViewImage.zoomScale > scrollViewImage.minimumZoomScale)
        {
            CGPoint point=[gestureRecognizer locationInView:gestureRecognizer.view];
            NSLog(@"Point %f, %f",point.x,point.y);
            // [scrollViewImage setZoomScale:1.0];
            
            CGRect zoomRect = [self zoomRectForScale:1.0 withCenter:[gestureRecognizer locationInView:gestureRecognizer.view] withIndexPath:indexPath];
            [cell.scrollView zoomToRect:zoomRect animated:YES];
            
            self.collectionView.scrollEnabled=YES;
            
            //cell2.frameRect=zoomRect;
            
        }
        else
        {
            CGRect zoomRect = [self zoomRectForScale:4.0 withCenter:[gestureRecognizer locationInView:gestureRecognizer.view] withIndexPath:indexPath];
            [cell.scrollView zoomToRect:zoomRect animated:YES];
            
            self.collectionView.scrollEnabled=NO;
            
            //cell2.frameRect=zoomRect;
        }
    }
}



#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center withIndexPath:(NSIndexPath *)indexPath
{
    
    CollectionImageCell *cell = (CollectionImageCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    UIScrollView* scrollViewImage =(UIScrollView *)cell.scrollView;
    //  NSLog(@"scrollViewImage Origin x=%f,Origin y=%f,Width=%f, Height=%f",scrollViewImage.frame.origin.x,scrollViewImage.frame.origin.y,scrollViewImage.frame.size.width,scrollViewImage.frame.size.height);
    NSLog(@"scrollview content size %f, %f",scrollViewImage.contentSize.width,scrollViewImage.contentSize.height);
    
    CGRect zoomRect;
    
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [scrollViewImage frame].size.height / scale;
    zoomRect.size.width  = [scrollViewImage frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
    
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    
}





@end
