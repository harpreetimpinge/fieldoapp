//
//  CurrentLocationView.h
//  Fieldo
//
//  Created by Anit Kumar on 13/02/15.
//  Copyright (c) 2015 Gagan Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CurrentLocationView : NSObject

@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *latitude;

-(void)userCurrentLocation:(UIView *)view;      //Send Current Location on Server. 

@end
