//
//  WorkPlanVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/19/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "WorkPlanVC.h"
#import "MBProgressHUD.h"
#import "Language.h"
#import "MaterialDetailsTVC.h"
#import "TaskDetailsTVC.h"
#import "NSString+HTML.h"
#import "TraingleView.h"
#import "AddTaskTVC.h"
#import "PersistentStore.h"

@interface WorkPlanVC ()

@end

@implementation WorkPlanVC


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  44.0;
}

-(void)showLoadingView
{
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = YES;
    hud.labelText = @"Loading...";
    hud.dimBackground = YES;
}

-(void)refreshTable
{
    
   // total_per_project
    self.progressView.progress = [self.strProjectComplete floatValue]/100.0;
    self.lblProgressView.text=[NSString stringWithFormat:@"%d %%", [self.strProjectComplete intValue]];
    
    [self.tableView reloadData];
    [self hideLoadingView];
    
}


-(void)hideLoadingView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}




-(void)postRequestProjectWorkPlan
{
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:self.stringProjectId forKey:@"project_id"];
    if (APP_DELEGATE.isServerReachable) {
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PROJECT_WorkPlan]];
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
             if ([object[@"CODE"] intValue])
             {
                 // [self performSelectorOnMainThread:@selector(alertLoginFailed) withObject:nil waitUntilDone:YES];
             }
             else
             {
                 NSMutableArray *objEvents=object[@"data"];
                 self.strProjectComplete=object[@"total_per_project"];
                 NSMutableArray *records = [@[] mutableCopy];
                 records=objEvents;
                 self.arrayWork=records;

             }
         }
         [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];

     }];
    }
    else
    {
        [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }

}







- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"View frame is: %@", NSStringFromCGRect(self.view.bounds));
    
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        UIBarButtonItem *cameraItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTask)];
        self.navigationItem.rightBarButtonItem = cameraItem;
    }
    
    
    
  
    
    
    self.arrayIndexExpandedSections=[[NSMutableArray alloc] init];
    
    
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    // progressView.frame=CGRectMake(20, 28, 280, 2);
    CGRect frame=self.progressView.frame;
    frame.origin.x=25;
    frame.origin.y=22;
    frame.size.width=220.0;
    self.progressView.frame=frame;
    // progressView.center = cell.center;
    self.progressView.progress = 0.0f;
    [view addSubview:self.progressView];
    
    
   
    
    
    self.lblProgressView=[[UILabel alloc] initWithFrame:CGRectMake(260, 10, 44, 25)];
    self.lblProgressView.text=@"0 %";
    self.lblProgressView.backgroundColor=[UIColor clearColor];
    [view addSubview:self.lblProgressView];
    
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor=[UIColor whiteColor];
    button.layer.borderColor=[[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] CGColor];
    button.layer.borderWidth=1.0;
    button.layer.cornerRadius=4.0;
    
    button.frame=CGRectMake(10,45,300, 40);
    button.titleLabel.font = [UIFont systemFontOfSize:18];
    [button setTitle:[[Language get:@"Material Details" alter:@"!Material Details"] stringByConvertingHTMLToPlainText] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goMaterialLog) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];

    
    
    self.tableView.tableHeaderView = view;
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
   // self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];

  
}


-(void)addTask
{
    AddTaskTVC *addTask=[[AddTaskTVC alloc] init];
    addTask.arraySubProjects = self.arrayWork;
    NSLog(@"%@",self.arrayWork);
    
    [self.navigationController pushViewController:addTask animated:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
   self.title=[Language get:@"Work Plan" alter:@"!Work Plan"];
      [self showLoadingView];
    
    [self postRequestProjectWorkPlan];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arrayWork count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor=[UIColor whiteColor];
    button.layer.borderColor=[[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] CGColor];
    button.layer.borderWidth=1.0;
    button.layer.cornerRadius=2.0;

    button.frame=CGRectMake(10,2, 300, 40);
    button.titleLabel.font = [UIFont systemFontOfSize:18];
    [button setTitle:[self.arrayWork[section][@"head_name"] stringByConvertingHTMLToPlainText] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(expandSection:) forControlEvents:UIControlEventTouchUpInside];
    button.tag=100+section;
    [view addSubview:button];
    
    
   if ([self.arrayWork[section][@"task"] count])
    {
        int flag=0;
        for (NSString *str in self.arrayIndexExpandedSections)
        {
            if ([str isEqualToString:[NSString stringWithFormat:@"%ld",100 + section]])
            {
                flag=1;
            }
        }
        if (flag)
        {
            
            TraingleView *traingle=[[TraingleView alloc] initWithFrame:CGRectMake(12, 12, 16, 16)];
            traingle.backgroundColor=[UIColor clearColor];
            traingle.shapeType=kShapeOpen;
            [button addSubview:traingle];
        }
        else
        {
            
            TraingleView *traingle=[[TraingleView alloc] initWithFrame:CGRectMake(12, 12, 16, 16)];
            traingle.backgroundColor=[UIColor clearColor];
            traingle.shapeType=kShapeClose;
            [button addSubview:traingle];
        }
        
        if (![self.arrayWork[section][@"unreadmsg"] intValue])
        {
            UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(260, 17, 24, 16)];
            imageView.image=[UIImage imageNamed:@"imageUnreadMsg@2x.png"];
            [view addSubview:imageView];
            
        }
}

    return view;
}






-(void)expandSection:(id)sender
{
    
        int flag=0;
        
        for (NSString *str in self.arrayIndexExpandedSections)
        {
            if ([str isEqualToString:[NSString stringWithFormat:@"%ld",(long)[sender tag]]])
            {
                flag=1;
            }
        }
        if (flag)
        {
           [self.arrayIndexExpandedSections removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
        }
        else
        {
             [self.arrayIndexExpandedSections addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
        }
    
        [self.tableView reloadData];
        
        
        NSLog(@"Expand section %@",self.arrayIndexExpandedSections);
    
    
}



-(void)goMaterialLog
{
   MaterialDetailsTVC *materialDetailsTVC=[[MaterialDetailsTVC alloc] init];
   materialDetailsTVC.arrayMaterial=self.arrayWork;
   [self.navigationController pushViewController:materialDetailsTVC animated:YES];
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
        int flag=0;
        for (NSString *str in self.arrayIndexExpandedSections)
        {
            if ([str isEqualToString:[NSString stringWithFormat:@"%ld",100+section]])
            {
                flag=1;
            }
        }
        if (flag)
        {
           return [self.arrayWork[section][@"task"] count];
        }
        else
        {
           return 0;
        }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"std"];
        
        
        // 1: To provide feedback to the user, create a UIActivityIndicatorView and set it as the cellís accessory view.
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text=[self.arrayWork[indexPath.section][@"task"][indexPath.row][@"task_name"]  stringByConvertingHTMLToPlainText];
    
    if (![self.arrayWork[indexPath.section][@"task"][indexPath.row][@"unreadmsg"] intValue])
    {
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 16)];
        imageView.image=[UIImage imageNamed:@"imageUnreadMsg@2x.png"];
        cell.accessoryView=imageView;
    }
    else if ([self.arrayWork[indexPath.section][@"task"][indexPath.row][@"per_of_complete"] intValue]==100)
    {
    cell.accessoryView=nil;
    cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    else
    {
    cell.accessoryView=nil;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    return cell;
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *dict= self.arrayWork[indexPath.section][@"task"][indexPath.row];
    
    TaskDetailsTVC *taskDetailTVC=[[TaskDetailsTVC alloc] init];
    taskDetailTVC.dictTaskDetail=dict;
    taskDetailTVC.strHead=[self.arrayWork[indexPath.section][@"head_name"] stringByConvertingHTMLToPlainText];
    taskDetailTVC.stringProjectId=self.arrayWork[indexPath.section][@"project_id"];
    taskDetailTVC.stringHeadId=self.arrayWork[indexPath.section][@"head_id"];
    [self.navigationController pushViewController:taskDetailTVC animated:YES];
    
    
}

@end
