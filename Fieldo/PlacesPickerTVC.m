//
//  PlacesPickerTVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/28/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "PlacesPickerTVC.h"


@interface PlacesPickerTVC ()

@end

@implementation PlacesPickerTVC


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
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location=locations[0];
    self.lattitudeStr= [NSString stringWithFormat:@"%g\u00B0",location.coordinate.latitude];
    self.longitudeStr = [NSString stringWithFormat:@"%g\u00B0",location.coordinate.longitude];
    
    [self fetchNearByPlaces];
    
    [self.locationManager stopUpdatingLocation];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    
    return cell;
}

-(void)fetchNearByPlaces
{
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%@,%@&radius=500&sensor=true&key=AIzaSyDkSx4Rk-kwiO_RbaBmxLjBGwmnM3h8WC4",self.lattitudeStr,self.longitudeStr];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"url string is:%@",urlString);
    self.arrayPlaces = [self fetchNearPlacesUsingGoogleApi:urlString];
    [self.tableView reloadData];
}




-(NSMutableArray *)fetchNearPlacesUsingGoogleApi:(NSString *)requestString
{
	NSMutableArray *responseArray = [[NSMutableArray alloc] init];
	NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:requestString] encoding:NSUTF8StringEncoding error:NULL];
	if (result)
    {
        NSError *error;
        NSMutableDictionary *dict =  [NSJSONSerialization JSONObjectWithData: [result dataUsingEncoding:NSUTF8StringEncoding]
                                        options: NSJSONReadingMutableContainers
                                          error: &error];
		NSMutableArray *resultArray = [dict valueForKey:@"results"];
		for(NSDictionary *dictionary in resultArray) {
			NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
			[resultDict setObject:[dictionary valueForKey:@"name"] forKey:@"NAME"];
			[resultDict setObject:[dictionary valueForKey:@"id"] forKey:@"REFERENCE"];
            if (![[dictionary valueForKey:@"vicinity"]length]) {
                [resultDict setObject:[dictionary valueForKey:@"name"] forKey:@"ADDRESS"];
            }
            else {
                [resultDict setObject:[dictionary valueForKey:@"vicinity"] forKey:@"ADDRESS"];
                
            }
            [resultDict setObject:[NSNumber numberWithDouble:[[[[dictionary valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"] doubleValue]] forKey:@"latitude"];
            [resultDict setObject:[NSNumber numberWithDouble:[[[[dictionary valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"] doubleValue]] forKey:@"longitude"];
            [responseArray addObject:resultDict];
			resultDict = nil;
		}
	}
	return responseArray;
}

@end
