//
//  workerViewController.m
//  Fieldo
//
//  Created by Vishal on 17/11/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "workerViewController.h"
#import "PersistentStore.h"
#import "AppDelegate.h"
#import "Language.h"
@interface workerViewController ()
{
NSMutableArray *arrayFilter;
}
@end

@implementation workerViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    m_workerArray=[[NSMutableArray alloc]init];
    [self getAllWorkers];
    selectedWorkers=@"";
    selectedWorkerIds=@"";
    
    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithTitle:[Language get:@"Done" alter:@"!Done"] style:UIBarButtonItemStylePlain target:self action:@selector(saveSelection)];
    [self.navigationItem setRightBarButtonItem:item];
    
    delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [self.navigationItem setTitle:[Language get:@"Select Workers" alter:@"!Select Workers"]];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [self hideLoadingView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

-(void)saveSelection
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getAllWorkers
{
    [self showLoadingView];
    
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
    }
    else
    {
        [postDict setObject:[PersistentStore getCustomerID] forKey:@"cust_id"];
    }
    
    
    if (APP_DELEGATE.isServerReachable) {
        
        NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PROJECTS_LIST]];
        
        if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
        {
            //urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PROJECTS_LIST]];
            //   urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PROJECTS_LIST]];//]@"http://fieldo.se/api/workerprojectlist.php"]];
            
            urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_GET_WORKERS]];
            
            
        }
        else
        {
            // urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_GET_CUSTOMERS]];
            
        }
    
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
                     [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
                 }
                 else
                 {
                     
                     NSArray *objEvents=object[@"data"];
                     [m_workerArray addObjectsFromArray:objEvents];
                     dispatch_async(dispatch_get_main_queue(), ^(void)
                                    {
                                        [self hideLoadingView];
                                        [self.m_tableView reloadData];
                                        
                                    });
                     
                 }
                 
             }
         }];
    }
    else
    {
        // [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    
    
    
}

- (void) showAlert
{
    // [self hideLoadingView];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"No data found." alter:@"!No data found."]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    alert.tag = 1;
    
    [alert show];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchBar.text.length>0)
{
    [searchBar setShowsCancelButton:YES];
    
    isSearching = YES;
}
else
{
    isSearching = NO;
}
    
    [arrayFilter removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"worker_name beginswith[c] %@", searchBar.text];
     
    arrayFilter = [NSMutableArray arrayWithArray:[m_workerArray filteredArrayUsingPredicate:predicate]];
    
    [self.m_tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [self.m_tableView reloadData];
}




#pragma mark - TABLEVIEW METHODS
#pragma mark Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    if (arrayFilter.count)
        return arrayFilter.count;
    else
        if(isSearching)
            return 0;
        else
            return [m_workerArray count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ci = @"ci";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:ci];
    
    if (cell == nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    for(UIView *v in cell.contentView.subviews)
        [v removeFromSuperview];
    
    [tableView setShowsVerticalScrollIndicator:NO];
    cell.textLabel.font=[UIFont systemFontOfSize:15];
    
    if (arrayFilter.count)
    {
        cell.textLabel.text=[[arrayFilter objectAtIndex:indexPath.row] objectForKey:@"worker_name"];
        if(arrayFilter.count>0)
        {
            NSArray *array=delegate.m_workersArrayGlobal;
            NSPredicate *predicate=[NSPredicate predicateWithFormat:@"worker_id CONTAINS[cd] %@",[[arrayFilter objectAtIndex:indexPath.row] objectForKey:@"worker_id"]];
            NSArray *filtered= [array filteredArrayUsingPredicate:predicate];
            if(filtered.count>0)
            {
                cell.accessoryType=UITableViewCellAccessoryCheckmark;
            }
        }
        
    }
    else
    {
        if(isSearching)
        {
            
        }
        else
        {
            cell.textLabel.text=[[m_workerArray objectAtIndex:indexPath.row] objectForKey:@"worker_name"];
            
            
            if(delegate.m_workersArrayGlobal.count>0)
            {
                NSArray *array=delegate.m_workersArrayGlobal;
                NSPredicate *predicate=[NSPredicate predicateWithFormat:@"worker_id CONTAINS[cd] %@",[[m_workerArray objectAtIndex:indexPath.row] objectForKey:@"worker_id"]];
                NSArray *filtered= [array filteredArrayUsingPredicate:predicate];
                if(filtered.count>0)
                {
                    cell.accessoryType=UITableViewCellAccessoryCheckmark;
                }
            }
        }
    }
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    
    if(cell.accessoryType==UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType=UITableViewCellAccessoryNone;
        NSMutableDictionary *dataDict=[[NSMutableDictionary alloc]init];

        if(isSearching)
        {
            [dataDict setObject:[[arrayFilter objectAtIndex:indexPath.row] objectForKey:@"worker_name"] forKey:@"worker_name"];
            [dataDict setObject:[[arrayFilter objectAtIndex:indexPath.row] objectForKey:@"worker_id"] forKey:@"worker_id"];
        }
        else
        {
        [dataDict setObject:[[m_workerArray objectAtIndex:indexPath.row] objectForKey:@"worker_name"] forKey:@"worker_name"];
        [dataDict setObject:[[m_workerArray objectAtIndex:indexPath.row] objectForKey:@"worker_id"] forKey:@"worker_id"];
        }
        [delegate.m_workersArrayGlobal removeObject:dataDict];
        
    }
    else
    {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;

        NSMutableDictionary *dataDict=[[NSMutableDictionary alloc]init];
        
        if(isSearching)
        {
            [dataDict setObject:[[arrayFilter objectAtIndex:indexPath.row] objectForKey:@"worker_name"] forKey:@"worker_name"];
            [dataDict setObject:[[arrayFilter objectAtIndex:indexPath.row] objectForKey:@"worker_id"] forKey:@"worker_id"];
        }
        else
        {
        [dataDict setObject:[[m_workerArray objectAtIndex:indexPath.row] objectForKey:@"worker_name"] forKey:@"worker_name"];
        [dataDict setObject:[[m_workerArray objectAtIndex:indexPath.row] objectForKey:@"worker_id"] forKey:@"worker_id"];
        }
        [delegate.m_workersArrayGlobal addObject:dataDict];
        
        
    }
    
    
}


@end
