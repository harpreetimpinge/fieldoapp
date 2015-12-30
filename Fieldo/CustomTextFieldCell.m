//
//  CustomTextFieldCell.m
//  Cells
//
//  Created by Gagan Joshi on 11/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import "CustomTextFieldCell.h"

@implementation CustomTextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGRect nameValueRect = CGRectMake(10, 7, 300, 30);
        _textField = [[UITextField alloc] initWithFrame:nameValueRect];
        _textField.borderStyle=UITextBorderStyleRoundedRect;
        [self.contentView addSubview:_textField];
        
    }
    return self;
}


-(void)setTextField:(UITextField *)textField
{
    if (textField !=_textField)
    {
        _textField = textField;
        
    }
}

@end
