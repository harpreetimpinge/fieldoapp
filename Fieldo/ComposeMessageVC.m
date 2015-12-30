//
//  ComposeMessageVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/13/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//


#import "ComposeMessageVC.h"
#import "CustomPickerCell.h"
#import "ProjectRecord.h"
#import "CustomTextFieldCell.h"
#import "CustomTextViewCell.h"
#import "PersistentStore.h"
#import "MBProgressHUD.h"
#import "Language.h"
#import "PersistentStore.h"
#import "NSString+HTML.h"

#define kPickerTag              99




#define kPickerRow        0

static NSString *kProjectCellID = @"projectCell";     // the cells with the start or end date
static NSString *kPickerID = @"projectPicker"; // the cell containing the date picker

static NSString *kTextFieldID = @"textField";
static NSString *kTextViewID = @"textView";
static NSString *kButtonID = @"button";

@interface ComposeMessageVC ()<customTextCellDelegate>

@property (assign) NSInteger pickerCellRowHeight;
@property (nonatomic, strong) NSIndexPath *pickerIndexPath;


@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ComposeMessageVC


-(void)showLoadingView
{
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showLoadingView];
    
    [self postRequestWorkersProjects];
    
    // setup our data source
    NSMutableDictionary *itemOne = [@{ kTitleKey :[Language get:@"Project:" alter:@"!Project:"],kValueKey :@"0" } mutableCopy];
    NSMutableDictionary *itemTwo = [@{ kTitleKey :[Language get:@"Title" alter:@"!Title"] ,  kValueKey  :@"" } mutableCopy];
    NSMutableDictionary *itemThree = [@{kTitleKey :[Language get:@"Message" alter:@"!Message"] ,kValueKey :@""} mutableCopy];
    NSMutableDictionary *itemFour = [@{ kTitleKey : @"Material Expense" } mutableCopy];
    
    self.dataArray = @[itemOne,itemTwo,itemThree,itemFour];
    
    self.tableView.rowHeight=50;
    self.pickerCellRowHeight =216;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];

    self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    self.navigationController.navigationBar.translucent=NO;
    self.navigationItem.title=[Language get:@"Compose" alter:@"!Compose"];

    [self.tableView registerClass:[CustomPickerCell class] forCellReuseIdentifier:kPickerID];
    [self.tableView registerClass:[CustomTextFieldCell class] forCellReuseIdentifier:kTextFieldID];
    [self.tableView registerClass:[CustomTextViewCell class]  forCellReuseIdentifier:kTextViewID];
    [self.tableView registerClass:[UITableViewCell class]  forCellReuseIdentifier:kButtonID];
    
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


#pragma mark - Table view data source

// Determines if the given indexPath has a cell below it with a UIDatePicker.
//param indexPath The indexPath to check if its cell has a UIDatePicker below it.
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
    return ([self hasInlineDatePicker] && self.pickerIndexPath.row == indexPath.row);
}

// Determines if the given indexPath points to a cell that contains the start/end dates.
//@param indexPath The indexPath to check if it represents start/end date cell.
- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath
{
    BOOL hasDate = NO;
    if ((indexPath.row == kPickerRow)  || ([self hasInlineDatePicker] && (indexPath.row == kPickerRow + 1)))
    {
        hasDate = YES;
    }
    return hasDate;
}





#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row==2 && !self.pickerIndexPath)  || (indexPath.row==3 && self.pickerIndexPath))
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
    if (self.pickerIndexPath != nil && self.pickerIndexPath.row < indexPath.row)
    {
        modelRow--;
    }
    NSDictionary *itemData = self.dataArray[modelRow];
    
    if (indexPath.row==0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kProjectCellID];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kProjectCellID];
        }
       // cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ProjectRecord *project=self.arrayProjects[[itemData[kValueKey] intValue]];
        cell.textLabel.text=itemData[kTitleKey];
        cell.detailTextLabel.text=[project.projectName stringByConvertingHTMLToPlainText];
        return cell;
 
    }
    
    else if ([self indexPathHasPicker:indexPath])
    {
        CustomPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:kPickerID];
        [cell.pickerView setDelegate:self];
        cell.pickerView.tag=kPickerTag;
        //cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    if ((indexPath.row==1 && !self.pickerIndexPath)  || (indexPath.row==2 && self.pickerIndexPath))
    {
        CustomTextFieldCell *cell =[tableView dequeueReusableCellWithIdentifier:kTextFieldID];
        cell.textField.enablesReturnKeyAutomatically = NO;
        cell.textField.delegate=self;
        cell.textField.placeholder=itemData[kTitleKey];
        cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [cell.contentView addSubview:cell.textField];

        cell.textField.placeholder = [itemData valueForKey:kTitleKey];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if((indexPath.row==2 && !self.pickerIndexPath)  || (indexPath.row==3 && self.pickerIndexPath))
    {
        CustomTextViewCell *cell =[tableView dequeueReusableCellWithIdentifier:kTextViewID];
        cell.textView.text = [itemData valueForKey:kTitleKey];
        cell.textView.delegate=self;
        cell.TextDelegate=self;
        cell.textView.textColor=[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.0];
        //cell.textLabel.textAlignment=NSTextAlignmentCenter;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kButtonID forIndexPath:indexPath];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kButtonID];
        }
        cell.backgroundColor=[UIColor clearColor];
        
        
        
        UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame=CGRectMake(50, 12, 100, 32);
        button.layer.cornerRadius = 3;
        button.layer.borderColor = [[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] CGColor];
        button.layer.borderWidth = .8f;
        [button setTitle:[Language get:@"Send" alter:@"!Send"]  forState:UIControlStateNormal];
        [button addTarget:self action:@selector(Send) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font=[UIFont systemFontOfSize:16];
        [cell.contentView addSubview:button];
        
        button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame=CGRectMake(180, 12, 100, 32);
        button.layer.cornerRadius = 3;
        button.layer.borderColor = [[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] CGColor];
        button.layer.borderWidth = .8f;
        [button setTitle:[Language get:@"Cancel" alter:@"!Cancel"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font=[UIFont systemFontOfSize:16];
        [cell.contentView addSubview:button];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        
        
        return cell;
 
    }
    
    
    
    
    
}

//
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//   
//    if([text isEqualToString:@"\n"])
//    {
//        if (![textView.text length])
//        {
//        textView.text = [Language get:@"Message" alter:@"!Message"];
//        textView.textColor=[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.0];
//        }
//        [textView resignFirstResponder];
//    }
//   
//    
//    return YES;
//}

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
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.pickerIndexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.pickerIndexPath = nil;
    }
    [self.tableView endUpdates];
}




-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self RemovePickerios7];
    return YES;
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}




-(void)goBack
{

    [self.navigationController popViewControllerAnimated:YES];
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
    return [project.projectName stringByConvertingHTMLToPlainText];
}



-(void)postRequestWorkersProjects
{
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
                 
             }
         }
         [self performSelectorOnMainThread:@selector(hideLoadingView) withObject:nil waitUntilDone:YES];

     }];
    }
    else
    {
        [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
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
    [self.view endEditing:YES];
    
 //   UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row==0)
    {
        [self displayInlineDatePickerForRowAtIndexPath:indexPath];
        
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - Actions

//User chose to change the date by changing the values inside the UIDatePicker.
//param sender The sender for this action: UIDatePicker.

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    
    // update our data model
    ProjectRecord *project=self.arrayProjects[row];
    
    NSMutableDictionary *itemData = self.dataArray[0];
    [itemData setValue:[NSString stringWithFormat:@"%ld",(long)row] forKey:kValueKey];
    
    // update the cell's date string
    cell.detailTextLabel.text =[project.projectName stringByConvertingHTMLToPlainText] ;
    
    //[self RemovePickerios7];
    
}



-(void)Send
{
    if ([self hasInlineDatePicker])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Please select project." alter:@"!Please select project."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
    NSLog(@"%@",self.dataArray);
    CustomTextFieldCell *cellTextField =(CustomTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    CustomTextViewCell *cellTextView =(CustomTextViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    NSDictionary *item=self.dataArray[0];
    ProjectRecord *project=self.arrayProjects[[item[kValueKey] intValue]];
    
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
    [postDict setObject:cellTextField.textField.text forKey:@"subject"];
    [postDict setObject:cellTextView.textView.text forKey:@"msg"];
    [postDict setObject:@"1" forKey:@"status"];
    [postDict setObject:project.projectId forKey:@"project_id"];
        
        NSDateFormatter *dateFormeterDate=[[NSDateFormatter alloc] init];
        [dateFormeterDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSString *curDate=[dateFormeterDate stringFromDate:[NSDate date]];
        
        [postDict setObject:curDate forKey:@"date"];
        
        
        if (APP_DELEGATE.isServerReachable) {
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_SEND_NOTES]];
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
            [self hideLoadingView];
            [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        }
        
        
        
    }

}








@end
