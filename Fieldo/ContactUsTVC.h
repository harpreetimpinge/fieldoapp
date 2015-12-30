//
//  ContactUs.h
//  Fieldo
//
//  Created by Gagan Joshi on 2/28/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MFMailComposeViewController.h>   //For Send Email

@interface ContactUsTVC : UITableViewController<MFMailComposeViewControllerDelegate>
{
    UIView *headerView;
    MFMailComposeViewController *mailer ;
    
}

@property(nonatomic,retain) NSMutableArray *arrayContactUs;
@property(nonatomic,retain) NSMutableArray *arrayImages;
@property(nonatomic,retain) NSMutableArray *arraykeys;



@end
