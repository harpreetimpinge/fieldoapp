//
//  LocationListingTVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 3/20/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "LocationListingTVC.h"
#import "LocationListBO.h"
#import "Language.h"
#import "MBProgressHUD.h"
@interface LocationListingTVC ()

@end

@implementation LocationListingTVC
@synthesize referenceNameArray,SearchedLocation;
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
    self.title=[Language get:@"Search Location" alter:@"!Search Location"];
    Connect=[[ConnectionManager alloc]init];
    SearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    self.tableView.tableHeaderView = SearchBar;
    
    SearchBar.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- TableView Methods
#pragma mark-

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.referenceNameArray.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    LocationListBO *locBo=[self.referenceNameArray objectAtIndex:indexPath.row];
    cell.textLabel.text=locBo.locName;
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strNotificationName=@"LocationList";
    LocationListBO *locBo=[self.referenceNameArray objectAtIndex:indexPath.row];
    NSData *stringJson=[self GetLatLong:locBo.locName];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:stringJson options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@",dict);
    CLLocationCoordinate2D center;
    center.latitude = [[[[[[dict valueForKey:@"results"]objectAtIndex:0] valueForKey:@"geometry"]valueForKey:@"location"]valueForKey:@"lat"]doubleValue];
    center.longitude = [[[[[[dict valueForKey:@"results"]objectAtIndex:0] valueForKey:@"geometry"]valueForKey:@"location"]valueForKey:@"lng"]doubleValue];
    locBo.locCoordinates=center;
    NSDictionary *dictdata=[NSDictionary dictionaryWithObject:locBo forKey:@"LocName"];
    [[NSNotificationCenter defaultCenter] postNotificationName:strNotificationName object:nil userInfo:dictdata];
     [self.navigationController popViewControllerAnimated:YES];
}

-(void)getData:(NSString *)searchString  latitude:(NSString *)lat longitude:(NSString*)lng
{
    self.referenceNameArray = [[NSMutableArray alloc]init];
    NSString *requestString = [[NSString alloc]init];
    requestString = [NSString stringWithFormat:@"/api/place/autocomplete/json?input=%@&location=%@,%@&&radius=33000&language=en&sensor=true&key=AIzaSyDYfC8v1zl6MBS8JGefpWnFQpqsrs-eY18",searchString,lat,lng];
    if (APP_DELEGATE.isServerReachable) {
   
    [Connect getDataForFunction:requestString withCurrentTask:TASK_GET_SEARCHED andDelegate:self];
    }
    else
    {
//        [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self getData:searchText latitude:[NSString stringWithFormat:@"%f",SearchedLocation.coordinate.latitude] longitude:[NSString stringWithFormat:@"%f",SearchedLocation.coordinate.longitude]];
}

#pragma mark- Connection Manager Delegate
#pragma mark-

- (void)didFailWithError:(id)obj
{
    NSLog(@"Did Fail");
    //    responseData = [[NSMutableData alloc]init];
}

- (void)responseReceived:(id)obj
{
    NSMutableDictionary *dictData  = Connect.responseDictionary;
    NSLog(@"dictData..%@",dictData.description);
    if(Connect.currentTask == TASK_GET_SEARCHED)
    {
        NSLog(@" Receive Data");
        
        NSArray *dataArray = [dictData objectForKey:@"predictions"];
        for (NSDictionary *dict in dataArray) {
            LocationListBO *locBO=[LocationListBO new];
            locBO.locName =[dict valueForKey:@"description"];
            [self.referenceNameArray addObject:locBO];
        }
        [self.tableView reloadData];
    }
}

-(NSData *) GetLatLong :(NSString *)address{
    address = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * urlString =[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true",address];
    NSURL * url=[NSURL URLWithString:urlString];
    NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url];
    NSURLResponse * response;
    NSError * error;
    NSData * responseData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    return responseData;
}
@end
