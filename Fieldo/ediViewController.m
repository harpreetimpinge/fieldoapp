//
//  ediViewController.m
//  Fieldo
//
//  Created by Vishal on 20/11/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "ediViewController.h"
#import "PersistentStore.h"
#import "Loader.h"
#import "ediCustomCellTableViewCell.h"
#import "MBProgressHUD.h"

#import "Language.h"

@interface ediViewController ()
{
    Loader *objLoader;
}
@end

@implementation ediViewController
@synthesize projectId,projectName;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"EDI"];
    
    m_dataArray=[[NSMutableArray alloc]init];
    if(!objLoader)
    {
        objLoader=[[Loader alloc]init];
    }
    
    [self getEDIDataForProject];
    
    self.amountField.delegate=self;
    self.quantityField.delegate=self;
    
    [self.quantityField addTarget:self action:@selector(updateLabelUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged];

    UIBarButtonItem *doneButton=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    
    
    self.m_editView.layer.cornerRadius=10.0f;
    
    
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


-(void)doneAction
{
    [self showLoadingView];
    
    
    NSMutableDictionary *jsonDict=[[NSMutableDictionary alloc]init];
    [jsonDict setObject:m_dataArray forKey:@"data"];
    [jsonDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
    [jsonDict setObject:self.projectId forKey:@"project_id"];
    [jsonDict setObject:fileName forKey:@"filename"];


    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        NSError *error;
        
        if (APP_DELEGATE.isServerReachable) {
            
            NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_UPDATE_EDI]];
            
            [urlRequest setTimeoutInterval:180];
            NSString *requestBody = [NSString stringWithFormat:@"JsonObject=%@",jsonString];
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
                     
                     [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Failed to upload data." alter:@"!Failed to upload data."]  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
                     
                 }
                 if ([object isKindOfClass:[NSDictionary class]] == YES)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^(void)
                                    {
                                        [self hideLoadingView];
                                        
                                        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:object[@"MSG"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
                                        
                                    });
                     
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
}

-(void)getEDIDataForProject
{
    [self showLoadingView];
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    
    [postDict setObject:[NSString stringWithFormat:@"%@",self.projectId]  forKey:@"project_id"];
    //[postDict setObject:self.projectName forKey:@"project_name"];

    if (APP_DELEGATE.isServerReachable) {
        
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_GET_EDI]];
        
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
                 dispatch_async(dispatch_get_main_queue(), ^(void)
                                {
                 [self hideLoadingView];
                 
                 NSLog(@"Error: %@",[error description]);
                 
                 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"No Data available." alter:@"!No Data available."] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                    alert.tag=100;
                                    [alert show];
                                });
                 
             }
             if ([object isKindOfClass:[NSDictionary class]] == YES)
             {
                 if ([object[@"CODE"] intValue]==1)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^(void)
                                    {
                     [self hideLoadingView];
                     
                     
                     [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"No Data available." alter:@"!No Data available."] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
                                    });
                 }
                 else
                 {
                     dispatch_async(dispatch_get_main_queue(), ^(void)
                                    {
                                        [self hideLoadingView];
                                        
                                        fileName=object[@"filename"];
                                        m_dataArray=[NSMutableArray arrayWithArray:object[@"data"]];
                                        
                                        [self.m_tableView reloadData];
                                        
                                    });
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==100)
    {
    if(buttonIndex==0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    }
}


#pragma mark - UITableView DataSource Methods

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section
{
    return [m_dataArray count];
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
    static NSString *ci = @"ediCustomCell";
    ediCustomCellTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:ci];
    
    if (cell == nil) {
        NSArray *array=[[NSBundle mainBundle]loadNibNamed:@"ediCustomCellTableViewCell" owner:self options:nil];
        cell=[array objectAtIndex:0];
        
    }
    
    cell.editBtn.tag = indexPath.row;
    [cell.editBtn addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell setContentOnCell:[m_dataArray objectAtIndex:indexPath.row]];
    [tableView setShowsVerticalScrollIndicator:NO];
    
    return cell;
}


#pragma mark - UITableView Delegate Methods

- (CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath
{
    return  255.0;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)editAction:(id)sender
{
    int tag=(int)[sender tag];
    editIndex=tag;
    [self.m_editView setHidden:NO];
    
    NSString *quantity=[[m_dataArray objectAtIndex:tag] objectForKey:@"quantity"];
    float cost=[[[m_dataArray objectAtIndex:tag] objectForKey:@"orderValue"] floatValue];

    self.quantityField.text=[NSString stringWithFormat:@"%i", (int)[quantity integerValue]];
    self.amountField.text=[NSString stringWithFormat:@"%.2f",cost];
    initialAmount=[[[m_dataArray objectAtIndex:tag] objectForKey:@"price"] floatValue];
    
}

-(void)animateUp:(float)amount
{
    [UIView beginAnimations:@"up" context:nil];
    [UIView setAnimationDuration:0.3f];
    [self.m_editView setFrame:CGRectMake(self.m_editView.frame.origin.x, amount, self.m_editView.frame.size.width, self.m_editView.frame.size.height)];
    [UIView commitAnimations];
}

-(void)animateDown
{
//    [UIView beginAnimations:@"up" context:nil];
//    [UIView setAnimationDuration:0.3f];
//    [self.m_editView setFrame:CGRectMake(self.m_editView.frame.origin.x, 87, self.m_editView.frame.size.width, self.m_editView.frame.size.height)];
//    [UIView commitAnimations];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField==self.quantityField)
    {
       // [self animateUp:30];
    }
    else if (textField==self.amountField)
    {
        //[self animateUp:-50];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength >6) ? NO : YES;
}

- (void)updateLabelUsingContentsOfTextField:(id)sender {
    
    UITextField *field=(UITextField*)sender;
    if(field.text.length<6)
    {
    float cost=initialAmount*(int)[field.text integerValue];
    self.amountField.text=[NSString stringWithFormat:@"%.2f",cost];
    }
}

- (IBAction)saveAction:(id)sender {
    
    [self.view endEditing:YES];
    
    [self animateDown];

    [self.m_editView setHidden:YES];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    dict=[[m_dataArray objectAtIndex:editIndex] mutableCopy];
    [dict setObject:self.amountField.text forKey:@"price"];
    [dict setObject:self.quantityField.text forKey:@"quantity"];
    [dict setObject:self.amountField.text forKey:@"orderValue"];

    [m_dataArray replaceObjectAtIndex:editIndex withObject:dict];
    
    [self.m_tableView reloadData];
}

- (IBAction)cancelAction:(id)sender {
    
    [self.view endEditing:YES];
    [self animateDown];
    [self.m_editView setHidden:YES];

}
@end
