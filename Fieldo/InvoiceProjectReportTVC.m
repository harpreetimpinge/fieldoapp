//
//  InvoiceProjectReportTVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 3/21/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//



#import "InvoiceProjectReportTVC.h"
#import "MBProgressHUD.h"
#import "Language.h"
#import "PersistentStore.h"
#import "NSString+HTML.h"

@interface InvoiceProjectReportTVC ()

@end

@implementation InvoiceProjectReportTVC
@synthesize stringProjectType;
@synthesize stringProjectId;
@synthesize custAccept;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        strCost=@"0";
        // Custom initialization
    }
    return self;
}


-(void)postRequestProjectReports
{
    
    [self showLoadingView];
    [self postRequestProjectCost];
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:self.stringProjectId forKey:@"project_id"];
    if (APP_DELEGATE.isServerReachable) {
    
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    
    
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://fieldo.se/api/proreportcustomer.php"]];
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
                 self.arrayMaterial=object[@"data"][@"material"];
                 self.arrayTravel=object[@"data"][@"KM"];
                 self.arrayTime=object[@"data"][@"TimeLog"];
                 [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
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

-(void)postRequestProjectCost
{
    
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:self.stringProjectId forKey:@"project_id"];
    if (APP_DELEGATE.isServerReachable) {

    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    
    
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://fieldo.se/api/totalreportofproject.php"]];
    
    
    
    
    
    [urlRequest setTimeoutInterval:180];
    NSString *requestBody = [NSString stringWithFormat:@"JsonObject=%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
         NSLog(@"%@ material",object);
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
                 strCost=object[@"data"][@"ProjCost"][0][@"FinalProjCost"];
                 NSLog(@"%@",strCost);
//                 [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
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
}
-(void)refreshTable1
{
    [self hideLoadingView];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)hideLoadingView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.tableView reloadData];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
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
    
    self.arrayTime     =   [[NSMutableArray alloc] init];
    self.arrayTravel   =   [[NSMutableArray alloc] init];
    self.arrayMaterial =   [[NSMutableArray alloc] init];
    
    self.title=[Language get:@"Project Report" alter:@"!Project Report"]  ;
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"] ];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    viewHeader=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 110)];
    
    lblProjectType=[[UILabel alloc]initWithFrame:CGRectMake(85, 5, 150, 30)];
    lblProjectType.textAlignment=NSTextAlignmentCenter;
    lblProjectType.font=[UIFont systemFontOfSize:14.0];
    [viewHeader addSubview:lblProjectType];
    
    lblProjectCost=[[UILabel alloc]initWithFrame:CGRectMake(85, 40, 150, 30)];
    lblProjectCost.textAlignment=NSTextAlignmentCenter;
    lblProjectCost.font=[UIFont systemFontOfSize:14.0];
    [viewHeader addSubview:lblProjectCost];
    
    NSMutableArray *array=[[NSMutableArray alloc] init];
    [array addObject:[Language get:@"Time Log" alter:@"!Time Log"]];
    [array addObject:[Language get:@"Material Log" alter:@"!Material Log"]];
    [array addObject:[Language get:@"Travel Log" alter:@"!Travel Log"]];
    
    self.segmentControl = [[UISegmentedControl alloc]initWithItems:array];
    
    self.segmentControl.frame = CGRectMake(10, 75, 300, 30);
    [self.segmentControl addTarget:self action:@selector(segmentedControl_ValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentControl setSelectedSegmentIndex:0];
    [viewHeader addSubview:self.segmentControl];
    
    
    
    viewFooter=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    NSMutableArray *array1=[[NSMutableArray alloc] init];
    [array1 addObject:[Language get:@"Accept" alter:@"!Accept"]];
    [array1 addObject:[Language get:@"Decline" alter:@"!Decline"]];
    
    self.segmentControlFooter = [[UISegmentedControl alloc]initWithItems:array1];
    
    self.segmentControlFooter.frame = CGRectMake(10, 5, 300, 30);
    [self.segmentControlFooter addTarget:self action:@selector(segmentedControl_ValueChanged_Footer:) forControlEvents:UIControlEventValueChanged];
//    [self.segmentControlFooter setSelectedSegmentIndex:0];
    [viewFooter addSubview:self.segmentControlFooter];
    
    self.tableView.tableFooterView=viewFooter;
    [self postRequestProjectReports];
    
    if ([custAccept isKindOfClass:[NSString class]]&&[custAccept  isEqualToString:@"1"]) {
        [[[UIAlertView alloc] initWithTitle:[Language get:@"This invoice has already been accepted." alter:@"!This invoice has already been accepted."]  message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        self.segmentControlFooter.selectedSegmentIndex=0;
        self.segmentControlFooter.enabled=NO;
    }
    else
    {
        self.segmentControlFooter.enabled=YES;
    }
}

-(void)segmentedControl_ValueChanged_Footer:(UISegmentedControl *)segment
{
    
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:self.managerEmail forKey:@"manager_email"];
    [postDict setObject:[PersistentStore getCustomerID] forKey:@"cust_id"];
    [postDict setObject:self.managerId forKey:@"manager_id"];
    [postDict setObject:self.stringProjectId forKey:@"project_id"];
    if(segment.selectedSegmentIndex == 0)
    {
        [postDict setObject:@"1" forKey:@"status"];
        //action for the first button (Current)
    }
    if(segment.selectedSegmentIndex == 1)
    {
        [postDict setObject:@"2" forKey:@"status"];
    }
    NSError *error;
   
    if (APP_DELEGATE.isServerReachable) {
   
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    
    
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://fieldo.se/api/CustomerInvoiceStatus.php"]];
    
    
    
    
    
    [urlRequest setTimeoutInterval:180];
    NSString *requestBody = [NSString stringWithFormat:@"JsonObject=%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPMethod:@"POST"];
    [self showLoadingView];
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
             if ([object[@"CODE"] intValue]==0)
             {
                 [self performSelectorOnMainThread:@selector(refreshTable1) withObject:nil waitUntilDone:NO];
             }
             else
             {
//                 strCost=object[@"data"][@"ProjCost"][0][@"FinalProjCost"];
//                 NSLog(@"%@",strCost);
                 //                 [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
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

-(void)segmentedControl_ValueChanged:(UISegmentedControl *)segment
{
    if(segment.selectedSegmentIndex == 0)
    {
        [segment setSelectedSegmentIndex:0];
        //action for the first button (Current)
    }
    if(segment.selectedSegmentIndex == 1)
    {
        [segment setSelectedSegmentIndex:1];

        //action for the first button (Current)
    }
    if (segment.selectedSegmentIndex == 2)
    {
        [segment setSelectedSegmentIndex:2];

    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.segmentControl.selectedSegmentIndex ==0)
    {
        return [self.arrayTime count];
    }
    else if (self.segmentControl.selectedSegmentIndex ==1)
    {
        return [self.arrayMaterial count];
    }
    else
    {
        return [self.arrayTravel count];
    }
    
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.segmentControl.selectedSegmentIndex ==2)
        return 70;
    return 50;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        
        // 1: To provide feedback to the user, create a UIActivityIndicatorView and set it as the cellís accessory view.
    }
    
    
    if(self.segmentControl.selectedSegmentIndex ==0)
    {
        NSString *string=[NSString stringWithFormat:@"%@ Hours, from %@ - %@",self.arrayTime[indexPath.row][@"tdiff"],self.arrayTime[indexPath.row][@"is_from"],self.arrayTime[indexPath.row][@"is_to"]];
        
        
        
        
        cell.textLabel.text=self.arrayTime[indexPath.row][@"date"];
        cell.detailTextLabel.text=[string stringByConvertingHTMLToPlainText];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        
        
        
    }
    else if (self.segmentControl.selectedSegmentIndex ==1)
    {
        
//        NSString *string=[NSString stringWithFormat:@"%@, %@, %@",self.arrayMaterial[indexPath.row][@"material_name"],self.arrayMaterial[indexPath.row][@"order_no"],self.arrayMaterial[indexPath.row][@"order_value"]];
//        cell.textLabel.text=self.arrayMaterial[indexPath.row][@"date"];
//        cell.detailTextLabel.text=[string stringByConvertingHTMLToPlainText];
//        cell.textLabel.font = [UIFont systemFontOfSize:12];
        
        NSString *materialName=[[NSString stringWithFormat:@"%@",self.arrayMaterial[indexPath.row][@"material_name"]] stringByConvertingHTMLToPlainText];
        NSString *OrderNo=[NSString stringWithFormat:@"Order No. - %@",self.arrayMaterial[indexPath.row][@"order_no"]];
        NSString *OrderValue=([[NSString stringWithFormat:@"%@",self.arrayMaterial[indexPath.row][@"order_value"]] length]>0)?[NSString stringWithFormat:@"Order Value - %@",self.arrayMaterial[indexPath.row][@"order_value"]]:@"";
        NSString *OrderDate=[NSString stringWithFormat:@"%@",self.arrayMaterial[indexPath.row][@"date"]];
        
        cell.textLabel.text=[NSString stringWithFormat:@"%@    %@",materialName,OrderDate];
        
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@    %@",OrderNo,OrderValue];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        
        
    }
    else
    {
        
        
        
        NSString *string=[NSString stringWithFormat:@"%@ - %@\n%@ km, %@",self.arrayTravel[indexPath.row][@"from"],self.arrayTravel[indexPath.row][@"to"],self.arrayTravel[indexPath.row][@"km"],self.arrayTravel[indexPath.row][@"other_fee"]];
        
        
        cell.textLabel.text=self.arrayTravel[indexPath.row][@"date"];
        cell.detailTextLabel.text=string;
        
        cell.detailTextLabel.numberOfLines=3;
        
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        
        
        
    }
    
    
    return cell;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    lblProjectCost.text=[NSString stringWithFormat:@"Cost: %@",strCost];
    lblProjectType.text=[NSString stringWithFormat:@"%@",[self ProjectType:[stringProjectType intValue]]];
    return viewHeader;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 110;
}

-(NSString *) ProjectType:(NSInteger) value
{
    if (value==0) {
        return [Language get:@"Fixed" alter:@"!Fixed"];
    }
    return [Language get:@"Time" alter:@"!Time"];
}
@end

