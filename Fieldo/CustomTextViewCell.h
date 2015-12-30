//
//  CustomTextViewCell.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/12/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol customTextCellDelegate <NSObject>

-(void)ResignTextViewForTable:(UITextView *)textView1;

@end

@interface CustomTextViewCell : UITableViewCell

@property (retain, nonatomic) UITextView *textView;

@property (assign ,atomic) id<customTextCellDelegate> TextDelegate;

@end
