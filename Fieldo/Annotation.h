//
//  Annotation.h
//  Fieldo
//
//  Created by Gagan Joshi on 10/29/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>


@interface Annotation : NSObject<MKAnnotation>

@property (copy,nonatomic) NSString *title;
@property (copy,nonatomic) NSString *subtitle;
@property (assign,nonatomic) CLLocationCoordinate2D coordinate;



@end
