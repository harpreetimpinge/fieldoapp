//
//  NotesDetailVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/13/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "NoteDetailsVC.h"
#import "MBProgressHUD.h"
#import "Language.h"
#import "NSString+HTML.h"
#define CellIdentifier @"cell"



@interface NoteDetailsVC ()

@end

@implementation NoteDetailsVC

-(void)showLoadingView
{
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = YES;
    hud.labelText = @"Loading...";
    hud.dimBackground = YES;
}

-(void)hideLoadingView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}



-(NSMutableArray *)arrayNoteDetail
{
    if (!_arrayNoteDetail)
    {
        NSError *error;
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
        [postDict setObject:self.stringNoteId forKey:@"notes_id"];
        if (APP_DELEGATE.isServerReachable) {
     
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_NOTES_DETAIL]];
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
                     //[self performSelectorOnMainThread:@selector(alertLoginFailed) withObject:nil waitUntilDone:YES];
                 }
                 else
                 {
                     NSLog(@"Array from server");
                     NSMutableArray *objEvents = object[@"data"];
                     NSMutableArray *arrayTemp=[[NSMutableArray alloc] init];
                     [arrayTemp addObject:objEvents[0][@"subject"]];
                     [arrayTemp addObject:objEvents[0][@"msg"]];
                     
                     
                     
                     if (![objEvents[0][@"isSender"] boolValue])
                     [arrayTemp addObject:objEvents[0][@"mname"]];
                     else
                     [arrayTemp addObject:objEvents[0][@"worker_name"]];
    
                     
                     self.arrayNoteDetail=arrayTemp;
                     [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:NO];
                     
                     
                     
                     
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
    return _arrayNoteDetail;
    
}



-(void)refreshTable
{
    [self hideLoadingView];
    [self.tableView reloadData];
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
    [self showLoadingView];
    self.title=[Language get:@"Note Detail" alter:@"!Note Detail"];

    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];

    self.arrayCellKeys=[[NSMutableArray alloc] init];
    [self.arrayCellKeys addObject:[Language get:@"Subject" alter:@"!Subject"]];
    [self.arrayCellKeys addObject:[Language get:@"Message" alter:@"!Message"]];
    [self.arrayCellKeys addObject:[Language get:@"Sender" alter:@"!Sender"]];
                        


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

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayNoteDetail count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text=self.arrayCellKeys[indexPath.row];
    cell.textLabel.textColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
    cell.textLabel.font=[UIFont systemFontOfSize:10];
    cell.detailTextLabel.text=[self.arrayNoteDetail[indexPath.row] stringByConvertingHTMLToPlainText];
    cell.detailTextLabel.font=[UIFont systemFontOfSize:14];
    
    
   
    return cell;
}



@end