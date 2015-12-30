//
//  CustomerDetailsVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/23/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Annotation.h"


@interface CustomerDetailsVC : UITableViewController<MKMapViewDelegate>

@property(nonatomic,retain) NSString *stringProjectId;
@property(nonatomic,retain) NSDictionary *dictCustomer;
@property(nonatomic,retain) NSArray *arrayCustomer;
@property(nonatomic,retain) NSMutableArray *arrayCellKeys;


@end
