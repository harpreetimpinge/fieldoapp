//
//  ediCustomCellTableViewCell.m
//  Fieldo
//
//  Created by Vishal on 20/11/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "ediCustomCellTableViewCell.h"

@implementation ediCustomCellTableViewCell
@synthesize editBtn;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setContentOnCell:(NSDictionary*)dict
{
  //  NSLog(@"%@",dict);
    
    self.orderNo.text=[dict objectForKey:@"orderNumber"];
    self.amount.text=[NSString stringWithFormat:@"%.2f",[[dict objectForKey:@"orderValue"] floatValue]];
    self.quantity.text=[NSString stringWithFormat:@"%li",(long)[[dict objectForKey:@"quantity"] integerValue]] ;
    self.store.text=[dict objectForKey:@"store"];
    self.descriptionText.text=[dict objectForKey:@"description"];
    
}

- (IBAction)editAction:(id)sender {
}
@end
