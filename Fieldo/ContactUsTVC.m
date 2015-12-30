//
//  ContactUs.m
//  Fieldo
//
//  Created by Gagan Joshi on 2/28/14.
//  Copyright (c) 2014 Gagan Joshi. All rights reserved.
//

#import "ContactUsTVC.h"
#import "NSString+HTML.h"
#import "AppDelegate.h"
#import "Language.h"

@interface ContactUsTVC ()

@end

@implementation ContactUsTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    
    self.title=[Language get:@"Contact Us" alter:@"!Contact Us"];
    self.arraykeys=[[NSMutableArray alloc] init];
    [self.arraykeys addObject:[Language get:@"URL" alter:@"!URL"]];
    [self.arraykeys addObject:[Language get:@"Email" alter:@"!Email"]];
    [self.arraykeys addObject:[Language get:@"Phone" alter:@"!Phone"]];
    
    
    self.arrayContactUs = [[NSMutableArray alloc] initWithObjects:@"http://www.fieldo.se",@"info@fieldo.se",@"+46765557780", nil];
    self.arrayImages = [[NSMutableArray alloc] initWithObjects:@"imageURL.png",@"imageMail.png",@"Call.png", nil];

    
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 280)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 180)];
    imageView.image = [UIImage imageNamed:@"contact_us.png"];
    [headerView addSubview:imageView];

    UILabel *AddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 190, 260, 90)];
    AddressLabel.numberOfLines = 5;
//    AddressLabel.text = @"Wermland Software AB/Pixodio AB \nRegementsplan 1 \n681 54 Kristinehamm \nSweden";
    AddressLabel.text = @"Redpoodle Systems AB \nKarlstad Innovation Park \nSommargatan 101A \n656 37 Karlstad \nSweden";

    AddressLabel.font = [UIFont systemFontOfSize:14];
    [headerView addSubview:AddressLabel];
    self.tableView.tableHeaderView=headerView;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.arrayContactUs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor=[UIColor clearColor];
    
    cell.textLabel.text=self.arraykeys[indexPath.row];
    
    cell.textLabel.textColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
    
    cell.textLabel.font=[UIFont systemFontOfSize:10];
    
    cell.detailTextLabel.text=[self.arrayContactUs[indexPath.row] stringByConvertingHTMLToPlainText];
    
    cell.detailTextLabel.font=[UIFont systemFontOfSize:14];
    
//    if (indexPath.row==2)
//    {
    UIButton *btnAccessory=[UIButton buttonWithType:UIButtonTypeCustom];
    btnAccessory.frame=CGRectMake(0, 0, 30, 30);
    btnAccessory.tag=1000+indexPath.row;
    [btnAccessory setBackgroundImage:[UIImage imageNamed:self.arrayImages[indexPath.row]] forState:UIControlStateNormal];
    [btnAccessory addTarget:self action:@selector(Call:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView=btnAccessory;
//   / }
    
    return cell;
}


-(void)Call:(id) sender
{
    
    if ([sender tag] ==1000)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://fieldo.se"]];
    }
    else if ([sender tag] ==1001)
    {
        [self sendEmail];
    }
    else
    {
        NSString *strPhone=[NSString stringWithFormat:@"telprompt://%@",@"+46765557780"];
        UIDevice *device=[UIDevice currentDevice];
        if ([[device model] isEqualToString:@"iPhone"]) {
            NSURL *url=[NSURL URLWithString:strPhone];
            if ([strPhone isEqualToString:@"telprompt://"]) {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Phone number does not exist." alter:@"!Phone number does not exist."]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
            else
                [[UIApplication sharedApplication] openURL:url];
        }
        else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Your device doesn't support this feature." alter:@"!Your device doesn't support this feature."]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }

    }
}






-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row==0) {
//        return 250;
//    }
    return 50;
}





#pragma mark Email Functionality Starts
-(void)sendEmail
{
	// make sure this device is setup to send email
	if ([MFMailComposeViewController canSendMail])
	{
        mailer = [[MFMailComposeViewController alloc] init];
        // make this view the delegate
        mailer.mailComposeDelegate = self;
        // create mail composer object
            [mailer setToRecipients:[NSArray arrayWithObject:@"info@fieldo.se"]];
        
        [self presentViewController:mailer animated:YES completion:nil];
        
	}
    else
    {
        UIAlertView *alert1=[[UIAlertView alloc] initWithTitle:@"Fieldo" message:[Language get:@"Please configure Email Functionality in your Device." alter:@"!Please configure Email Functionality in your Device."]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert1 show];
    }
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark Email Functionality Ends



@end
