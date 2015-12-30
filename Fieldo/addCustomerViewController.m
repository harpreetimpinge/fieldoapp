//
//  addCustomerViewController.m
//  Fieldo
//
//  Created by Vishal on 18/11/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "addCustomerViewController.h"
#import "PersistentStore.h"
#import "Language.h"
#import "NSIUtility.h"

@interface addCustomerViewController ()
{
}
@end

@implementation addCustomerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.m_scrollView setContentSize:CGSizeMake(320, 568)];
    self.companyNameField.delegate=self;
    self.organizationNoField.delegate=self;
    self.phoneField.delegate=self;
    self.emailField.delegate=self;
    self.customerNameField.delegate=self;
    

    [self.navigationItem setTitle:[Language get:@"Add Customer" alter:@"!Add Customer"]];
    
    
    ////Localization
    
    [self.saveBtn setTitle:[Language get:@"Done" alter:@"!Done"] forState:UIControlStateNormal];
    self.nameLabel.text=[Language get:@"Name" alter:@"!Name"];
    self.customerNameField.placeholder=[Language get:@"Customer" alter:@"!Customer"];
    self.companyNameLabel.text=[Language get:@"Company Name" alter:@"!Company Name"];
    self.companyNameField.placeholder=[Language get:@"Company Name" alter:@"!Company Name"];
    self.organisationNoLabel.text=[Language get:@"Organization No." alter:@"!Organization No."];
    self.organizationNoField.placeholder=[Language get:@"Organization No." alter:@"!Organization No."];
    self.phoneLabel.text=[Language get:@"Phone" alter:@"!Phone"];
    self.phoneField.placeholder=[Language get:@"Phone" alter:@"!Phone"];
    self.emailLabel.text=[Language get:@"Email" alter:@"!Email"];
    self.emailField.placeholder=[Language get:@"Email" alter:@"!Email"];
    [self.cancelBtn setTitle:[Language get:@"Cancel" alter:@"!Cancel"] forState:UIControlStateNormal];
    
    self.customerNameField.borderStyle=UITextBorderStyleRoundedRect;
    self.companyNameField.borderStyle=UITextBorderStyleRoundedRect;
    self.organizationNoField.borderStyle=UITextBorderStyleRoundedRect;
    self.phoneField.borderStyle=UITextBorderStyleRoundedRect;
    self.emailField.borderStyle=UITextBorderStyleRoundedRect;

}

-(void)viewWillDisappear:(BOOL)animated
{
    [self hideLoadingView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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


- (IBAction)saveAction:(id)sender {
    
    
    if(self.customerNameField.text.length>0 && self.phoneField.text.length>0)
    {
        if(self.emailField.text.length>0)
        {
        if(![NSIUtility validateEmail:self.emailField.text])
             {
                 UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:[Language get:@"Please enter valid email." alter:@"!Please enter valid email."]  delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                 [alert show];
             }
             else
             {
       [self showLoadingView];
   
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:self.customerNameField.text forKey:@"cname"];
    [dict setObject:self.organizationNoField.text forKey:@"orgname"];
    [dict setObject:self.phoneField.text forKey:@"contact"];
    [dict setObject:self.emailField.text forKey:@"email"];
    [dict setObject:self.companyNameField.text forKey:@"com_name"];
    [dict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
        
        [self addCustomerWith:dict];
             }
        }
        else
        {
            [self showLoadingView];
            
            NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
            [dict setObject:self.customerNameField.text forKey:@"cname"];
            [dict setObject:self.organizationNoField.text forKey:@"orgname"];
            [dict setObject:self.phoneField.text forKey:@"contact"];
            [dict setObject:self.emailField.text forKey:@"email"];
            [dict setObject:self.companyNameField.text forKey:@"com_name"];
            [dict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
            
            [self addCustomerWith:dict];

        }

    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[Language get:@"Please fill the required fields to create customer." alter:@"!Please fill the required fields to create customer."]  delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField==self.phoneField)
    {
        [self.m_scrollView setContentOffset:CGPointMake(0, 110) animated:YES];
  
    }
   else if (textField==self.emailField)
   {
       [self.m_scrollView setContentOffset:CGPointMake(0, 160) animated:YES];
   }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.m_scrollView setContentOffset:CGPointMake(0, 0)];
    [textField resignFirstResponder];
    return YES;
}

-(void)addCustomerWith:(NSDictionary*)dict
{
    
    NSError *error;
    
    if (APP_DELEGATE.isServerReachable) {
        
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_CREATE_CUSTOMER]];
        
    
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
                 [self hideLoadingView];

                 NSLog(@"Error: %@",[error description]);
             }
             if ([object isKindOfClass:[NSDictionary class]] == YES)
             {
                 if ([object[@"CODE"] intValue]==1)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^(void)
                                    {
                     [self hideLoadingView];

                           [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:object[@"MSG"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
                                    });
                 }
                 else
                 {
                    //NSLog(@"%@",object);
                     [[NSUserDefaults standardUserDefaults]setObject:[object objectForKey:@"ID"] forKey:@"customerID"];
                     [[NSUserDefaults standardUserDefaults]setObject:self.customerNameField.text forKey:@"customerNAME"];
                     [[NSUserDefaults standardUserDefaults]synchronize];

                     dispatch_async(dispatch_get_main_queue(), ^(void)
                                    {

                            [self hideLoadingView];

                     [self.navigationController popViewControllerAnimated:YES];
                                    });
                 }
                 
             }
         }];
    }
    else
    {
       // [objLoader hideLoader];

        // [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }

}


- (IBAction)cancelAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];

}
@end
