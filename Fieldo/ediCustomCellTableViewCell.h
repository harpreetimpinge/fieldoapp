//
//  ediCustomCellTableViewCell.h
//  Fieldo
//
//  Created by Vishal on 20/11/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ediCustomCellTableViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *orderNo;
@property (retain, nonatomic) IBOutlet UILabel *quantity;
@property (retain, nonatomic) IBOutlet UILabel *amount;
@property (retain, nonatomic) IBOutlet UILabel *store;
@property (retain, nonatomic) IBOutlet UILabel *descriptionText;

-(void)setContentOnCell:(NSDictionary*)dict;
- (IBAction)editAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *editBtn;

@end
