//
//  CustomNoteCell.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/13/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "CustomNoteCell.h"

@implementation CustomNoteCell


- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _labelNoteSubject = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 30)];
        _labelNoteSubject.textAlignment=NSTextAlignmentLeft;
        _labelNoteSubject.font = [UIFont fontWithName:@"Arial" size:16];
        [self.contentView addSubview:_labelNoteSubject];
        
        _labelNoteSender= [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 150, 25)];
        _labelNoteSender.textAlignment=NSTextAlignmentLeft;
        _labelNoteSender.font = [UIFont fontWithName:@"Arial" size:14];
        [self.contentView addSubview:_labelNoteSender];
        
        _labelNoteDate = [[UILabel alloc] initWithFrame:CGRectMake(160, 35, 150, 25)];
        _labelNoteDate.textAlignment=NSTextAlignmentRight;
        _labelNoteDate.font = [UIFont fontWithName:@"Arial" size:12];
        [self.contentView addSubview:_labelNoteDate];
    }
    return self;
}



-(void)setLabelNoteDate:(UILabel *)labelNoteDate
{
    if (labelNoteDate !=_labelNoteDate)
    {
        _labelNoteDate = labelNoteDate;
        
    }

}

-(void)setLabelNoteSender:(UILabel *)labelNoteSender
{
    if (labelNoteSender !=_labelNoteSender)
    {
        _labelNoteSender = labelNoteSender;
        
    }

}


-(void)setLabelNoteSubject:(UILabel *)labelNoteSubject
{
    if (labelNoteSubject !=_labelNoteSubject)
    {
        _labelNoteSubject = labelNoteSubject;
        
    }

}



@end