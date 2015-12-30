

#pragma mark -
#import "MaterialExpenseVC.h"
#import "CustomDatePickerCell.h"
#import "CustomPickerCell.h"
#import "CustomTextFieldCell.h"
#import "CustomTextViewCell.h"
#import "PersistentStore.h"
#import "Language.h"
#import "MBProgressHUD.h"
#import "Helper.h"
#import "NSString+HTML.h"
#import "AppDelegate.h"


#import <CoreLocation/CoreLocation.h>
#import "CurrentLocationView.h"

#define kDatePickerTag              99
#define kSimplePickerTag            98


#define kPlaceHolderKey     @"placeHolder"

// keep track of which rows have date cells
#define kDateRow        0
#define KPickerRow      1

static NSString *kDateCellID = @"dateCell";     // the cells with the start or end date
static NSString *kDatePickerID = @"datePicker"; // the cell containing the date picker
static NSString *kOtherCell = @"otherCell";     // the remaining cells at the end
static NSString *kTextViewID = @"textView";
static NSString *kButtonID = @"buttonId";
static NSString *kTextFieldID = @"textField";

static NSString *kProjectCellID = @"projectCell";   // the cells with the start or end date
static NSString *kPickerID = @"projectPicker";      // the cell containing the date picker


#pragma mark -

@interface MaterialExpenseVC ()<CLLocationManagerDelegate,customTextCellDelegate>{
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


@implementation MaterialExpenseVC

@synthesize dictBinding;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self currentLocation];
    
    self.title=[Language get:@"Material Log" alter:@"!Material Log"] ;
    
    [self showLoadingView];
    UIBarButtonItem *cameraItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(getPhotoActionSheet)];
    NSArray *actionButtonItems = @[cameraItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    
    
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
    NSMutableDictionary *itemOne   =  [@{ kTitleKey : [Language get:@"Date:" alter:@"!Date:"] ,       kValueKey:[NSDate date] } mutableCopy];
    NSMutableDictionary *itemTwo   =  [@{ kTitleKey :[Language get:@"Store:" alter:@"!Store:"] ,       kValueKey:@"0"} mutableCopy];
    NSMutableDictionary *itemThree =  [@{ kTitleKey :[Language get:@"Order no." alter:@"!Order no."] ,   kValueKey:[NSDate date] } mutableCopy];
    NSMutableDictionary *itemFour  =  [@{ kTitleKey :[Language get:@"Order value." alter:@"!Order value."] ,kValueKey:[NSDate date] } mutableCopy];
    NSMutableDictionary *itemFive  =  [@{ kTitleKey :[Language get:@"Comments" alter:@"!Comments"] ,    kValueKey:[NSDate date] } mutableCopy];
    NSMutableDictionary *itemSix =  [@{ kTitleKey : @"(other item2)", kValueKey:[NSDate date] } mutableCopy];
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
    
    dictBinding=[NSMutableDictionary new];
    
    [dictBinding setValue:self.stringProjectId forKey:@"OrderNumber"];
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

#pragma Mark Show hide Loading
-(void)showLoadingView
{
    //self.tableView.hidden=YES;
    NSLog(@"%@",self.view);
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

#pragma mark assorsser of Array Stores.
-(NSMutableArray *)arrayStores
{
    if (!_arrayStores)
    {
        NSError *error;
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
        [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
        if (APP_DELEGATE.isServerReachable) {
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_STORES_LIST]];
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
                 
                 
                 _arrayStores=object;
                 [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:NO];
             }
             
         }];
        }
        else
        {
            [self hideLoadingView];
            [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        }
        
    }
    return _arrayStores;
}

#pragma mark UIPickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.arrayStores count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSString *string=[[NSString stringWithFormat:@"%@",self.arrayStores[row][@"store_name"]] stringByConvertingHTMLToPlainText];
    return string;
}

#pragma mark TextField Delegates


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self hidePickerIOS7];
    
    return YES;
}
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag==2)
    {
        [dictBinding setValue:textField.text forKey:@"OrderNumber"];
    }
    else if (textField.tag==3)
    {
        [dictBinding setValue:textField.text forKey:@"OrderValue"];
    }
}
/*
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    return YES;
}
*/

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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



#pragma mark TextView Delegates
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    
//    if([text isEqualToString:@"\n"])
//    {
//        if (![textView.text length])
//        {
//            textView.text =[Language get:@"Comments" alter:@"Comments"] ;
//            textView.textColor=[UIColor colorWithRed:0.8235 green:4 blue:0.8235 alpha:1.0];
//        }
//        [textView resignFirstResponder];
//    }
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
    
    if ((indexPath.row == kDateRow) || (indexPath.row == KPickerRow) ||
        (([self hasInlineDatePicker] && (indexPath.row == KPickerRow + 1))))
    {
        hasDate = YES;
    }
    
    return hasDate;
}




#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        
        
        if(self.datePickerIndexPath.row==1  )
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
             cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        
        if (indexPath.row==0 )
            cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[itemData valueForKey:kValueKey]];
        else
        {
            NSLog(@"Picker Value %@",self.arrayStores[[[itemData valueForKey:kValueKey] intValue]]);
                                         
//            cell.detailTextLabel.text = [[NSString stringWithFormat:@"%@",self.arrayStores[row][@"store_name"]] stringByConvertingHTMLToPlainText];
//            cell.detailTextLabel.text = self.arrayStores[[[itemData valueForKey:kValueKey] intValue]][[@"store_name"] stringByConvertingHTMLToPlainText];
            cell.detailTextLabel.text = [self.arrayStores[[[itemData valueForKey:kValueKey] intValue]][@"store_name"] stringByConvertingHTMLToPlainText];
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
      else if(((indexPath.row==[self.dataArray count]-2) && ![self hasInlineDatePicker]) || ((indexPath.row==[self.dataArray count]-1) && [self hasInlineDatePicker]))
      {
          CustomTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTextViewID];
          
          if (cell == nil)
          {
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
          [dictBinding setValue:cell.textView.text forKey:@"Comments"];
          [cell.contentView addSubview:cell.textView];
          return cell;
  
      }
        else
        {
         
            CustomTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kTextFieldID];
            if (cell == nil) {
                cell = [[CustomTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kTextFieldID];
            }
//            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            // Add a UITextField
            cell.textField.enablesReturnKeyAutomatically = NO;
            cell.textField.delegate=self;
            cell.textField.keyboardType=UIKeyboardTypeNumberPad;
            cell.textField.placeholder=itemData[kTitleKey];
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.tag=indexPath.row;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            
            if (cell.textField.tag==2) {
                cell.textField.text=self.stringProjectId;
            }
            else if (cell.textField.tag==3)
            {                cell.textField.text=[dictBinding objectForKey:@"OrderValue"];
            }
            return cell;
  
            
        }
        
    }
    
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
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
    
    //   [[itemData valueForKey:kLogKey] intValue]
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    
    
    // update our data model
    NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
    [itemData setValue:[NSString stringWithFormat:@"%ld",(long)row] forKey:kValueKey];
    // update the cell's date string
    cell.detailTextLabel.text = [[NSString stringWithFormat:@"%@",self.arrayStores[row][@"store_name"]] stringByConvertingHTMLToPlainText];
  //  [self RemovePickerios7];
}

#pragma mark - UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag!=2)
    [self.navigationController popViewControllerAnimated:YES];
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


- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

-(void)save
{
    [self.view endEditing:YES];
    [self.tableView setContentOffset:CGPointMake(0, 44)];
    NSLog(@"%@",self.dataArray);
    if ([self hasInlineDatePicker])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Please select date." alter:@"!Please select date."]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else if (self.stringProjectId == nil)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"No project lists are available." alter:@"No project lists are available."] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        alert.tag = 1;
        
        [alert show];
    }
    else if ([dictBinding objectForKey:@"OrderNumber"]&&![dictBinding objectForKey:@"OrderValue"])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Please provide Order value." alter:@"!Please provide Order value."] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        alert.tag = 2;
        
        [alert show];
    }
    else
    {
        [self showLoadingView];
//         CustomTextFieldCell *cellTextFieldOrderNo =(CustomTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
//         CustomTextFieldCell *cellTextFieldOrderValue =(CustomTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
         CustomTextViewCell *cellTextViewComment =(CustomTextViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        
    
        
        if ([[dictBinding objectForKey:@"OrderNumber"] length]<1)
        {
            [self hideLoadingView];
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:[Language get:@"Please Fill Order Number." alter:@"Please Fill Order Number."]  message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            NSDateFormatter *dateFormeterDate=[[NSDateFormatter alloc] init];
            [dateFormeterDate setDateFormat:@"yyyy-MM-dd"];
//            [dateFormeterDate setDateFormat:@"dd-MM-yyyy"];
            NSString *stringStartDate=[dateFormeterDate stringFromDate:self.dataArray[0][kValueKey]];
            
            // NSLog(@"%@",str);
            
            NSData *imageData=UIImagePNGRepresentation(self.imageMaterial);
            
            NSString *base64EncodedString= [imageData base64EncodedStringWithOptions:0];

            if ([base64EncodedString length]<1)
            {
                base64EncodedString=@"";
            }
            
            NSError *error;
            NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
            [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
            [postDict setObject:self.stringProjectId forKey:@"project_id"];
            [postDict setObject:[self.arrayStores[[self.dataArray[1][kValueKey] intValue]][@"store_name"] stringByConvertingHTMLToPlainText] forKey:@"material_name"];
            [postDict setObject:[dictBinding objectForKey:@"OrderNumber"] forKey:@"order_no"];
            
            [postDict setObject:[dictBinding objectForKey:@"OrderValue"]?[dictBinding objectForKey:@"OrderValue"]:@""  forKey:@"order_value"];
            
//            [postDict setObject:([[dictBinding objectForKey:@"OrderValue"] length]>0)?[dictBin    ding objectForKey:@"OrderValue"]:@"" forKey:@"order_value"];
            [postDict setObject:cellTextViewComment.textView.text forKey:@"comment"];
            [postDict setObject:stringStartDate forKey:@"date"];
            [postDict setObject:base64EncodedString forKey:@"img"];
            
            if (APP_DELEGATE.isServerReachable) {
            NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
            NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_METERIAL_EXPENCES]];
            [urlRequest setTimeoutInterval:180];
            NSString *requestBody = [NSString stringWithFormat:@"JsonObject=%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
            NSData *dtosend = [requestBody dataUsingEncoding:NSUTF8StringEncoding];
            [urlRequest setHTTPBody:dtosend];
            [urlRequest setHTTPMethod:@"POST"];
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
             {
                 id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                 NSLog(@"%@",object);
                 if (error)
                 {
                     NSLog(@"Error: %@",[error description]);
                     [self hideLoadingView];
                 }
                 if ([object isKindOfClass:[NSDictionary class]] == YES)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^(void)
                                    {
                     if ([object[@"CODE"] intValue]==1)
                     {
                
                         [self goToLogView];
                         
                     }
                     else
                     {
                         [self goBackView];
                     }
                                    
            });
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
-(void)goToLogView
{
    [self hideLoadingView];// [self performSelectorOnMainThread:@selector(alertLoginFailed) withObject:nil waitUntilDone:YES];
    [[[UIAlertView alloc] initWithTitle:[Language get:@"Material Log already exists." alter:@"!Material Log already exists."] message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

}

-(void)goBackView
{
    [self hideLoadingView];
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


#pragma mark UIImagePickerController Group Starts

-(void)getPhotoActionSheet   //Action sheet
{
    UIActionSheet *actionsheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"New Photo",@"Upload from Library", nil];
    [actionsheet showInView:self.view];
}

//ActionSheet Delegate Method
- (void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [actionSheet cancelButtonIndex])
    {
        if(buttonIndex==0)
            [self methodGetImageFromCamera];
        else
            [self methodGetImageFromLibrary];
    }
    
}

-(void)methodGetImageFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        picker =[[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        // Insert the overlay:
        picker.delegate = self;
        picker.allowsEditing = YES;
        
        [self presentViewController:picker animated:YES completion:nil];

    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Device doesn't support that media source." alter:@"!Device doesn't support that media source."] delegate:nil cancelButtonTitle:@"Drat!" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)methodGetImageFromLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        picker =[[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
        
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Device doesn't support that media source." alter: @"!Device doesn't support that media source."] delegate:nil cancelButtonTitle:@"Drat!" otherButtonTitles:nil];
        [alert show];
    }
}

//UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker1 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *ActualImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *EditedImage=[info objectForKey:UIImagePickerControllerEditedImage];
    NSLog(@"Actual Image Image Width: %f,Height %f)",ActualImage.size.width,ActualImage.size.width);
    UIImage *newImage=[Helper aspectScaleImage:EditedImage toSize:CGSizeMake(500, 500)];
//    UIImage *newImage=EditedImage;
    self.imageMaterial=newImage;
   // [picker.view removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker1
{
    //[picker.view removeFromSuperview];
   [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIImagePickerController Group Ends





@end


