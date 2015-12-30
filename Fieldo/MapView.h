//
//  MapView.h
//  googleMapDemo
//
//  Created by Gagan Joshi on 11/22/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

@class MapView;
@protocol MapInfoDelegate <NSObject>

-(void)mapViewDidFinish:(MapView *)mapView;

@end

@interface MapView : UIViewController <UIGestureRecognizerDelegate>

@property(nonatomic, strong) NSMutableString *returnText;
@property (strong, nonatomic) id <MapInfoDelegate> delegate;

@property(nonatomic,assign) CLLocationCoordinate2D startLocation;
@property(nonatomic,assign) CLLocationCoordinate2D endLocation;


@property(nonatomic,assign) int intStartLocation;

@property(nonatomic,assign) CLLocationDistance distance; 

@end
