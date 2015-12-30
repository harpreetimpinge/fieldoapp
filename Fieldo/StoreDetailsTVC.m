//
//  StoreDetailsTVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/23/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.

#import "StoreDetailsTVC.h"
#import "Language.h"
#import "NSString+HTML.h"

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>


#import "MBProgressHUD.h"

#define CELL_CONTENT_WIDTH 280.0f
#define CELL_CONTENT_MARGIN 10.0f


static NSString *CellIdentifier=@"Cell";
static NSString *MapCellIdentifier=@"mapCell";

@interface StoreDetailsTVC ()

@end

@implementation StoreDetailsTVC

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==[self.arrayStore count]-1)
        return 330.0;
    
    if(indexPath.row==1)
    {
        NSString *text = [self.arrayStore[indexPath.row] stringByConvertingHTMLToPlainText];
        
        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
        
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        CGFloat height = MAX(size.height+20, 44.0f);
        
        return height + (CELL_CONTENT_MARGIN * 2);
    }
    
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
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showLoadingView];
    
    self.arrayCellKeys=[[NSMutableArray alloc] init];
    [self.arrayCellKeys addObject:[Language get:@"Store Url" alter:@"!Store Url"]];
    [self.arrayCellKeys addObject:[Language get:@"Address" alter:@"!Address"]];
    [self.arrayCellKeys addObject:[Language get:@"Account No." alter:@"!Account No."]];
    [self.arrayCellKeys addObject:[Language get:@"Description" alter:@"!Description"]];
    [self.arrayCellKeys addObject:[Language get:@"Map" alter:@"!Map"]];

    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
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
    
    return [self.arrayStore count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row==[self.arrayStore count]-1)
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
        
        
        MKMapView   *mapView=[[MKMapView alloc]initWithFrame:CGRectMake(20,30, 280, 280)];
        mapView.layer.borderColor=[[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] CGColor];
        mapView.layer.borderWidth=1.0;
        mapView.delegate=self;
        [cell.contentView addSubview:mapView];
        
        
        CLLocationCoordinate2D location;
        location.latitude=[self.dictStoreDetail[@"lat"] doubleValue];
        location.longitude=[self.dictStoreDetail[@"log"] doubleValue];
        
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
        annotation.title=self.dictStoreDetail[@"cust_name"];
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
        if(indexPath.row==0)
        {
          
            
            CGRect frame1 = CGRectMake(15, 5, 80, 30);
            UITextField *textField1 = [[UITextField alloc] initWithFrame:frame1];
            textField1.enabled = NO;
            textField1.textColor = [UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
            textField1.font = [UIFont systemFontOfSize:12];
            textField1.text = self.arrayCellKeys[indexPath.row];
            textField1.backgroundColor = [UIColor clearColor];
            
            CGRect frame = CGRectMake(11, 20,320, 30);
            UITextView *textField = [[UITextView alloc] initWithFrame:frame];
            textField.editable = NO;
            textField.font = [UIFont systemFontOfSize:15];
            textField.text = [self.arrayStore[indexPath.row] stringByConvertingHTMLToPlainText];
            textField.backgroundColor = [UIColor clearColor];
           NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:[self.arrayStore[indexPath.row] stringByConvertingHTMLToPlainText]];
            [str addAttribute: NSLinkAttributeName value:[NSURL URLWithString:[self.arrayStore[indexPath.row] stringByConvertingHTMLToPlainText]]  range: NSMakeRange(0, str.length)];
            textField.textColor =[UIColor blackColor];
             textField.attributedText = str;
              textField.dataDetectorTypes = UIDataDetectorTypeLink;
             [cell addSubview:textField];
          [cell addSubview:textField1];
        }
        else
        {
            cell.textLabel.text=self.arrayCellKeys[indexPath.row];
            cell.textLabel.textColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
            cell.textLabel.font=[UIFont systemFontOfSize:12];
        cell.detailTextLabel.text=[self.arrayStore[indexPath.row] stringByConvertingHTMLToPlainText];
        cell.detailTextLabel.font=[UIFont systemFontOfSize:15];
        }
        
        if(indexPath.row==1)
        {
            UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(15, 5, 80, 20)];
            lab.textColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
           lab.font=[UIFont systemFontOfSize:12];
         
            cell.textLabel.text=@"";
          
            lab.text=self.arrayCellKeys[indexPath.row];

            [cell addSubview:lab];
            
            UILabel *addres=[[UILabel alloc] initWithFrame:CGRectMake(15,-20,280, 120)];
         
            addres.numberOfLines = 5;
            
            [addres setLineBreakMode:UILineBreakModeWordWrap];
            
            addres.font=[UIFont systemFontOfSize:15];
            
            cell.detailTextLabel.text=@"";
            
            addres.text=[self.arrayStore[indexPath.row] stringByConvertingHTMLToPlainText];
            
            [cell addSubview:addres];
        }
        return cell;
    }
}




-(IBAction)openLink:(id)sender
{
    
}

-(NSArray *)arrayStore
{
    if (!_arrayStore)
    {
        NSError *error;
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
        [postDict setObject:self.stringStoreId forKey:@"store_id"];
        if (APP_DELEGATE.isServerReachable) {
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_STORE_Detail]];
        
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
             if ([object isKindOfClass:[NSArray class]] == YES)
             {
                 
                self.dictStoreDetail=object[0];
                 
                 
                 NSMutableString *strAddress = [NSMutableString string];
                 if ([self.dictStoreDetail[@"store_location"] length]>0) {
                     [strAddress appendString:self.dictStoreDetail[@"store_location"]];
                      if ([self.dictStoreDetail[@"city"] length]>0)
                     [strAddress appendString:@", "];
                 }
                 if ([self.dictStoreDetail[@"city"] length]>0) {
                     [strAddress appendString:self.dictStoreDetail[@"city"]];
                      if ([self.dictStoreDetail[@"state"] length]>0)
                     [strAddress appendString:@", "];
                 }
                 if ([self.dictStoreDetail[@"state"] length]>0) {
                     [strAddress appendString:self.dictStoreDetail[@"state"]];
                      if ([self.dictStoreDetail[@"country"] length]>0)
                     [strAddress appendString:@", "];
                 }
                 if ([self.dictStoreDetail[@"country"] length]>0) {
                     [strAddress appendString:self.dictStoreDetail[@"country"]];
                 }
                 if (![self.dictStoreDetail[@"city"] length] && ![self.dictStoreDetail[@"state"] length] && ![self.dictStoreDetail[@"country"] length]) {
                     strAddress = nil;
                     strAddress = [NSMutableString string];
                     if ([self.dictStoreDetail[@"store_location"] length]>0) {
                         [strAddress appendString:self.dictStoreDetail[@"store_location"]];
                     }
                 }
                 if([strAddress length]>0)
                     [strAddress appendString:@"."];
     
                 
                 
              //   NSString *strAddress=[NSString stringWithFormat:@"%@,%@,%@,%@",self.dictStoreDetail[@"store_location"],self.dictStoreDetail[@"city"],self.dictStoreDetail[@"state"],self.dictStoreDetail[@"country"]];
                 
                     
                 NSArray *arrayDetails=[[NSArray alloc] initWithObjects:self.dictStoreDetail[@"store_url"],strAddress,self.dictStoreDetail[@"account_name"],self.dictStoreDetail[@"store_description"],@" ", nil];
                 
                     
                     self.arrayStore=arrayDetails;
                     [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
                     
                     
             }
         }];
        }
        else
        {
            [self hideLoadingView];
            [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        }
    }
    return _arrayStore;
    
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


