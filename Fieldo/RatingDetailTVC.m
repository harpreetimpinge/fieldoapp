//
//  RatingDetailTVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 2/21/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "RatingDetailTVC.h"
#import "Language.h"
#import "NSString+HTML.h"
#import "AXRatingView.h"
#import "CustomTextViewCell.h"
#import "PersistentStore.h"
#import "MBProgressHUD.h"

static NSString *kTextViewID = @"textView";
static NSString *kButtonID = @"buttonId";


@interface RatingDetailTVC ()<customTextCellDelegate>
{
    MBProgressHUD *hud;
}

@end

@implementation RatingDetailTVC

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

    
    self.title=[Language get:@"Update Rating" alter:@"!Update Rating"];
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    self.tableView.scrollEnabled=NO;
    
    NSMutableDictionary *itemOne =  [@  { kTitleKey :@"Project Name" , kValueKey : self.dictRatingProject[@"title"] } mutableCopy];
    NSMutableDictionary *itemTwo =  [@  { kTitleKey :@"Company Name" , kValueKey : self.dictRatingProject[@"com_name"] } mutableCopy];
    NSMutableDictionary *itemThree =[@  { kTitleKey :@"SetRating"    , kValueKey : @"" } mutableCopy];
    NSMutableDictionary *itemFour = [@  { kTitleKey :@"Comments"      , kValueKey : self.dictRatingProject[@"subject"] } mutableCopy];
    NSMutableDictionary *itemFifth =[@  { kTitleKey :@"Button"      , kValueKey : @"" } mutableCopy];

    self.dataArray = @[itemOne, itemTwo, itemThree, itemFour,itemFifth];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==3)
          return 100;
        return 50;
    
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        NSDictionary *itemData = self.dataArray[indexPath.row];

   
    if (indexPath.row==0 || indexPath.row==1)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell)
        {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }

        
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.textLabel.text=self.dataArray[indexPath.row][kTitleKey];
        cell.textLabel.textColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
        cell.textLabel.font=[UIFont systemFontOfSize:12];
        cell.detailTextLabel.text=[self.dataArray[indexPath.row][kValueKey] stringByConvertingHTMLToPlainText];
        cell.detailTextLabel.font=[UIFont systemFontOfSize:15];
        
        return cell;

    }
    else if (indexPath.row==2)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell)
        {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }

        cell.selectionStyle=UITableViewCellSelectionStyleNone;

        
        AXRatingView *basicRatingView = [[AXRatingView alloc] initWithFrame:CGRectMake(85,5, 200, 30)];
        [basicRatingView sizeToFit];
        basicRatingView.value=[self.dictRatingProject[@"rating"] floatValue];
        [basicRatingView addTarget:self action:@selector(ratingChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:basicRatingView];
        return cell;

    }
    else if (indexPath.row==3)
    {
        

        
        CustomTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTextViewID];
        if (cell == nil) {
            cell = [[CustomTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextViewID];
        }
        // Add a UITextField
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.textView.enablesReturnKeyAutomatically = NO;
        cell.textView.text = (![[itemData valueForKey:kValueKey] isEqualToString:@""])?[itemData valueForKey:kValueKey]:[Language get:[itemData valueForKey:kTitleKey] alter:[itemData valueForKey:kTitleKey]];
        cell.textView.delegate=self;
        cell.TextDelegate=self;
        if (![[itemData valueForKey:kValueKey] isEqualToString:@""]) {
            cell.textView.textColor=[UIColor blackColor];
        }
        else {
        cell.textView.textColor=[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.0];
        }
        cell.textView.autocorrectionType = UITextAutocorrectionTypeNo;
        cell.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [cell.contentView addSubview:cell.textView];
        return cell;
        
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kButtonID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kButtonID];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;

        UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame=CGRectMake(0, 0, 80, 32);
        [button setTitle:[Language get:@"Submit" alter:@"!Submit"] forState:UIControlStateNormal];
        button.layer.cornerRadius = 3;
        button.layer.borderColor = [[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] CGColor];
        button.layer.borderWidth = .8f;
        [button addTarget:self action:@selector(Send) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font=[UIFont systemFontOfSize:16];
       // [cell.contentView addSubview:button];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.accessoryView=button;

        
        return cell;
 
    }
    

    
}



-(void)Send
{
    CustomTextViewCell *cellTextView =(CustomTextViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];

    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.labelText = @"Loading....";
    
    [hud show:YES];
    
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:[PersistentStore getCustomerID] forKey:@"cust_id"];
    [postDict setObject:self.dictRatingProject[@"project_id"] forKey:@"project_id"];
    [postDict setObject:[NSString stringWithFormat:@"%f",ratingValue] forKey:@"rating"];
    [postDict setObject:cellTextView.textView.text forKey:@"subject"];
    
    if (APP_DELEGATE.isServerReachable) {
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://fieldo.se/api/projectrating.php"]];
    
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
        
         NSString *stringMsg = [object objectForKey:@"MSG"];
         
         if ([stringMsg isEqualToString:@"Inserted Successfully"])
         {
             [self performSelectorOnMainThread:@selector(showAlertForRating) withObject:nil waitUntilDone:YES];
         }
     }];
    }
    else
    {
//        [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
   }


-(void)BackBtn
{
    [self.navigationController popViewControllerAnimated:YES];

}

- (void) showAlertForRating
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Inserted Successfully." alter:@"!Inserted Successfully."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    alert.tag = 1;
    
    [alert show];
    
    [hud hide:YES];
    
    [hud removeFromSuperViewOnHide];
}

- (void)ratingChanged:(AXRatingView *)sender
{
    ratingValue=sender.value;
    NSLog(@"sender value %f", sender.value) ;
}

-(void) ResignTextViewForTable:(UITextView *)textView1
{
    if(textView1.text.length==0)
    {
        textView1.text=[Language get:@"Comments" alter:@"Comments"];
        textView1.textColor=[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.0];
    }
    
    [textView1 resignFirstResponder];
    self.tableView.contentOffset=CGPointMake(0, 0);
}


#pragma mark TextView Delegates
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    if([text isEqualToString:@"\n"])
//    {
//        if (![textView.text length])
//        {
//            textView.text = [Language get:@"Comments" alter:@"!Comments"];
//            textView.textColor=[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.0];
//        }
//        [textView resignFirstResponder];
//    }
//    
//    
//    return YES;
//}


- (BOOL)textViewShouldReturn:(UITextView *)textView
{
    if (![textView.text length])
    {
        textView.text = [Language get:@"Comments" alter:@"!Comments"];
        textView.textColor=[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.0];
    }
    [textView resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    
    NSLog(@"%@",[Language get:@"Comments" alter:@"!Comments"]);
    if([textView.text isEqualToString:[Language get:@"Comments" alter:@"!Comments"]])
    {
        textView.textColor=[UIColor blackColor];
        textView.text = @"";
    }
    self.tableView.contentOffset=CGPointMake(0, 0);
    return YES;
}




- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}




@end
