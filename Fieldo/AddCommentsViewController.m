//
//  AddCommentsViewController.m
//  Fieldo
//
//  Created by Gagan Joshi on 3/20/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "AddCommentsViewController.h"
#import "Language.h"
#import "PersistentStore.h"
#import "MBProgressHUD.h"
#import "Helper.h"
#import "NSString+HTML.h"
#import "LogVC.h"
#import "AppDelegate.h"
#import "ProjectsVC.h"

@interface AddCommentsViewController ()

@end

@implementation AddCommentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
    
    }
    return self;
}

////

#pragma mark - DesignInterface
#pragma mark -

-(void) DesignInterface
{
    
      self.view.backgroundColor=[UIColor whiteColor];
      self.title =[Language get:@"Progress Report" alter:@"!Progress Report"];
    
      self.btnImage=[UIButton buttonWithType:UIButtonTypeRoundedRect];
      self.btnImage.frame=CGRectMake(10, 60, 60, 60);
      [self.btnImage setBackgroundColor:[UIColor whiteColor]];
      self.btnImage.layer.cornerRadius=6.0;
      self.btnImage.titleLabel.font=[UIFont systemFontOfSize:10];
      [self.btnImage setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
      [self.btnImage setTitle:[Language get:@"Get Image" alter:@"!Get Image"]   forState:UIControlStateNormal];
      [self.btnImage addTarget:self action:@selector(getPhotoActionSheet) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:self.btnImage];
    
      self.imageComment=[[UIImageView alloc]initWithFrame:CGRectMake(10, 60, 60, 60)];
      self.imageComment.contentMode=UIViewContentModeScaleAspectFit;
      self.imageComment.layer.borderColor=[[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f]  CGColor] ;
      self.imageComment.layer.borderWidth=1.0;
      self.imageComment.layer.cornerRadius=2.0;
      [self.view addSubview:self.imageComment];
    
    
      self.lblSlider=[[UILabel alloc] initWithFrame:CGRectMake(270, 30, 44, 20)];
      self.lblSlider.text=[NSString stringWithFormat:@"%d %%",[self.stringPercentage intValue]];
      self.lblSlider.backgroundColor=[UIColor clearColor];
      self.lblSlider.font = [UIFont systemFontOfSize:14];
      [self.view addSubview:self.lblSlider];

    
    
      self.textField = [[UITextField alloc] initWithFrame:CGRectMake(75, 60, 220, 30)];
      self.textField.borderStyle = UITextBorderStyleRoundedRect;
      self.textField.font = [UIFont systemFontOfSize:15];
      self.textField.placeholder =[Language get:@"Comments" alter:@"Comments"] ;
      self.textField.delegate=self;
      self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
      self.textField.keyboardType = UIKeyboardTypeDefault;
      self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
      self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
      [self.view addSubview:self.textField];
    
    
      UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
      button.frame=CGRectMake(190, 102, 100, 32);
      button.layer.cornerRadius = 3;
      button.layer.borderColor = [[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] CGColor];
      button.layer.borderWidth = .8f;
      [button setTitle:[Language get:@"Submit" alter:@"!Submit"]  forState:UIControlStateNormal];
      [button addTarget:self action:@selector(Send) forControlEvents:UIControlEventTouchUpInside];
      button.titleLabel.font=[UIFont systemFontOfSize:16];
      [self.view addSubview:button];
  
    
      self.sliderTaskProgress = [[UISlider alloc] init];
      CGRect frame=self.sliderTaskProgress.frame;
      frame.origin.x=20;
      frame.origin.y=24;
      frame.size.width=240.0;
      [self.sliderTaskProgress addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
      self.sliderTaskProgress.minimumValue=0.0;
      self.sliderTaskProgress.maximumValue=100.0;
      self.sliderTaskProgress.frame=frame;
      self.sliderTaskProgress.value = [self.stringPercentage intValue];
      [self.view addSubview:self.sliderTaskProgress];

}


//-(void)loadView
//{
//    [super loadView];
//    
//    CGRect rect= CGRectMake(0, 100, 320, 380);
//    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//        if (screenSize.height > 480.0f)
//            rect=CGRectMake(0, 100, 320, 468);
//    }
//    UIView *view=[[UIView alloc] initWithFrame:rect];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 280, 30)];
//    label.textAlignment=NSTextAlignmentCenter;
//    label.text=@"Coming Soon";
//    label.font = [UIFont fontWithName:@"Arial" size:16];
//    [view addSubview:label];
//    
//    
//    view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
//    self.view=view;
//}



- (void)sliderChanged:(UISlider *)sender
{
    
    if (lroundf(sender.value)<[self.stringPercentage intValue])
    {
        self.sliderTaskProgress.value=[self.stringPercentage intValue];
    }
    else
    {
        int progress = lroundf(sender.value);
        self.lblSlider.text = [NSString stringWithFormat:@"%d %%", progress];
    }
}

-(void)Send
{
    
    [self.view endEditing:YES];
    
//    if (self.textField.text.length==0) {
//        [[[UIAlertView alloc]initWithTitle:@"Please Enter the Comment." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        return;
//    }
    
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
    
    NSDateFormatter *dateFormeterDate=[[NSDateFormatter alloc] init];
    [dateFormeterDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *curDate=[dateFormeterDate stringFromDate:[NSDate date]];
    
    [postDict setObject:curDate forKey:@"date"];
    
  
    if (APP_DELEGATE.isServerReachable)
    {
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
//                 if ([object[@"total_per_project"]floatValue]==100) {
////                    [self performSelectorOnMainThread:@selector(goToLog) withObject:nil waitUntilDone:YES];
//                 }
//                 else
//                 {
                    [self performSelectorOnMainThread:@selector(goBack) withObject:nil waitUntilDone:YES];
                 }
//             }
             [self hideLoadingView];
         }
     }];
    }
    else
    {
        [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not availabel. Please try again." alter:@"!Internet connection is not availabel. Please try again."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
}

-(void)goToLog
{
    [[[UIAlertView alloc] initWithTitle:[Language get:@"Any Log Left ?" alter:@"!Any Log Left ?"]  message:[Language get:@"Click Yes to fill the logs." alter:@"!Click Yes to fill the logs."]  delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil] show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        LogVC *logobj=[[LogVC alloc]init];
        [self.navigationController pushViewController:logobj animated:YES];
    }
    else
    {
        for (UIViewController *controller in [self.navigationController viewControllers])
        {
            if ([controller isKindOfClass:[ProjectsVC class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
                break;
            }
        }
    }
    [self hideLoadingView];

}
-(void)goBack
{
    NSString *strNotificationName=@"CommentReload";
    [[NSNotificationCenter defaultCenter] postNotificationName:strNotificationName object:nil userInfo:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

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
////

#pragma mark - TextField Delegates
#pragma mark -

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


////

#pragma mark - UIImagePickerController
#pragma mark -

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
        if(buttonIndex==0) {
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                imagePicker =[[UIImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                // Insert the overlay:
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;
                
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Device doesn't support that camera." alter:@"!Device doesn't support that camera."] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alert show];
            }
            
            
        }
        else
        {
            [self methodGetImageFromLibrary];
        }
    }
}

-(void)methodGetImageFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
       imagePicker =[[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        // Insert the overlay:
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Device doesn’t support that media source." alter:@"!Device doesn’t support that media source."] delegate:nil cancelButtonTitle:@"Drat!" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)methodGetImageFromLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        imagePicker =[[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Device doesn’t support that media source." alter:@"!Device doesn’t support that media source."] delegate:nil cancelButtonTitle:@"Drat!" otherButtonTitles:nil];
        [alert show];
    }
}

//UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // UIImage *ActualImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *EditedImage=[info objectForKey:UIImagePickerControllerEditedImage];
//    NSLog(@"Actual Image Image Width: %f,Height %f)",ActualImage.size.width,ActualImage.size.width);
//    //   NSLog(@"Edited Image Image Width: %f,Height %f)",EditedImage.size.width,EditedImage.size.width);
    UIImage *newImage=[Helper aspectScaleImage:EditedImage toSize:CGSizeMake(500, 500)];
    self.imageComment.image=newImage;
    
    
    NSLog(@"%@",self);
    
    [self.btnImage setTitle:nil forState:UIControlStateNormal];
//    [imagePicker.view removeFromSuperview];
//    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
     NSLog(@"%@",self);
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
//        [imagePicker.view removeFromSuperview];
}

////

#pragma mark - UIVIEWS
#pragma mark -


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self DesignInterface];
}

////


#pragma mark- Memory Managements
#pragma mark-

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
