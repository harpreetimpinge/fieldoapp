//
//  SettingVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 10/16/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "SettingVC.h"
#import "ProfileVC.h"
#import "ChangeLanguageVC.h"
#import "OutOfTheOfficeVC.h"
#import "PersistentStore.h"
#import "AppDelegate.h"
#import "Language.h"
#import "ContactUsTVC.h"

@interface SettingVC ()

@end

@implementation SettingVC


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.tableView=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    }
    return self;
}



- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
   // [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
         self.arrayIcons=[[NSArray alloc] initWithObjects:@"imageProfile.png",@"imageLanguageChange.png",@"imageOutOfOffice.png",@"imageContactUs.png",@"imageLogout.png", nil];
    }
    else
    {
         self.arrayIcons=[[NSArray alloc] initWithObjects:@"imageProfile.png",@"imageLanguageChange.png",@"imageLogout.png", nil];
    }
    
    
  
    
    
   
    
   // self.tableView.  style=UITableViewStyleGrouped;
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;

    self.arraySettingMenu=[[NSMutableArray alloc] init];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=[Language get:@"Settings" alter:@"!Settings"];
    
    if ([self.arraySettingMenu count])
    {
        [self.arraySettingMenu removeAllObjects];
    }
    
    
    [self.arraySettingMenu addObject:[Language get:@"Profile" alter:@"!Profile"]];
    [self.arraySettingMenu addObject:[Language get:@"Change Language" alter:@"!Change Language"]];
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        [self.arraySettingMenu addObject:[Language get:@"Out of the Office" alter:@"!Out of the Office"]];
        [self.arraySettingMenu addObject:[Language get:@"Contact Us" alter:@"!Contact Us"]];

    }
    
    [self.arraySettingMenu addObject:[Language get:@"Log Out" alter:@"!Log Out"]];
    
    [self.tableView reloadData];
 
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.arraySettingMenu count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"std"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.backgroundColor=[UIColor clearColor];
    cell.textLabel.text=[self.arraySettingMenu objectAtIndex:indexPath.row];
   // cell.imageView.frame  =CGRectMake(0, 0, 40, 40);
    cell.imageView.image=[UIImage imageNamed:self.arrayIcons[indexPath.row]];
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            ProfileVC *profileVC=[[ProfileVC alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:profileVC animated:YES];
            break;
        }
        case 1:
        {
            ChangeLanguageVC *changeLanguageVC=[[ChangeLanguageVC alloc] init];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"cancelbutton"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.navigationController pushViewController:changeLanguageVC animated:YES];
            break;
        }
        case 2:
        {
            
            if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
            {
                OutOfTheOfficeVC *outOfTheOfficeVC=[[OutOfTheOfficeVC alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:outOfTheOfficeVC animated:YES];
                break;
            }
            else
            {
                [PersistentStore setLoginStatus:@"Log Out"];
                NSLog(@"Login Status %@",[PersistentStore getLoginStatus]);
                NSLog(@"LogOut");
                
                [self.navigationController popViewControllerAnimated:NO];
                AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.window.rootViewController=appDelegate.loginVC;
                break;
            }
          
        }
        case 3:
        {
            
           
                ContactUsTVC *contactUsTVC=[[ContactUsTVC alloc] init];
                [self.navigationController pushViewController:contactUsTVC animated:YES];
                break;
           
            
         }
        case 4:
        {
            [[[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Are you sure to logout ?" alter:@"!Are you sure to logout ?"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil] show];
            
            break;
        }
            default:
            break;
    }
}



#pragma mark - UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0)
    {
        [PersistentStore setLoginStatus:@"Log Out"];
        NSLog(@"Login Status %@",[PersistentStore getLoginStatus]);
        NSLog(@"LogOut");
        
        [self.navigationController popViewControllerAnimated:NO];
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController=appDelegate.loginVC;
    }
}


@end
