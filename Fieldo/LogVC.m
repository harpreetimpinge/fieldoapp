//
//  LogVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 10/30/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//



#import "LogVC.h"
#import "CustomPickerCell.h"
#import "TimeLogVC.h"
#import "TravelExpenseVC.h"
#import "MaterialExpenseVC.h"
#import "ProjectReportTVC.h"
#import "MBProgressHUD.h"
#import "Language.h"
#import "PersistentStore.h"
#import "NSString+HTML.h"
#import "ediViewController.h"

#import "AppDelegate.h"

#define kPickerTag    99

static ProjectRecord *record=nil;

static NSString *kProjectCellID = @"projectCell";     // the cells with the start or end date
static NSString *kPickerID = @"projectPicker"; // the cell containing the date picker

@interface LogVC ()

@property (assign) NSInteger pickerCellRowHeight;
@property (nonatomic, strong) NSIndexPath *pickerIndexPath;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *dataArray2;

@end

@implementation LogVC

+(void)sendValue:(ProjectRecord *)projectRecord
{
    record=projectRecord;
}

-(void)showLoadingView
{
    //self.tableView.hidden=YES;
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = YES;
    hud.labelText = @"Loading...";
    hud.dimBackground = YES;
}


-(void)hideLoadingView
{
    [self redesign];

    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.tableView reloadData];
    //self.tableView.hidden=NO;
}








- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
       
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.arrayIcons = [[NSMutableArray alloc] initWithObjects:@"Timelog.png",@"TravelLog.png",@"MaterialLog.png",@"ProjectReport.png",@"ProjectReport.png", nil];
    
    self.tableView.rowHeight=50;
    self.pickerCellRowHeight =216;
    self.navigationController.navigationBar.translucent=NO;
    
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell2"];
    [self.tableView registerClass:[CustomPickerCell class] forCellReuseIdentifier:@"kPickerID"];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    if (APP_DELEGATE.checkLogView == YES){
        
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:self.navigationItem.backBarButtonItem.style target:self action:@selector(backButton)];
//        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Arrow.png"] style:self.navigationItem.backBarButtonItem.style target:self action:@selector(backButton)];
//        leftButton.title = @"Back";
        self.navigationItem.leftBarButtonItem = leftButton;
        
    }else{
    
        self.navigationItem.leftBarButtonItem = nil;
    
    }
    
//    NSMutableDictionary *itemOne =   [@ { kTitleKey :[Language get:@"Project:" alter:@"!Project:"] ,kValueKey :@"0" } mutableCopy];
//    NSMutableDictionary *itemTwo =   [@ { kTitleKey :[Language get:@"Time Log" alter:@"!Time Log"]  } mutableCopy];
//    NSMutableDictionary *itemThree = [@ { kTitleKey :[Language get:@"Travel Log" alter:@"!Travel Log"] } mutableCopy];
//    NSMutableDictionary *itemFour =  [@ { kTitleKey :[Language get:@"Material Log" alter:@"!Material Log"]  } mutableCopy];
//    NSMutableDictionary *itemFive =  [@ { kTitleKey :[Language get:@"Project Report" alter:@"!Project Report"]  } mutableCopy];
//    
//    self.navigationItem.title= [Language get:@"Log" alter:@"!Log"];

    if ([[PersistentStore getFlagLog] isEqualToString:@"YES"])
    {
//        if ([self.dataArray count] || [self.dataArray2 count])
//        {
//            [self.dataArray removeAllObjects];
//            self.dataArray=nil;
//            
//            [self.dataArray2 removeAllObjects];
//            self.dataArray2=nil;
//        }
//        self.dataArray = [[NSMutableArray alloc] initWithObjects:itemOne,nil];
//        self.dataArray2 = [[NSMutableArray alloc] initWithObjects:itemTwo,itemThree,itemFour,itemFive,nil];

        [self postRequestWorkersProjects];
        
        
    }
    

    
}
-(void)backButton{
    
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.mainMenuVC.btnProject setBackgroundImage:[UIImage imageNamed:@"SelectedTop"] forState:UIControlStateNormal];
    [appDelegate.mainMenuVC.btnProject setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [appDelegate.mainMenuVC.btnCalOrRating setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
    [appDelegate.mainMenuVC.btnCalOrRating setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
    
    [appDelegate.mainMenuVC.btnLogOrInvoice setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
    [appDelegate.mainMenuVC.btnLogOrInvoice setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
    
    [appDelegate.mainMenuVC.btnHome setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
    [appDelegate.mainMenuVC.btnHome setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
    
    
    NSLog(@"%@",appDelegate.mainMenuVC.contentView);
    if([appDelegate.mainMenuVC.contentView.subviews count] == 1)
    {
        [[appDelegate.mainMenuVC.contentView.subviews objectAtIndex:0] removeFromSuperview];
    }
    UIViewController* controller = (UIViewController*)[appDelegate.mainMenuVC.childViewControllers objectAtIndex:0];
    controller.view.frame = appDelegate.mainMenuVC.contentView.bounds;
    [appDelegate.mainMenuVC.contentView addSubview:controller.view];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"ProjectName"];
}

-(void)redesign
{
    
    NSMutableDictionary *itemOne =   [@ { kTitleKey :[Language get:@"Project:" alter:@"!Project:"] ,kValueKey :@"0" } mutableCopy];
    NSMutableDictionary *itemTwo =   [@ { kTitleKey :[Language get:@"Time Log" alter:@"!Time Log"]  } mutableCopy];
    NSMutableDictionary *itemThree = [@ { kTitleKey :[Language get:@"Travel Log" alter:@"!Travel Log"] } mutableCopy];
    NSMutableDictionary *itemFour =  [@ { kTitleKey :[Language get:@"Material Log" alter:@"!Material Log"]  } mutableCopy];
    NSMutableDictionary *itemFive =  [@ { kTitleKey :[Language get:@"Project Report" alter:@"!Project Report"]  } mutableCopy];
    NSMutableDictionary *itemSix=  [@ { kTitleKey :[Language get:@"EDI" alter:@"!EDI"]  } mutableCopy];

    self.navigationItem.title= [Language get:@"Log" alter:@"!Log"];
    
    if ([[PersistentStore getFlagLog] isEqualToString:@"YES"])
    {
        if ([self.dataArray count] || [self.dataArray2 count])
        {
            [self.dataArray removeAllObjects];
            self.dataArray=nil;
            
            [self.dataArray2 removeAllObjects];
            self.dataArray2=nil;
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *firstName = [defaults objectForKey:@"ProjectName"];
        if (![firstName isEqualToString:@""]) {
            NSPredicate *predicate=[NSPredicate predicateWithFormat:@"SELF.projectName  MATCHES %@",firstName];
            NSArray *tempArray=[self.arrayProjects filteredArrayUsingPredicate:predicate];
            if(tempArray.count>0)
            {
                NSInteger index=[self.arrayProjects indexOfObject:[tempArray objectAtIndex:0]];
                itemOne=   [@ { kTitleKey :[Language get:@"Project:" alter:@"!Project:"] ,kValueKey :[NSString stringWithFormat:@"%ld",(long)index] } mutableCopy];
            }
        }
        
        self.dataArray = [[NSMutableArray alloc] initWithObjects:itemOne,nil];
        self.dataArray2 = [[NSMutableArray alloc] initWithObjects:itemTwo,itemThree,itemFour,itemSix,itemFive,nil];
        
    }

   
}

#pragma mark - Table view data source
#pragma mark - Utilities
- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasDatePicker = NO;
    
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkDatePickerCell =
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];
    UIPickerView *checkDatePicker = (UIPickerView *)[checkDatePickerCell viewWithTag:kPickerTag];
    
    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}

// Updates the UIDatePicker's value to match with the date of the cell above it.
- (void)updateDatePicker
{
    if (self.pickerIndexPath != nil)
    {
        
        UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.pickerIndexPath];
        UIPickerView *targetedDatePicker = (UIPickerView *)[associatedDatePickerCell viewWithTag:kPickerTag];
        if (targetedDatePicker != nil)
        {
            NSDictionary *itemData = self.dataArray[self.pickerIndexPath.row - 1];
            [targetedDatePicker selectRow:[itemData[kValueKey] intValue]  inComponent:0 animated:YES];
        }
    }
}

// Determines if the UITableViewController has a UIDatePicker in any of its cells.
- (BOOL)hasInlineDatePicker
{
    return (self.pickerIndexPath != nil);
}

// Determines if the given indexPath points to a cell that contains the UIDatePicker.
// @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return ([self hasInlineDatePicker] && self.pickerIndexPath.row == indexPath.row  && indexPath.section==0);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}




#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self indexPathHasPicker:indexPath] ? self.pickerCellRowHeight : self.tableView.rowHeight);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
    {
        if ([self hasInlineDatePicker])
            return [self.dataArray count]+1;
        return [self.dataArray count];
    }
    return [self.dataArray2 count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger modelRow = indexPath.row;
    if (self.pickerIndexPath != nil && self.pickerIndexPath.row < indexPath.row)
    {
        modelRow--;
    }
    
    if ([self indexPathHasPicker:indexPath])
    {
            CustomPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:kPickerID];
            if (cell == nil)
            {
                cell = [[CustomPickerCell alloc]
                        initWithStyle:UITableViewCellStyleDefault
                        reuseIdentifier:kPickerID];
            }
        cell.backgroundColor=[UIColor clearColor];
            [cell.pickerView setDelegate:self];
            cell.pickerView.tag=kPickerTag;
            return cell;
            
    }
    else if(indexPath.row==0  && indexPath.section==0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kProjectCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kProjectCellID];
        }
        NSDictionary *itemData = self.dataArray[modelRow];

        ProjectRecord *project=self.arrayProjects[[itemData[kValueKey] intValue]];
        cell.textLabel.text = itemData[kTitleKey];
        
        if (project.projectId.length == 0 || project.projectName.length == 0) {
            cell.detailTextLabel.text = @"";
        }else{
            cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@] %@",project.projectId,[project.projectName stringByConvertingHTMLToPlainText]];
        }
        
        
//        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else
    {
        static NSString *CellIdentifier2 = @"Cell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
        if (!cell)
        {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            // 1: To provide feedback to the user, create a UIActivityIndicatorView and set it as the cellís accessory view.
        }
        
        NSDictionary *itemData = self.dataArray2[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.backgroundColor=[UIColor clearColor];
        cell.textLabel.text = [itemData valueForKey:kTitleKey];
        cell.imageView.frame  = CGRectMake(0, 0, 40, 40);
        cell.imageView.image=[UIImage imageNamed:self.arrayIcons[indexPath.row]];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        return cell;
            
    }
    
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (!section)
        return [Language get:@"Scroll to Pick Project, Tap again" alter:@"!Scroll to Pick Project, Tap again" ];
    return @"";
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.arrayProjects count];
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    ProjectRecord *project=self.arrayProjects[row];
    return [project.projectName stringByConvertingHTMLToPlainText]  ;
}



-(void)postRequestWorkersProjects
{
    [self showLoadingView];
    
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
    
    if (APP_DELEGATE.isServerReachable) {
   
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PROJECTS_LIST]];
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
                 [[[UIAlertView alloc] initWithTitle:@"Projects" message:[Language get:@"No Projects yet." alter:@"!No Projects yet."]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

                 // [self performSelectorOnMainThread:@selector(alertLoginFailed) withObject:nil waitUntilDone:YES];
             }
             else
             {
                 NSMutableArray *objEvents=object[@"data"];
                 NSMutableArray *records = [@[] mutableCopy];
                 for(NSMutableDictionary *objEvent in objEvents)
                 {
                     @autoreleasepool
                     {
                         ProjectRecord *project=[[ProjectRecord alloc] init];
                         project.projectId=objEvent[@"project_id"];
                         project.projectName=objEvent[@"title"];
                         project.projectImageURL=[NSURL URLWithString:objEvent[@"file_name"]];
                         [records addObject:project];
                         project=nil;
                         
                     }
                     
                 }
                 self.arrayProjects=records;

                 [self performSelectorOnMainThread:@selector(hideLoadingView) withObject:nil waitUntilDone:YES];

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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [self performSelectorOnMainThread:@selector(hideLoadingView) withObject:nil waitUntilDone:YES];
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mainMenuVC.menuView.hidden=NO;
    appDelegate.mainMenuVC.buttonAdvertise.hidden=YES;
    
    NSLog(@"%lu",(unsigned long)[appDelegate.mainMenuVC.contentView.subviews count]);
    
    if([appDelegate.mainMenuVC.contentView.subviews count] == 1)
    {
        [[appDelegate.mainMenuVC.contentView.subviews objectAtIndex:0] removeFromSuperview];
    }
    UIViewController* controller = (UIViewController*)[appDelegate.mainMenuVC.childViewControllers objectAtIndex:3];
    controller.view.frame = appDelegate.mainMenuVC.contentView.bounds;
    [appDelegate.mainMenuVC.contentView addSubview:controller.view];
    
}






- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display the date picker inline with the table content
    [self.tableView beginUpdates];
    
    BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
    if ([self hasInlineDatePicker])
    {
        before = self.pickerIndexPath.row < indexPath.row;
    }
    
    BOOL sameCellClicked = (self.pickerIndexPath.row - 1 == indexPath.row);
    
    // remove any date picker cell if it exists
    if ([self hasInlineDatePicker])
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.pickerIndexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.pickerIndexPath = nil;
    }
    
    if (!sameCellClicked)
    {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:0];
        NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0]];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        self.pickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0];
    }
    
    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
    
    // inform our date picker of the current date to match the current cell
    [self updateDatePicker];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row==0 && indexPath.section==0)
    {
        if(_shouldSelectProjectBtn)
            [self displayInlineDatePickerForRowAtIndexPath:indexPath];
        
        return;
        
    }

       
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.reuseIdentifier == kPickerID)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
 
    
    
    
    if ([self hasInlineDatePicker])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Please select project." alter:@"!Please select project."]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
   
    NSDictionary *item=self.dataArray[0];
    ProjectRecord *project=self.arrayProjects[[item[kValueKey] intValue]];

    
    if (indexPath.section)
    {
        if(indexPath.row==0 )
        {
            TimeLogVC *timeLogVC=[[TimeLogVC alloc] init];
            timeLogVC.stringProjectId=project.projectId;
            [self.navigationController pushViewController:timeLogVC animated:YES];
            [PersistentStore setFlagLog:@"NO"];
        }
        else if(indexPath.row==1)
        {
            TravelExpenseVC *travelExpenseVC=[[TravelExpenseVC alloc] initWithNibName:nil bundle:nil];
            travelExpenseVC.stringProjectId=project.projectId;
            [self.navigationController pushViewController:travelExpenseVC animated:YES];
            [PersistentStore setFlagLog:@"NO"];
        }
        else if(indexPath.row==2 )
        {
            MaterialExpenseVC *materialExpenseVC=[[MaterialExpenseVC alloc] initWithNibName:nil bundle:nil];
            materialExpenseVC.stringProjectId=project.projectId;
            [self.navigationController pushViewController:materialExpenseVC animated:YES];
            [PersistentStore setFlagLog:@"NO"];
        }
        else if(indexPath.row==3)
        {
            ediViewController *projectReportTVC=[[ediViewController alloc] initWithNibName:@"ediViewController" bundle:nil];
            projectReportTVC.projectId=project.projectId;
            projectReportTVC.projectName=project.projectName;
            [self.navigationController pushViewController:projectReportTVC animated:YES];
            [PersistentStore setFlagLog:@"NO"];
        }
        
        else if(indexPath.row==4)
        {
            ProjectReportTVC *projectReportTVC=[[ProjectReportTVC alloc] initWithNibName:nil bundle:nil];
            projectReportTVC.stringProjectId=project.projectId;
            projectReportTVC.stringWorkerId=[PersistentStore getWorkerID];
            [self.navigationController pushViewController:projectReportTVC animated:YES];
            [PersistentStore setFlagLog:@"NO"];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        

    }
        
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    
    // update our data model
    ProjectRecord *project = self.arrayProjects[row];
    
    NSMutableDictionary *itemData = self.dataArray[0];
    [itemData setValue:[NSString stringWithFormat:@"%ld", (long)row] forKey:kValueKey];
    
    // update the cell's date string
    cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@] %@",project.projectId,[project.projectName stringByConvertingHTMLToPlainText]];
    
   // m_ProjectName=project.projectName;
   // m_ProjectId=project.projectId;
  //  [self RemovePickerios7];
    
}

-(void)RemovePickerios7
{
    [self.tableView beginUpdates];
    if ([self hasInlineDatePicker])
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.pickerIndexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.pickerIndexPath = nil;
    }
    [self.tableView endUpdates];
}












@end

