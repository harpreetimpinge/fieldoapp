//
//  customerViewController.h
//  Fieldo
//
//  Created by Vishal on 17/11/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Loader.h"

@interface customerViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>
{
    NSMutableArray *m_customerArray;
    
    BOOL isSearching;
}
@property (strong, nonatomic) IBOutlet UITableView *m_tableView;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBarTableView;

@end
