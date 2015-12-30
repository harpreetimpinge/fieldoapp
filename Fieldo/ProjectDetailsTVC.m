//
//  ProjectDetailsTVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/23/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "ProjectDetailsTVC.h"
#import "Language.h"
#import "NSString+HTML.h"
#import "MapView.h"
#import "MapRouteViewController.h"
#import "PersistentStore.h"


static NSString *CellIdentifier=@"Cell";
static NSString *MapCellIdentifier=@"mapCell";

@interface ProjectDetailsTVC ()

@end

@implementation ProjectDetailsTVC

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==[self.arrayProject count]-1)
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
       
    NSLog(@"View frame is: %@", NSStringFromCGRect(self.view.bounds));
    [self showLoadingView];
   
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.title=[Language get:@"Project Details" alter:@"!Project Details"]  ;
    self.arrayCellKeys=[[NSMutableArray alloc] init];
    
    [self.arrayCellKeys addObject:[Language get:@"Start Date" alter:@"!Start Date"]];
    [self.arrayCellKeys addObject:[Language get:@"Address" alter:@"!Address"]];
    [self.arrayCellKeys addObject:[Language get:@"Port Code" alter:@"!Port Code"]];
    [self.arrayCellKeys addObject:[Language get:@"Phone" alter:@"!Phone"]];
    if (![[PersistentStore getLoginStatus] isEqualToString:@"Worker"]) {
        [self.arrayCellKeys addObject:[Language get:@"Cost" alter:@"!Cost"]];
    }
    [self.arrayCellKeys addObject:[Language get:@"Project Type" alter:@"!Project Type"]];
    [self.arrayCellKeys addObject:[Language get:@"Comment" alter:@"!Comment"]];
    [self.arrayCellKeys addObject:[Language get:@"Description" alter:@"!Description"]];
    [self.arrayCellKeys addObject:[Language get:@"Map" alter:@"!Map"]];
    
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
    
    return [self.arrayProject count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row==[self.arrayProject count]-1)
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
        
        
        UILabel  *labelKey = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 50, 20)];
        labelKey.textAlignment=NSTextAlignmentLeft;
        labelKey.text=[Language get:@"Map" alter:@"!Map"];
        labelKey.textColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
        labelKey.font=[UIFont systemFontOfSize:12];
        [cell.contentView addSubview:labelKey] ;
        
        
        UIButton *btnRouteMe=[UIButton buttonWithType:UIButtonTypeCustom];
        btnRouteMe.frame=CGRectMake(220, 5, 100, 20);
        [btnRouteMe setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
        btnRouteMe.titleLabel.font = [UIFont systemFontOfSize:12];
        [btnRouteMe setTitle:[Language get:@"Route Me" alter:@"!Route Me"] forState:UIControlStateNormal];
        [btnRouteMe addTarget:self action:@selector(RouteMe:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnRouteMe];

        
        MKMapView   *mapView=[[MKMapView alloc]initWithFrame:CGRectMake(60,25, 200, 200)];
        mapView.layer.borderColor=[[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] CGColor];
        mapView.layer.borderWidth=1.0;
        mapView.delegate=self;
        [cell.contentView addSubview:mapView];
        
        
        CLLocationCoordinate2D location;
        location.latitude=[self.dictProject[@"project_lat"] doubleValue];
        location.longitude=[self.dictProject[@"project_long"] doubleValue];
        
        
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
        annotation.title=self.dictProject[@"location"];
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
        cell.detailTextLabel.text=[self.arrayProject[indexPath.row] stringByConvertingHTMLToPlainText];
        cell.detailTextLabel.font=[UIFont systemFontOfSize:15];
        
        if (indexPath.row==3)
        {
            UIButton *btnAccessory=[UIButton buttonWithType:UIButtonTypeCustom];
            btnAccessory.frame=CGRectMake(0, 0, 30, 30);
            [btnAccessory setBackgroundImage:[UIImage imageNamed:@"Call.png"] forState:UIControlStateNormal];
            [btnAccessory addTarget:self action:@selector(Call) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView=btnAccessory;
        }
        
        return cell;
    }
    
    
}


-(void)RouteMe:(id)sender
{
    NSURL *testURL = [NSURL URLWithString:@"comgooglemaps-x-callback://"];
    if ([[UIApplication sharedApplication] canOpenURL:testURL]) {
        
        NSString *direction=[NSString stringWithFormat:@"comgooglemaps-x-callback://?saddr=%@,%@&daddr=%@,%@&x-success=sourceapp://?resume=true&x-source=AirApp", @"18.9750", @"72.8258", @"23.0300",@"72.5800"];
        NSURL *directionsURL = [NSURL URLWithString:direction];
        [[UIApplication sharedApplication] openURL:directionsURL];
    }
    else {
        
        NSString *direction=[NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@,%@&daddr=%@,%@", @"18.9750", @"72.8258", @"23.0300",@"72.5800"];
//        NSURL *directionsURL = [NSURL URLWithString:direction];
        NSURL* directionsURL = [[NSURL alloc] initWithString:[direction stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:directionsURL];
//        showAlert(AlertTitle, @"You don't have GoogleMaps App on this device. Please install it.");
        //NSLog(@"Can't use comgooglemaps-x-callback:// on this device.");
    }

//    MapRouteViewController *routeMap=[[MapRouteViewController alloc]init];
//    routeMap.dictProject=self.dictProject;
//    [self.navigationController pushViewController:routeMap animated:YES];
    
}

- (CLLocationCoordinate2D)geoCodeUsingAddress :(NSString *)address Status:(NSInteger )sts
{
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    
    CLLocationCoordinate2D center;
    center.latitude = latitude;
    center.longitude = longitude;
    return center;
}




-(void)Call
{
    
    NSString *strPhone=[NSString stringWithFormat:@"telprompt://%@",self.dictProject[@"phone"]];
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


-(NSArray *)arrayProject
{
    if (!_arrayProject)
    {
       
            NSError *error;
            NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
            [postDict setObject:self.stringProjectId forKey:@"project_id"];
        
           if (APP_DELEGATE.isServerReachable) {
            NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
            
            NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PROJECT_DETAIL]];
        
            
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
                         self.dictProject=object[@"data"][0];
                         NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                         [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//                         [dateFormatter setDateFormat:@"dd-MM-yyyy"];
//                         [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                         NSDate *date=[dateFormatter dateFromString:self.dictProject[@"start_date_by_worker"]];
                         NSDateFormatter *dateFormatter2=[[NSDateFormatter alloc] init];
                         [dateFormatter2 setDateFormat:@"dd-MM-YYYY"];
                         
                         NSMutableArray *arrayDetail=[NSMutableArray new];
                         
                         if (date == nil)
                         {
                             NSLog(@"No date");
                             
//                             [arrayDetail addObject:@"0000-00-00"];
                             [arrayDetail addObject:[NSString stringWithFormat:@"This project is in proposal."]];
                         }
                         else
                         {
                             [arrayDetail addObject:[dateFormatter2 stringFromDate:date]];
                         }

//                         [arrayDetail addObject:[self.dictProject[@"start_date_by_worker"] stringByConvertingHTMLToPlainText]];
                         [arrayDetail addObject:[self.dictProject[@"location"] stringByConvertingHTMLToPlainText]];
                         [arrayDetail addObject:[self.dictProject[@"zip"] stringByConvertingHTMLToPlainText]];
                         [arrayDetail addObject:[self.dictProject[@"phone"] stringByConvertingHTMLToPlainText]];
                         
                         
                         if (![[PersistentStore getLoginStatus] isEqualToString:@"Worker"]) {
                             [arrayDetail addObject:[self.dictProject[@"cost"] stringByConvertingHTMLToPlainText]];

                         }
                         NSString *projectType=[self ProjectType:[self.dictProject[@"project_type"]intValue]];
                         [arrayDetail addObject:projectType];
                         [arrayDetail addObject:[self.dictProject valueForKey:@"comment"]];
                         [arrayDetail addObject:[self.dictProject[@"description"] stringByConvertingHTMLToPlainText]];
                         [arrayDetail addObject:@" "];

                         
//                         NSArray *arrayDetails=[[NSArray alloc] initWithObjects:self.dictProject[@"created_at"],self.dictProject[@"location"],self.dictProject[@"zip"],
//                                                self.dictProject[@"phone"],self.dictProject[@"projectType"],@" ", nil];
//                         
                         
                         self.arrayProject=arrayDetail;
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
    return _arrayProject;
    
}

-(NSString *) ProjectType:(NSInteger) value
{
    if (value==0) {
        return [Language get:@"Fixed" alter:@"!Fixed"];
    }
    return [Language get:@"Time" alter:@"!Time"];
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
