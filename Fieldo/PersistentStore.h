//
//  PersistentStore.h
//  Fieldo
//
//  Created by Gagan Joshi on 10/31/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersistentStore : NSObject


+(void)setLoginStatus:(NSString *)loginStatus;

+(void)setLoginEmailWorker:(NSString *)loginEmail;
+(void)setLoginPasswordWorker:(NSString *)loginPassword;
+(void)setLoginEmailCustomer:(NSString *)loginEmail;
+(void)setLoginPasswordCustomer:(NSString *)loginPassword;




+(void)setDeviceToken:(NSString *)deviceToken;

+(void)setWorkerID:(NSString *)workerID;
+(void)setWorkerName:(NSString *)workerName;
+(void)setWorkerImageUrl:(NSString *)workerUrl;


+(void)setCustomerID:(NSString *)customerID;
+(void)setCustomerName:(NSString *)customerName;
+(void)setCustomerImageUrl:(NSString *)customerUrl;





+(void)setLocalLanguage:(NSString *)localLanguage;

+(void)setFlagLog:(NSString *)flagLog;
+(NSString *)getLocalLanguage;
+(NSString *)getLoginStatus;

+(NSString *)getLoginEmailWorker;
+(NSString *)getLoginPasswordWorker;
+(NSString *)getLoginEmailCustomer;
+(NSString *)getLoginPasswordCustomer;


+(NSString *)getDeviceToken;



+(NSString *)getWorkerID;
+(NSString *)getWorkerName;
+(NSString *)getWorkerImageUrl;


+(NSString *)getCustomerID;
+(NSString *)getCustomerName;
+(NSString *)getCustomerImageUrl;



+(NSString *)getFlagLog;


@end
