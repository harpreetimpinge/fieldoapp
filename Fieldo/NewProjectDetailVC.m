//
//  NewProjectDetailVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 4/7/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "NewProjectDetailVC.h"
#import "Language.h"
#import "NSString+HTML.h"

static int showHide=1;

@interface NewProjectDetailVC ()
{
    UIScrollView *scrollView;
}
@end

@implementation NewProjectDetailVC
@synthesize currentProject;
@synthesize textField;
@synthesize textView;
@synthesize datePicker;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


-(void) DesignInterface
{
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    
    NSString *startDate =  currentProject.startDate;
    
    // Prepare an NSDateFormatter to convert to and from the string representation
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // ...using a date format corresponding to your date
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    // Parse the string representation of the date
    NSDate *date = [dateFormatter dateFromString:startDate];
    
    // Write the date back out using the same format
    NSLog(@"Month %@",[dateFormatter stringFromDate:date]);
    
    scrollView=[[UIScrollView alloc]initWithFrame:self.view.frame];
    scrollView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:scrollView];
    
    
    NSDateFormatter *dateFormatterNew = [[NSDateFormatter alloc] init];
    [dateFormatterNew setDateFormat:@"dd-MM-yyyy"];
    NSString *newDateString = [dateFormatterNew stringFromDate:date];
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(20, 10, 280, 260)];
    view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    [[view layer] setBorderColor:[[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] CGColor]];
    [[view layer] setBorderWidth:1];
    [[view layer] setCornerRadius:3.0];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 280, 30)];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=[currentProject.projectName stringByConvertingHTMLToPlainText];
    label.font = [UIFont fontWithName:@"Arial" size:16];
    [view addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0,40, 140, 30)];
    label.textAlignment=NSTextAlignmentCenter;

    label.text=@"Start Date";
    label.font = [UIFont fontWithName:@"Arial" size:14];
    [view addSubview:label];
    
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(120, 40, 100, 30)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.userInteractionEnabled = FALSE;
    textField.font = [UIFont systemFontOfSize:15];
//    textField.text = [dateFormatter stringFromDate:date];
    textField.text = newDateString;
    textField.delegate=self;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [view addSubview:textField];
    UIButton *button;
    /*
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(120, 40, 100, 30);
    [button addTarget:self action:@selector(displayExternalDatePickerForRowAtIndexPath) forControlEvents:UIControlEventTouchUpInside];
    [view  addSubview:button];
    */
    textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 80, 240, 80)];
    textView.font=[UIFont systemFontOfSize:16];
    textView.delegate=self;
    textView.text=[currentProject.Comment stringByConvertingHTMLToPlainText];
    [textView setInputAccessoryView:[self createToolbar]];
    [[textView layer] setBorderColor:[[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.f] CGColor]];
    [[textView layer] setBorderWidth:1];
    [[textView layer] setCornerRadius:3.0];
    [view addSubview:textView];
    
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(10, 180, 80, 40);
    button.tag=100;
    [button setBackgroundImage:[UIImage imageNamed:@"btn_welcome_screen"] forState:UIControlStateNormal];
    [button setTitle:[Language get:@"Accept" alter:@"!Accept"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(postRequestProjectAssignReply:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font=[UIFont systemFontOfSize:14];
    [view addSubview:button];
    
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(100, 180, 80, 40);
    button.tag=102;
    [button setBackgroundImage:[UIImage imageNamed:@"btn_welcome_screen"] forState:UIControlStateNormal];
    [button setTitle:[Language get:@"Pending" alter:@"!Pending"]  forState:UIControlStateNormal];
    [button addTarget:self action:@selector(postRequestProjectAssignReply:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font=[UIFont systemFontOfSize:14];
    [view addSubview:button];
    
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(190, 180, 80, 40);
    button.tag=101;
    [button setBackgroundImage:[UIImage imageNamed:@"btn_welcome_screen"] forState:UIControlStateNormal];
    [button setTitle:[Language get:@"Decline" alter:@"!Decline"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(postRequestProjectAssignReply:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font=[UIFont systemFontOfSize:14];
    [view addSubview:button];
    
    [scrollView addSubview:view];

}

- (UIToolbar*)createToolbar
{
    UIToolbar* toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.backgroundColor=[UIColor blackColor];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(ResignTextView)];
    UIBarButtonItem *flexibleButton =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *buttonItems = [NSArray arrayWithObjects:flexibleButton,shareButton,nil];
    [toolbar setItems:buttonItems];
    return toolbar;
    
}

-(void)ResignTextView
{
    [textView resignFirstResponder];
    scrollView.contentOffset=CGPointMake(0, 0);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self DesignInterface];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayExternalDatePickerForRowAtIndexPath
{
    
    if (showHide==1)
    {
        NSString *startDate =self.textField.text;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        NSDate *date = [dateFormatter dateFromString:startDate];
        
        self.datePicker=[[UIDatePicker alloc] init];
        self.datePicker.datePickerMode=UIDatePickerModeDate;
        // first update the date picker's date value according to our model
        [self.datePicker setDate:date animated:NO];
        [self.datePicker addTarget:self action:@selector(dateAction:) forControlEvents:UIControlEventValueChanged];
        //the date picker might already be showing, so don't add it to our view
        

        if (self.datePicker.superview == nil)
        {
            self.datePicker.frame = CGRectMake(0, 400, 320, 248);
//            CGRect startFrame = self.datePicker.frame;
//            CGRect endFrame = self.datePicker.frame;
//            
//            // the start position is below the bottom of the visible frame
//            startFrame.origin.y = self.view.frame.size.height;
//            
//            // the end position is slid up by the height of the view
//            endFrame.origin.y = startFrame.origin.y - endFrame.size.height;
//            
//            self.datePicker.frame = startFrame;
//            
//            [self.view addSubview:self.datePicker];
//            
//            // animate the date picker into view
//            [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.datePicker.frame = endFrame; }
//                             completion:^(BOOL finished) {
//                             }];
        }
        
        showHide=0;
    }
    else
    {
        [self doneAction];
        showHide=1;
    }
    
}


- (void)dateAction:(UIDatePicker *)datePicker1;
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    self.textField.text=[dateFormatter stringFromDate:datePicker1.date];
}

-(void)postRequestProjectAssignReply:(UIButton *)sender
{
    
//    NSLog(@"%@",self.dictionaryProjectNotification);
    NSString *accept = [NSString stringWithFormat:@"%d",(int)[sender tag]-100];
    
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:accept forKey:@"ISAccept"];
    [postDict setObject:currentProject.WorkerId forKey:@"worker_id"];
   [postDict setObject:currentProject.WorkId forKey:@"work_id"];
    [postDict setObject:self.textField.text forKey:@"start_date_by_worker"];
    [postDict setObject:currentProject.projectId forKey:@"project_id"];
    
    if (APP_DELEGATE.isServerReachable) {
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_Project_Assign_Return]];
    [urlRequest setTimeoutInterval:180];
    NSString *requestBody = [NSString stringWithFormat:@"JsonObject=%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
         NSLog(@"%@",object);
         
         [self performSelectorOnMainThread:@selector(removeNotificationView) withObject:object waitUntilDone:YES];
         
     }];
    }
    else
    {
//        [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
}
-(void)removeNotificationView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if(showHide==0)
    {
        showHide=1;
        [self doneAction];
    }
    scrollView.contentOffset=CGPointMake(0, 80);
    return YES;
}

//- (BOOL)textView:(UITextView *)textView1 shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    if([text isEqualToString:@"\n"])
//    {
//        [textView1 resignFirstResponder];
//    }
//    return YES;
//}

- (void)doneAction
{
    CGRect pickerFrame = self.datePicker.frame;
    pickerFrame.origin.y = self.view.frame.size.height;
    
    // animate the date picker out of view
    [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.datePicker.frame = pickerFrame; }
                     completion:^(BOOL finished) {
                         [self.datePicker removeFromSuperview];
                     }];
    
}



@end
