//
//  ConnectionManager.h
//  NearByPlaces
//
//  Created by Amit Kumar Singh on 3/19/14.
//  Copyright (c) 2014 Parveen Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum
{
    
    TASK_SIGN_IN = 1000,
    TASK_GET_DISTANCE,
    TASK_GET_SEARCHED,
    TASK_GET_COORDINATE
    
} CURRENT_TASK;

@protocol ConnectionManager_Delegate <NSObject>

@optional
-(void) didFailWithError : (id)obj;
-(void) responseReceived : (id)obj;
@end

@interface ConnectionManager : NSObject
{
    CURRENT_TASK currentTask;
    NSMutableData *responseData;
}

@property (nonatomic , assign) id<ConnectionManager_Delegate> delegate;
@property (nonatomic , assign) CURRENT_TASK currentTask;
@property (nonatomic , strong) NSMutableDictionary *responseDictionary;
@property (nonatomic , strong) NSError *responseError;

//-(BOOL) getDataForFunction : (NSString *) functionName withInputString : (NSString *) inputString withCurrentTask : (CURRENT_TASK) inputTask andDelegate : (id)inputDelegate;
-(BOOL) getDataForFunction : (NSString *) functionName withCurrentTask : (CURRENT_TASK) inputTask andDelegate : (id)inputDelegate;
@end
