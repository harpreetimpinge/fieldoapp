//
//  PersistentStore.m
//  Fieldo
//
//  Created by Gagan Joshi on 10/31/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "PersistentStore.h"

@implementation PersistentStore



+(void)setLoginStatus:(NSString *)loginStatus
{
  [[NSUserDefaults standardUserDefaults] setObject:loginStatus forKey:@"loginStatus"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}
+(void)setLoginEmailCustomer:(NSString *)loginEmail
{
    [[NSUserDefaults standardUserDefaults] setObject:loginEmail forKey:@"loginEmail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(void)setLoginPasswordCustomer:(NSString *)loginPassword
{
    [[NSUserDefaults standardUserDefaults] setObject:loginPassword forKey:@"loginPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)setLoginEmailWorker:(NSString *)loginEmail
{
    [[NSUserDefaults standardUserDefaults] setObject:loginEmail forKey:@"loginEmail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(void)setLoginPasswordWorker:(NSString *)loginPassword
{
    [[NSUserDefaults standardUserDefaults] setObject:loginPassword forKey:@"loginPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



+(void)setDeviceToken:(NSString *)deviceToken
{
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)setWorkerID:(NSString *)workerID
{
    [[NSUserDefaults standardUserDefaults] setObject:workerID forKey:@"workerId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(void)setWorkerName:(NSString *)workerName
{
    [[NSUserDefaults standardUserDefaults] setObject:workerName forKey:@"workerName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(void)setWorkerImageUrl:(NSString *)workerUrl
{
    [[NSUserDefaults standardUserDefaults] setObject:workerUrl forKey:@"workerUrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+(void)setCustomerID:(NSString *)customerID
{
    [[NSUserDefaults standardUserDefaults] setObject:customerID forKey:@"customerId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(void)setCustomerName:(NSString *)customerName
{
    [[NSUserDefaults standardUserDefaults] setObject:customerName forKey:@"customerName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(void)setCustomerImageUrl:(NSString *)customerUrl
{
    [[NSUserDefaults standardUserDefaults] setObject:customerUrl forKey:@"customerUrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+(void)setLocalLanguage:(NSString *)localLanguage
{
     [[NSUserDefaults standardUserDefaults] setObject:localLanguage forKey:@"localLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)setFlagLog:(NSString *)flagLog
{
    [[NSUserDefaults standardUserDefaults] setObject:flagLog forKey:@"flagLog"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+(NSString *)getLocalLanguage
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"localLanguage"];
}

+(NSString *)getLoginStatus
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"loginStatus"];
}
+(NSString *)getLoginEmailWorker
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"loginEmail"];
}
+(NSString *)getLoginPasswordWorker
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"loginPassword"];
}


+(NSString *)getLoginEmailCustomer
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"loginEmail"];
}
+(NSString *)getLoginPasswordCustomer
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"loginPassword"];
}


+(NSString *)getDeviceToken
{
   return [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
}

+(NSString *)getWorkerID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"workerId"];
}

+(NSString *)getWorkerName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"workerName"];
}
+(NSString *)getWorkerImageUrl
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"workerUrl"];
}


+(NSString *)getCustomerID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"customerId"];
}

+(NSString *)getCustomerName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"customerName"];
}


+(NSString *)getCustomerImageUrl
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"workerUrl"];
}

+(NSString *)getFlagLog
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"flagLog"];
}


@end
