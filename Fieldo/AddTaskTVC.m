//
//  AddTask.m
//  Fieldo
//
//  Created by Gagan Joshi on 3/14/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//
#pragma mark -





#pragma mark -
#import "AddTaskTVC.h"
#import "CustomDatePickerCell.h"
#import "CustomPickerCell.h"
#import "CustomTextFieldCell.h"
#import "CustomTextViewCell.h"
#import "PersistentStore.h"
#import "Language.h"
#import "MBProgressHUD.h"
#import "Helper.h"

#import "NSString+HTML.h"

#import <CoreLocation/CoreLocation.h>
#import "CurrentLocationView.h"

#define kDatePickerTag              99
#define kSimplePickerTag            98


#define kPlaceHolderKey     @"placeHolder"

// keep track of which rows have date cells
#define kStartDate        0
#define kEndDate          1
#define KPickerRow        2

static NSString *kDateCellID = @"dateCell";     // the cells with the start or end date
static NSString *kDatePickerID = @"datePicker"; // the cell containing the date picker
static NSString *kOtherCell = @"otherCell";     // the remaining cells at the end
static NSString *kTextViewID = @"textView";
static NSString *kButtonID = @"buttonId";
static NSString *kTextFieldID = @"textField";

static NSString *kProjectCellID = @"projectCell";   // the cells with the start or end date
static NSString *kPickerID = @"projectPicker";      // the cell containing the date picker


#pragma mark -

@interface AddTaskTVC ()<CLLocationManagerDelegate,customTextCellDelegate>{
    CLLocation *SearchedLocation;
    CLLocationManager *locationManager;
}


@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (assign) NSInteger pickerCellRowHeight;

// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;
@property (nonatomic,retain) NSMutableDictionary *dictBinding;


@end


@implementation AddTaskTVC

@synthesize dictBinding;


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self currentLocation];
    
    self.title=[Language get:@"Add Task" alter:@"!Add Task"] ;

    // [self.navigationController.navigationItem setRightBarButtonItem:cameraItem];
    
    //TableView Cell Class Registration
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    [self.tableView registerClass:[CustomPickerCell class] forCellReuseIdentifier:kPickerID];
    [self.tableView registerClass:[CustomDatePickerCell class] forCellReuseIdentifier:kDatePickerID];
    [self.tableView registerClass:[CustomTextViewCell class] forCellReuseIdentifier:kTextViewID];
    [self.tableView registerClass:[CustomTextFieldCell class] forCellReuseIdentifier:kTextFieldID];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    
    self.tableView.rowHeight=44;
    self.pickerCellRowHeight =216;
    //TableView Cell Class Registration
    
    
    //setUp Our Table with Values
    NSMutableDictionary *itemOne    = [@{ kTitleKey : [Language get:@"Start Time:" alter:@"!Start Time:"] , kValueKey:[NSDate date] } mutableCopy];
    NSMutableDictionary *itemTwo    =  [@{ kTitleKey : [Language get:@"End Time:" alter:@"!Start Time:"] ,   kValueKey:[NSDate date] } mutableCopy];
    NSMutableDictionary *itemThree  = [@{ kTitleKey : [Language get:@"Under:" alter:@"!Under:"] ,kValueKey: @"0" } mutableCopy];
    NSMutableDictionary *itemFour   =  [@{ kTitleKey :[Language get:@"Task Name*" alter:@"!Task Name*"] ,   kValueKey:[NSDate date] } mutableCopy];
    NSMutableDictionary *itemFive   =  [@{ kTitleKey :[Language get:@"Material Name" alter:@"!Material Name"] ,kValueKey:[NSDate date] } mutableCopy];
    NSMutableDictionary *itemSix    =  [@{ kTitleKey :[Language get:@"Estimated Hour*" alter:@"!Estimated Hour*"] ,kValueKey:[NSDate date] } mutableCopy];
    NSMutableDictionary *itemSeven  =  [@{ kTitleKey :[Language get:@"Comments" alter:@"!Comments"] , kValueKey:[NSDate date] } mutableCopy];
    NSMutableDictionary *itemEight  =  [@{ kTitleKey : @"(other item2)", kValueKey:[NSDate date] } mutableCopy];
    self.dataArray = @[itemOne, itemTwo, itemThree, itemFour, itemFive,itemSix,itemSeven,itemEight];
    
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"dd-MM-yyyy, hh:mm a"];
    
    // if the local changes while in the background, we need to be notified so we can update the date
    // format in the table view cells
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeChanged:) name:NSCurrentLocaleDidChangeNotification object:nil];
    
    dictBinding=[NSMutableDictionary new];

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
    
        CurrentLocationView *currentView = [[CurrentLocationView alloc] init];
        currentView.longitude = [NSString stringWithFormat:@"%f",SearchedLocation.coordinate.longitude];
        currentView.latitude = [NSString stringWithFormat:@"%f",SearchedLocation.coordinate.latitude];
        [currentView userCurrentLocation:self.view];
        
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

#pragma Mark Show hide Loading
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
    //self.tableView.hidden=NO;
}



#pragma mark TextField Delegates


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self hidePickerIOS7];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.tableView reloadData];
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag==3) {
        [dictBinding setValue:textField.text forKey:@"TaskName"];
    }
    else if (textField.tag==4) {
        [dictBinding setValue:textField.text forKey:@"MaterialName"];
    }
    else if (textField.tag==5) {
        [dictBinding setValue:textField.text forKey:@"Estimated"];
    }
}
/*
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag==3) {
        [dictBinding setValue:textField.text forKey:@"TaskName"];
    }
    else if (textField.tag==4) {
        [dictBinding setValue:textField.text forKey:@"MaterialName"];
    }
    else if (textField.tag==5) {
        [dictBinding setValue:textField.text forKey:@"Estimated"];
    }
   
    return YES;
}
*/
//-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    
//    //    CustomTextFieldCell *cellTextFieldOrderNo =(CustomTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
//    //    CustomTextFieldCell *cellTextFieldOrderValue =(CustomTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
//    //    CustomTextViewCell *cellTextViewComment =(CustomTextViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
//    
//    
//    return YES;
//}

#pragma mark TextView Delegates
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    
////    if([text isEqualToString:@"\n"])
////    {
//        if (![textView.text length])
//        {
//            textView.text =[Language get:@"Comments" alter:@"Comments"] ;
//            textView.textColor=[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.0];
//        }
//        else
//        {
//            
//            textView.textColor=[UIColor blackColor];
//        }
////        [textView resignFirstResponder];
////    }
//    
//    
//    return YES;
//}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self hidePickerIOS7];
    if([textView.text isEqualToString:[Language get:@"Comments" alter:@"Comments"]])
    {
        textView.textColor=[UIColor blackColor];
        textView.text = nil;
    }
    self.tableView.contentOffset=CGPointMake(0, 160);

    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{

    [self.tableView reloadData];
    return YES;
}

-(void)hidePickerIOS7
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
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.arraySubProjects count];
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return (NSMutableString *)[self.arraySubProjects[row][@"head_name"] stringByConvertingHTMLToPlainText];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSIndexPath *targetedCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
    [itemData setValue:[NSString stringWithFormat:@"%ld",(long)row] forKey:kValueKey];
    cell.detailTextLabel.text = self.arraySubProjects[row][@"head_name"];
    
    //[self RemovePickerios7];
}


-(void) ResignTextViewForTable:(UITextView *)textView1
{
    if(textView1.text.length==0)
    {
        textView1.text=[Language get:@"Comments" alter:@"Comments"];
        textView1.textColor=[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.0];
    }

    [textView1 resignFirstResponder];
    self.tableView.contentOffset=CGPointMake(0, 0);
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSCurrentLocaleDidChangeNotification object:nil];
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


- (void)updateDatePicker
{

    if (self.datePickerIndexPath != nil)
    {
        if(self.datePickerIndexPath.row==1 ||  self.datePickerIndexPath.row==2)
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
                NSDictionary *itemData = self.dataArray[self.datePickerIndexPath.row - 1];
                [targetedDatePicker selectRow:[[itemData valueForKey:kValueKey] intValue] inComponent:0 animated:YES];
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
    
    if ((indexPath.row == kStartDate) || (indexPath.row == kEndDate)|| (indexPath.row == KPickerRow) ||
        (([self hasInlineDatePicker] && (indexPath.row == KPickerRow + 1))))
    {
        hasDate = YES;
    }
    
    return hasDate;
}




#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 || indexPath.row == 1)
        return 0;
    
    if(((indexPath.row==[self.dataArray count]-2) && ![self hasInlineDatePicker]) || ((indexPath.row==[self.dataArray count]-1) && [self hasInlineDatePicker]) )
        return 100;
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
        
        if (indexPath.row==3)
        {
            static NSString *cellIdentifier = @"cell";
            CustomPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:kPickerID];
            if (cell == nil)
            {
                cell = [[CustomPickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.pickerView.tag=kSimplePickerTag;
            [cell.pickerView setDelegate:self];
            return cell;

        }
        else
        {
            CustomDatePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:kDatePickerID];
            if (cell == nil)
            {
                cell = [[CustomDatePickerCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kDatePickerID];
            }
            [cell.cellDatePicker addTarget:self action:@selector(dateAction:) forControlEvents:UIControlEventValueChanged];
            cell.cellDatePicker.date=[NSDate date];
            cell.cellDatePicker.tag=99;
            cell.cellDatePicker.datePickerMode=UIDatePickerModeDateAndTime;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

        
        if (indexPath.row==0 || indexPath.row==1)
        {
            cell.hidden = YES;
            cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[itemData valueForKey:kValueKey]];
        }
        else
        {
            NSLog(@"Picker Value %@",self.arraySubProjects[[[itemData valueForKey:kValueKey] intValue]][@"head_name"]);
            cell.detailTextLabel.text = (NSMutableString *)[ self.arraySubProjects[[[itemData valueForKey:kValueKey] intValue]][@"head_name"] stringByConvertingHTMLToPlainText];
        }
        
        

        return cell;
    }
    else
    {
        if(((indexPath.row==[self.dataArray count]-1) && ![self hasInlineDatePicker]) || ((indexPath.row==[self.dataArray count]) && [self hasInlineDatePicker]) )
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
        else if(((indexPath.row==[self.dataArray count]-2) && ![self hasInlineDatePicker]) || ((indexPath.row==[self.dataArray count]-1) && [self hasInlineDatePicker]) )
        {
            CustomTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTextViewID];
            if (cell == nil) {
                cell = [[CustomTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextViewID];
            }
            // Add a UITextField
            cell.textView.enablesReturnKeyAutomatically = NO;
            cell.textView.text = [itemData valueForKey:kTitleKey];
            cell.textView.delegate=self;
            cell.TextDelegate=self;
            cell.textView.textColor=[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.0];
            cell.textView.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            cell.textField.tag=indexPath.row;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ((indexPath.row==5 && ![self hasInlineDatePicker]) ||  (indexPath.row==6 && [self hasInlineDatePicker]))
            {
                [cell.textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
                
            }
            
            if (cell.textField.tag==3) {
                cell.textField.text =[dictBinding objectForKey:@"TaskName"];
//                [dictBinding setValue:cell.textField.text forKey:@"TaskName"];
            }
            else if (cell.textField.tag==4) {
                cell.textField.text =[dictBinding objectForKey:@"MaterialName"];

//                [dictBinding setValue:cell.textField.text forKey:@"MaterialName"];
            }
            else if (cell.textField.tag==5) {
                cell.textField.text =[dictBinding objectForKey:@"Estimated"];

//                [dictBinding setValue:cell.textField.text forKey:@"Estimated"];
            }
            return cell;
            
        }
        
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


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

-(void)save
{
    NSLog(@"%@",self.dataArray);
    if ([self hasInlineDatePicker])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Please select date." alter:@"!Please select date."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
//        CustomTextFieldCell *cellTextFieldTaskName =(CustomTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
//        CustomTextFieldCell *cellTextFieldMaterialName =(CustomTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
//        CustomTextFieldCell *cellTextFieldEstimateHours =(CustomTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
        CustomTextViewCell *cellTextViewComment =(CustomTextViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
        
        if ([[dictBinding objectForKey:@"TaskName"] length]<1)
        {
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:[Language get:@"Please fill required details." alter:@"!Please fill required details."]  message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else if([[dictBinding objectForKey:@"Estimated"] length]<=0)
        {
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:[Language get:@"Please provide estimated hours." alter:@"!Please provide estimated hours."]  message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            
            NSDateFormatter *dateFormeterDate=[[NSDateFormatter alloc] init];
            [dateFormeterDate setDateFormat:@"yyyy-MM-dd"];
//            [dateFormeterDate setDateFormat:@"dd-MM-yyyy"];
            
            NSDateFormatter *dateFormeterTime=[[NSDateFormatter alloc] init];
            [dateFormeterTime setDateFormat:@"HH:mm"];
            
//            NSString *stringStartDate=[dateFormeterDate stringFromDate:self.dataArray[0][kValueKey]];
//            NSString *stringEndDate=[dateFormeterDate stringFromDate:self.dataArray[1][kValueKey]];
//            NSString *stringStartTime=[dateFormeterTime stringFromDate:self.dataArray[0][kValueKey]];
//            NSString *stringEndTime=[dateFormeterTime stringFromDate:self.dataArray[1][kValueKey]];
//            NSString *sd=[NSString stringWithFormat:@"%@ %@",stringStartDate,stringStartTime];
//            NSString *ed=[NSString stringWithFormat:@"%@ %@",stringEndDate,stringEndTime];
            
            NSString *stringStartDate = [[self.arraySubProjects valueForKey:@"start_date"] firstObject];
            NSString *stringEndDate = [[self.arraySubProjects valueForKey:@"end_date"] firstObject];
            NSString *stringStartTime = [[self.arraySubProjects valueForKey:@"from_time"] firstObject];
            NSString *stringEndTime = [[self.arraySubProjects valueForKey:@"to_time"] firstObject];
            NSString *sd=[NSString stringWithFormat:@"%@ %@",stringStartDate,stringStartTime];
            NSString *ed=[NSString stringWithFormat:@"%@ %@",stringEndDate,stringEndTime];
            
            NSComparisonResult res=[sd compare:ed];
            
            if(res==NSOrderedDescending||res==NSOrderedSame)
            {
                UIAlertView *alert= [[UIAlertView alloc] initWithTitle:[Language get:@"End Date should be greater than start date." alter:@"!End Date should be greater than start date."] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                alert.tag=5;
                [alert show];
                return;
            }

            NSDictionary *item=self.dataArray[2];

            NSError *error;
            NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
            
            [postDict setObject:self.arraySubProjects[[item[kValueKey] intValue]][@"head_id"] forKey:@"head_id"];
            [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
            [postDict setObject:[dictBinding objectForKey:@"TaskName"] forKey:@"task_name"];
            [postDict setObject:cellTextViewComment.textView.text forKey:@"description"];
            [postDict setObject:([[dictBinding objectForKey:@"MaterialName"] length]>0)?[dictBinding objectForKey:@"MaterialName"]:@"" forKey:@"material_name"];
            [postDict setObject:[dictBinding  objectForKey:@"Estimated"] forKey:@"estimated_hour"];
            [postDict setObject:stringStartDate forKey:@"start_date"];
            [postDict setObject:stringEndDate forKey:@"end_date"];
            [postDict setObject:@"status" forKey:@"status"];
            [postDict setObject:cellTextViewComment.textView.text forKey:@"comment"];
            [postDict setObject:stringStartTime forKey:@"from_time"];
            [postDict setObject:stringEndTime forKey:@"to_time"];

            
            if(APP_DELEGATE.isServerReachable)
            {
            NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
            NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://fieldo.se/api/addtaskmore.php"]];
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
    }
}

- (void) alertLoginFailed
{
    
}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
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



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.reuseIdentifier == kDateCellID)
    {
//        if (indexPath.row==0)
//            start_date_selected=YES;
//         
//        if (indexPath.row!=1)
//        [self displayInlineDatePickerForRowAtIndexPath:indexPath];
//        else if(start_date_selected)
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
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    UIDatePicker *targetedDatePicker = sender;
    
    
    // update our data model
    NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
    [itemData setValue:targetedDatePicker.date forKey:kValueKey];
    
    // update the cell's date string
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:targetedDatePicker.date];
    
}
@end




