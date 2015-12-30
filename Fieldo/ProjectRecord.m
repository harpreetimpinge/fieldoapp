//
//  ProjectRecord.m
//  Fieldo
//
//  Created by Gagan Joshi on 10/27/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "ProjectRecord.h"

@implementation ProjectRecord

@synthesize projectId=_projectId;
@synthesize projectType=_projectType;
@synthesize projectDescription=_projectDescription;
@synthesize projectName=_projectName;
@synthesize projectImage=_projectImage;
@synthesize projectImageURL=_projectImageURL;
@synthesize hasImage=_hasImage;
@synthesize failed=_failed;
@synthesize projectUnreadMsg=_projectUnreadMsg;
@synthesize managerId=_managerId;
@synthesize managerEmail=_managerEmail;

@synthesize startDate=_startDate;

@synthesize endDate=_endDate;

@synthesize from=_from;

@synthesize to=_to;

@synthesize workerName=_workerName;

@synthesize WorkerId=_WorkerId;
@synthesize WorkId=_WorkId;
@synthesize Comment=_Comment;
@synthesize projectValue=_projectValue;
@synthesize custAccept=_custAccept;


@synthesize location=_location;
@synthesize city=_city;
@synthesize state=_state;
@synthesize Country=_Country;

- (BOOL)hasImage
{
    return _projectImage != nil;
}


- (BOOL)isFailed {
    return _failed;
}




@end
