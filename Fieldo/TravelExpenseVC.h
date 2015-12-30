//
//  TravelExpenseVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/12/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"
#import <MapKit/MapKit.h>
#import "ConnectionManager.h"


@interface TravelExpenseVC : UITableViewController<UITextFieldDelegate,MapInfoDelegate,ConnectionManager_Delegate>
{
 //   CLLocationManager *locationManager;
    ConnectionManager *Connect;
    
    NSMutableArray *dataArray;
 //   CLLocation *SearchedLocation;

    CLLocationCoordinate2D sourceLoc;
    CLLocationCoordinate2D destLoc;
    
}


@property (nonatomic ,strong) NSMutableArray *referenceNameArray;

@property(nonatomic,retain) NSString *stringProjectId;
@property(nonatomic,retain) NSString *stringFromLocation;
@property(nonatomic,retain) NSString *stringTOLocation;
@property(nonatomic,assign) CLLocationCoordinate2D startLocation;
@property(nonatomic,assign) CLLocationCoordinate2D endLocation;
@property(nonatomic,retain) NSString *stringDistance;



@end
