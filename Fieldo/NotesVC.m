//
//  NotesVCViewController.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/13/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "NotesVC.h"
#import "PersistentStore.h"
#import "NoteRecord.h"
#import "CustomNoteCell.h"
#import "NoteDetailsVC.h"
#import "ComposeMessageVC.h"
#import "MBProgressHUD.h"
#import "Language.h"
#import "NSString+HTML.h"

@interface NotesVC ()

@end


@implementation NotesVC


- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
[self deleteNote:indexPath];
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
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;

    [self hideLoadingView];
    [self.tableView reloadData];

}




-(void)hideLoadingView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


-(NSMutableArray *)arrayNotes
{
    if (!_arrayNotes)
    {
        NSError *error;
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
        [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
        if (APP_DELEGATE.isServerReachable) {
        
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_NOTES_LIST]];
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
                     [self performSelectorOnMainThread:@selector(showAlertNotes) withObject:nil waitUntilDone:YES];
                 }
                 else
                 {
                     NSLog(@"Array from server");
                     NSMutableArray *objEvents = object[@"data"];
                     NSMutableArray *notes = [@[] mutableCopy];
                     for(NSMutableDictionary *objEvent in objEvents)
                     {
                         @autoreleasepool
                         {
                             NoteRecord *note=[[NoteRecord alloc] init];
                             note.noteId=objEvent[@"notes_id"];
                             note.noteSubject=objEvent[@"subject"];
                             note.noteWorkerName=objEvent[@"worker_name"];
                             note.noteManegerName=objEvent[@"mname"];
                             note.noteDate=objEvent[@"created_at"];
                             note.isSender=[objEvent[@"isSender"] boolValue];
                             note.hasRead=[objEvent[@"status"] boolValue];

                             [notes addObject:note];
                             note=nil;
                         }
                         
                     }
                     self.arrayNotes=notes;
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
    return _arrayNotes;
    
}


#pragma mark - UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        // [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    
    
    self.arrayNotes=nil;
    [self showLoadingView];

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

    self.title=[Language get:@"Notes List" alter:@"!Notes List"];
    
    
    [self.tableView registerClass:[CustomNoteCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"button"];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];



//    UIBarButtonItem *composeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(Compose)];
//    NSArray *actionButtonItems = @[self.editButtonItem,composeItem];
//    self.navigationItem.rightBarButtonItems = actionButtonItems;

    
    //create the button and assign the image
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"Notes.png"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 30, 30);
    [button addTarget:self action:@selector(Compose) forControlEvents:UIControlEventTouchUpInside];
    
    //create a UIBarButtonItem with the button as a custom view
    UIBarButtonItem *composeItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    NSArray *actionButtonItems = @[composeItem,self.editButtonItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;


}


-(void)Compose
{
    ComposeMessageVC *composeMessageVC=[[ComposeMessageVC alloc] init];
    [self.navigationController pushViewController:composeMessageVC animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayNotes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    static NSString *CellIdentifier = @"CellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NoteRecord *note=self.arrayNotes[indexPath.row];
    
    cell.detailTextLabel.text=note.isSender? [note.noteWorkerName stringByConvertingHTMLToPlainText] :[note.noteManegerName stringByConvertingHTMLToPlainText];
    cell.textLabel.text=[note.noteSubject stringByConvertingHTMLToPlainText];
    
    UILabel  *labelNoteDate = [[UILabel alloc] initWithFrame:CGRectMake(160, 35, 150, 25)];
    labelNoteDate.textAlignment=NSTextAlignmentRight;
    labelNoteDate.font = [UIFont fontWithName:@"Arial" size:12];
    labelNoteDate.text=note.noteDate;
    cell.accessoryView=labelNoteDate;
    
    if (!note.hasRead) {
        cell.backgroundColor=[UIColor clearColor];
    }
    else
        cell.backgroundColor=[UIColor lightGrayColor];
    
    return cell;


}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return UITableViewCellEditingStyleDelete;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        NoteRecord *note=self.arrayNotes[indexPath.row];
         NoteDetailsVC *noteDetailsVC=[[NoteDetailsVC alloc] init];
         noteDetailsVC.stringNoteId=note.noteId;
        [self.navigationController pushViewController:noteDetailsVC animated:YES];
}





-(void)deleteNote:(NSIndexPath *)indexPath
{
    
    
    [self showLoadingView];
    
       NoteRecord *note=self.arrayNotes[indexPath.row];
    
    
        NSError *error;
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
        [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
        [postDict setObject:note.noteId forKey:@"notes_id"];
    
        if (APP_DELEGATE.isServerReachable) {
      
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_DELETE_NOTE]];
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
                      [self performSelectorOnMainThread:@selector(showAlertNotes) withObject:nil waitUntilDone:YES];
                 }
                 else
                 {
                     
                     self.arrayNotes=nil;
                     [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
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


- (void)showAlertNotes
{
    [self hideLoadingView];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"No notes found." alter:@"!No notes found."]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    alert.tag = 1;
    
    [alert show];
}


@end
