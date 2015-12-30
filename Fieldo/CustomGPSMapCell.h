//
//  CustomGPSMapCell.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/23/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface CustomGPSMapCell : UITableViewCell

@property(strong,nonatomic) GMSMapView *mapView;
@property(strong,nonatomic) GMSMarker *marker;

@property(assign,nonatomic) CLLocationCoordinate2D location;
@property(strong,nonatomic) GMSCameraPosition *camera;

@end
