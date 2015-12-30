//
//  CustomPickerCell.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/14/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "CustomPickerCell.h"

@implementation CustomPickerCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        CGRect nameValueRect = CGRectMake(0, 0, 320, 216);
        _pickerView = [[UIPickerView alloc] initWithFrame:nameValueRect];
        [self.contentView addSubview:_pickerView];
    }
    return self;
}

-(void)setPickerView:(UIPickerView *)pickerView
{
    if (pickerView !=_pickerView) {
        _pickerView = pickerView;
        
    }
}


@end
