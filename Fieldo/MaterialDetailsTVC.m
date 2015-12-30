//
//  MaterialDetailsTVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 11/28/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "MaterialDetailsTVC.h"
#import "MBProgressHUD.h"
#import "PersistentStore.h"
#import "Language.h"
#import "NSString+HTML.h"

@interface MaterialDetailsTVC ()

@end

@implementation MaterialDetailsTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=[Language get:@"Material Details" alter:@"!Material Details"];
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];

    self.tableView.rowHeight=50.0;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.arrayMaterial[section][@"task"] count])
        return 30;
    return 0.0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    
    return [self.arrayMaterial[section][@"head_name"] stringByConvertingHTMLToPlainText];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arrayMaterial count];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayMaterial[section][@"task"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text=[NSString stringWithFormat:@"Task Name : %@",[self.arrayMaterial[indexPath.section][@"task"][indexPath.row][@"task_name"]  stringByConvertingHTMLToPlainText]];
    cell.detailTextLabel.text= [NSString stringWithFormat:@"Material Name : %@",[self.arrayMaterial[indexPath.section][@"task"][indexPath.row][@"material_name"]  stringByConvertingHTMLToPlainText]];

    cell.textLabel.textColor=[UIColor colorWithRed:0.0000 green:0.4784 blue:1.0000 alpha:1.0f];
    cell.textLabel.font=[UIFont systemFontOfSize:12];
    cell.detailTextLabel.font=[UIFont systemFontOfSize:15];
    
    
    return cell;
}


@end
