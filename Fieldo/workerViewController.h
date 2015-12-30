//
//  workerViewController.h
//  Fieldo
//
//  Created by Vishal on 17/11/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"
@interface workerViewController : UIViewController<UITextFieldDelegate>
{
    NSMutableArray *m_workerArray;
    NSString *selectedWorkers;
    NSString *selectedWorkerIds;
    AppDelegate *delegate;
    BOOL isSearching;

}
@property (strong, nonatomic) IBOutlet UITableView *m_tableView;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBarTableView;

@end
