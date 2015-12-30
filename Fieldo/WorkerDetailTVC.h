//
//  WorkerDetailTVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 3/21/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkerDetailTVC : UITableViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    UIImagePickerController *picker;
}
@property(nonatomic,retain) NSDictionary *dictProfile;
@property(nonatomic,retain) NSMutableArray *arrayProfile;
@property(nonatomic,retain) NSMutableArray *arrayCellKeys;
@property(nonatomic,retain) NSString *stringUrl;

@property(nonatomic,retain) NSString *stringWorkerId;


@property(nonatomic,retain) UIImage *image;


@property(nonatomic,retain) NSString *stringName;
@property(nonatomic,retain) NSString *stringComponyName;

@property(nonatomic,retain) UIActivityIndicatorView *activityIndicatorView;

@property(nonatomic,retain) UIImageView *imageViewHeader;
@property(nonatomic,retain) UILabel     *textLabelHeader;
@property(nonatomic,retain) UILabel     *detailTextLabelHeader;


@end
