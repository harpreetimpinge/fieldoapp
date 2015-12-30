//
//  StoreDetailsTVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/23/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Annotation.h"

@interface StoreDetailsTVC : UITableViewController<MKMapViewDelegate>

@property(nonatomic,retain) NSString *stringStoreId;
@property(nonatomic,retain) NSDictionary *dictStoreDetail;
@property(nonatomic,retain) NSMutableArray *arrayCellKeys;
@property(nonatomic,retain) NSArray *arrayStore;




@end


