//
//  NSIUtility.h
//  VideoHotspot
//
//  Copyright (c) 2014 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIUtility : NSObject{
    
}

+(BOOL)checkIfStringContainsText:(NSString *)string;

+(NSString *)getStringFromChar:(char const *)characterString;

+(void)showUnderDevelopmentAlert;

+(void)addBasicConstraintsOnSubView:(UIView *)subView onSuperView:(UIView *)superView;

+ (BOOL)validateEmail:(NSString *)emailStr;

+(void)showAlert:(NSString *)title withMessage:(NSString *)message delegate:(id)delegate;

+(void)addSubview:(UIView *)subview withFadeInAnimationOnSuperView:(UIView *)superview;

+(void)removeSubviewWithFadeOutAnimation:(UIView *)subview;

+(void)setFrameOfView :(UIView *)vwName withRect:(CGRect)rect withAnimationDuration:(CGFloat)duration;

+(void)setValueToUserdefault:(NSString *)value withKey:(NSString *)key;

+ (NSString*)setDataByKeyName:(NSString*)keyName withUser:(NSDictionary*)dict;

+ (BOOL)setBOOLData:(NSString*)keyName withUser:(NSDictionary*)dict;

+(NSString *)getValueFromUserDefaultWithKey:(NSString *)key;

+ (NSString *)getPathOfFileName:(NSString *)name type:(NSString *)type;

+ (UIColor *)colorFromHexString:(NSString *)hexString;

+ (int)setIntegerData:(NSString*)keyName withUser:(NSDictionary*)dict;

+(NSString *)getTitleCaseString:(NSString *)string;

+(BOOL)checkIfDeviceIsIPad;

+(id)getObjectForKey:(NSString *)key fromDict:(NSDictionary *)dict;

+(id)getStringFromObject:(NSString *)string;

+(BOOL)isIphone5;

+(CGSize)getSizeOfText:(NSString *)text forWidth:(CGFloat)width withFont:(UIFont *)font;

#pragma mark - Drawing Score Progress with Cut Circle
+ (UIImage *)drawImageWithScore:(float)score withColor:(UIColor *)color withImageSize:(CGSize)size withLineWidth:(CGFloat)width;

+(NSString*)encryptString:(NSString *)password;


@end