//
//  NSIUtility.m
//  VideoHotspot
//

//

#import "NSIUtility.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import "Language.h"

@implementation NSIUtility

+(BOOL)checkIfStringContainsText:(NSString *)string
{
    if(!string || string == NULL || [string isEqual:[NSNull null]])
        return FALSE;
    
    NSString *newString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([newString isEqualToString:@""])
        return FALSE;
    
    return TRUE;
}

+(NSString *)getStringFromChar:(char const *)characterString
{
    if(!characterString || characterString == NULL)
        return nil;
    
    return [NSString stringWithUTF8String:characterString];
}

+(void)showUnderDevelopmentAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Under Development!" message:[Language get:@"This feature is under development and will be available in future releases." alter:@"!This feature is under development and will be available in future releases."]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

+(void)addBasicConstraintsOnSubView:(UIView *)subView onSuperView:(UIView *)superView
{
    [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [superView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[subView]-%f-|",subView.frame.origin.y,subView.frame.origin.y] options: NSLayoutFormatAlignmentMask metrics:nil views:NSDictionaryOfVariableBindings(subView)]];
    [superView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"|-%f-[subView]-%f-|",subView.frame.origin.x,subView.frame.origin.x] options: NSLayoutFormatAlignmentMask metrics:nil views:NSDictionaryOfVariableBindings(subView)]];
}

+ (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

+(void)showAlert:(NSString *)title withMessage:(NSString *)message delegate:(id)delegate
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

+(void)addSubview:(UIView *)subview withFadeInAnimationOnSuperView:(UIView *)superview
{
    if(!subview || !superview)
        return;
    
    [subview setAlpha:0.0];
    [superview addSubview:subview];
    
    [UIView animateWithDuration:0.3 animations:^{
        [subview setAlpha:1.0];
    }];
}

+(void)removeSubviewWithFadeOutAnimation:(UIView *)subview
{
    if(!subview || ![subview superview])
        return;
    
    [subview setAlpha:1.0];
    
    [UIView animateWithDuration:0.3 animations:^{
        [subview setAlpha:0.0];
    } completion:^(BOOL finished) {
        [subview removeFromSuperview];
    }];
}

+ (NSString*)setDataByKeyName:(NSString*)keyName withUser:(NSDictionary*)dict
{
    if (![dict isKindOfClass:[NSDictionary class]])
        return @"";
    
    
    if([dict valueForKey:keyName])
        return [dict valueForKey:keyName];
    
    return @"";
}

+ (int)setIntegerData:(NSString*)keyName withUser:(NSDictionary*)dict
{
    if( ([dict objectForKey:keyName] != [NSNull null]) && [[dict objectForKey:keyName] intValue])
        return [[dict objectForKey:keyName] intValue];
    
    return 0;
}

+ (BOOL)setBOOLData:(NSString*)keyName withUser:(NSDictionary*)dict
{
    NSNumber *numObj = [dict objectForKey:keyName];
    if ([numObj boolValue])
    {
        return YES;
    }
    return NO;
}

+(void)setFrameOfView :(UIView *)vwName withRect:(CGRect)rect withAnimationDuration:(CGFloat)duration
{
    [vwName setTranslatesAutoresizingMaskIntoConstraints:YES];
    [UIView animateWithDuration:duration
                     animations:^{
                         [vwName setFrame:rect];
                     }];
}

+(void)setValueToUserdefault:(NSString *)value withKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults]setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(NSString *)getValueFromUserDefaultWithKey:(NSString *)key
{
    NSString *result = @"";
    
    result = [[NSUserDefaults standardUserDefaults]valueForKey:key];
    if (!key || !result) {
        return result;
    }
    
    return result;
}

+(BOOL)isIphone5
{
    CGFloat height = [[UIScreen mainScreen]bounds].size.height;
    if (height == 568)
        return YES;
    else
        return NO;
}

#pragma mark - Get Path for Bundle File
+ (NSString *)getPathOfFileName:(NSString *)name type:(NSString *)type{
    NSString *pathToFile = [[NSBundle mainBundle] pathForResource:name ofType:type];
    return pathToFile;
}

// Assumes input like "#00FF00" (#RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(NSString *)getTitleCaseString:(NSString *)string
{
    if(![self checkIfStringContainsText:string])
        return @"";
    
    NSMutableString *str2 = [NSMutableString string];
    int convertText = 0;
    
    
    for (NSInteger i=0; i<string.length; i++){
        NSString *ch = [string substringWithRange:NSMakeRange(i, 1)];
        
        if([ch isEqualToString:@" "])
            convertText = i+1;
        
        if(convertText == i)
            ch = [ch uppercaseString];
         
        [str2 appendString:ch];
    }
    
    return str2;
}

+(BOOL)checkIfDeviceIsIPad
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // The device is an iPad running iOS 3.2 or later.
        return TRUE;
    }
    
    return FALSE;
}

+(id)getObjectForKey:(NSString *)key fromDict:(NSDictionary *)dict
{
    if(!dict || ![NSIUtility checkIfStringContainsText:key])
        return nil;
    
    id value = [dict objectForKey:key];
    
    if([value isEqual:[NSNull null]] || value == NULL)
        return nil;
    
    return value;
}

+(id)getStringFromObject:(NSString *)string
{
    if(![self checkIfStringContainsText:string])
        return @"";
    
    return string;
}

#pragma mark - Drawing Score Progress with Cut Circle
+ (UIImage *)drawImageWithScore:(float)score withColor:(UIColor *)color withImageSize:(CGSize)size withLineWidth:(CGFloat)width
{
    UIImage* im;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width,size.height), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0].CGColor);
    CGContextAddArc(context, size.width/2, size.height/2, (size.width/2)-10, (M_PI_2+M_PI_4), M_PI_4, 0) ;
    CGContextStrokePath(context);
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context,color.CGColor);
    CGContextAddArc(context, size.width/2, size.height/2, (size.width/2)-10, (M_PI_2+M_PI_4), ((score*2.7)*M_PI)/180 +(M_PI_2+M_PI_4), 0) ;
    CGContextStrokePath(context);
    
    im = nil;
    im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return im;
}

+(CGSize)getSizeOfText:(NSString *)text forWidth:(CGFloat)width withFont:(UIFont *)font
{
    NSDictionary *attributes = @{NSFontAttributeName: font};
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
    
    return rect.size;
}

+(NSString*)encryptString:(NSString *)password {
    const char* str = [password UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}

@end