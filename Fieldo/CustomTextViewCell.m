//
//  CustomTextViewCell.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/12/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "CustomTextViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomTextViewCell
@synthesize TextDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGRect nameValueRect = CGRectMake(10, 10, 300, 80);
        _textView = [[UITextView alloc] initWithFrame:nameValueRect];
        _textView.font=[UIFont systemFontOfSize:16];
        _textView.keyboardType = UIKeyboardTypeASCIICapable;
        [[_textView layer] setBorderColor:[[UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.f] CGColor]];
        [[_textView layer] setBorderWidth:1];
        [[_textView layer] setCornerRadius:3.0];
        _textView.inputAccessoryView=[self createToolbar];
        [self.contentView addSubview:_textView];
        
        
        
    }
    return self;
}

- (UIToolbar*)createToolbar
{
    UIToolbar* toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.backgroundColor=[UIColor blackColor];
    toolbar.barStyle = UIBarStyleBlackTranslucent;

    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(ResignTextView)];
    UIBarButtonItem *flexibleButton =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *buttonItems = [NSArray arrayWithObjects:flexibleButton,shareButton,nil];
    [toolbar setItems:buttonItems];
    return toolbar;
    
}

-(void)ResignTextView
{
    if (self.TextDelegate!=nil && [self.TextDelegate respondsToSelector:@selector(ResignTextViewForTable:)]) {
        [self.TextDelegate performSelector:@selector(ResignTextViewForTable:) withObject:_textView];
    }
}
-(void)setTextView:(UITextView *)textView
{
    if (textView !=_textView) {
        _textView = textView;
        
    }
}

@end
