//
//  CustomPicker.m
//  Cells
//
//  Created by Gagan Joshi on 11/11/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import "CustomDatePickerCell.h"

@implementation CustomDatePickerCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGRect nameValueRect = CGRectMake(0, 0, 320, 216);
        _cellDatePicker = [[UIDatePicker alloc] initWithFrame:nameValueRect];
        [self.contentView addSubview:_cellDatePicker];
        
    }
    return self;
}


-(void)setDatePicker:(UIDatePicker *)datePicker
{
    if (datePicker !=_cellDatePicker) {
        _cellDatePicker = datePicker;
        
    }
}



@end
