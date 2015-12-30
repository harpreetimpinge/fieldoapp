//
//  LocationListingTVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 3/20/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionManager.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationListingTVC : UITableViewController<UISearchBarDelegate,CLLocationManagerDelegate>
{
    UISearchBar *SearchBar;
    ConnectionManager *Connect;
}
@property (nonatomic ,strong) NSMutableArray *referenceNameArray;


@property (nonatomic , strong) CLLocation *SearchedLocation;

@end
