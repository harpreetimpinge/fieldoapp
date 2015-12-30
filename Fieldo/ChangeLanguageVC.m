//
//  ChangeLanguageVC.m
//  Fieldo
//
//  Created by Gurpreet Singh on 7/8/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//


#import "ChangeLanguageVC.h"

// Helper Classes
#import "Language.h"
#import "AppDelegate.h"
#import "PersistentStore.h"


@interface ChangeLanguageVC ()
{
    NSArray *arrayLanguages, *arrayFlags;
    
    IBOutlet UITableView *tableViewLanguage;
    
    IBOutlet UIButton *buttonCancel;
    
    IBOutlet UILabel *labelLanguage;
}

- (IBAction) buttonBack:(id)sender;


@end


@implementation ChangeLanguageVC


- (id) initWithNibName:(NSString *) nibNameOrNil bundle:(NSBundle *) nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self)
    {
        // Custom initialization
    }
    return self;
}



- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title=[Language get:@"Choose Language" alter:@"!Choose Language"];
    
    arrayLanguages=[[NSArray alloc] initWithObjects:@"Norwegian",@"Swedish",@"English", nil];
    
    arrayFlags=[[NSArray alloc] initWithObjects:@"imageFlagNorway.png",@"imageFlagSweden.png",@"imageFlagUK.png", nil];
    
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
}

- (void) viewWillAppear:(BOOL) animated
{
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"cancelbutton"])
    {
        buttonCancel.hidden = YES;
        
        labelLanguage.hidden = YES;
        
        tableViewLanguage.frame = CGRectMake(0, 37, 320, 148);
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cancelbutton"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - IBActions

- (IBAction) buttonBack:(id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - UITableView DataSource Methods

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section
{
    return [arrayLanguages count];
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"std"];
    }
    
    cell.imageView.frame = CGRectMake(0, 0, 40, 40);
    
    cell.textLabel.text = [arrayLanguages objectAtIndex:indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:[arrayFlags objectAtIndex:indexPath.row]];
    
    return cell;
}



#pragma mark - UITableView Delegate Methods

- (CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath
{
    return  50.0;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
    switch (indexPath.row)
    {
        case 0:
            [Language setLanguage:@"nn"];
    
            [PersistentStore setLocalLanguage:@"nn"];
            
            break;
        case 1:
            [Language setLanguage:@"sv"];
            
            [PersistentStore setLocalLanguage:@"sv"];
            
            break;
        case 2:
            [Language setLanguage:@"en"];
            
            [PersistentStore setLocalLanguage:@"en"];
            
            break;
        default:
            break;
    }
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([[PersistentStore getLoginStatus] isEqualToString:@"Worker"])
    {
        UIButton *button=(UIButton *)[appDelegate.mainMenuVC.menuView viewWithTag:1];
     
        [button setTitle:[Language get:@"Projects" alter:@"!Projects"] forState:UIControlStateNormal];
        
        button=(UIButton *)[appDelegate.mainMenuVC.menuView viewWithTag:2];
        
        [button setTitle:[Language get:@"Calendar" alter:@"!Calendar"] forState:UIControlStateNormal];
        
        button=(UIButton *)[appDelegate.mainMenuVC.menuView viewWithTag:3];
        
        [button setTitle:[Language get:@"Log" alter:@"!Log"] forState:UIControlStateNormal];
        
        button=(UIButton *)[appDelegate.mainMenuVC.menuView viewWithTag:4];
        
        [button setTitle:[Language get:@"Home" alter:@"!Home"] forState:UIControlStateNormal];
        
        if (self.navigationController)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            NSString *strNotification=@"LanguageChange";
        
            [[NSNotificationCenter defaultCenter]postNotificationName:strNotification object:nil userInfo:nil];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else
    {
        UIButton *button=(UIButton *)[appDelegate.mainMenuVC.menuView viewWithTag:1];

        [button setTitle:[Language get:@"Projects" alter:@"!Projects"] forState:UIControlStateNormal];
        
        button=(UIButton *)[appDelegate.mainMenuVC.menuView viewWithTag:2];
        
        [button setTitle:[Language get:@"Ratings" alter:@"!Ratings"] forState:UIControlStateNormal];
        
        button=(UIButton *)[appDelegate.mainMenuVC.menuView viewWithTag:3];
        
        [button setTitle:[Language get:@"Invoices" alter:@"!Invoices"] forState:UIControlStateNormal];
        
        button=(UIButton *)[appDelegate.mainMenuVC.menuView viewWithTag:4];
        
        [button setTitle:[Language get:@"Home" alter:@"!Home"] forState:UIControlStateNormal];
        
        if (self.navigationController)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            NSString *strNotification=@"LanguageChange";
        
            [[NSNotificationCenter defaultCenter]postNotificationName:strNotification object:nil userInfo:nil];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}



#pragma mark - Memory Handling

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
