//
//  ProjectReportTVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/28/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "ProjectReportTVC.h"
#import "MBProgressHUD.h"
#import "Language.h"
#import "PersistentStore.h"
#import "NSString+HTML.h"

@interface ProjectReportTVC ()

@end

@implementation ProjectReportTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) postRequestProjectReports
{
    if (self.stringProjectId == nil)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"No project lists are available." alter:@"!No project lists are available."]  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        alert.tag = 1;
        
        [alert show];
    }
    else
    {
     [self showLoadingView];
    
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:self.stringWorkerId forKey:@"worker_id"];
    [postDict setObject:self.stringProjectId forKey:@"project_id"];
    
    if (APP_DELEGATE.isServerReachable) {
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://fieldo.se/api/proreport.php"]];
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
                  [self performSelectorOnMainThread:@selector(alertLoginFailed) withObject:nil waitUntilDone:YES];
             }
             else
             {
                 if ([self.arrayTime isKindOfClass:[NSArray class]])
                 {
                    [self performSelectorOnMainThread:@selector(noData) withObject:nil waitUntilDone:YES];
                 }
                 else if (self.arrayMaterial == nil)
                 {
                     [self performSelectorOnMainThread:@selector(noData) withObject:nil waitUntilDone:YES];
                 }
                 else if (self.arrayTravel == nil)
                 {
                     [self performSelectorOnMainThread:@selector(noData) withObject:nil waitUntilDone:YES];
                 }
                 
                 self.arrayMaterial=object[@"data"][@"material"];
                 self.arrayTravel=object[@"data"][@"KM"];
                 
                 self.arrayTime =object[@"data"][@"TimeLog"];
                 
                  [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
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
}
- (void) noData
{
    labelData = [[UILabel alloc] initWithFrame:CGRectMake(125, 185, 100, 30)];
    
    labelData.text = @"No Data.";
    
    labelData.textColor = [UIColor lightGrayColor];
    
    [self.tableView addSubview:labelData];
}

- (void) alertLoginFailed
{
    [self hideLoadingView];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"No data found." alter:@"!No data found."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    alert.tag = 1;
    
    [alert show];
}

#pragma mark - UIAlertView Delegate

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger) buttonIndex
{
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

-(void)refreshTable
{
    [self hideLoadingView];
}

-(void)hideLoadingView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.tableView reloadData];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
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
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    
    NSMutableArray *array=[[NSMutableArray alloc] init];
    [array addObject:[Language get:@"Time Log" alter:@"!Time Log"]];
    [array addObject:[Language get:@"Material Log" alter:@"!Material Log"]];
    [array addObject:[Language get:@"Travel Log" alter:@"!Travel Log"]];
    
    self.segmentControl = [[UISegmentedControl alloc]initWithItems:array];
    self.segmentControl.frame = CGRectMake(10, 7, 300, 30);
    [self.segmentControl addTarget:self action:@selector(segmentedControl_ValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentControl setSelectedSegmentIndex:0];
    [view addSubview:self.segmentControl];
      self.tableView.tableHeaderView = view;
    
    [self postRequestProjectReports];
    
}


-(void)segmentedControl_ValueChanged:(UISegmentedControl *)segment
{
    
    if(segment.selectedSegmentIndex == 0)
    {
        //action for the first button (Current)
    }
    if(segment.selectedSegmentIndex == 1)
    {
        //action for the first button (Current)
    }
    if (segment.selectedSegmentIndex == 2)
    {
        
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
      if ([self.arrayTravel isKindOfClass:[NSArray class]])
      {
          labelData.hidden = NO;
          return [self.arrayTravel count];  
      }
      else
      {
          return [self.arrayTravel count];
      }
 }
    
    return NO;
    
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(self.segmentControl.selectedSegmentIndex ==0)
    {
        
        NSString *string=[NSString stringWithFormat:@"%@ Hours, from %@ - %@",self.arrayTime[indexPath.row][@"tdiff"],self.arrayTime[indexPath.row][@"is_from"],self.arrayTime[indexPath.row][@"is_to"]];
        
        /*
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//      [dateFormatter setDateFormat:@"dd-MM-yyyy"];
//      [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        NSMutableArray *arrayDate = [self.arrayTime valueForKey:@"date"];
        NSDate *date123=[dateFormatter dateFromString:[NSString stringWithFormat:@"%@", arrayDate]];
        
        NSDateFormatter *dateFormatter2=[[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"dd-MMMM-YYYY"];
        
//      [self.arrayTime addObject:[dateFormatter2 dateFromString:[NSString stringWithFormat:@"%@", date123]]];
        NSMutableArray *arrayDateTime = [[NSMutableArray alloc] init];
        NSMutableArray *array = [self.arrayTime valueForKey:@"date"];
        for (NSDate* dateAsDate in array)
        {
           //get the date next NSDate from the array as: NSDate *dateAsDate...
           NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
           [dateFormat setDateFormat:@"dd-MMMM-yyyy"];
           NSString *dateAsStr = [dateFormat stringFromDate:date123];
           [arrayDateTime addObject:dateAsStr];
        }
        */
        
        
        NSString *str = [[self.arrayTime objectAtIndex:indexPath.row] valueForKey:@"date"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *date = [dateFormatter dateFromString:str];
        
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"dd-MM-yyyy"];
        NSString *newDateString = [dateFormatter2 stringFromDate:date];
        
        cell.textLabel.text = [[NSString stringWithFormat:@"%@", newDateString] stringByConvertingHTMLToPlainText];
        
        
        cell.detailTextLabel.text=[string stringByConvertingHTMLToPlainText];
        cell.textLabel.font = [UIFont systemFontOfSize:12];

        labelData.hidden = YES;
        
    }
    else if (self.segmentControl.selectedSegmentIndex ==1)
    {
        
        NSString *materialName=[[NSString stringWithFormat:@"%@",self.arrayMaterial[indexPath.row][@"material_name"]] stringByConvertingHTMLToPlainText];
        NSString *OrderNo=[NSString stringWithFormat:@"Order No. - %@",self.arrayMaterial[indexPath.row][@"order_no"]];
        NSString *OrderValue=([[NSString stringWithFormat:@"%@",self.arrayMaterial[indexPath.row][@"order_value"]] length]>0)?[NSString stringWithFormat:@"Order Value - %@",self.arrayMaterial[indexPath.row][@"order_value"]]:@"";
//      NSString *OrderDate=[NSString stringWithFormat:@"%@",self.arrayMaterial[indexPath.row][@"date"]];
        
        NSString *OrderDate = [[self.arrayMaterial objectAtIndex:indexPath.row] valueForKey:@"date"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *date = [dateFormatter dateFromString:OrderDate];
        
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"dd-MM-yyyy"];
        NSString *newDateString = [dateFormatter2 stringFromDate:date];
        
        
        
        cell.textLabel.text=[NSString stringWithFormat:@"%@    %@",materialName,newDateString];
        
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@    %@",OrderNo,OrderValue];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        
        labelData.hidden = YES;
        
    }
    else
    {
        
        NSString *resourceparams = [NSString stringWithFormat:@"%@",self.arrayTravel[indexPath.row][@"from"]];
        NSLog(@"before replace resourceparams: %@", resourceparams);
        resourceparams = [resourceparams stringByReplacingOccurrencesOfString:@"\\U" withString:@"\\u"];
        NSLog(@"after replace resourceparams: %@", resourceparams);
        
         NSString *string=[NSString stringWithFormat:@"%@ - %@\n%@, %@",self.arrayTravel[indexPath.row][@"from"],self.arrayTravel[indexPath.row][@"to"],self.arrayTravel[indexPath.row][@"km"],self.arrayTravel[indexPath.row][@"other_fee"]];
        

        NSString *str = [[self.arrayTravel objectAtIndex:indexPath.row] valueForKey:@"date"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *date = [dateFormatter dateFromString:str];
        
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"dd-MM-yyyy"];
        NSString *newDateString = [dateFormatter2 stringFromDate:date];
        
        cell.textLabel.text=[NSString stringWithFormat:@"%@", newDateString];
        
        cell.detailTextLabel.text=string;

        cell.detailTextLabel.numberOfLines=3;
        
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        
        labelData.hidden = YES;
        
    }
    
    return cell;
    
}
@end

