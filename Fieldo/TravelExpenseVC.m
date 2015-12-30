//
//  TravelExpenseVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/12/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#pragma mark -

#import "TravelExpenseVC.h"
#import "CustomDatePickerCell.h"
#import "CustomTextFieldCell.h"
#import "Language.h"
#import "PlacesPickerTVC.h"
#import "PersistentStore.h"
#import "Language.h"
#import "MBProgressHUD.h"
#import "LocationListBO.h"

#import "LocationListingTVC.h"

#import <CoreLocation/CoreLocation.h>
#import "CurrentLocationView.h"

#define kDatePickerTag              99
#define kSimplePickerTag            98


#define kPlaceHolderKey  @"placeHolder"
#define kDateRow          0

static NSString *kDateCellID = @"dateCell";     // the cells with the start or end date
static NSString *kDatePickerID = @"datePicker"; // the cell containing the date picker
static NSString *kOtherCell = @"otherCell";     // the remaining cells at the end
static NSString *kTextFieldID = @"textField";
static NSString *kButtonID = @"buttonId";


#pragma mark -

@interface TravelExpenseVC ()<CLLocationManagerDelegate>{
    CLLocation *SearchedLocation;
    CLLocationManager *locationManager;
}

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (assign) NSInteger pickerCellRowHeight;

@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;


@end


int i=0;

@implementation TravelExpenseVC

{
    bool distanceCalculated;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self currentLocation];
    
    Connect = [[ConnectionManager alloc] init];
    
    
    distanceCalculated=NO;

    NSString *strNotificationName=@"LocationList";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(FillTheTextField:) name:strNotificationName object:nil];
    
    self.title=[Language get:@"Travel Log" alter:@"Travel Log"];
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
   
        
    // setup our data source
    NSMutableDictionary *itemOne   =  [@{ kTitleKey :[Language get:@"Date:" alter:@"!Date:"],          kValueKey:[NSDate date] } mutableCopy];
    NSMutableDictionary *itemTwo   =  [@{ kTitleKey :[Language get:@"From" alter:@"!From"],            kValueKey:@"" } mutableCopy];
    NSMutableDictionary *itemThree =  [@{ kTitleKey :[Language get:@"To" alter:@"!To"],                kValueKey:@"" } mutableCopy];
    NSMutableDictionary *itemFour  =  [@{ kTitleKey :[Language get:@"Km" alter:@"!Km"],                kValueKey:@"" } mutableCopy];
    NSMutableDictionary *itemFive  =  [@{ kTitleKey :[Language get:@"Other fee" alter:@"!Other fee"],  kValueKey:@"" } mutableCopy];
    NSMutableDictionary *itemSix   =  [@{ kTitleKey :[Language get:@"Comments" alter:@"!Comments"] ,   kValueKey:@"" } mutableCopy];
    NSMutableDictionary *itemSeven =  [@{  } mutableCopy];

    
    self.dataArray = @[itemOne, itemTwo, itemThree, itemFour, itemFive,itemSix,itemSeven];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"dd-MM-YYYY"];
//    [self.dateFormatter setDateStyle:NSDateFormatterLongStyle];    // show short-style date format
    
    // if the local changes while in the background, we need to be notified so we can update the date
    // format in the table view cells
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeChanged:) name:NSCurrentLocaleDidChangeNotification object:nil];
    
    [self.tableView registerClass:[CustomDatePickerCell class] forCellReuseIdentifier:kDatePickerID];
    [self.tableView registerClass:[CustomTextFieldCell class] forCellReuseIdentifier:kTextFieldID];
    
    
    self.tableView.rowHeight=44;
    self.pickerCellRowHeight =216; //pickerViewCellToCheck.frame.size.height;
    
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSCurrentLocaleDidChangeNotification object:nil];
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
            UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
            UIDatePicker *targetedDatePicker = (UIDatePicker *)[associatedDatePickerCell viewWithTag:kDatePickerTag];
            if (targetedDatePicker != nil)
            {
                // we found a UIDatePicker in this cell, so update it's date value
                NSDictionary *itemData = self.dataArray[self.datePickerIndexPath.row - 1];
                [targetedDatePicker setDate:[itemData valueForKey:kValueKey] animated:NO];
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
    
    if (indexPath.row == kDateRow)
    {
        hasDate = YES;
    }
    
    return hasDate;
}



#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self indexPathHasPicker:indexPath] ? self.pickerCellRowHeight : self.tableView.rowHeight);
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
    
    if ([self indexPathHasPicker:indexPath])
    {
         CustomDatePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:kDatePickerID];
            if (cell == nil)
            {
                cell = [[CustomDatePickerCell alloc]
                        initWithStyle:UITableViewCellStyleSubtitle
                        reuseIdentifier:kDatePickerID];
            }
            [cell.cellDatePicker addTarget:self action:@selector(dateAction:) forControlEvents:UIControlEventValueChanged];
            cell.cellDatePicker.date=[NSDate date];
            cell.cellDatePicker.tag=99;
            cell.cellDatePicker.datePickerMode=UIDatePickerModeDate;
            return cell;
        
    }
    else if([self indexPathHasDate:indexPath])
    {
       
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDateCellID];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kDateCellID];
        }
        cell.textLabel.text = [itemData valueForKey:kTitleKey];
        cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[itemData valueForKey:kValueKey]];
        return cell;
    }
    else
    {
       
        if((indexPath.row==[self.dataArray count]-1 && ![self hasInlineDatePicker]) ||  (indexPath.row==[self.dataArray count] && [self hasInlineDatePicker]))
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
           
            CustomTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kTextFieldID];
            if (cell == nil) {
                cell = [[CustomTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextFieldID];
            }
            // Add a UITextField
            cell.textField.enablesReturnKeyAutomatically = NO;
            cell.textField.delegate=self;
            cell.textField.placeholder=itemData[kTitleKey];
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
             cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            
            if ((indexPath.row==1 && ![self hasInlineDatePicker]) ||  (indexPath.row==2 && [self hasInlineDatePicker]))
            {
//                cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
                cell.textField.text=self.stringFromLocation;
                cell.textField.tag=101;
            }
            if ((indexPath.row==2 && ![self hasInlineDatePicker]) ||  (indexPath.row==3 && [self hasInlineDatePicker]))
            {
//                 cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
                cell.textField.text=self.stringTOLocation;
                cell.textField.tag=102;
            }
            if ((indexPath.row==3 && ![self hasInlineDatePicker]) ||  (indexPath.row==4 && [self hasInlineDatePicker]))
            {
                cell.textField.text=self.stringDistance;
                cell.textField.tag=103;
            }
            
            if (indexPath.row==4)
            {
                cell.textField.tag=104;
                [ cell.textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation ];
            }
            if (indexPath.row==5)
            {
                cell.textField.tag=105;

            }
            
            
            [cell.contentView addSubview:cell.textField];
            return cell;

        }
        
    }
    
}


-(void)mapViewDidFinish:(MapView *)mapView
{
    if(i==1)
    {
        self.stringFromLocation=mapView.returnText;
    }
    if(i==2)
    {
        self.stringTOLocation=mapView.returnText;
    }
    i=0;
    
    self.startLocation=mapView.startLocation;
    self.endLocation=mapView.endLocation;
    
    if ([self.stringFromLocation length] && [self.stringTOLocation length])
    {
        self.stringDistance=[NSString stringWithFormat:@"%.2f",mapView.distance/1000.0] ;
    }
    [self.tableView reloadData];
    
}


- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag==104)
    {
        NSMutableDictionary *itemData = self.dataArray[4];
        [itemData setValue:textField.text forKey:kValueKey];
    }
    if (textField.tag==105)
    {
        NSMutableDictionary *itemData = self.dataArray[5];
        [itemData setValue:textField.text forKey:kValueKey];
        
    }
}

/*
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    

    return YES;
}
*/

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

    if ((indexPath.row==1 && ![self hasInlineDatePicker]) ||  (indexPath.row==2 && [self hasInlineDatePicker]))
    {
        i=1;
//        MapView *mapView=[[MapView alloc] initWithNibName:nil bundle:nil];
//        mapView.startLocation=self.startLocation;
//        mapView.endLocation=self.endLocation;
//        mapView.intStartLocation=1;
//        mapView.delegate=self;
//        [self presentViewController:mapView animated:YES completion:nil];
//
    }
    if ((indexPath.row==2 && ![self hasInlineDatePicker]) ||  (indexPath.row==3 && [self hasInlineDatePicker]))
    {
        i=2;
//        MapView *mapView=[[MapView alloc] initWithNibName:nil bundle:nil];
//        mapView.startLocation=self.startLocation;
//        mapView.endLocation=self.endLocation;
//        mapView.intStartLocation=2;
//        mapView.delegate=self;
//        [self presentViewController:mapView animated:YES completion:nil];
//
    }
//

}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}



-(void)save
{
    NSLog(@"%@",self.dataArray);
    if ([self hasInlineDatePicker])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Please select date." alter:@"!Please select date."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        
    NSLog(@"%@, %@, %@, %@",self.stringFromLocation,self.stringTOLocation,self.dataArray[4][kValueKey],self.dataArray[5][kValueKey]);
        
        
        if ([self.stringFromLocation length]<1  || [self.stringTOLocation length]<1 )
        {
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:[Language get:@"Please fill required details." alter:@"!Please fill required details."] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            NSDateFormatter *dateFormeterDate=[[NSDateFormatter alloc] init];
            [dateFormeterDate setDateFormat:@"yyyy-MM-dd"];
//            [dateFormeterDate setDateFormat:@"dd-MM-yyyy"];
            NSString *stringStartDate=[dateFormeterDate stringFromDate:self.dataArray[0][kValueKey]];
            
            // NSLog(@"%@",str);
            
            
            
            
            NSError *error;
            NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
            [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
            [postDict setObject:self.stringProjectId forKey:@"project_id"];
            [postDict setObject:self.stringFromLocation forKey:@"from"];
            [postDict setObject:self.stringTOLocation forKey:@"to"];
            [postDict setObject:self.stringDistance forKey:@"km"];
            [postDict setObject:self.dataArray[4][kValueKey] forKey:@"other_fee"];
            [postDict setObject:self.dataArray[5][kValueKey] forKey:@"comment"];
            [postDict setObject:stringStartDate forKey:@"date"];
            
            if (APP_DELEGATE.isServerReachable) {
            NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
            NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_TRAVEL_EXPENCES]];
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
                         // [self performSelectorOnMainThread:@selector(alertLoginFailed) withObject:nil waitUntilDone:YES];
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
//                [self hideLoadingView];
                [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
            }
        }
    }
}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [self RemovePickerios7];
    
    if (textField.tag==101||textField.tag==102)
    {
        LocationListingTVC *locList=[[LocationListingTVC alloc]init];
        locList.SearchedLocation = SearchedLocation;
        [self.navigationController pushViewController:locList animated:YES];
        
        [textField resignFirstResponder];
        
        if (textField.tag==101)
        {
            i=1;
            //        MapView *mapView=[[MapView alloc] initWithNibName:nil bundle:nil];
            //        mapView.startLocation=self.startLocation;
            //        mapView.endLocation=self.endLocation;
            //        mapView.intStartLocation=1;
            //        mapView.delegate=self;
            //        [self presentViewController:mapView animated:YES completion:nil];
            //
        }
        else if (textField.tag==102)
        {
            i=2;
            //        MapView *mapView=[[MapView alloc] initWithNibName:nil bundle:nil];
            //        mapView.startLocation=self.startLocation;
            //        mapView.endLocation=self.endLocation;
            //        mapView.intStartLocation=2;
            //        mapView.delegate=self;
            //        [self presentViewController:mapView animated:YES completion:nil];
            //
        }

    }
    else if ((textField.tag==103)&!distanceCalculated)
    {
        [textField resignFirstResponder];
    }

   
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag==104)
    {
        NSMutableDictionary *itemData = self.dataArray[4];
        [itemData setValue:textField.text forKey:kValueKey];
    }
    else if (textField.tag==105)
    {
        NSMutableDictionary *itemData = self.dataArray[5];
        [itemData setValue:textField.text forKey:kValueKey];
        
    }

    
    [textField resignFirstResponder];
    return YES;
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

/*! Reveals the UIDatePicker as an external slide-in view, iOS 6.1.x and earlier, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath used to display the UIDatePicker.
 */

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
   
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
        UIDatePicker *targetedDatePicker = sender;
        
        
        // update our data model
        NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
        [itemData setValue:targetedDatePicker.date forKey:kValueKey];
        
        // update the cell's date string
        cell.detailTextLabel.text = [self.dateFormatter stringFromDate:targetedDatePicker.date];
    
}



-(void) FillTheTextField:(NSNotification*)notification
{
    NSDictionary *datadict=notification.userInfo;
    LocationListBO *loc=[datadict valueForKey:@"LocName"];
    
    if(i==1)
    {
        self.stringFromLocation=loc.locName;
        sourceLoc=loc.locCoordinates;
    }
    if(i==2)
    {
        self.stringTOLocation=loc.locName;
        destLoc=loc.locCoordinates;
    }
    i=0;
    if ([self.stringFromLocation length] && [self.stringTOLocation length])
    {
        [self getDistanceFromOrigin:sourceLoc destination:destLoc];
    }
    [self.tableView reloadData];
}

-(void)getDistanceFromOrigin:(CLLocationCoordinate2D )source destination:(CLLocationCoordinate2D)dest
{
    NSString* strDriverLoc = [NSString stringWithFormat:@"%f,%f", source.latitude, source.longitude];
    NSString* strPassengerLoc = [NSString stringWithFormat:@"%f,%f", dest.latitude, dest.longitude];
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/distancematrix/json?origins=%@&destinations=%@&sensor=false", strDriverLoc, strPassengerLoc];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    NSError* error;
    NSData* data = [NSData dataWithContentsOfURL:apiUrl];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSString* toDistance=[[[[[[json objectForKey:@"rows"] objectAtIndex:0 ] objectForKey:@"elements"] objectAtIndex:0] objectForKey:@"distance"] valueForKey:@"text"];
    NSString* toTime=[[[[[[json objectForKey:@"rows"] objectAtIndex:0 ] objectForKey:@"elements"] objectAtIndex:0] objectForKey:@"duration"] valueForKey:@"text"];
    if (toDistance.length>0 && toTime.length>0)
    {
        self.stringDistance=[NSString stringWithFormat:@"%.2f km",[toDistance floatValue]] ;
        distanceCalculated=YES;
    }
    else
    {
        self.stringDistance = @"";
        self.stringFromLocation=@"";
        self.stringTOLocation=@"";
        UIAlertView *alertV=[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Over the Sea...." alter:@"!Over the Sea...."]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        
        
        alertV.tag=5;
        [alertV show];
    }
}
@end

