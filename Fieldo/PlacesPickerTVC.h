//
//  PlacesPickerTVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/28/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PlacesPickerTVC : UITableViewController <MKMapViewDelegate,CLLocationManagerDelegate>
{
    
}

@property(nonatomic,retain) CLLocationManager *locationManager;;
@property(nonatomic,retain) NSMutableArray *arrayPlaces;
@property(nonatomic,assign) NSString *lattitudeStr;
@property(nonatomic,assign) NSString *longitudeStr;


@end
