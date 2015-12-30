//
//  ProjectRecord.h
//  Fieldo
//
//  Created by Gagan Joshi on 10/27/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>    // because we need UIImage

@interface ProjectRecord : NSObject


@property(nonatomic,strong) NSString *projectId;
@property(nonatomic,strong) NSString *projectType;
@property(nonatomic,strong) NSString *projectDescription;
@property(nonatomic,strong) NSString *projectName;
@property (nonatomic, strong) UIImage *projectImage; // To store the actual image
@property (nonatomic, strong) NSURL *projectImageURL; // To store the URL of the image
@property (nonatomic, readonly) BOOL hasImage; // Return YES if image is downloaded.
@property (nonatomic,strong) NSString *managerId;
@property (nonatomic,strong) NSString *managerEmail;

@property (nonatomic,strong) NSString *location;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *state;
@property (nonatomic,strong) NSString *Country;


@property (nonatomic,retain) NSString *projectUnreadMsg; // Return YES if image is downloaded.



@property (nonatomic, getter = isFailed) BOOL failed; // Return Yes if image failed to be downloaded


@property(nonatomic,strong) NSString *projectValue;


@property (nonatomic,strong) NSString *startDate;
@property (nonatomic,strong) NSString *endDate;

@property (nonatomic,strong) NSString *from;
@property (nonatomic,strong) NSString *to;

@property (nonatomic,strong) NSString *workerName;
@property (nonatomic,strong) NSString *WorkerId;


@property (nonatomic,strong) NSString *WorkId;
@property (nonatomic,strong) NSString *Comment;

@property (nonatomic,strong) NSString *custAccept;

//priority = 2;
//status = 0;
//"work_id" = 290;
//"worker_id" = 144;
//




@end
