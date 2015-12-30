//
//  MainMenuVC.h
//  Fieldo
//
//  Created by Gagan Joshi on 11/21/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuVC : UIViewController
{
NSTimer *theTimer;   //timer object for first component
}

@property (retain, nonatomic) UIImageView *imageViewProfile;
@property (retain, nonatomic) UIView *menuView;
@property (retain, nonatomic) UIView *contentView;

@property (retain, nonatomic) UIButton *btnProject;
@property (retain, nonatomic) UIButton *btnCalOrRating;
@property (retain, nonatomic) UIButton *btnLogOrInvoice;
@property (retain, nonatomic) UIButton *btnHome;

@property(retain, nonatomic) NSMutableArray *arrayAdvertiseLink;
@property(retain, nonatomic) NSMutableArray *arrayAdvertiseImages;

@property (retain, nonatomic) UIButton *buttonAdvertise;

@property (assign, nonatomic) NSNumber *IsLogin;

//picker view group
-(void)initializeTimer;
-(void)Spin:(NSTimer *)theTimer;

@end



