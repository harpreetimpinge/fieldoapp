//
//  TimeLogVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/11/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

//
//  MyTable.m
//  Cells
//
//  Created by Gagan Joshi on 11/7/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//
#pragma mark -

#import "TimeLogVC.h"
#import "CustomDatePickerCell.h"
#import "CustomPickerCell.h"
#import "CustomTextViewCell.h"
#import "PersistentStore.h"
#import "MBProgressHUD.h"
#import "Language.h"
#import "NSString+HTML.h"

#import <CoreLocation/CoreLocation.h>
#import "CurrentLocationView.h"

#define kDatePickerTag              99
#define kSimplePickerTag            98

#define kTimeKey     @"time"
#define kLogKey      @"log"

// keep track of which rows have date cells
#define kDateRow        0
#define KStartTimeRow   1
#define KEndTimeRow     2
#define KLogTimeRow     3

static NSString *kDateCellID = @"dateCell";     // the cells with the start or end date
static NSString *kDatePickerID = @"datePicker"; // the cell containing the date picker
static NSString *kOtherCell = @"otherCell";     // the remaining cells at the end
static NSString *kPickerID = @"simplePicker";   // the cell containing the one component picker
static NSString *kTextViewID = @"textView";
static NSString *kButtonID = @"buttonId";


#pragma mark -

@interface TimeLogVC ()<CLLocationManagerDelegate,customTextCellDelegate>{
    CLLocation *SearchedLocation;
    CLLocationManager *locationManager;
}

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (assign) NSInteger pickerCellRowHeight;

// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;
@property (nonatomic, assign) NSInteger pickerRow;




@end


@implementation TimeLogVC

//- (id)init
//{
//    self = [super initWithStyle:UITableViewStyleGrouped];
//    if (self)
//    {
//        
//    }
//    return self;
//}

-(void)goBack
{
    [self hideLoadingView];
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





-(void)hideLoadingView
{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self currentLocation];
    
    self.title=[Language get:@"Time Log" alter:@"!Time Log"];
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];

    [self.tableView registerClass:[CustomDatePickerCell class] forCellReuseIdentifier:kDatePickerID];
    [self.tableView registerClass:[CustomPickerCell class] forCellReuseIdentifier:kPickerID];
    [self.tableView registerClass:[CustomTextViewCell class] forCellReuseIdentifier:kTextViewID];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    // setup our data source
    NSMutableDictionary *itemOne = [@{ kTitleKey :[Language get:@"Date:" alter:@"!Date:"] ,kValueKey : [NSDate date] } mutableCopy];
    NSMutableDictionary *itemTwo = [@{ kTitleKey :[Language get:@"From:" alter:@"!From:"] ,kValueKey : [NSDate date] } mutableCopy];
    NSMutableDictionary *itemThree = [@{ kTitleKey:[Language get:@"To:" alter:@"!To:"] ,kValueKey : [NSDate date] } mutableCopy];
    NSMutableDictionary *itemFour = [@{ kTitleKey : [Language get:@"Type:" alter:@"!Type:"],kValueKey: @"0" } mutableCopy];
    NSMutableDictionary *itemFive = [@{ kTitleKey : [Language get:@"Comments:" alter:@"!Comments:"] } mutableCopy];
    NSMutableDictionary *itemSix = [@{ kTitleKey : @"(other item2)" } mutableCopy];
    
    self.dataArray = @[itemOne, itemTwo, itemThree, itemFour, itemFive,itemSix];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"dd-MM-YYYY"];
    //    [self.dateFormatter setDateStyle:NSDateFormatterLongStyle];    // show short-style date format
    
    // if the local changes while in the background, we need to be notified so we can update the date
    // format in the table view cells
    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localeChanged:)
                                                 name:NSCurrentLocaleDidChangeNotification
                                               object:nil];
    
    
    self.tableView.rowHeight=44;
    self.pickerCellRowHeight =216; //pickerViewCellToCheck.frame.size.height;

}
-(void) viewWillAppear:(BOOL)animated
{
    if (self.arrayLogTime) {
        [self.arrayLogTime removeAllObjects];
        self.arrayLogTime=nil;
    }
    
    self.arrayLogTime=[[NSMutableArray alloc] init];

    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:[PersistentStore getLocalLanguage] forKey:@"lang"];
    
    
    // {"worker_id":"18","project_id":"126","is_to":"09:30","is_from":"10:30","comment":"zyx","date":"2013-11-29","priority":"Uncomfortable time"}';
    if (APP_DELEGATE.isServerReachable) {
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_TIME_LOG_TYPE_OPTIONS]];
        [urlRequest setTimeoutInterval:180];
        NSString *requestBody = [NSString stringWithFormat:@"JsonObject=%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
        [urlRequest setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
        [urlRequest setHTTPMethod:@"POST"];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
             NSLog(@"%@",object);
             if (!error)
             {
                 NSArray *typeArray=object;
                 [self.arrayLogTime addObjectsFromArray:typeArray];
                 
                 [self performSelectorOnMainThread:@selector(ReloadDataOfTable) withObject:nil waitUntilDone:YES];
             }
         }];
    }
    else
    {
        [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }

}

-(void)ReloadDataOfTable
{
    [self.tableView reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSCurrentLocaleDidChangeNotification object:nil];
}

#pragma mark - CLLocation For Current Location
-(void)currentLocation{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    if(IS_OS_8_OR_LATER){
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
#pragma mark -
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Failed to get your location." alter:@"!Failed to get your location."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        SearchedLocation = currentLocation;
        [locationManager stopUpdatingLocation];
        
        if ([[USER_LOGINID valueForKey:@"userLogin"] isEqualToString:@"0"]) {
            CurrentLocationView *currentView = [[CurrentLocationView alloc] init];
            currentView.longitude = [NSString stringWithFormat:@"%f",SearchedLocation.coordinate.longitude];
            currentView.latitude = [NSString stringWithFormat:@"%f",SearchedLocation.coordinate.latitude];
            [currentView userCurrentLocation:self.view];
        }
        
    }
}

#pragma mark - Locale

// Responds to region format or locale changes.
- (void)localeChanged:(NSNotification *)notif
{
    // the user changed the locale (region format) in Settings, so we are notified here to
    // update the date format in the table view cells
    //
    [self.tableView reloadData];
}


#pragma mark - Utilities



// Determines if the given indexPath has a cell below it with a UIDatePicker.
//param indexPath The indexPath to check if its cell has a UIDatePicker below it.
- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasDatePicker = NO;
    
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkDatePickerCell =
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];
    UIDatePicker *checkDatePicker = (UIDatePicker *)[checkDatePickerCell viewWithTag:kDatePickerTag];
    
    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}

// Updates the UIDatePicker's value to match with the date of the cell above it.
- (void)updateDatePicker
{
    if (self.datePickerIndexPath != nil)
    {
        if (self.datePickerIndexPath.row==1)
        {
            UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
            UIDatePicker *targetedDatePicker = (UIDatePicker *)[associatedDatePickerCell viewWithTag:kDatePickerTag];
            if (targetedDatePicker != nil)
            {
                // we found a UIDatePicker in this cell, so update it's date value
                NSDictionary *itemData = self.dataArray[self.datePickerIndexPath.row - 1];
                [targetedDatePicker setDate:[itemData valueForKey:kValueKey] animated:NO];
            }
            
        }
        else if(self.datePickerIndexPath.row==2 ||  self.datePickerIndexPath.row==3)
        {
            UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
            UIDatePicker *targetedDatePicker = (UIDatePicker *)[associatedDatePickerCell viewWithTag:kDatePickerTag];
            if (targetedDatePicker != nil)
            {
                NSDictionary *itemData = self.dataArray[self.datePickerIndexPath.row - 1];
                [targetedDatePicker setDate:[itemData valueForKey:kValueKey] animated:NO];
            }
        }
        else
        {
            UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
            UIPickerView *targetedDatePicker = (UIPickerView *)[associatedDatePickerCell viewWithTag:kSimplePickerTag];
            if (targetedDatePicker != nil)
            {
                // we found a UIDatePicker in this cell, so update it's date value
                NSDictionary *itemData = self.dataArray[self.datePickerIndexPath.row - 1];
                [targetedDatePicker selectRow:[[itemData valueForKey:kValueKey] intValue] inComponent:0 animated:YES];
                // [targetedDatePicker selectRow:self.pickerRow inComponent:0 animated:YES];
            }
        }
        
        
    }
    
    
    
}

// Determines if the UITableViewController has a UIDatePicker in any of its cells.
- (BOOL)hasInlineDatePicker
{
    return (self.datePickerIndexPath != nil);
}

// Determines if the given indexPath points to a cell that contains the UIDatePicker.
// @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return ([self hasInlineDatePicker] && self.datePickerIndexPath.row == indexPath.row);
}

// Determines if the given indexPath points to a cell that contains the start/end dates.
//@param indexPath The indexPath to check if it represents start/end date cell.
- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath
{
    BOOL hasDate = NO;
    
    if ((indexPath.row == kDateRow) ||(indexPath.row == KStartTimeRow) || (indexPath.row == KEndTimeRow) ||
        (indexPath.row == KLogTimeRow || ([self hasInlineDatePicker] && (indexPath.row == KLogTimeRow + 1))))
    {
        hasDate = YES;
    }
    
    return hasDate;
}


//-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    if([text isEqualToString:@"\n"])
//        [textView resignFirstResponder];
//    return YES;
//}


#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self indexPathHasPicker:indexPath])
        return self.pickerCellRowHeight;
    else if ((indexPath.row==[self.dataArray count]-2 && !self.datePickerIndexPath)  || (indexPath.row==[self.dataArray count]-1 && self.datePickerIndexPath))
        return 100;
    else
        return self.tableView.rowHeight;
    
    //return ([self indexPathHasPicker:indexPath] ? self.pickerCellRowHeight : self.tableView.rowHeight);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self hasInlineDatePicker])
    {
        // we have a date picker, so allow for it in the number of rows in this section
        NSInteger numRows = self.dataArray.count;
        return ++numRows;
    }
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger modelRow = indexPath.row;
    if (self.datePickerIndexPath != nil && self.datePickerIndexPath.row < indexPath.row)
    {
        modelRow--;
    }
    NSDictionary *itemData = self.dataArray[modelRow];
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    
    if ([self indexPathHasPicker:indexPath])
    {
        if(self.datePickerIndexPath.row==1)
        {
            CustomDatePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:kDatePickerID];
            if (cell == nil)
            {
                cell = [[CustomDatePickerCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kDatePickerID];
            }
            [cell.cellDatePicker addTarget:self action:@selector(dateAction:) forControlEvents:UIControlEventValueChanged];
            cell.cellDatePicker.date=[NSDate date];
            cell.cellDatePicker.maximumDate=[NSDate date];
            cell.cellDatePicker.tag=99;
            cell.cellDatePicker.datePickerMode=UIDatePickerModeDate;
            
            return cell;
        }
        else if(self.datePickerIndexPath.row==2 || self.datePickerIndexPath.row==3)
        {
            CustomDatePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:kDatePickerID];
            if (cell == nil)
            {
                cell = [[CustomDatePickerCell alloc]
                        initWithStyle:UITableViewCellStyleDefault
                        reuseIdentifier:kDatePickerID];
            }
            [cell.cellDatePicker addTarget:self action:@selector(dateAction:) forControlEvents:UIControlEventValueChanged];
            cell.cellDatePicker.date=[NSDate date];
            cell.cellDatePicker.maximumDate=nil;
            cell.cellDatePicker.tag=99;
            cell.cellDatePicker.datePickerMode=UIDatePickerModeTime;
            return cell;
        }
        else
        {
            static NSString *cellIdentifier = @"cell";
            CustomPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:kPickerID];
            if (cell == nil)
            {
                cell = [[CustomPickerCell alloc]
                        initWithStyle:UITableViewCellStyleDefault
                        reuseIdentifier:cellIdentifier];
            }
            cell.pickerView.tag=kSimplePickerTag;
            [cell.pickerView setDelegate:self];
            return cell;
            
        }
        
    }
    else if([self indexPathHasDate:indexPath])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDateCellID];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kDateCellID];
        }
        cell.textLabel.text = [itemData valueForKey:kTitleKey];
        
        if (indexPath.row==0)
        {
//            tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
            cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[itemData valueForKey:kValueKey]];
        }
        else if((indexPath.row==3  && !self.datePickerIndexPath) || (indexPath.row==4 && self.datePickerIndexPath.row<4 && self.datePickerIndexPath.row>0) ||(indexPath.row==3 && self.datePickerIndexPath.row==4))
        {
//            NSLog(@"Picker Value %@",self.arrayLogTime[[[itemData valueForKey:kValueKey] intValue]]);
            cell.detailTextLabel.text = (self.arrayLogTime.count)?[[self.arrayLogTime[[[itemData valueForKey:kValueKey] intValue]] valueForKey:@"value"] stringByConvertingHTMLToPlainText]:@"";
        }
        else
        {
            NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
            [outputFormatter setDateFormat:@"HH:mm"]; //24hr time format
            cell.detailTextLabel.text = [outputFormatter stringFromDate:[itemData valueForKey:kValueKey]];
        }
        return cell;
    }
    else
    {
        if ((indexPath.row==[self.dataArray count]-2 && !self.datePickerIndexPath)  || (indexPath.row==[self.dataArray count]-1 && self.datePickerIndexPath))
        {
            
            CustomTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTextViewID];
            if (cell == nil) {
                cell = [[CustomTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextViewID];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            // Add a UITextField
            cell.textView.enablesReturnKeyAutomatically = NO;
            cell.textView.delegate=self;
            cell.TextDelegate=self;
            cell.textView.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [cell.contentView addSubview:cell.textView];
            return cell;
            
        }
        else if ((indexPath.row==[self.dataArray count]-1 && !self.datePickerIndexPath)  || (indexPath.row==[self.dataArray count] && self.datePickerIndexPath))
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kButtonID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kButtonID];
            }
            
            UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame=CGRectMake(220, 5, 80, 32);
            [button setTitle:[Language get:@"Submit" alter:@"!Submit"] forState:UIControlStateNormal];
            button.layer.cornerRadius = 3;
            button.layer.borderColor = [[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] CGColor];
            button.layer.borderWidth = .8f;
            [button addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.font=[UIFont systemFontOfSize:16];
            [cell.contentView addSubview:button];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            
            return cell;
        }
        else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kOtherCell];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kOtherCell];
            }
            cell.textLabel.textAlignment=NSTextAlignmentCenter;
            cell.textLabel.text=[itemData valueForKey:kTitleKey];
            return cell;
        }
        
    }
    
}



//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    tableView.sectionFooterHeight = (section == 0 ? 10 : 10);
//    
//    return tableView.sectionFooterHeight;
//}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)ResignTextViewForTable:(UITextView *)textView1
{
    [textView1 resignFirstResponder];
    self.tableView.contentOffset=CGPointMake(0, 0);
}
-(void)save
{
    
    NSLog(@"%@",self.dataArray);
    if ([self hasInlineDatePicker])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Please select date." alter:@"!Please select date."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if (self.stringProjectId == nil)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"No project lists are available." alter:@"!No project lists are available."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = 1;
        
        [alert show];
    }
    else
    {
        NSDateFormatter *dateFormeterDate=[[NSDateFormatter alloc] init];
        [dateFormeterDate setDateFormat:@"yyyy-MM-dd"];
//        [dateFormeterDate setDateFormat:@"dd-MM-yyyy"];
        
        if ([[dateFormeterDate stringFromDate:self.dataArray[0][kValueKey]] isEqualToString:[dateFormeterDate stringFromDate:[NSDate date]]])
        {
            NSTimeInterval differenceBtwCurrentTimeAndFromTime = [[NSDate date] timeIntervalSinceDate:self.dataArray[1][kValueKey]];
//            NSTimeInterval differenceBtwCurrentTimeAndToTime = [[NSDate date] timeIntervalSinceDate:self.dataArray[2][kValueKey]];
            NSTimeInterval differenceBtwFromTimeAndToTime = [self.dataArray[2][kValueKey] timeIntervalSinceDate:self.dataArray[1][kValueKey]];
            
            
            NSLog(@"time Interval %f, %f",differenceBtwCurrentTimeAndFromTime,differenceBtwFromTimeAndToTime);
            
            if (differenceBtwCurrentTimeAndFromTime >0 && differenceBtwFromTimeAndToTime>0)
            {
                
                
                [self showLoadingView];
                
                
                
                NSDateFormatter *dateFormeterTime=[[NSDateFormatter alloc] init];
                [dateFormeterTime setDateFormat:@"HH:mm"];
                
                
                
                NSString *stringStartDate=[dateFormeterDate stringFromDate:self.dataArray[0][kValueKey]];
                
                NSString *stringStartTime=[dateFormeterTime stringFromDate:self.dataArray[1][kValueKey]];
                NSString *stringEndTime=[dateFormeterTime stringFromDate:self.dataArray[2][kValueKey]];
                
                
                // NSLog(@"%@",str);
                
                
                CustomTextViewCell *cellTextView =(CustomTextViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                
                
                NSError *error;
                NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
                [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
                [postDict setObject:self.stringProjectId forKey:@"project_id"];
                [postDict setObject:stringStartDate forKey:@"date"];
                [postDict setObject:stringStartTime forKey:@"is_from"];
                [postDict setObject:stringEndTime forKey:@"is_to"];
                [postDict setObject:self.arrayLogTime[[self.dataArray[3][kValueKey] intValue]] forKey:@"priority"];
                [postDict setObject:cellTextView.textView.text  forKey:@"comment"];
                
                
                // {"worker_id":"18","project_id":"126","is_to":"09:30","is_from":"10:30","comment":"zyx","date":"2013-11-29","priority":"Uncomfortable time"}';
                if (APP_DELEGATE.isServerReachable) {
            
            
                NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
                NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_TIME_LOG]];
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
                             [self performSelectorOnMainThread:@selector(alertAlreadyAdded) withObject:nil waitUntilDone:YES];
                         }
                         else
                         {
                             
                             
                             [self performSelectorOnMainThread:@selector(goBack) withObject:nil waitUntilDone:YES];
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
            else
            {
                if (differenceBtwCurrentTimeAndFromTime<0)
                {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[Language get:@"From Time Cannot exceeds the current time." alter:@"!From Time Cannot exceeds the current time."] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[Language get:@"Selected time cannot be exceeded." alter:@"!Selected time cannot be exceeded."] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                }
//                else if(differenceBtwCurrentTimeAndToTime<0)
//                {
//                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Time Cannot exceeds the current time" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//                    [alert show];
//                    
//                }
            }
        }
        else
        {
                NSTimeInterval differenceBtwFromTimeAndToTime = [self.dataArray[2][kValueKey] timeIntervalSinceDate:self.dataArray[1][kValueKey]];
                
                
                NSLog(@"time Interval %f",differenceBtwFromTimeAndToTime);
                
                if (differenceBtwFromTimeAndToTime>0)
                {
                    
                    
                    [self showLoadingView];
                    
                    
                    
                    NSDateFormatter *dateFormeterTime=[[NSDateFormatter alloc] init];
                    [dateFormeterTime setDateFormat:@"HH:mm"];
                    
                    
                    
                    NSString *stringStartDate=[dateFormeterDate stringFromDate:self.dataArray[0][kValueKey]];
                    
                    NSString *stringStartTime=[dateFormeterTime stringFromDate:self.dataArray[1][kValueKey]];
                    NSString *stringEndTime=[dateFormeterTime stringFromDate:self.dataArray[2][kValueKey]];
                    
                    
                    // NSLog(@"%@",str);
                    
                    
                    CustomTextViewCell *cellTextView =(CustomTextViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                    
                    
                    NSError *error;
                    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
                    [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
                    [postDict setObject:self.stringProjectId forKey:@"project_id"];
                    [postDict setObject:stringStartDate forKey:@"date"];
                    [postDict setObject:stringStartTime forKey:@"is_from"];
                    [postDict setObject:stringEndTime forKey:@"is_to"];
                    [postDict setObject:self.arrayLogTime[[self.dataArray[3][kValueKey] intValue]] forKey:@"priority"];
                    [postDict setObject:cellTextView.textView.text  forKey:@"comment"];
                    
                    
                    // {"worker_id":"18","project_id":"126","is_to":"09:30","is_from":"10:30","comment":"zyx","date":"2013-11-29","priority":"Uncomfortable time"}';
                    if (APP_DELEGATE.isServerReachable) {
                    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
                    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_TIME_LOG]];
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
                                 [self performSelectorOnMainThread:@selector(alertAlreadyAdded) withObject:nil waitUntilDone:YES];
                             }
                             else
                             {
                                 
                                 
                                 [self performSelectorOnMainThread:@selector(goBack) withObject:nil waitUntilDone:YES];
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
                else
                {
                    
                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[Language get:@"Selected time cannot be exceeded." alter:@"!Selected time cannot be exceeded."] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        
                    
                }
            }
          }
    
}


-(void)alertAlreadyAdded
{
    [self hideLoadingView];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[Language get:@"Time Log already exists for this date." alter:@"!Time Log already exists for this date."]  message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];

}




- (BOOL)textViewShouldReturn:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
}


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.arrayLogTime count];
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[self.arrayLogTime[row] valueForKey:@"value"]stringByConvertingHTMLToPlainText];
}



- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display the date picker inline with the table content
    [self.tableView beginUpdates];
    
    BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
    if ([self hasInlineDatePicker])
    {
        before = self.datePickerIndexPath.row < indexPath.row;
    }
    
    BOOL sameCellClicked = (self.datePickerIndexPath.row - 1 == indexPath.row);
    
    // remove any date picker cell if it exists
    if ([self hasInlineDatePicker])
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }
    
    if (!sameCellClicked)
    {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:0];
        NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0]];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0];
    }
    
    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
    
    // inform our date picker of the current date to match the current cell
    [self updateDatePicker];
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self RemovePickerios7];
    self.tableView.contentOffset = CGPointMake(0, 160);
    return YES;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  //  [self.view endEditing:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.reuseIdentifier == kDateCellID)
    {
            [self displayInlineDatePickerForRowAtIndexPath:indexPath];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark - Actions

//User chose to change the date by changing the values inside the UIDatePicker.
//param sender The sender for this action: UIDatePicker.

- (void)dateAction:(id)sender
{
    NSIndexPath *targetedCellIndexPath = nil;
    
    if ([self hasInlineDatePicker])
    {
        // inline date picker: update the cell's date "above" the date picker cell
        targetedCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    }
    else
    {   // external date picker: update the current "selected" cell's date
        targetedCellIndexPath = [self.tableView indexPathForSelectedRow];
    }
    
    if (targetedCellIndexPath.row==0)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
        UIDatePicker *targetedDatePicker = sender;
        
        
        // update our data model
        NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
        [itemData setValue:targetedDatePicker.date forKey:kValueKey];
        
        // update the cell's date string
        cell.detailTextLabel.text = [self.dateFormatter stringFromDate:targetedDatePicker.date];
    }
    else
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
        UIDatePicker *targetedDatePicker = sender;
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"HH:mm"]; //24hr time format
        NSString *dateString = [outputFormatter stringFromDate:targetedDatePicker.date];
        
        // update our data model
        NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
        [itemData setValue:targetedDatePicker.date forKey:kValueKey];
        
        // update the cell's date string
        cell.detailTextLabel.text = dateString;
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
   NSIndexPath *targetedCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
    [itemData setValue:[NSString stringWithFormat:@"%ld",(long)row] forKey:kValueKey];
    cell.detailTextLabel.text = [[self.arrayLogTime[row] valueForKey:@"value"] stringByConvertingHTMLToPlainText];
    
    //[self RemovePickerios7];
}

-(void)RemovePickerios7
{
    [self.tableView beginUpdates];
    if ([self hasInlineDatePicker])
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }
    [self.tableView endUpdates];
}

@end

