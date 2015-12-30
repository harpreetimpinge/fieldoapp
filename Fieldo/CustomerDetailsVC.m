//
//  CustomerDetailsVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/23/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>



#import "CustomerDetailsVC.h"
#import "MBProgressHUD.h"
#import "CustomGPSMapCell.h"
#import "Language.h"
#import "NSString+HTML.h"
#import "PersistentStore.h"

static NSString *CellIdentifier=@"Cell";
static NSString *MapCellIdentifier=@"mapCell";

@interface CustomerDetailsVC ()

@end

@implementation CustomerDetailsVC
    {
    GMSMapView *mapView_;
    }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==[self.arrayCustomer count]-1)
        return 250.0;
        return  50.0;
}



- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


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
  
    [self showLoadingView];
    NSLog(@"View frame is: %@", NSStringFromCGRect(self.view.bounds));
    
    self.arrayCellKeys=[[NSMutableArray alloc] init];
    
    if (![[PersistentStore getLoginStatus] isEqualToString:@"Worker"]) {
        [self.arrayCellKeys addObject:[Language get:@"Company Name" alter:@"!Company Name"]];
        self.title=[Language get:@"Company Details" alter:@"!Company Details"]  ;
    }
    else
    {
        self.title=[Language get:@"Customer Details" alter:@"!Customer Details"]  ;

    }
    
    [self.arrayCellKeys addObject:[Language get:@"Name" alter:@"!Name"]];
    [self.arrayCellKeys addObject:[Language get:@"Address" alter:@"!Address"]];
    [self.arrayCellKeys addObject:[Language get:@"Contact No." alter:@"!Contact No."]];
    [self.arrayCellKeys addObject:[Language get:@"Map" alter:@"!Map"]];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerClass:[CustomGPSMapCell class] forCellReuseIdentifier:MapCellIdentifier];
    
    self.tableView.backgroundColor=[UIColor clearColor];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"Memory Warning just came");
    
    // Dispose of any resources that can be recreated.
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
        return [self.arrayCustomer count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row==[self.arrayCustomer count]-1)
    {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MapCellIdentifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MapCellIdentifier];
        }
       
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        
        UILabel  *labelKey = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 80, 25)];
        labelKey.textAlignment=NSTextAlignmentLeft;
        labelKey.text=[Language get:@"Map" alter:@"!Map"];
        labelKey.textColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
        labelKey.font=[UIFont systemFontOfSize:12];
        [cell.contentView addSubview:labelKey] ;

        
        MKMapView   *mapView=[[MKMapView alloc]initWithFrame:CGRectMake(60,25, 200, 200)];
        mapView.layer.borderColor=[[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] CGColor];
        mapView.layer.borderWidth=1.0;
        mapView.delegate=self;
        [cell.contentView addSubview:mapView];
        
       
        CLLocationCoordinate2D location;
        location.latitude=[self.dictCustomer[@"lat"] doubleValue];
        location.longitude=[self.dictCustomer[@"log"] doubleValue];
        
        MKCoordinateSpan spanObj;
        spanObj.latitudeDelta=0.2;
        spanObj.longitudeDelta=0.2;
        
        MKCoordinateRegion region;
        region.center=location;
        region.span=spanObj;
        
        [mapView setZoomEnabled:YES];
        [mapView setScrollEnabled:YES];
        [mapView setRegion:region animated:YES];
        [mapView regionThatFits:region];
        
        Annotation *annotation=[[Annotation alloc] init];
        annotation.title=self.dictCustomer[@"cust_name"];
        annotation.coordinate=region.center;
        
        [mapView addAnnotation:annotation];

        
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;

        
        
        
        return cell;

    }
    else
    {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
     cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.textLabel.text=self.arrayCellKeys[indexPath.row];
    cell.textLabel.textColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
    cell.textLabel.font=[UIFont systemFontOfSize:12];
    cell.detailTextLabel.text=self.arrayCustomer[indexPath.row] ;
    cell.detailTextLabel.font=[UIFont systemFontOfSize:15];
    
    
    if ((indexPath.row==2 && [[PersistentStore getLoginStatus] isEqualToString:@"Worker"])  || (indexPath.row==3 && ![[PersistentStore getLoginStatus] isEqualToString:@"Worker"]))
    {
        UIButton *btnAccessory=[UIButton buttonWithType:UIButtonTypeCustom];
        btnAccessory.frame=CGRectMake(0, 0, 30, 30);
        [btnAccessory setBackgroundImage:[UIImage imageNamed:@"Call.png"] forState:UIControlStateNormal];
        [btnAccessory addTarget:self action:@selector(Call) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView=btnAccessory;
    }
    else
        cell.accessoryView=nil;
    
    return cell;
    }
    
    
}

-(void)Call
{
    
    
    
    
    NSString *strPhone=[NSString stringWithFormat:@"telprompt://%@",self.dictCustomer[@"contact"]];
    UIDevice *device=[UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"]) {
        NSURL *url=[NSURL URLWithString:strPhone];
        if ([strPhone isEqualToString:@"telprompt://"]) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Phone number does not exist." alter:@"!Phone number does not exist."]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        else
            [[UIApplication sharedApplication] openURL:url];
    }
    else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Your device doesn't support this feature." alter:@"!Your device doesn't support this feature."]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
}


-(NSArray *)arrayCustomer
{
    if (!_arrayCustomer)
    {
        NSError *error;
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
        [postDict setObject:self.stringProjectId forKey:@"project_id"];
        
        if (APP_DELEGATE.isServerReachable) {
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])?URL_CUSTOMER_DETAIL:URL_COMPANY_DETAIL]];
        
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
                     
                 }
                 else
                 {
                     self.dictCustomer=object[@"data"][0];
                     
                     
                     NSMutableArray *arrayDetail=[NSMutableArray new];
                     
                     
                     NSString *str1=[self.dictCustomer[@"address"] stringByConvertingHTMLToPlainText];
                     NSString *str2=[self.dictCustomer[@"city"] stringByConvertingHTMLToPlainText];
                     NSString *str3=[self.dictCustomer[@"state"] stringByConvertingHTMLToPlainText];
                     NSString *str4=[self.dictCustomer[@"country"] stringByConvertingHTMLToPlainText];
                     
                     
                     if (![[PersistentStore getLoginStatus] isEqualToString:@"Worker"]) {
                         [arrayDetail addObject:[self.dictCustomer[@"com_name"] stringByConvertingHTMLToPlainText]];

                     }
                     NSMutableString *address = [NSMutableString string];
                     if ([str1 length]>0) {
                         [address appendString:str1];
                         [address appendString:@", "];
                     }
                     if ([str2 length]>0) {
                         [address appendString:str2];
                         [address appendString:@", "];
                     }
                     if ([str3 length]>0) {
                         [address appendString:str3];
                         [address appendString:@", "];
                     }
                     if ([str4 length]>0) {
                         [address appendString:str4];
                     }
                     if (![str2 length] && ![str3 length] && ![str4 length]) {
                         address = nil;
                         address = [NSMutableString string];
                         if ([str1 length]>0) {
                             [address appendString:str1];
                         }
                     }
                     if([address length]>0)
                     [address appendString:@"."];

                     [arrayDetail addObject:[self.dictCustomer[@"cust_name"] stringByConvertingHTMLToPlainText]];
                     [arrayDetail addObject:address];
                     [arrayDetail addObject:[self.dictCustomer[@"contact"] stringByConvertingHTMLToPlainText]];
                     [arrayDetail addObject:@""];

                     
                     
                     
                    


                     
                                          
//                      NSArray *arrayDetails=[[NSArray alloc] initWithObjects:[self.dictCustomer[@"cust_name"] stringByConvertingHTMLToPlainText],[NSString stringWithFormat:@"%@, %@, %@, %@.",str1,str2,str3,str4],[self.dictCustomer[@"contact"] stringByConvertingHTMLToPlainText],@" ", nil];
                     
                    
                     self.arrayCustomer=arrayDetail;
                     [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
                     arrayDetail=nil;
                     
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
    return _arrayCustomer;
    
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


-(void)refreshTable
{
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [self.tableView reloadData];
    [self hideLoadingView];
}




@end
