//
//  customerViewController.m
//  Fieldo
//
//  Created by Vishal on 17/11/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "customerViewController.h"
#import "PersistentStore.h"
#import "Language.h"
#import "MBProgressHUD.h"
@interface customerViewController ()
{
    NSMutableArray *arrayFilter;
}
@end

@implementation customerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationItem setTitle:[Language get:@"Select Customer" alter:@"!Select Customer"]];
    
    m_customerArray=[[NSMutableArray alloc]init];
    
    [self getAllCustomers];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self hideLoadingView];
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


-(void)getAllCustomers
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
          
            urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_GET_CUSTOMERS]];
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
                 [self hideLoadingView];
                 NSLog(@"Error: %@",[error description]);
             }
             if ([object isKindOfClass:[NSDictionary class]] == YES)
             {
                 if ([object[@"CODE"] intValue]==1)
                 {
                     
                     [self hideLoadingView];

                     [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
                 }
                 else
                 {
                     NSArray *objEvents=object[@"data"];
                     NSLog(@"%@",[objEvents objectAtIndex:0]);
                     [Customer_Details setObject:[objEvents objectAtIndex:0] forKey:@"Customer_Details"];
                     [Customer_Details synchronize];
                     
                     [m_customerArray addObjectsFromArray:objEvents];
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
        [self hideLoadingView];

       // [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    

    
}

- (void) showAlert
{
    // [self hideLoadingView];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"No data found." alter:@"No data found."]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cust_name beginswith[c] %@", searchBar.text];
    
    arrayFilter = [NSMutableArray arrayWithArray:[m_customerArray filteredArrayUsingPredicate:predicate]];
    
    [self.m_tableView reloadData];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.m_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 44;
//}
//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 5, self.m_ownerTable.frame.size.width, 54)];
//    UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(0,0,headerView.frame.size.width,headerView.frame.size.height)];
//    [imageview setImage:[UIImage imageNamed:@"header-bg"]];
//    [headerView addSubview:imageview];
//
//    UILabel *categoryLabel=[[UILabel alloc]initWithFrame:CGRectMake(45, -5, 220, 40)];
//    categoryLabel.backgroundColor=[UIColor clearColor];
//    categoryLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:22];
//    categoryLabel.text=@"Projects";
//    categoryLabel.textAlignment=1;
//    categoryLabel.textColor=[UIColor whiteColor];
//    [headerView addSubview:categoryLabel];
//    return headerView;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (arrayFilter.count)
        return arrayFilter.count;
    else
        if(isSearching)
        return 0;
    else
        return [m_customerArray count];
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
        cell.textLabel.text=[[arrayFilter objectAtIndex:indexPath.row] objectForKey:@"cust_name"];
    else
    {
        if(isSearching)
        {
            
        }
            else
        cell.textLabel.text=[[m_customerArray objectAtIndex:indexPath.row] objectForKey:@"cust_name"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
     if (arrayFilter.count)
     {
        [[NSUserDefaults standardUserDefaults]setObject:[[arrayFilter objectAtIndex:indexPath.row] objectForKey:@"cust_id"] forKey:@"customerID"];
        [[NSUserDefaults standardUserDefaults]setObject:[[arrayFilter objectAtIndex:indexPath.row] objectForKey:@"cust_name"] forKey:@"customerNAME"];
     }
    else
    {
        [[NSUserDefaults standardUserDefaults]setObject:[[m_customerArray objectAtIndex:indexPath.row] objectForKey:@"cust_id"] forKey:@"customerID"];
        [[NSUserDefaults standardUserDefaults]setObject:[[m_customerArray objectAtIndex:indexPath.row] objectForKey:@"cust_name"] forKey:@"customerNAME"];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
