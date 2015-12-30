//
//  OutOfTheOfficeVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/18/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "OutOfTheOfficeVC.h"
#import "PersistentStore.h"
#import "Language.h"
#import "CustomDatePickerCell.h"
#import "CustomPickerCell.h"
#import "CustomTextViewCell.h"
#import "LeaveListTVC.h"

#import "NSString+HTML.h"

#define kDatePickerTag              99
#define kSimplePickerTag            98


#define KStartTimeRow   0
#define KEndTimeRow     1
#define KLogTimeRow     2

static NSString *kDateCellID = @"dateCell";        //the cells with the start or end date
static NSString *kDatePickerID = @"datePicker";    //the cell containing the date picker
static NSString *kPickerID = @"simplePicker";      //the cell containing the one component picker
static NSString *kTextViewID = @"textView";
static NSString *kButtonID = @"buttonId";


#pragma mark -

@interface OutOfTheOfficeVC ()<customTextCellDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;


@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;



@end


@implementation OutOfTheOfficeVC

@synthesize leaveBO;
-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger) getIndex:(NSString *)reason
{
    NSInteger index=0;
    NSString *getPlainString=[reason stringByConvertingHTMLToPlainText];
    if ([getPlainString isEqualToString:@"Sick Leave"]||[getPlainString isEqualToString:@"Sjukfrånvaro"]||[getPlainString isEqualToString:@"Sykefravær"]) {
        index=0;
    }
    else if ([getPlainString isEqualToString:@"Holiday"]||[getPlainString isEqualToString:@"Semester"]||[getPlainString isEqualToString:@"Ferie"]) {
        index=1;
    }
    else if ([getPlainString isEqualToString:@"Parental Leave"]||[getPlainString isEqualToString:@"Föräldraledighet"]||[getPlainString isEqualToString:@"Foreldrepermisjon"]) {
        index=2;
    }
    else if ([getPlainString isEqualToString:@"Other"]||[getPlainString isEqualToString:@"Annat"]||[getPlainString isEqualToString:@"Annet"]) {
        index=3;
    }
    return index;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=[Language get:@"Out of the Office" alter:@"!Out of the Office"];
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    
    self.arrayLeaveReason=[[NSMutableArray alloc] init];
    [self.arrayLeaveReason addObject:[Language get:@"Sick Leave" alter:@"!Sick Leave"]];
    [self.arrayLeaveReason addObject:[Language get:@"Holiday" alter:@"!Holiday"]];
    [self.arrayLeaveReason addObject:[Language get:@"Parental Leave" alter:@"!Parental Leave"]];
    [self.arrayLeaveReason addObject:[Language get:@"Other" alter:@"!Other"]];
    
    // setup our data source
    if (leaveBO) {
        NSDateFormatter *formatter;
        NSDate        *dateFrom;
        NSDate        *dateTo;

        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
//        [formatter setDateFormat:@"dd-MM-yyyy"];
        
        dateFrom = [formatter dateFromString:leaveBO.from];
        dateTo=[formatter dateFromString:leaveBO.to];
        
        
        NSInteger index=[self getIndex:leaveBO.reason];
        
        NSString *indexVal=[NSString stringWithFormat:@"%ld",(long)index];
        
        NSMutableDictionary *itemOne =  [@  { kTitleKey : [Language get:@"Start Date:" alter:@"!Start Date:"], kValueKey : dateFrom} mutableCopy];
        NSMutableDictionary *itemTwo =  [@  { kTitleKey : [Language get:@"End Date:" alter:@"!End Date:"], kValueKey : dateTo } mutableCopy];
        NSMutableDictionary *itemThree =[@  { kTitleKey : [Language get:@"Reason:" alter:@"!Reason:"],kValueKey:indexVal } mutableCopy];
        NSMutableDictionary *itemFour = [@  { kTitleKey : [Language get:@"Message" alter:@"!Message"],kValueKey: [leaveBO.desc stringByConvertingHTMLToPlainText] } mutableCopy];
        NSMutableDictionary *itemFive = [@  { kTitleKey : @"(other item2)" } mutableCopy];
        
        self.dataArray = @[itemOne, itemTwo, itemThree, itemFour, itemFive];
    }
    else
    {
    NSMutableDictionary *itemOne =  [@  { kTitleKey : [Language get:@"Start Date:" alter:@"!Start Date:"], kValueKey : [NSDate date] } mutableCopy];
    NSMutableDictionary *itemTwo =  [@  { kTitleKey : [Language get:@"End Date:" alter:@"!End Date:"], kValueKey : [NSDate date] } mutableCopy];
    NSMutableDictionary *itemThree =[@  { kTitleKey : [Language get:@"Reason:" alter:@"!Reason:"],kValueKey: @"0" } mutableCopy];
    NSMutableDictionary *itemFour = [@  { kTitleKey : [Language get:@"Message" alter:@"!Message"],kValueKey: @"" } mutableCopy];
    NSMutableDictionary *itemFive = [@  { kTitleKey : @"(other item2)" } mutableCopy];
    
    self.dataArray = @[itemOne, itemTwo, itemThree, itemFour, itemFive];
    }
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"dd-MM-YYYY"];
//    [self.dateFormatter setDateStyle:NSDateFormatterLongStyle];    // show short-style date format
//    [self.dateFormatter setDateFormat:@"dd:MM:yyyy"];
    [self.dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeChanged:) name:NSCurrentLocaleDidChangeNotification object:nil];
    
    [self.tableView registerClass:[CustomDatePickerCell class] forCellReuseIdentifier:kDatePickerID];
    [self.tableView registerClass:[CustomPickerCell class] forCellReuseIdentifier:kPickerID];
    [self.tableView registerClass:[CustomTextViewCell class] forCellReuseIdentifier:kTextViewID];
    
    self.navigationItem.hidesBackButton=YES;
    
    if (leaveBO==nil) {
        UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:[Language get:@"Edit" alter:@"!Edit"] style:UIBarButtonItemStylePlain target:self
                                                                      action:@selector(NewProjects:)];
        self.navigationItem.rightBarButtonItem = backButton;

    }
    UIBarButtonItem* backButton1 = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(NewProjects1:)];
    self.navigationItem.leftBarButtonItem = backButton1;
}

-(void) NewProjects:(id)sender
{
    LeaveListTVC *leave=[[LeaveListTVC alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:leave animated:YES];
}
-(void) NewProjects1:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSCurrentLocaleDidChangeNotification object:nil];
}



#pragma mark - Locale
- (void)localeChanged:(NSNotification *)notif
{
    [self.tableView reloadData];
}


- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasDatePicker = NO;
    
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkDatePickerCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];
    UIDatePicker *checkDatePicker = (UIDatePicker *)[checkDatePickerCell viewWithTag:kDatePickerTag];
    
    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}

- (void)updateDatePicker
{
    if (self.datePickerIndexPath != nil)
    {
        if (self.datePickerIndexPath.row==1 || self.datePickerIndexPath.row==2)
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

- (BOOL)hasInlineDatePicker
{
    return (self.datePickerIndexPath != nil);
}

- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return ([self hasInlineDatePicker] && self.datePickerIndexPath.row == indexPath.row);
}

- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath
{
    BOOL hasDate = NO;
    
    if ((indexPath.row == KStartTimeRow) || (indexPath.row == KEndTimeRow) ||
        (indexPath.row == KLogTimeRow || ([self hasInlineDatePicker] && (indexPath.row == KLogTimeRow + 1))))
    {
        hasDate = YES;
    }
    
    return hasDate;
}




#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self indexPathHasPicker:indexPath])
        return 216.0;
    else if ((indexPath.row==[self.dataArray count]-2 && ![self hasInlineDatePicker])  || (indexPath.row==[self.dataArray count]-1 && [self hasInlineDatePicker]))
        return 100;
    else
        return 44;
    
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self hasInlineDatePicker])
    {
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
        if(self.datePickerIndexPath.row==1 || self.datePickerIndexPath.row==2 )
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
            cell.cellDatePicker.minimumDate=[NSDate date];
            cell.cellDatePicker.tag=99;
            cell.cellDatePicker.datePickerMode=UIDatePickerModeDate;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
        }
        else
        {
            static NSString *cellIdentifier = @"cell";
            CustomPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:kPickerID];
            if (cell == nil)
            {
                cell = [[CustomPickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.pickerView.tag=kSimplePickerTag;
            [cell.pickerView setDelegate:self];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
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
        
        if (indexPath.row==0 || indexPath.row==1 || ((indexPath.row==2) && (self.datePickerIndexPath.row==1)))
            cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[itemData valueForKey:kValueKey]];
        else
        {
            NSLog(@"Picker Value %@",self.arrayLeaveReason[[[itemData valueForKey:kValueKey] intValue]]);
            cell.detailTextLabel.text = self.arrayLeaveReason[[[itemData valueForKey:kValueKey] intValue]];
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
            // Add a UITextField
            cell.textView.enablesReturnKeyAutomatically = NO;
            cell.textView.text = [itemData valueForKey:(leaveBO)?kValueKey:kTitleKey];
            cell.textView.delegate=self;
            cell.TextDelegate=self;
            if(!leaveBO)
            cell.textView.textColor=[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.0];
            cell.textView.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [cell.contentView addSubview:cell.textView];
            return cell;
            
        }
        else
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
            [button addTarget:self action:@selector(Send) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.font=[UIFont systemFontOfSize:16];
            [cell.contentView addSubview:button];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            
            return cell;
        }
        
        
    }
    
}

- (void) Send
{
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];    // show short-style date format
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSLog(@"%@",self.dataArray);
    
    if ([self hasInlineDatePicker])
    {
        
        if (self.datePickerIndexPath.row==1)
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[Language get:@"Select Start Date." alter:@"!Select Start Date."] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
 
        }
        else if(self.datePickerIndexPath.row==2)
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[Language get:@"Select End Date." alter:@"!Select End Date."]  message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[Language get:@"Select Reason For Leave." alter:@"!Select Reason For Leave."]  message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    else
    {
        
        //        else if (differenceBtwStartDateAndEndDate>0 && [self.arrayLeaveReason[[self.dataArray[2][kValueKey] intValue]]isEqualToString:[Language get:@"Sick Leave" alter:@"!Sick Leave"]])
        //        {
        //            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Sick Leave cannot exceed for more than 1 day." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        //            [alert show];
        //
        //        }

        NSTimeInterval differenceBtwStartDateAndEndDate = [self.dataArray[1][kValueKey] timeIntervalSinceDate:self.dataArray[0][kValueKey]];
        if (differenceBtwStartDateAndEndDate<0)
        {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[Language get:@"End Date should not be earlier than the Start Date." alter:@"!End Date should not be earlier than the Start Date."] message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
        }
        else
        {
        NSString *stringStartDate=[dateFormatter stringFromDate:self.dataArray[0][kValueKey]];
        NSString *stringEndDate=[dateFormatter stringFromDate:self.dataArray[1][kValueKey]];
        
        
        
        CustomTextViewCell *cellTextView =(CustomTextViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        
        
        NSError *error;
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
        [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
        [postDict setObject:stringStartDate forKey:@"from"];
        [postDict setObject:stringEndDate forKey:@"to"];
        [postDict setObject:self.arrayLeaveReason[[self.dataArray[2][kValueKey] intValue]] forKey:@"reason"];
        [postDict setObject:cellTextView.textView.text  forKey:@"desc"];
        
            NSDateFormatter *dateFormeterDate=[[NSDateFormatter alloc] init];
            [dateFormeterDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSString *curDate=[dateFormeterDate stringFromDate:[NSDate date]];
            
            [postDict setObject:curDate forKey:@"date"];
            
            
        if (leaveBO) {
            [postDict setObject:leaveBO.leave_id forKey:@"leave_id"];

        }
        if (APP_DELEGATE.isServerReachable) {
        
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
            
            NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:(leaveBO)?URL_EDIT_LEAVE:URL_OUT_OF_OFFICE]];
        [urlRequest setTimeoutInterval:180];
        NSString *requestBody = [NSString stringWithFormat:@"JsonObject=%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
            NSData *data=[requestBody dataUsingEncoding:NSUTF8StringEncoding];
        [urlRequest setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *newStr = [NSString stringWithUTF8String:[data bytes]];
        NSLog(@"%@",newStr);
        [urlRequest setHTTPMethod:@"POST"];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
             NSLog(@"%@",object);
             if (error)
             {
                 NSLog(@"Error: %@",[error description]);
             }
             if ([object isKindOfClass:[NSDictionary class]] == YES)
             {
                 if ([object[@"CODE"] intValue]==1)
                 {
                     [self performSelectorOnMainThread:@selector(showPop) withObject:nil waitUntilDone:NO];
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
//            [self hideLoadingView];
            [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        }
    }
    }
}

-(void)showPop
{
    [[[UIAlertView alloc]initWithTitle:[Language get:@"Leave already applied." alter:@"!Leave already applied." ] message:[Language get:@"You can edit the Leave." alter:@"!You can edit the Leave."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.arrayLeaveReason count];
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.arrayLeaveReason[row];
}




- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    BOOL before = NO;
    if ([self hasInlineDatePicker])
    {
        before = self.datePickerIndexPath.row < indexPath.row;
    }
    
    BOOL sameCellClicked = (self.datePickerIndexPath.row - 1 == indexPath.row);
    
    if ([self hasInlineDatePicker])
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }
    
    if (!sameCellClicked)
    {
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:0];
        
        NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0]];
        
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
    
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



- (void)dateAction:(id)sender
{
    NSIndexPath *targetedCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    UIDatePicker *targetedDatePicker = sender;
    
    NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
    [itemData setValue:targetedDatePicker.date forKey:kValueKey];
    
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:targetedDatePicker.date];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    
    NSIndexPath *targetedCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
    
    [itemData setValue:[NSString stringWithFormat:@"%ld",(long)row] forKey:kValueKey];
    cell.detailTextLabel.text = self.arrayLeaveReason[row];
    
   // [self RemovePickerios7];
    
}


-(void) ResignTextViewForTable:(UITextView *)textView1
{
    if(textView1.text.length==0)
    {
        textView1.text=[Language get:@"Message" alter:@"!Message"];
        textView1.textColor=[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.0];
    }
    
    [textView1 resignFirstResponder];
    self.tableView.contentOffset=CGPointMake(0, 0);
}


#pragma mark TextView Delegates
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    if([text isEqualToString:@"\n"])
//    {
//        if (![textView.text length])
//        {
//            textView.text = [Language get:@"Message" alter:@"!Message"];
//            textView.textColor=[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.0];
//        }
//        [textView resignFirstResponder];
//    }
//    
//    
//    return YES;
//}

- (BOOL)textViewShouldReturn:(UITextView *)textView
{
    if (![textView.text length])
    {
        textView.text = [Language get:@"Message" alter:@"!Message"];
        textView.textColor=[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.0];
    }
    [textView resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self RemovePickerios7];
    if([textView.text isEqualToString:[Language get:@"Message" alter:@"!Message"]])
    {
        textView.textColor=[UIColor blackColor];
        textView.text = nil;
    }
    self.tableView.contentOffset=CGPointMake(0, 160);
    return YES;
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

