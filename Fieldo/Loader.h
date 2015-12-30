//
//  Loader.h
//  VideoTag
//
//
//

#import <Foundation/Foundation.h>

@interface Loader : NSObject
{
    UIView *loaderView;
}

- (void)showLoader;
- (void)hideLoader;

@end
