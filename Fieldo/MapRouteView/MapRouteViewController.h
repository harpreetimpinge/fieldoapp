//
//  MapRouteViewController.h
//  Fieldo
//
//  Created by Gagan Joshi on 3/20/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapViewRoute.h"
#import "Place.h"
#import <CoreLocation/CoreLocation.h>

@interface MapRouteViewController : UIViewController<CLLocationManagerDelegate>
{
    MapViewRoute* mapView;
    Place *home;
    Place* office;
    CLLocationManager *locmanager;
    CLLocation *SearchedLocation;
}

@property (strong, nonatomic) Place* office;
@property (strong, nonatomic) Place *home;

@property(nonatomic,retain) NSDictionary *dictProject;

@end
