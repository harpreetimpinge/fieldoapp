//
//  NoteRecord.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/13/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteRecord : NSObject


@property(nonatomic,strong) NSString *noteWorkerName;
@property(nonatomic,strong) NSString  *noteManegerName;
@property(nonatomic,strong) NSString *noteDate;
@property(nonatomic,strong) NSString *noteId;
@property(nonatomic,strong) NSString *noteSubject;
@property (nonatomic, assign) BOOL hasRead;
@property (nonatomic, assign) BOOL isSender;



//"created_at" = "2013-11-13 05:39:26";
//isSender = 0;
//mname = "Birender Singh Rana";
//"notes_id" = 92;
//status = 0;
//subject = "please go";
//"worker_name" = "";






@end
