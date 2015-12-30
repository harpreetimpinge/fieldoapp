//
//  HomeCVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 2/20/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//



#import "HomeCVC.h"
#import "CollectionViewCell.h"
#import "AppDelegate.h"
#import "PersistentStore.h"
#import "NSString+HTML.h"
#import "Language.h"
#import "StoresVC.h"
#import "NotesVC.h"
#import "SettingVC.h"
#import "RatingIndexVC.h"
#import "ContactUsTVC.h"
#import "Reachability.h"
#import "LogVC.h"

@interface HomeCVC ()

@end

@implementation HomeCVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)receivedRotate:(NSNotification *)notification
{
    //Obtaining the current device orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(UIDeviceOrientationIsPortrait(orientation))
    {
        return;
    }
    
}



- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.collectionViewLayout invalidateLayout];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.arrayHomeMenu=[[NSMutableArray alloc] init];
    self.arrayImages=[[NSMutableArray alloc] init];
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView=[[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flow];
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"CONTENT"];
    self.collectionView.pagingEnabled=YES;
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    
    
    [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    
    if ([UIScreen mainScreen].bounds.size.height>480)
    {
        flow.sectionInset =  UIEdgeInsetsMake(15, 40, 15, 40);
        flow.minimumLineSpacing = 15;
    }
    else
    {
        flow.sectionInset =UIEdgeInsetsMake(12, 52, 10, 52);
       flow.minimumLineSpacing = 5;
    }
    flow.itemSize = self.collectionView.frame.size;
    self.navigationController.navigationBar.translucent=NO;
    self.collectionView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE"];
    
    self.stringDay=[dateFormatter stringFromDate:[NSDate date]];
    self.stringDate=[[NSString stringWithFormat:@"%@",[NSDate date]] substringWithRange:NSMakeRange(8,2)];

    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mainMenuVC.menuView.hidden=YES;
    appDelegate.mainMenuVC.buttonAdvertise.hidden=NO;
    
    
    [self reloadCollectionView];
    
    

}


-(void)reloadCollectionView
{
    
    if ([self.arrayHomeMenu count])
    {
        [self.arrayHomeMenu removeAllObjects];
        [self.arrayImages removeAllObjects];
    }

    
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        [self.arrayImages addObject:@"imageProjects.png"];
        [self.arrayImages addObject:@"imageCalendar.png"];
        [self.arrayImages addObject:@"imageLog.png"];
        [self.arrayImages addObject:@"imageStore.png"];
        [self.arrayImages addObject:@"imageNotes.png"];
        [self.arrayImages addObject:@"imageSettings.png"];
        
        [self.arrayHomeMenu addObject:[Language get:@"Projects" alter:@"!Projects"]];
        [self.arrayHomeMenu addObject:[Language get:@"Calendar" alter:@"!Calendar"]];
        [self.arrayHomeMenu addObject:[Language get:@"Log" alter:@"!Log"]];
        [self.arrayHomeMenu addObject:[Language get:@"Stores" alter:@"!Stores"]];
        [self.arrayHomeMenu addObject:[Language get:@"Notes" alter:@"!Notes"]];
        [self.arrayHomeMenu addObject:[Language get:@"Settings" alter:@"!Settings"]];
        
        // self.title=[NSString stringWithFormat:@"Welcome,%@",[[PersistentStore getWorkerName] stringByConvertingHTMLToPlainText]];
        self.title=@"Fieldo";
    }
    else
    {
        [self.arrayImages addObject:@"imageProjects.png"];
        [self.arrayImages addObject:@"imageRating.png"];
        [self.arrayImages addObject:@"imageInvoice.png"];
        [self.arrayImages addObject:@"imageCheckRating.png"];
        [self.arrayImages addObject:@"imageContactUs.png"];
        [self.arrayImages addObject:@"imageSettings.png"];
        
        
        [self.arrayHomeMenu addObject:[Language get:@"Projects" alter:@"!Projects"]];
        [self.arrayHomeMenu addObject:[Language get:@"Rating" alter:@"!Rating"]];
        [self.arrayHomeMenu addObject:[Language get:@"Invoices" alter:@"!Invoices"]];
        [self.arrayHomeMenu addObject:[Language get:@"Rating Index" alter:@"!Rating Index"]];
        [self.arrayHomeMenu addObject:[Language get:@"Contact Us" alter:@"!Contact Us"]];
        [self.arrayHomeMenu addObject:[Language get:@"Settings" alter:@"!Settings"]];
        
        self.title=@"Fieldo";
        
        // self.title=[NSString stringWithFormat:@"Welcome,%@",[[PersistentStore getWorkerName] stringByConvertingHTMLToPlainText]];
        
        
        
        
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^
                   {
                       NSData* imageData;
                       
                       if (![[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
                       {
//                           imageData=[NSData dataWithContentsOfFile:@"logo.jpg"];
                           
                       }
                       else
                       {
                           imageData=[NSData dataWithContentsOfURL:[NSURL URLWithString:[PersistentStore getCustomerImageUrl]]];
                           
                       }
                       
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                                          appDelegate.mainMenuVC.imageViewProfile.backgroundColor = [UIColor clearColor];
                                          appDelegate.mainMenuVC.imageViewProfile.image=([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])?[UIImage imageWithData:imageData]:[UIImage imageNamed:@"logo.jpg"];
                                      });
                   });
    

    [self.collectionView reloadData];

    
}


-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


- (void)loadView
{
    UIView* view = [[UIView alloc] init];
    self.view = view;
}

#pragma mark CollectionViewDelegate starts
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.arrayHomeMenu count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell =(CollectionViewCell *) [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CONTENT" forIndexPath:indexPath];
    cell.imageView.image= [UIImage imageNamed:self.arrayImages[indexPath.row]];
    cell.labelTitle.text=self.arrayHomeMenu[indexPath.row];
    
    if (indexPath.row==1 && [[PersistentStore getLoginStatus] isEqualToString:@"Worker"] )
    {
        cell.labelDate.text=self.stringDate;
        cell.labelDay.text=self.stringDay;
    }
    else
    {
        cell.labelDate.text=@"";
        cell.labelDay.text=@"";
    }
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (screenSize.height > 480.0f)
            return CGSizeMake(100, 120);
    }
    return CGSizeMake(80, 100);
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"index %ld",(long)indexPath.row);
    CGRect rect= CGRectMake(0, 100, 320, 380);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (screenSize.height > 480.0f)
            rect=CGRectMake(0, 100, 320, 468);
    }
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mainMenuVC.menuView.hidden=NO;
    appDelegate.mainMenuVC.buttonAdvertise.hidden=YES;

    
    APP_DELEGATE.checkLogView = NO;
    
    switch (indexPath.row) {
        case 0:
        {
            
            [appDelegate.mainMenuVC.btnProject setBackgroundImage:[UIImage imageNamed:@"SelectedTop"] forState:UIControlStateNormal];
            [appDelegate.mainMenuVC.btnProject setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [appDelegate.mainMenuVC.btnCalOrRating setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
            [appDelegate.mainMenuVC.btnCalOrRating setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
            
            [appDelegate.mainMenuVC.btnLogOrInvoice setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
            [appDelegate.mainMenuVC.btnLogOrInvoice setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
            
            [appDelegate.mainMenuVC.btnHome setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
            [appDelegate.mainMenuVC.btnHome setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
            
            
            NSLog(@"%@",appDelegate.mainMenuVC.contentView);
            if([appDelegate.mainMenuVC.contentView.subviews count] == 1)
            {
                [[appDelegate.mainMenuVC.contentView.subviews objectAtIndex:0] removeFromSuperview];
            }
            UIViewController* controller = (UIViewController*)[appDelegate.mainMenuVC.childViewControllers objectAtIndex:0];
            controller.view.frame = appDelegate.mainMenuVC.contentView.bounds;
            [appDelegate.mainMenuVC.contentView addSubview:controller.view];
            
            break;
        }
        case 1:
        {
            [appDelegate.mainMenuVC.btnProject setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
            [appDelegate.mainMenuVC.btnProject setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
            
            [appDelegate.mainMenuVC.btnCalOrRating setBackgroundImage:[UIImage imageNamed:@"SelectedTop"] forState:UIControlStateNormal];
            [appDelegate.mainMenuVC.btnCalOrRating setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [appDelegate.mainMenuVC.btnLogOrInvoice setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
            [appDelegate.mainMenuVC.btnLogOrInvoice setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
            
            
            [appDelegate.mainMenuVC.btnHome setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
            [appDelegate.mainMenuVC.btnHome setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
            
            [PersistentStore setFlagLog:@"YES"];
            NSLog(@"%@",appDelegate.mainMenuVC.contentView);
            if([appDelegate.mainMenuVC.contentView.subviews count] == 1)
            {
                [[appDelegate.mainMenuVC.contentView.subviews objectAtIndex:0] removeFromSuperview];
            }
            UIViewController* controller = (UIViewController*)[appDelegate.mainMenuVC.childViewControllers objectAtIndex:1];
            controller.view.frame = appDelegate.mainMenuVC.contentView.bounds;
            [appDelegate.mainMenuVC.contentView addSubview:controller.view];
            break;

        }
        case 2:
        {
            [appDelegate.mainMenuVC.btnProject setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
            [appDelegate.mainMenuVC.btnProject setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
            
            [appDelegate.mainMenuVC.btnCalOrRating setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
            [appDelegate.mainMenuVC.btnCalOrRating setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
            
            [appDelegate.mainMenuVC.btnLogOrInvoice setBackgroundImage:[UIImage imageNamed:@"SelectedTop"] forState:UIControlStateNormal];
            [appDelegate.mainMenuVC.btnLogOrInvoice setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [appDelegate.mainMenuVC.btnHome setBackgroundImage:[UIImage imageNamed:@"UnSelectedTop"] forState:UIControlStateNormal];
            [appDelegate.mainMenuVC.btnHome setTitleColor:[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f] forState:UIControlStateNormal];
            
            
            [PersistentStore setFlagLog:@"YES"];
            NSLog(@"%@",appDelegate.mainMenuVC.contentView);
            if([appDelegate.mainMenuVC.contentView.subviews count] == 1)
            {
                [[appDelegate.mainMenuVC.contentView.subviews objectAtIndex:0] removeFromSuperview];
            }
            UIViewController* controller = (UIViewController*)[appDelegate.mainMenuVC.childViewControllers objectAtIndex:2];
            controller.view.frame = appDelegate.mainMenuVC.contentView.bounds;
            
            if([controller isKindOfClass:[LogVC class]])
            {
                LogVC *logVC = (LogVC*)controller;
                logVC.shouldSelectProjectBtn = NO;
            } else if([controller isKindOfClass:[UINavigationController class]]) {
                if ([[(UINavigationController*)controller topViewController] isKindOfClass:[LogVC class]]) {
                    LogVC *logVC = (LogVC*)[(UINavigationController*)controller topViewController];
                    logVC.shouldSelectProjectBtn = YES;
                }
            }
            [appDelegate.mainMenuVC.contentView addSubview:controller.view];
            break;

           
        }
        case 3:
        {
            
            if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
            {
                StoresVC *storesVC=[[StoresVC alloc] init];
                [self.navigationController pushViewController:storesVC animated:YES];
                 break;
            }
            else
            {
                RatingIndexVC *ratingIndexVC=[[RatingIndexVC alloc] init];
                [self.navigationController pushViewController:ratingIndexVC animated:YES];

                break;
            }
            
          
            
        }
        case 4:
        {
            if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
            {
                NotesVC *notesVC=[[NotesVC alloc] init];
                [self.navigationController pushViewController:notesVC animated:YES];
                break;

            }
            else
            {
               
                ContactUsTVC *contactUsTVC=[[ContactUsTVC alloc] init];
                [self.navigationController pushViewController:contactUsTVC animated:YES];
                break;

            }
         }
        case 5:
        {
            
            SettingVC *settingVC=[[SettingVC alloc] init];
            [self.navigationController pushViewController:settingVC animated:YES];
            break;
            
           
        }
           default:
            break;
    }
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
