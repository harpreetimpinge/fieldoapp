//
//  CalendarVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 10/26/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarVC : UIViewController<UIScrollViewDelegate>
{
  
    NSDate *refreshDate;
    
    int selectedIndex;
    BOOL Add;
}

@property (nonatomic,retain) NSMutableArray *arrayDates;
@property (nonatomic,retain) NSDate *currentDate;



@property (nonatomic,retain) NSDate *firstDate;


@property(nonatomic,retain)  UIScrollView *scrollViewTopBar;
@property(nonatomic,retain)  UIScrollView *scrollViewMain;

@property(nonatomic,retain)  UILabel *labelCurrentDate;


@property(nonatomic,retain) NSMutableArray *arrayEvents;


@property (nonatomic,retain)  UIScrollView *projectScroll;

@property (nonatomic,retain) NSMutableArray *addproject;

@property (nonatomic, retain) NSMutableArray *allDayProjectArray;
@end
