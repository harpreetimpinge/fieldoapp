//
//  ProjectOptionsVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 10/26/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "ProjectOptionsVC.h"
#import "CustomerDetailsVC.h"
#import "ProjectDetailsTVC.h"
#import "WorkPlanVC.h"
#import "FloorPlanVC.h"
#import "AppDelegate.h"
#import "Language.h"
#import "PersistentStore.h"
#import "NSString+HTML.h"
#import "WorkersTVC.h"
#import "FloorPlanCVC.h"
#import "LogVC.h"

@interface ProjectOptionsVC ()

@end

@implementation ProjectOptionsVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    if (APP_DELEGATE.checkLogView == YES) {
        
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSLog(@"%@",appDelegate.mainMenuVC.contentView);
        
        [appDelegate.mainMenuVC.btnProject setBackgroundImage:[UIImage imageNamed:@"SelectedTop"] forState:UIControlStateNormal];
        [appDelegate.mainMenuVC.btnProject setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [appDelegate.mainMenuVC.btnCalOrRating setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
        [appDelegate.mainMenuVC.btnCalOrRating setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
        
        [appDelegate.mainMenuVC.btnLogOrInvoice setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
        [appDelegate.mainMenuVC.btnLogOrInvoice setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
        
        [appDelegate.mainMenuVC.btnHome setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
        appDelegate.mainMenuVC.btnHome.titleLabel.textColor =[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
        
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  50.0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"View frame is: %@", NSStringFromCGRect(self.view.bounds));
    
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    self.navigationItem.title=[self.currentProject.projectName stringByConvertingHTMLToPlainText];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.arrayProjectDetails=[[NSMutableArray alloc] init];
    self.arrayImages=[[NSMutableArray alloc] init];

    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        [self.arrayProjectDetails addObject:[Language get:@"Customer Details" alter:@"!Customer Details"]];
        [self.arrayProjectDetails addObject:[Language get:@"Project Details" alter:@"!Project Details"]];
        [self.arrayProjectDetails addObject:[Language get:@"Work Plan" alter:@"!Work Plan"]];
        [self.arrayProjectDetails addObject:[Language get:@"Floor Plan" alter:@"!Floor Plan"]];
        [self.arrayProjectDetails addObject:[Language get:@"Log" alter:@"!Log"]];
    }
    else
    {
        [self.arrayProjectDetails addObject:[Language get:@"Company Details" alter:@"!Company Details"]];
        [self.arrayProjectDetails addObject:[Language get:@"Project Details" alter:@"!Project Details"]];
        [self.arrayProjectDetails addObject:[Language get:@"Work Plan" alter:@"!Work Plan"]];
        [self.arrayProjectDetails addObject:[Language get:@"Floor Plan" alter:@"!Floor Plan"]];
        [self.arrayProjectDetails addObject:[Language get:@"Workers" alter:@"!Workers"]];
    }
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        [self.arrayImages addObject:@"CustomerDetails.png"];
        [self.arrayImages addObject:@"ProjectDetails.png"];
        [self.arrayImages addObject:@"WorkPlan.png"];
        [self.arrayImages addObject:@"FloorPlan.png"];
        [self.arrayImages addObject:@"Log.png"];
    }
    else
    {
        [self.arrayImages addObject:@"CompanyDetails.png"];
        [self.arrayImages addObject:@"ProjectDetails.png"];
        [self.arrayImages addObject:@"WorkPlan.png"];
        [self.arrayImages addObject:@"FloorPlan.png"];
        [self.arrayImages addObject:@"Workers.png"];
    }
    
    
                              
                              
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayProjectDetails count];
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
    cell.imageView.image=[UIImage imageNamed:[self.arrayImages objectAtIndex:indexPath.row]];

    cell.textLabel.text=[self.arrayProjectDetails objectAtIndex:indexPath.row];
    // Configure the cell...
    
    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        switch (indexPath.row)
        {
            case 0:
            {
                CustomerDetailsVC *customerDetailsVC=[[CustomerDetailsVC alloc] initWithNibName:nil bundle:nil];
                customerDetailsVC.stringProjectId=self.currentProject.projectId;
                [self.navigationController pushViewController:customerDetailsVC animated:NO];
                break;
            }
                
            case 1:
            {
                
                ProjectDetailsTVC *projectDetailsTVC=[[ProjectDetailsTVC alloc] initWithNibName:nil bundle:nil];
                projectDetailsTVC.stringProjectId=self.currentProject.projectId;
                projectDetailsTVC.stringWorkerId=[PersistentStore getWorkerID];
                [self.navigationController pushViewController:projectDetailsTVC animated:YES];
                break;
                
            }
                
            case 2:
            {
                WorkPlanVC *workPlanVC=[[WorkPlanVC alloc] init];
                workPlanVC.stringProjectId = self.currentProject.projectId;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:self.currentProject.projectName forKey:@"ProjectName"];
                [defaults synchronize];
                [self.navigationController pushViewController:workPlanVC animated:YES];
                break;
                
            }
                
            case 3:
            {
                
                FloorPlanCVC *floorPlanCVC=[[FloorPlanCVC alloc] init];
                floorPlanCVC.stringProjectId=self.currentProject.projectId;
                
                
                [self.navigationController pushViewController:floorPlanCVC animated:YES];
                break;
                
            }
                
            case 4:
            {
                
                
                APP_DELEGATE.checkLogView = YES;
                
                AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                NSLog(@"%@",appDelegate.mainMenuVC.contentView);
                
                [appDelegate.mainMenuVC.btnProject setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
                [appDelegate.mainMenuVC.btnProject setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
                
                [appDelegate.mainMenuVC.btnCalOrRating setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
                [appDelegate.mainMenuVC.btnCalOrRating setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
                
                [appDelegate.mainMenuVC.btnLogOrInvoice setBackgroundImage:[UIImage imageNamed:@"SelectedTop"] forState:UIControlStateNormal];
                [appDelegate.mainMenuVC.btnLogOrInvoice setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                [appDelegate.mainMenuVC.btnHome setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
                appDelegate.mainMenuVC.btnHome.titleLabel.textColor =[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
                
                if([appDelegate.mainMenuVC.contentView.subviews count] == 1)
                {
                    [[appDelegate.mainMenuVC.contentView.subviews objectAtIndex:0] removeFromSuperview];
                }
                
                UIViewController* controller = (UIViewController*)[appDelegate.mainMenuVC.childViewControllers objectAtIndex:2];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:self.currentProject.projectName forKey:@"ProjectName"];
                [defaults synchronize];
                controller.view.frame = appDelegate.mainMenuVC.contentView.bounds;
                
                // Prabhjot
                
                if([controller isKindOfClass:[LogVC class]])
                {
                    LogVC *logVC = (LogVC*)controller;
                    logVC.shouldSelectProjectBtn = NO;
                } else if([controller isKindOfClass:[UINavigationController class]]) {
                    if ([[(UINavigationController*)controller topViewController] isKindOfClass:[LogVC class]]) {
                        LogVC *logVC = (LogVC*)[(UINavigationController*)controller topViewController];
                        logVC.shouldSelectProjectBtn = NO;
                    }
                }
                
                //Stop
                
                [appDelegate.mainMenuVC.contentView addSubview:controller.view];
                
                break;
                
            }
                
            default:
                break;
        }

    }
    else
    {
        switch (indexPath.row)
        {
            case 0:
            {
               
                CustomerDetailsVC *customerDetailsVC=[[CustomerDetailsVC alloc] initWithNibName:nil bundle:nil];
                customerDetailsVC.stringProjectId=self.currentProject.projectId;
                [self.navigationController pushViewController:customerDetailsVC animated:NO];
                break;
            }
                
            case 1:
            {
                ProjectDetailsTVC *projectDetailsTVC=[[ProjectDetailsTVC alloc] initWithNibName:nil bundle:nil];
                projectDetailsTVC.stringProjectId=self.currentProject.projectId;
                projectDetailsTVC.stringWorkerId=[PersistentStore getWorkerID];
                [self.navigationController pushViewController:projectDetailsTVC animated:YES];
                break;
                
            }
                
            case 2:
            {
                WorkPlanVC *workPlanVC=[[WorkPlanVC alloc] initWithNibName:nil bundle:nil];
                workPlanVC.stringProjectId = self.currentProject.projectId;
                [self.navigationController pushViewController:workPlanVC animated:YES];
                break;
                
            }
                
            case 3:
            {
                FloorPlanCVC *floorPlanCVC=[[FloorPlanCVC alloc] initWithNibName:nil bundle:nil];
                floorPlanCVC.stringProjectId=self.currentProject.projectId;
                [self.navigationController pushViewController:floorPlanCVC animated:YES];
                break;               
                
            }
            case 4:
            {
                NSLog(@"workers List");
                WorkersTVC *workersTVC=[[WorkersTVC alloc] initWithNibName:nil bundle:nil];
                workersTVC.stringProjectId=self.currentProject.projectId;
                workersTVC.navigateFrom=@"Project";
                workersTVC.title=[Language get:@"Worker List" alter:@"!Worker List"];
                [self.navigationController pushViewController:workersTVC animated:YES];
               
                break;
                
            }
                
                           
            default:
                break;
        }

    }
    
    
    
}








@end
