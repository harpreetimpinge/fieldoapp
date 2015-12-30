//
//  LocationListBO.h
//  Fieldo
//
//  Created by Gagan Joshi on 3/20/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface LocationListBO : NSObject
@property (nonatomic, strong) NSString *locName;
@property (nonatomic ,assign) CLLocationCoordinate2D locCoordinates;
@end
