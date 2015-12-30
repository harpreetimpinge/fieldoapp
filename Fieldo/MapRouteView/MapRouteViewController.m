//
//  MapRouteViewController.m
//  Fieldo
//
//  Created by Gagan Joshi on 3/20/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "MapRouteViewController.h"
#import "Language.h"

@interface MapRouteViewController ()

@end

@implementation MapRouteViewController
@synthesize home,office;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    locmanager = [[CLLocationManager alloc] init];
    locmanager.delegate = self;
    locmanager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locmanager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locmanager startUpdatingLocation];
    [self DesignInterface];
    self.title=[Language get:@"Route Me" alter:@"!Route Me"];
}


-(void) DesignInterface
{
    
    if (mapView) {
        [mapView removeFromSuperview];
        mapView=nil;
    }
    
    mapView=[[MapViewRoute alloc]initWithFrame:self.view.bounds];
    mapView.layer.borderColor=[[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] CGColor];
    mapView.layer.borderWidth=1.0;
    //    mapView.delegate=self;
    [self.view addSubview:mapView];
    
    
    
    
    home = [[Place alloc] init] ;
    home.name = [Language get:@"My Location" alter:@"!My Location"];
//    home.description = @"Where am I.";
    home.latitude  = SearchedLocation.coordinate.latitude;
    home.longitude = SearchedLocation.coordinate.longitude;
    
    office = [[Place alloc] init] ;
    office.name = [Language get:@"Project Location" alter:@"!Project Location"];
//    office.description = @"Task Location";
    
    office.latitude = [self.dictProject[@"project_lat"] doubleValue];
    office.longitude = [self.dictProject[@"project_long"] doubleValue];
    
    [mapView showRouteFrom:home to:office];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAct:)];
    longPress.minimumPressDuration = 1;
    [mapView addGestureRecognizer:longPress];

}

- (void)longPressAct:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"longlonglonglonglong");
        CGPoint touchPoint = [recognizer locationInView:mapView.mapView];
        CLLocationCoordinate2D coordinate = [mapView.mapView convertPoint:touchPoint toCoordinateFromView:mapView.mapView];
        office.longitude = coordinate.longitude;
        office.latitude = coordinate.latitude;
        [mapView showRouteFrom:home to:office];
    }
}


#pragma mark - CLLocationManagerDelegate
#pragma mark -


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Failed to get your location." alter:@"!Failed to get your location."]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    [locmanager stopUpdatingLocation];
    if (currentLocation != nil) {
        SearchedLocation=currentLocation;
        [self DesignInterface];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
