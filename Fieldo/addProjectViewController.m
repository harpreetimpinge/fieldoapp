//
//  addProjectViewController.m
//  Fieldo
//
//  Created by Vishal on 14/11/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "addProjectViewController.h"
#import "PersistentStore.h"
#import "customerViewController.h"
#import "workerViewController.h"
#import "addCustomerViewController.h"
#import "Loader.h"
#import "AppDelegate.h"
#import "Language.h"
#import "MBProgressHUD.h"

#define REGEX_COST @"[0-9.]"


@interface addProjectViewController ()
{
Loader *objLoader;
}
@end

@implementation addProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationItem setTitle:[Language get:@"Add Project" alter:@"!Add Project"]];
    
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        [self.scrollView setContentSize:CGSizeMake(320, 850)];
    }else{
        [self.scrollView setContentSize:CGSizeMake(320, 750)];
    }
    
    self.pickerBackView.layer.cornerRadius=10.0f;
    //[self.datePicker setValue:[UIColor whiteColor] forKeyPath:@"textColor"];
    self.datePicker.minimumDate=[NSDate date];
    self.datePicker.date=[NSDate date];
    
    NSDate *currentDate = [NSDate date];
    NSLog(@"Current Date = %@", currentDate);
    
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = 6;
    
    NSDate *currentDatePlus6Month = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    NSLog(@"Date = %@", currentDatePlus6Month);
    
   // self.datePicker.maximumDate=currentDatePlus6Month;
    
    
    self.projectNameField.borderStyle=UITextBorderStyleRoundedRect;
    self.costField.borderStyle=UITextBorderStyleRoundedRect;
    self.descriptionField.borderStyle=UITextBorderStyleRoundedRect;
    self.taxField.borderStyle=UITextBorderStyleRoundedRect;
    self.commentTextField.borderStyle = UITextBorderStyleRoundedRect;

    self.projectNameField.delegate=self;
    self.taxField.delegate=self;
    self.descriptionField.delegate=self;
    self.costField.delegate=self;
    
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];

    ////Localization
    
    [self.doneBtn setTitle:[Language get:@"Done" alter:@"!Done"] forState:UIControlStateNormal];
    self.descriptionLabel.text=[Language get:@"Description" alter:@"!Description"];
    self.descriptionField.placeholder=[Language get:@"Description" alter:@"!Description"];
    self.vatLabel.text=[Language get:@"Incl. Vat" alter:@"!Incl. Vat"];
    self.costLabel.text=[Language get:@"Cost" alter:@"!Cost"];
    self.costField.placeholder=[Language get:@"Cost" alter:@"!Cost"];
    
    

    
    self.startDateLabel.text=[Language get:@"Start Date" alter:@"!Start Date"];
    [self.dateButton setTitle:[Language get:@"Start Date" alter:@"!Start date"] forState:UIControlStateNormal];

    self.taxReductionLabel.text=[Language get:@"Tax Reduction Code" alter:@"!Tax Reduction Code"];
    self.taxField.placeholder=[Language get:@"Tax Reduction Code" alter:@"!Tax Reduction Code"];
    
    self.commentLable.text = [Language get:@"Comment" alter:@"!Comment"];
    self.commentTextField.placeholder = [Language get:@"Comment" alter:@"!Comment"];

    
    self.workersNameLabel.text=[Language get:@"Worker(s)" alter:@"!Worker(s)"];
    [self.workersButton setTitle:[Language get:@"Select Workers" alter:@"!Select Workers"] forState:UIControlStateNormal];
    self.customerNameLabel.text=[Language get:@"Customer" alter:@"!Customer"];
    [self.customerButton setTitle:[Language get:@"Choose Customer" alter:@"!Choose Customer"] forState:UIControlStateNormal];
    self.projectNameLabel.text=[Language get:@"Project Name" alter:@"!Project Name"];
    self.projectNameField.placeholder=[Language get:@"Project Name" alter:@"!Project Name"];
    [self.saveBtn setTitle:[Language get:@"Save" alter:@"!Save"] forState:UIControlStateNormal];
    [self.cancelBtn setTitle:[Language get:@"Cancel" alter:@"!Cancel"] forState:UIControlStateNormal];
    
    
    NSDate *date=[NSDate date];
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString=[formatter stringFromDate:date];
    
    projectStartDate=dateString;
    
    [self.dateButton setTitle:projectStartDate forState:UIControlStateNormal];

}

-(void)viewWillAppear:(BOOL)animated{
    
    [self.view endEditing:YES];
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"customerNAME"]!=nil)
    {
        [self.customerButton setTitle:[[NSUserDefaults standardUserDefaults]objectForKey:@"customerNAME"] forState:UIControlStateNormal];
    }
    
    AppDelegate *delegate=(AppDelegate*)[UIApplication sharedApplication].delegate;

    if(delegate.m_workersArrayGlobal.count>0)
    {
       // self.workersTextview.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"selectedWorkers"];
        NSString *workerString=@"";
        
        for(int i=0;i<delegate.m_workersArrayGlobal.count;i++)
        {
            
            workerString=[workerString stringByAppendingString:[NSString stringWithFormat:@"%@",[[delegate.m_workersArrayGlobal objectAtIndex:i] objectForKey:@"worker_name"]]];
            if(i<delegate.m_workersArrayGlobal.count-1)
            {
                workerString=[workerString stringByAppendingString:@", "];
            }
            
        }
        
        self.workersTextview.text=workerString;
        [self.workersButton setTitle:[Language get:@"Select Workers" alter:@"!Select Workers"] forState:UIControlStateNormal];
        
    }
    
    else
    {
        self.workersTextview.text=@"";
        [self.workersButton setTitle:[Language get:@"Select Workers" alter:@"!Select Workers"] forState:UIControlStateNormal];
    }
    
    self.customerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    self.customerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    self.workersButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    self.workersButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    self.dateButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    self.dateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
}

-(void)viewWillDisappear:(BOOL)animated
{

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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


- (IBAction)chooseCustomerAction:(id)sender {
 
    customerViewController *customer=[[customerViewController alloc]initWithNibName:@"customerViewController" bundle:nil];
    [self.navigationController pushViewController:customer animated:YES];
}

- (IBAction)addWorkersAction:(id)sender {
    
    workerViewController *customer=[[workerViewController alloc]initWithNibName:@"workerViewController" bundle:nil];
    [self.navigationController pushViewController:customer animated:YES];
}

- (IBAction)startDateAction:(id)sender {
       [self.view endEditing:YES];
    [self.pickerBackView setHidden:NO];
}

- (IBAction)vatAction:(id)sender {
    
    if(includeVat==NO)
    {
    if(self.taxField.text.length>0)
    {
        includeVat=YES;
        [self.vatButton setBackgroundImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    }
    else
    {
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Please enter Tax Reduction Code first." alter:@"!Please enter Tax Reduction Code first."]  delegate:self
                        cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        
    }
    }
    else
    {
        includeVat=NO;
        [self.vatButton setBackgroundImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];

    }
}

- (IBAction)captureAction:(id)sender {
    
  [[[UIActionSheet alloc] initWithTitle:@"Take Photos" delegate:self cancelButtonTitle:[Language get:@"Cancel" alter:@"!Cancel"] destructiveButtonTitle:[Language get:@"Camera" alter:@"!Camera"] otherButtonTitles:[Language get:@"Photos" alter:@"!Photos"], nil] showInView:self.view];
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{


    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    switch (buttonIndex)
    {
        case 0:
            if (TARGET_IPHONE_SIMULATOR){
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[Language get:@"Simulator doesn't support the camera." alter:@"!Simulator doesn't support the camera."]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
            else{
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:NULL];
            }
            break;
            
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:NULL];
            break;
            
        case 2:
            NSLog(@"Cancel option selected by User");
            break;
            
        default:
            break;
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
   // [self.captureButton setBackgroundImage:chosenImage forState:UIControlStateNormal];
    self.imageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (IBAction)saveAction:(id)sender {
    
    [self saveProject];
}

- (IBAction)cancelAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addCustomerAction:(id)sender {
    
    addCustomerViewController *add=[[addCustomerViewController alloc]initWithNibName:@"addCustomerViewController" bundle:nil];
    [self.navigationController pushViewController:add animated:YES];
    
}
- (IBAction)changeDateAction:(id)sender {
    
    // [self.pickerBackView setHidden:YES];
}

-(void)saveProject
{
    
    [self showLoadingView];
    NSString *errorString=@"";
    
    
    if(self.projectNameField.text.length==0)
    {
    errorString=@"Project name";
    }
    else if ([self.customerButton.titleLabel.text isEqualToString:@"Choose Customer"])
    {
        errorString=@"Customer";
    }
    
    if([errorString isEqualToString:@""])
    {
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];

    [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
    [postDict setObject:self.projectNameField.text forKey:@"title"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"customerID"] forKey:@"client"];
    [postDict setObject:self.workersTextview.text forKey:@"workers"];
    [postDict setObject:projectStartDate forKey:@"start_date"];
    [postDict setObject:self.taxField.text forKey:@"tax_code"];
    [postDict setObject:[NSNumber numberWithBool:includeVat] forKey:@"Incl_VAT"];
    [postDict setObject:self.costField.text forKey:@"cost"];
    [postDict setObject:self.descriptionField.text forKey:@"description"];
    [postDict setObject:self.commentTextField.text forKey:@"comment"];
        
    [postDict setObject:[[Customer_Details valueForKey:@"Customer_Details"] valueForKey:@"address"] forKey:@"address"];
    [postDict setObject:[[Customer_Details valueForKey:@"Customer_Details"] valueForKey:@"city"] forKey:@"city"];
    [postDict setObject:[[Customer_Details valueForKey:@"Customer_Details"] valueForKey:@"state"] forKey:@"state"];
    [postDict setObject:[[Customer_Details valueForKey:@"Customer_Details"] valueForKey:@"country"] forKey:@"country"];
    [postDict setObject:[[Customer_Details valueForKey:@"Customer_Details"] valueForKey:@"zip"] forKey:@"zip"];
    [postDict setObject:[[Customer_Details valueForKey:@"Customer_Details"] valueForKey:@"contact"] forKey:@"contact"];
        
    
    NSData *data=UIImageJPEGRepresentation(self.imageView.image, 0.9f);
    if(data)
    {
    NSString *imageString=[self base64forData:data];
    [postDict setObject:imageString forKey:@"file"];
    }

    if (APP_DELEGATE.isServerReachable) {
        
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_CREATE_PROJCT]];
        
        [urlRequest setTimeoutInterval:180];
        NSString *requestBody = [NSString stringWithFormat:@"JsonObject=%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
        [urlRequest setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
        [urlRequest setHTTPMethod:@"POST"];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if(data==nil)
             {
                 
             }
             else
             {
             id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
             NSLog(@"%@",object);
             if (error)
             {
                        [self hideLoadingView];
                       [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Server is down, Please try again." alter:@"!Server is down, Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
                        NSLog(@"Error: %@",[error description]);
             }
             if ([object isKindOfClass:[NSDictionary class]] == YES)
             {
                 if ([object[@"CODE"] intValue]==1)
                 {
                     [self hideLoadingView];
                             [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:object[@"MSG"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
                 }
                 else
                 {
                     dispatch_async(dispatch_get_main_queue(), ^(void){
                                            [self hideLoadingView];
                                            [self.navigationController popViewControllerAnimated:YES];
                                    });
                 }
                 
             }
             }
         }];
    }
    else
    {
        [self hideLoadingView];
        // [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    
    }
    else
    {
        [self hideLoadingView];

             [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Please fill all the mandatory fields to create a project." alter: @"!Please fill all the mandatory fields to create a project."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _taxField) {
        [self.scrollView setContentOffset:CGPointMake(0, 190) animated:YES];
    }else if (textField==self.costField){
        [self.scrollView setContentOffset:CGPointMake(0, 290) animated:YES];
    }
    else if (textField==self.descriptionField)
    {
        [self.scrollView setContentOffset:CGPointMake(0, 340) animated:YES];
    }
    else if (textField==self.commentTextField)
    {
        [self.scrollView setContentOffset:CGPointMake(0, 340) animated:YES];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([textField isEqual:self.costField])
    {
        if ([string length] == 0 && range.length > 0)
        {
            self.costField.text = [self.costField.text stringByReplacingCharactersInRange:range withString:string];
            return NO;
        }
        
        NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
        if ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0)return YES;
        
        return NO;
    }

    
    return YES;
}

- (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (IBAction)doneAction:(id)sender {
    
    NSDate *date=self.datePicker.date;
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString=[formatter stringFromDate:date];
    
    projectStartDate=dateString;
    
    [self.dateButton setTitle:projectStartDate forState:UIControlStateNormal];
    
    [self.pickerBackView setHidden:YES];
}
@end
