//
//  ViewController.m
//  FieldLocation
//
//  Created by Herry on 20/11/13.
//  Copyright (c) 2013 Herry Makker. All rights reserved.
//
#import "MapView.h"

#import <GoogleMaps/GoogleMaps.h>

@implementation MapView
{
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
    GMSMutablePath *totalpath;
}
@synthesize delegate;

-(void)viewWillDisappear:(BOOL)animated
{
    [self.delegate mapViewDidFinish:self];
}


-(void)goBack
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad
{
    // Create a GMSCameraPosition that tells the map to display the
    // user's current Location at zoom level 12.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:mapView_.myLocation.coordinate zoom:12];
    mapView_ = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    mapView_.settings.consumesGesturesInView = NO;
    [self.view addSubview:mapView_];
    
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:NULL];
    //Adding a long hold Gesture to tap the Location and retrieve the coordinates
    UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame=CGRectMake(110,20,100, 37);
    [button setTitle:@"Back" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UILongPressGestureRecognizer *tapLocation = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapLocation:)];
    tapLocation.delegate=self;
    tapLocation.minimumPressDuration = 0.5f;
    
    [mapView_ addGestureRecognizer:tapLocation];
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       mapView_.myLocationEnabled = YES;
                   });
}


- (void)handleTapLocation:(UIGestureRecognizer *)locationGesture
{
    CGPoint touchPoint = [locationGesture locationInView:mapView_];
    CLLocationCoordinate2D touchMapCoordinate = [mapView_.projection coordinateForPoint:touchPoint];
    // Creates a marker in the center of the map.
    [mapView_ clear];    
    if (self.intStartLocation==1)
    {
        self.startLocation=touchMapCoordinate;
    }
    if (self.intStartLocation==2)
    {
        self.EndLocation=touchMapCoordinate;
    }
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    totalpath = [GMSMutablePath path];
    [totalpath addCoordinate:self.startLocation];
    [totalpath addCoordinate:self.endLocation];
    [totalpath count];
    NSLog(@"Path Between Places: %ld:",(unsigned long)[totalpath count]);
    if(UIGestureRecognizerStateEnded == locationGesture.state)
    {
        [self mapView:mapView_ didLongPressAtCoordinate:touchMapCoordinate];
        marker.map = mapView_;
    }
   
}

-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    GMSReverseGeocodeCallback handler = ^(GMSReverseGeocodeResponse *response, NSError *error)
    {
        if (response && response.firstResult) {
            GMSMarker *marker = [[GMSMarker alloc] init]; marker.position = coordinate;
            marker.title = response.firstResult.addressLine1;
            marker.snippet = response.firstResult.addressLine2;
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.map = mapView_;
            
        }
        else
        {
            NSLog(@"Could not reverse geocode point (%f,%f): %@",
                  coordinate.latitude, coordinate.longitude, error);
        }
        
        
        CLLocation *locA = [[CLLocation alloc] initWithLatitude:self.startLocation.latitude longitude:self.startLocation.longitude];
        
        CLLocation *locB = [[CLLocation alloc] initWithLatitude:self.endLocation.latitude longitude:self.endLocation.longitude];
        
        self.distance = [locA distanceFromLocation:locB];
        
        
        _returnText =  [NSMutableString stringWithFormat:@"%@ %@",response.firstResult.addressLine1,response.firstResult.addressLine2];
    };
    GMSGeocoder *geocoder_ = [[GMSGeocoder alloc] init];
    [geocoder_ reverseGeocodeCoordinate:coordinate completionHandler:handler];
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:12];
    }
}

- (void)dealloc
{
    [mapView_ removeObserver:self forKeyPath:@"myLocation" context:NULL];
}


-(void)loadView
{
    CGRect rect= CGRectMake(0, 100, 320, 480);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (screenSize.height > 480.0f)
            rect=CGRectMake(0, 100, 320, 568);
    }
    UIView *view=[[UIView alloc] initWithFrame:rect];
    self.view=view;
}





@end
