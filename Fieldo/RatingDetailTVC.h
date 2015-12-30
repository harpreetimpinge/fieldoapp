//
//  RatingDetailTVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 2/21/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RatingDetailTVC : UITableViewController<UITextViewDelegate>
{
    float ratingValue;
}

@property(nonatomic,retain) NSMutableDictionary *dictRatingProject;

@property(nonatomic,retain) NSArray *dataArray;




@end
