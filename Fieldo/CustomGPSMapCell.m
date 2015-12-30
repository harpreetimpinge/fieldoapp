//
//  CustomGPSMapCell.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/23/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "CustomGPSMapCell.h"

@implementation CustomGPSMapCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        @try {
            _mapView = [GMSMapView mapWithFrame:CGRectMake(20, 20, 280, 280) camera:_camera];
            _mapView.settings.consumesGesturesInView = YES;
            // [_mapView.settings setAllGesturesEnabled:NO];
            // [self.contentView addSubview:_mapView];
            
            
            _marker = [[GMSMarker alloc] init];
            _marker.map = _mapView;
            [self.contentView addSubview:_marker.map];
        }
        @catch (NSException *exception) {
            NSLog(@"Expected Exception: %@", exception);
        }

    }
    return self;
}

-(void)setLocation:(CLLocationCoordinate2D)location
{
    if (location.latitude !=_location.latitude)
    {
        _location.latitude = location.latitude;
    }
    if (location.longitude !=_location.longitude)
    {
        _location.longitude = location.longitude;
    }
    
    _camera = [GMSCameraPosition cameraWithTarget:location zoom:14];
    _mapView = [GMSMapView mapWithFrame:CGRectMake(20, 20, 280, 280) camera:_camera];

    _marker.position = location;

}








@end
