//
//  WorkerDetailTVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 3/21/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "WorkerDetailTVC.h"
#import "MBProgressHUD.h"
#import "Language.h"
#import "PersistentStore.h"
#import "NSString+HTML.h"
#import "Helper.h"

#import "AppDelegate.h"


static NSString *CellIdentifier=@"Cell";
@interface WorkerDetailTVC ()

@end

@implementation WorkerDetailTVC

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
    self.title=[Language get:@"Profile" alter:@"!Profile"];
    
    [self showLoadingView];
    
    
    
         self.arrayCellKeys=[[NSMutableArray alloc] init];
        [self.arrayCellKeys addObject:[Language get:@"Skill Set" alter:@"!Skill Set"]];
        [self.arrayCellKeys addObject:[Language get:@"Email" alter:@"!Email"]];
        [self.arrayCellKeys addObject:[Language get:@"Contact No." alter:@"!Contact No."]];
        [self.arrayCellKeys addObject:[Language get:@"Address" alter:@"!Address"]];
        [self.arrayCellKeys addObject:[Language get:@"City" alter:@"!City"]];
        [self.arrayCellKeys addObject:[Language get:@"State" alter:@"!State"]];
        [self.arrayCellKeys addObject:[Language get:@"Country" alter:@"!Country"]];
        [self.arrayCellKeys addObject:[Language get:@"Zip" alter:@"!Zip"]];
    
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    
    
    
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.frame=CGRectMake(15, 10, 70, 70);
    
    [view addSubview:self.activityIndicatorView];
    
    
    self.imageViewHeader=[[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 70, 70)];
    self.imageViewHeader.image=[Helper maskImage:self.image withMask:[UIImage imageNamed:@"Mask1.png"]];
    self.imageViewHeader.layer.cornerRadius = 35;
    self.imageViewHeader.layer.masksToBounds = YES;
    self.imageViewHeader.layer.borderColor=[UIColor blackColor].CGColor;
    
    self.textLabelHeader = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 210, 30)];
    self.textLabelHeader.font=[UIFont boldSystemFontOfSize:18];
    [view addSubview:self.textLabelHeader];
    
    self.detailTextLabelHeader = [[UILabel alloc] initWithFrame:CGRectMake(100,40, 210, 30)];
    self.detailTextLabelHeader.textColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
    self.detailTextLabelHeader.font = [UIFont systemFontOfSize:12];
    [view addSubview:self.detailTextLabelHeader];
    
    
    
    
    [view addSubview:self.imageViewHeader];
    
    self.tableView.tableHeaderView = view;
    
    
    [self FetchWorkerDetails];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source







- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}






- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayProfile count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    
    
    cell.textLabel.text=self.arrayCellKeys[indexPath.row];
    cell.textLabel.textColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
    cell.textLabel.font=[UIFont systemFontOfSize:10];
    cell.detailTextLabel.text=[self.arrayProfile[indexPath.row] stringByConvertingHTMLToPlainText];
    cell.detailTextLabel.font=[UIFont systemFontOfSize:14];
    
    if (indexPath.row==2)
    {
        UIButton *btnAccessory=[UIButton buttonWithType:UIButtonTypeCustom];
        btnAccessory.frame=CGRectMake(0, 0, 30, 30);
        [btnAccessory setBackgroundImage:[UIImage imageNamed:@"Call.png"] forState:UIControlStateNormal];
        [btnAccessory addTarget:self action:@selector(Call) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView=btnAccessory;
    }
    else
        cell.accessoryView=nil;
    
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
    
    
    
}

-(void)Call
{
    
    
    NSString *strPhone=[NSString stringWithFormat:@"telprompt://%@",self.dictProfile[@"contact"]];
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


-(void) FetchWorkerDetails
{
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:self.stringWorkerId forKey:@"worker_id"];
    if (APP_DELEGATE.isServerReachable) {
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_Worker_PROFILE]];
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
                 self.dictProfile=object[@"data"];
                 self.stringUrl=object[@"worker_img_url"];
                 self.stringName=self.dictProfile[@"worker_name"];
                 
                 
                 NSArray *arraySkills=self.dictProfile[@"skill"];
                 NSMutableString *stringSkills=[[NSMutableString alloc] init];
                 for (NSString __strong *str in arraySkills)
                 {
                     [stringSkills appendString:[NSString stringWithFormat:@"%@ ",str]];
                 }
                 stringSkills = (NSMutableString *)[stringSkills stringByConvertingHTMLToPlainText];
                 //  self.dictProfile[@"worker_name"],
                 NSString *Adreess=[NSString stringWithFormat:@"%@ %@ %@ %@",self.dictProfile[@"address"],self.dictProfile[@"city"],
                                    self.dictProfile[@"country"],self.dictProfile[@"zip"]];

                 NSMutableArray *arrayDetails=[[NSMutableArray alloc] initWithObjects:stringSkills,self.dictProfile[@"email"],
                                               self.dictProfile[@"contact"],Adreess, nil];
                 self.arrayProfile=arrayDetails;                         [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
                 
                 dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                 dispatch_async(queue, ^
                                {
                                    NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:object[@"worker_img_url"]]];
                                    dispatch_async(dispatch_get_main_queue(), ^
                                                   {
                                                       self.imageViewHeader.image=[UIImage imageWithData:data];
                                                       
                                                       //                                         self.imageViewHeader.image=[Helper maskImage:[UIImage imageWithData:data] withMask:[UIImage imageNamed:@"MaskForImage.png"]]   ;
                                                   });
                                    [self.activityIndicatorView stopAnimating];
                                    
                                });
                 
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
    
    self.textLabelHeader.text=self.stringName;
    self.detailTextLabelHeader.text=self.stringComponyName;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    
    [self.activityIndicatorView startAnimating];
    
    
    [self.tableView reloadData];
    [self hideLoadingView];
}


@end
