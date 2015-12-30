//
//  StoresVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 10/30/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "StoresVC.h"
#import "StoreDetailsTVC.h"
#import "MBProgressHUD.h"
#import "Language.h"
#import "PersistentStore.h"
#import "NSString+HTML.h"

@interface StoresVC ()

@end

@implementation StoresVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)showLoadingView
{
    self.tableView.hidden = YES;
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = YES;
    hud.labelText =@"Loading...";
    hud.dimBackground = YES;
    
}

-(void)refreshTable
{
    [self.tableView reloadData];
    [self hideLoadingView];
    
}


-(void)hideLoadingView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}



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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  56.0;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
   // [self showLoadingView];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.navigationItem.title=[Language get:@"Stores" alter:@"!Stores"];
}

#pragma mark - Table view data source

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayStores count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"std"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text=[self.arrayStores[indexPath.row][@"store_name"] stringByConvertingHTMLToPlainText];
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    StoreDetailsTVC *storeDetailsTVC=[[StoreDetailsTVC alloc] initWithNibName:nil bundle:nil];
    storeDetailsTVC.stringStoreId=self.arrayStores[indexPath.row][@"store_id"];
    storeDetailsTVC.title=[selectedCell.textLabel.text stringByConvertingHTMLToPlainText];
    [self.navigationController pushViewController:storeDetailsTVC animated:YES];
}



@end
