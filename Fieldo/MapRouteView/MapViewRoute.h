//
//  MapViewRoute.h
//  Fieldo
//
//  Created by Gagan Joshi on 3/20/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RegexKitLite.h"
#import "Place.h"
#import "PlaceMark.h"

@interface MapViewRoute : UIView<MKMapViewDelegate> {
    
	MKMapView* mapView;
	UIImageView* routeView;
	
	NSArray* routes;
	
    //	UIColor* lineColor;
    
}

//@property (nonatomic, retain) UIColor* lineColor;
@property (nonatomic, retain) MKMapView* mapView;

-(void) showRouteFrom: (Place*) f to:(Place*) t;


@end
