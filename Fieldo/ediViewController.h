//
//  ediViewController.h
//  Fieldo
//
//  Created by Vishal on 20/11/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ediViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>
{
    NSMutableArray *m_dataArray;
    NSString *projectName;
    NSString *projectId;
    float initialAmount;
    int editIndex;
    NSString *fileName;
}

@property (retain, nonatomic) NSString *projectName;
@property (retain, nonatomic) NSString *projectId;
@property (strong, nonatomic) IBOutlet UITableView *m_tableView;
@property (strong, nonatomic) IBOutlet UIView *m_editView;
@property (strong, nonatomic) IBOutlet UITextField *quantityField;
@property (strong, nonatomic) IBOutlet UITextField *amountField;


- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
@end
