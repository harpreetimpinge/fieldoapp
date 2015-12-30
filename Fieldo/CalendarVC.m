//
//  CalendarVC.m
//  Fieldo
//
//  Created by Gagan Joshi on 10/26/13.
//  Copyright (c) 2013 Gagan Joshi. All rights reserved.
//

#import "CalendarVC.h"
#import "Language.h"
#import "PersistentStore.h"
#import "MBProgressHUD.h"
#import "NSString+HTML.h"

#import "ProjectRecord.h"

@interface CalendarVC ()

@end

@implementation CalendarVC
{
    int occurenceCount;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent=NO;
    self.navigationItem.title=@"Calendar";
    
   
    [self StructureSetUpFirstTime];
    
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [self refreshCalendar];
    [self hideLoadingView];
}
-(void)StructureSetUpFirstTime
{
    NSArray *array=[[NSArray alloc] initWithObjects:@"S",@"M",@"T",@"W",@"T",@"F",@"S", nil];
    int xPos=20;
    for (int i=0; i<7; i++)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xPos, 5, 40, 20)];
        if (i>5 || i<1)
            label.textColor =[UIColor lightGrayColor] ;
        else
            label.textColor =[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f] ;
        
        label.font=[UIFont systemFontOfSize:12];
        label.textAlignment=NSTextAlignmentCenter;
        label.text=array[i];
        [self.view addSubview:label];
        xPos=xPos+40;
    }
    
    [self drawTopBarScrollView];
  //  [self drawContentAndMainScrollView];
    
    
    unsigned unitFlags = NSYearCalendarUnit   |  NSCalendarUnitDay  | NSWeekdayCalendarUnit | NSCalendarUnitWeekOfYear;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:[NSDate date]];

    
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setWeekOfYear:components.weekOfYear];
    [comps setWeekday:1];
    [comps setYear:components.year];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *resultDate = [gregorian dateFromComponents:comps];
    
    NSLog(@"result Date %@",resultDate);
    
    [self getEventoftheWeek:resultDate];
 
}


-(void)drawTopBarScrollView
{
    NSDate *todayDate=[NSDate date];
    self.arrayDates=[[NSMutableArray alloc] init];
    
    unsigned unitFlags = NSYearCalendarUnit   |  NSCalendarUnitDay  | NSWeekdayCalendarUnit | NSCalendarUnitWeekOfYear;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:todayDate];
    
    
    if (components.month==1 && components.day<7)
    {
        int i,j;
        for (i=1, j=7; j>=components.day; j--,i++)
        {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setMonth:12];
            [comps setWeekday:i];
            [comps setWeekOfYear:53];
            [comps setYear:components.year-1];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:comps];
            [self.arrayDates addObject:date];
        }
        for (int k=1, j=i; j<=7;k++, j++)
        {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setMonth:1];
            [comps setDay:k];
            [comps setYear:components.year];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:comps];
            [self.arrayDates addObject:date];
        }
        for (int k=1; k<=7; k++)
        {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setMonth:1];
            [comps setWeekday:k];
            [comps setWeekOfYear:2];
            [comps setYear:components.year];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:comps];
            [self.arrayDates addObject:date];
        }
        for (int k=1; k<=7; k++)
        {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setMonth:1];
            [comps setWeekday:k];
            [comps setWeekOfYear:3];
            [comps setYear:components.year];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:comps];
            [self.arrayDates addObject:date];
        }
    }
    else if (components.month==12  && components.day>18)
    {
        int i,j;
        for (i=1;i<=7 ; i++)
        {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setDay:components.day-8+i];
            [comps setMonth:12];
            [comps setYear:components.year];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:comps];
            [self.arrayDates addObject:date];
        }
        for (j=components.day; j<=31; j++,i++)
        {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setDay:j];
            [comps setMonth:12];
            [comps setYear:components.year];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:comps];
            [self.arrayDates addObject:date];
        }
        for (int k=1; i<=21; k++,i++)
        {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setMonth:1];
            [comps setDay:k];
            [comps setYear:components.year+1];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:comps];
            [self.arrayDates addObject:date];
        }
    }
    else
    {
    
    for (int j=0;j<3;j++ )
    {
        for (int i=1; i<=7; i++)
        {
            @autoreleasepool
            {
                NSDateComponents *comps = [[NSDateComponents alloc] init];
                [comps setWeekOfYear:components.weekOfYear+j-1];
                [comps setWeekday:i];
                [comps setYear:components.year];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDate *date = [gregorian dateFromComponents:comps];
                [self.arrayDates addObject:date];
            }
        }
    }
    }
    //Top ScrollBar For changing Dates
    self.scrollViewTopBar=[[UIScrollView alloc] initWithFrame:CGRectMake(20, 20, 280, 40)];
    self.scrollViewTopBar.delegate=self;
    self.scrollViewTopBar.showsHorizontalScrollIndicator=NO;
    self.scrollViewTopBar.pagingEnabled=YES;
    self.scrollViewTopBar.contentOffset=CGPointMake(280, 0);
    self.scrollViewTopBar.contentSize=CGSizeMake(840, 40);


    [self.view addSubview:self.scrollViewTopBar];
    
    int i;
    
    for (i=0;i<[self.arrayDates count];i++)
    {
        @autoreleasepool
        {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(i*40+5, 5, 30, 30);
        button.layer.cornerRadius=15.0;
        button.tag=100+i;
        //setting title color of buttons
        if (i%7==0 || i%7==6)
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        else
        [button setTitleColor:[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f] forState:UIControlStateNormal];
        NSDateFormatter *dateFormet=[[NSDateFormatter alloc] init];
//        [dateFormet setDateFormat:@"dd-MMM-yyyy"];
            [dateFormet setDateFormat:@"dd-MM-yyyy"];
        if ([[dateFormet stringFromDate:self.arrayDates[i]] isEqualToString:[dateFormet stringFromDate:todayDate]])
        {
            //setting title color and background color of today's date button
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor redColor]];
            selectedIndex=i;
        }
        [button setTitle:[NSString stringWithFormat:@"%d",[[[dateFormet stringFromDate:self.arrayDates[i]] substringWithRange:NSMakeRange(0, 2)] intValue]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollViewTopBar addSubview:button];
        }

    }
   
    NSDateFormatter *dateFormet=[[NSDateFormatter alloc] init];
//    [dateFormet setDateFormat:@"EEEE  d MMMM YYYY"];
    [dateFormet setDateFormat:@"dd-MM-YYYY"];
    self.labelCurrentDate = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 280, 30)];
    self.labelCurrentDate.text=[dateFormet stringFromDate:todayDate];
    self.labelCurrentDate.textAlignment=NSTextAlignmentCenter;
    self.labelCurrentDate.font=[UIFont systemFontOfSize:12];

    self.labelCurrentDate.textColor =[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f];
    [self.view addSubview:self.labelCurrentDate];
    
    
   
    
}




#pragma Mark Show hide Loading
-(void)showLoadingView
{
    //self.tableView.hidden=YES;
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = YES;
    hud.labelText = @"Loading...";
    hud.dimBackground = YES;
}

-(void)refreshTable
{
    [self hideLoadingView];
    
}

-(void)hideLoadingView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


-(void)buttonClick:(UIButton *)sender
{
//    ProjectRecord *projRec=[self.addproject objectAtIndex:sender.tag-100];
//    NSString *Message=([projRec.from isEqualToString:@"07:00"] && [projRec.to isEqualToString:@"17:00"])?[NSString stringWithFormat:@"Start Date : %@\nEnd Date :%@",projRec.startDate,projRec.endDate]:[NSString stringWithFormat:@"Start Date : %@\nEnd Date :%@\nStart Time : %@\nEnd Time : %@",projRec.startDate,projRec.endDate,projRec.from,projRec.to];
//    [[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@\n%@",@"All Day Project",[projRec.projectName stringByConvertingHTMLToPlainText]] message:Message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}

-(void)drawContentAndMainScrollView
{
    [self hideLoadingView];
    Add=YES;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (screenSize.height > 480.0f)
        {
            self.scrollViewMain=[[UIScrollView alloc] initWithFrame:CGRectMake(0, (Add)?110:80, 320, 344)];
            self.scrollViewMain.contentSize=CGSizeMake(2880, 344);
        }
        else
        {
             self.scrollViewMain=[[UIScrollView alloc] initWithFrame:CGRectMake(0, (Add)?110:80, 320, 256)];
             self.scrollViewMain.contentSize=CGSizeMake(2880, 256);
        }
    }
    
    self.scrollViewMain.layer.borderWidth=1.0;
    self.scrollViewMain.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.scrollViewMain.delegate=self;
    self.scrollViewMain.showsHorizontalScrollIndicator=NO;
    self.scrollViewMain.pagingEnabled=YES;
    
    self.scrollViewMain.contentOffset=CGPointMake((selectedIndex-6)*320, 0);
    
    [self.view addSubview:self.scrollViewMain];
    
    for (int i=0; i<9; i++)
    {
        UIScrollView *scrollViewContents;
        
     occurenceCount=0;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            if (screenSize.height > 480.0f)
            {
                scrollViewContents=[[UIScrollView alloc] initWithFrame:CGRectMake(i*320, 0, 320, 343)];
            }
            else
            {
                scrollViewContents=[[UIScrollView alloc] initWithFrame:CGRectMake(i*320, 0, 320, 255)];
            }
        }
        
        scrollViewContents.contentSize=CGSizeMake(320, 1470);
        scrollViewContents.backgroundColor=[UIColor whiteColor];
        scrollViewContents.contentOffset=CGPointMake(0, 480);
        [self.scrollViewMain addSubview:scrollViewContents];
       
        
        int yPos=5;
        for (int i=0; i<=24; i++)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, yPos, 35, 20)];
            label.textAlignment=NSTextAlignmentCenter;
            label.font=[UIFont systemFontOfSize:11];
            label.textColor =[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f];
            
            if (i==0)
            label.text=@"12:00";
            else if(i==12)
            {
            label.text=@"Noon";
            label.frame=CGRectMake(5, yPos, 35, 20);
            }
            else if(i==24)
            label.text=@"12:00";
            
            else
            label.text=[NSString stringWithFormat:@"0%d:00",i%12];
            
             if (i == 10)
            {
                label.text = @"10:00";
            }
            else if (i == 11)
            {
                label.text = @"11:00";
            }
            if ([label.text isEqualToString:@"010:00"])
            {
                label.text = @"10:00";
            }
            else if ([label.text isEqualToString:@"011:00"])
            {
                label.text = @"11:00";
            }
            label.textAlignment=NSTextAlignmentRight;
            [scrollViewContents addSubview:label];
            
            UIView *view=[[UIView alloc] initWithFrame:CGRectMake(45,yPos+9,270,0.5)];
            view.backgroundColor=[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:0.400f];
            [scrollViewContents addSubview:view];
            yPos=yPos+60;
        }
        
        if (i!=0 && i!=8)
        {
            if([self.arrayEvents[i-1][@"leave"] count])
            {
                
                UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
                [button setBackgroundColor:[UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:0.3]];
                [button setTitleEdgeInsets:UIEdgeInsetsMake(5, 5, 0, 0)];
                button.titleLabel.numberOfLines=4;
                button.titleLabel.font=[UIFont systemFontOfSize:12];
                button.frame=CGRectMake(47, 496, 266, 536);
                [scrollViewContents addSubview:button];
                
                UILabel *labelReason=[[UILabel alloc]initWithFrame:CGRectMake(60, 498, 260, 20)];
                labelReason.text=[[NSString stringWithFormat:@"%@",self.arrayEvents[i-1][@"leave"][0][@"reason"]]stringByConvertingHTMLToPlainText];
                labelReason.textAlignment=NSTextAlignmentLeft;
                labelReason.font=[UIFont boldSystemFontOfSize:14.0];
                labelReason.textColor=[UIColor blackColor];
                [scrollViewContents addSubview:labelReason];
               
                labelReason=[[UILabel alloc]initWithFrame:CGRectMake(60, 520, 260, 40)];
                labelReason.text=[[NSString stringWithFormat:@"%@",self.arrayEvents[i-1][@"leave"][0][@"desc"]]stringByConvertingHTMLToPlainText];
                labelReason.textAlignment=NSTextAlignmentLeft;
                labelReason.numberOfLines=2;
                labelReason.font=[UIFont systemFontOfSize:12.0];
                labelReason.textColor=[UIColor blackColor];
                [scrollViewContents addSubview:labelReason];
                
                UIView *viewBtn=[[UIView alloc]initWithFrame:CGRectMake(47, 496, 1.5, 536)];
                viewBtn.backgroundColor=[UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:1.0];
                [scrollViewContents addSubview:viewBtn];

            }
          else if([self.arrayEvents[i-1][@"Proj"] count])//([self.addproject count])
          {
              
              NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
              [dateFormat setDateFormat:@"HH:mm"];
              
              NSLog(@"%lu",(unsigned long)[self.arrayEvents[i-1][@"Proj"] count]);
              for (int k=0; k<[self.arrayEvents[i-1][@"Proj"] count]; k++) {
                 
                  NSDate* date1 = [dateFormat dateFromString:[NSString stringWithFormat:@"%@",self.arrayEvents[i-1][@"Proj"][k][@"from_time"]]];
                  NSDate* date2 = [dateFormat dateFromString:[NSString stringWithFormat:@"%@",self.arrayEvents[i-1][@"Proj"][k][@"to_time"]]];
                  NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
                  double secondsInAnHour = 3600;
                  NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
                  
                  if (hoursBetweenDates<10)
                  {
                      UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
                      [button setBackgroundColor:[UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:0.3]];
                      NSString *fromget=[NSString stringWithFormat:@"%@",self.arrayEvents[i-1][@"Proj"][k][@"from_time"]];
                      CGFloat CalculatedYPos=[self from1:fromget]*60+14;
                      NSString *toget=[NSString stringWithFormat:@"%@",self.arrayEvents[i-1][@"Proj"][k][@"to_time"]];
                      CGFloat CalculatedWidth=[self from1:toget]*60+14;
                      button.frame=CGRectMake(47, CalculatedYPos, 280, CalculatedWidth-CalculatedYPos);
                      [scrollViewContents addSubview:button];
                      
                      NSMutableDictionary *dic=[self projectRepeatIndex:k iVar:i];
                      int totaloccurence=[[dic valueForKey:@"totaloccurence"] intValue];
                      NSLog(@"%@",dic);
                      UILabel *labelReason;
                      if(totaloccurence>1)
                      {
                          int occurence=[[dic valueForKey:@"occurenceCount"] intValue];
                          float yPos=(((CalculatedWidth-CalculatedYPos)/totaloccurence+1)*occurence)-30;
                         labelReason  =[[UILabel alloc]initWithFrame:CGRectMake(60, yPos, 260, 40)];
                          NSLog(@"%f %@ %@",yPos,self.arrayEvents[i-1][@"Proj"][k][@"title"],dic);
                            labelReason.text=[[NSString stringWithFormat:@"%@",self.arrayEvents[i-1][@"Proj"][k][@"title"]] stringByConvertingHTMLToPlainText];
                      }else
                    labelReason=[[UILabel alloc]initWithFrame:CGRectMake(60, ((CalculatedWidth-CalculatedYPos)/2)-20, 260, 40)];
                      
                      
//                    UILabel *labelReason=[[UILabel alloc]initWithFrame:CGRectMake(60, ((CalculatedWidth-CalculatedYPos)/2)-20, 260, 40)];
                      labelReason.text=[[NSString stringWithFormat:@"%@",self.arrayEvents[i-1][@"Proj"][k][@"title"]] stringByConvertingHTMLToPlainText];
                      labelReason.textAlignment=NSTextAlignmentLeft;
                      labelReason.numberOfLines=0;
                      labelReason.font=[UIFont boldSystemFontOfSize:14.0];
                      labelReason.textColor=[UIColor blackColor];
                      [button addSubview:labelReason];
                      
                      UIView *viewBtn=[[UIView alloc]initWithFrame:CGRectMake(47, CalculatedYPos, 1.0, CalculatedWidth-CalculatedYPos)];
                      viewBtn.backgroundColor=[UIColor colorWithRed:0.0 green:0.478 blue:1.5 alpha:1.0];
                      [scrollViewContents addSubview:viewBtn];
                      
                      NSDictionary *dict=[NSDictionary dictionaryWithObject:@"NO" forKey:@"Project"];
                      [self.addproject addObject:dict];
                      
                  }
                  else
                  {
                      
                      NSDictionary *dict=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"YES",self.arrayEvents[i-1][@"Proj"], nil] forKeys:[NSArray arrayWithObjects:@"Project",@"ProjDict", nil]];
                      [self.addproject addObject:dict];
                  }

              }
        }
     }
     else
     {
         //add nothing
     }
    }
    
    NSArray *arrayProjects=(selectedIndex>=7)?self.arrayEvents[selectedIndex-7][@"Proj"]:nil;
    if ( arrayProjects.count>0) {
        self.allDayProjectArray=[NSMutableArray new];
        [self addLoopToView:arrayProjects];
    }
    else
    {
        Add=NO;
        [self.allDayProjectArray removeAllObjects];
        if (self.projectScroll) {
            NSArray *allView=[self.projectScroll subviews];
            for (id views in allView)
            {
                [views removeFromSuperview];
            }
            [self.projectScroll removeFromSuperview];
            self.projectScroll=nil;
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (screenSize.height > 480.0f)
        {
            self.scrollViewMain.frame=CGRectMake(0, (self.allDayProjectArray.count>0)?110:80, 320, 344);
            self.scrollViewMain.contentSize=CGSizeMake(2880, 344);
        }
        else
        {
            self.scrollViewMain.frame=CGRectMake(0, (self.allDayProjectArray.count>0)?110:80, 320, 256);
            self.scrollViewMain.contentSize=CGSizeMake(2880, 256);
        }
    }
 }

-(NSMutableDictionary *)projectRepeatIndex:(int)index iVar:(int)i
{
    NSString *fromget=[NSString stringWithFormat:@"%@",self.arrayEvents[i-1][@"Proj"][index][@"from_time"]];
    NSString *toget=[NSString stringWithFormat:@"%@",self.arrayEvents[i-1][@"Proj"][index][@"to_time"]];
    NSMutableDictionary *res=[[ NSMutableDictionary alloc]init];
    

    
    int totaloccurence=0;
    
      for (int k=0; k<[self.arrayEvents[i-1][@"Proj"] count]; k++) {
    if([fromget isEqualToString:self.arrayEvents[i-1][@"Proj"][k][@"from_time"]]&&[toget isEqualToString:self.arrayEvents[i-1][@"Proj"][k][@"to_time"]])
    {
        if (totaloccurence==1)
        occurenceCount++;
        totaloccurence++;
        
    }
      }
    [res setValue:[NSNumber numberWithInt:totaloccurence] forKey:@"totaloccurence"];
     [res setValue:[NSNumber numberWithInt:occurenceCount] forKey:@"occurenceCount"];
    return res;
    
}

-(CGFloat)from1:(NSString *)Time
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date=[dateFormatter dateFromString:Time];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    CGFloat minuteDecimal=(CGFloat)minute/60;
    CGFloat finalFromDecimal=(CGFloat)hour+minuteDecimal;
    return finalFromDecimal;
}

-(CGFloat)from:(NSString *)Time
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *date=[dateFormatter dateFromString:Time];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    CGFloat minuteDecimal=(CGFloat)minute/60;
    CGFloat finalFromDecimal=(CGFloat)hour+minuteDecimal;
    return finalFromDecimal;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView==self.scrollViewMain)
    {
        if (self.scrollViewMain.contentOffset.x==2560)
        {
            self.scrollViewMain.contentOffset=CGPointMake(320, 0);
            selectedIndex=7;
            refreshDate=self.arrayDates[16];
            [self getEventoftheWeek:self.arrayDates[16]];
            [self resetTopBarScrollView:self.arrayDates[16]];
        }
        else if (self.scrollViewMain.contentOffset.x==0)
        {
            self.scrollViewMain.contentOffset=CGPointMake(2240, 0);
            selectedIndex=13;
            refreshDate=self.arrayDates[1];
            [self getEventoftheWeek:self.arrayDates[1]];
            [self resetTopBarScrollView:self.arrayDates[1]];
        }
        else
        {
            int flag=self.scrollViewMain.contentOffset.x/320+106;
            [self changeDatebyScroll:flag];
        }
    }
    else if(scrollView==self.self.scrollViewTopBar)
    {
        if (self.scrollViewTopBar.contentOffset.x==0)
        {
            refreshDate=self.arrayDates[1];
            [self getEventoftheWeek:self.arrayDates[1]];
            [self resetTopBarScrollView:self.arrayDates[1]];
        }
        else if(self.scrollViewTopBar.contentOffset.x==560)
        {
            refreshDate=self.arrayDates[16];
            [self getEventoftheWeek:self.arrayDates[16]];
            [self resetTopBarScrollView:self.arrayDates[16]];
        }
    }
}

-(void)resetTopBarScrollView:(NSDate *)date
{
    NSLog(@"date %@",date);
    
    NSMutableArray  *arrayDate=[[NSMutableArray alloc] init];
    
    unsigned unitFlags = NSCalendarUnitYear   |  NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekOfMonth;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:date];
    
    if (components.month==1 && components.day<7)
    {
        int i,j;
        for (i=1, j=7; j>=components.day; j--,i++)
        {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setMonth:12];
            [comps setWeekday:i];
            [comps setWeekOfYear:53];
            [comps setYear:components.year-1];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:comps];
            [arrayDate addObject:date];
        }
        for (int k=1, j=i; j<=7;k++, j++)
        {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setMonth:1];
            [comps setDay:k];
            [comps setYear:components.year];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:comps];
            [arrayDate addObject:date];
        }
        for (int k=1; k<=7; k++)
        {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setMonth:1];
            [comps setWeekday:k];
            [comps setWeekOfYear:2];
            [comps setYear:components.year];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:comps];
            [arrayDate addObject:date];
        }
        for (int k=1; k<=7; k++)
        {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setMonth:1];
            [comps setWeekday:k];
            [comps setWeekOfYear:3];
            [comps setYear:components.year];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:comps];
            [arrayDate addObject:date];
        }
    }
    else if (components.month==12  && components.day>18)
    {
        int i,j;
        for (i=1;i<=7 ; i++)
        {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setDay:components.day-8+i];
            [comps setMonth:12];
            [comps setYear:components.year];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:comps];
            [arrayDate addObject:date];
        }
        for (j=components.day; j<=31; j++,i++)
        {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setDay:j];
            [comps setMonth:12];
            [comps setYear:components.year];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:comps];
            [arrayDate addObject:date];
        }
        for (int k=1; i<=21; k++,i++)
        {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setMonth:1];
            [comps setDay:k];
            [comps setYear:components.year+1];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:comps];
            [arrayDate addObject:date];
        }
    }
    else
    {
        for (int j=0;j<3;j++ )
        {
            for (int i=1; i<=7; i++)
            {
                @autoreleasepool
                {
                    NSDateComponents *comps = [[NSDateComponents alloc] init];
                    [comps setWeekOfYear:components.weekOfYear+j-1];
                    [comps setWeekday:i];
                    [comps setYear:components.year];
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDate *date = [gregorian dateFromComponents:comps];
                    [arrayDate addObject:date];
                }
            }
            
        }
    }
    self.arrayDates=nil;
    
    self.arrayDates=arrayDate;
    
    [[self.scrollViewTopBar subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
   
        for (int i=0;i<[self.arrayDates count];i++)
        {
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            button.frame=CGRectMake(i*40+5, 5, 30, 30);
            [button addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventTouchUpInside];
            button.tag=100+i;
            button.layer.cornerRadius=15.0;
            if (i%7==0 || i%7==6  )
                [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            else
                [button setTitleColor:[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f] forState:UIControlStateNormal];
            
            
            NSDateFormatter *dateFormet=[[NSDateFormatter alloc] init];
            [dateFormet setDateFormat:@"dd-MMM-yyyy"];
            
            if ([[dateFormet stringFromDate:self.arrayDates[i]] isEqualToString:[dateFormet stringFromDate:[NSDate date]]])
                [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            
            
            if (selectedIndex==i)
            {
                if ([[dateFormet stringFromDate:self.arrayDates[i]] isEqualToString:[dateFormet stringFromDate:[NSDate date]]])
                {
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [button setBackgroundColor:[UIColor redColor]];
                }
                else
                {
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [button setBackgroundColor:[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f]];
                }
                NSDateFormatter *dateFormet2=[[NSDateFormatter alloc] init];
//                [dateFormet2 setDateFormat:@"EEEE  d MMMM YYYY"];
                [dateFormet2 setDateFormat:@"dd-MM-YYYY"];
                self.labelCurrentDate.text=[dateFormet2 stringFromDate:self.arrayDates[i]];
            }
            [button setTitle:[NSString stringWithFormat:@"%d",[[[dateFormet stringFromDate:self.arrayDates[i]] substringWithRange:NSMakeRange(0, 2)] intValue]] forState:UIControlStateNormal];
            [self.scrollViewTopBar addSubview:button];
            
        }
    
    
    self.scrollViewTopBar.contentOffset=CGPointMake(280, 0);


}


-(void)changeDate:(id)sender
{
    if (selectedIndex==[sender tag]-100)
    {
        return;
    }
    
    selectedIndex=(int)[sender tag]-100;

   
    NSArray *arrayProjects=(selectedIndex>=7)?self.arrayEvents[selectedIndex-7][@"Proj"]:nil;
    if ( arrayProjects.count>0) {
        self.allDayProjectArray=[NSMutableArray new];
        [self addLoopToView:arrayProjects];
    }
    else
    {
        Add=NO;
        if (self.projectScroll) {
            [self.allDayProjectArray removeAllObjects];
            NSArray *allView=[self.projectScroll subviews];
            for (id views in allView) {
                [views removeFromSuperview];
            }
            [self.projectScroll removeFromSuperview];
            self.projectScroll=nil;
        }
    }
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (screenSize.height > 480.0f)
        {
            self.scrollViewMain.frame=CGRectMake(0, (self.allDayProjectArray.count>0)?110:80, 320, 344);
            self.scrollViewMain.contentSize=CGSizeMake(2880, 344);
        }
        else
        {
            self.scrollViewMain.frame=CGRectMake(0, (self.allDayProjectArray.count>0)?110:80, 320, 256);
            self.scrollViewMain.contentSize=CGSizeMake(2880, 256);
        }
    }
    
    NSDateFormatter *dateFormet=[[NSDateFormatter alloc] init];
    [dateFormet setDateFormat:@"dd MMM YYYY"];
    
        for (UIButton *button in self.scrollViewTopBar.subviews)
        {
            
            if (button.tag>106 && button.tag <114)
            {
                [button setBackgroundColor:[UIColor clearColor]];
                
                if ((button.tag-100)%7==0 || (button.tag-100)%7==6  )
                    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                else
                    [button setTitleColor:[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f] forState:UIControlStateNormal];
                
                if ([[dateFormet stringFromDate:self.arrayDates[button.tag-100]] isEqualToString:[dateFormet stringFromDate:[NSDate date]]])
                    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                

            }
        }

    UIButton *btn=sender;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f]];
    
    
    NSDateFormatter *dateFormet2=[[NSDateFormatter alloc] init];
//    [dateFormet2 setDateFormat:@"EEEE  d MMMM YYYY"];
    [dateFormet2 setDateFormat:@"dd-MM-YYYY"];
    self.labelCurrentDate.text=[dateFormet2 stringFromDate:self.arrayDates[[sender tag]-100]];
    
    if ([[dateFormet stringFromDate:self.arrayDates[[sender tag]-100 ]] isEqualToString:[dateFormet stringFromDate:[NSDate date]] ])
    {
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor redColor]];
    }

    [self.scrollViewMain setContentOffset:CGPointMake((btn.tag-106)*320, 0) animated:YES];
}


-(void) addProjectScrollToView
{
    if (self.projectScroll) {
        NSArray *allView=[self.projectScroll subviews];
        for (id views in allView) {
            [views removeFromSuperview];
        }
        [self.projectScroll removeFromSuperview];
        self.projectScroll=nil;
    }
    
    self.projectScroll=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 80, 320, 30)];
    self.projectScroll.contentSize=CGSizeMake(320, 30);
    self.projectScroll.backgroundColor=[UIColor clearColor];
    self.projectScroll.showsHorizontalScrollIndicator=NO;
    [self.view addSubview:self.projectScroll];
    
    CGFloat x=0;
    CGFloat totalWidth=0;
    for (int i=0; i<[self.allDayProjectArray count]; i++)
    {
        CGFloat width=[self widthOfString:[self.allDayProjectArray objectAtIndex:i] withFont:[UIFont boldSystemFontOfSize:12]];
        totalWidth+=width;
    }
    CGFloat AddedValues=0;
    if (totalWidth<320) {
        CGFloat remainingValue=320-totalWidth;
        AddedValues=remainingValue/[self.allDayProjectArray count];
    }
    for (int i=0; i<[self.allDayProjectArray count]; i++)
    {
        CGFloat width=[self widthOfString:[self.allDayProjectArray objectAtIndex:i] withFont:[UIFont boldSystemFontOfSize:12]];
        UIButton *ProjectLabel=[[UIButton alloc]initWithFrame:CGRectMake(x, 0,width+AddedValues+10, 30)];
        ProjectLabel.layer.borderColor=(__bridge CGColorRef)([UIColor grayColor]);
        ProjectLabel.backgroundColor=[UIColor colorWithRed:0.0 green:0.478 blue:1.5 alpha:1.0];
        ProjectLabel.layer.borderWidth=2;
        ProjectLabel.tag=100+i;
        [ProjectLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        ProjectLabel.titleLabel.font=[UIFont boldSystemFontOfSize:12];
        [ProjectLabel addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.projectScroll addSubview:ProjectLabel];
        Add=YES;
        [ProjectLabel setTitle:[self.allDayProjectArray objectAtIndex:i] forState:UIControlStateNormal];
        x+=width+AddedValues+12;
    }
    
    [self.projectScroll setContentSize:CGSizeMake(x, 30)];
}

-(CGFloat) widthOfString:(NSString *)string withFont :(UIFont *) font
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:[string capitalizedString] attributes:attributes] size].width;
}
-(void)addLoopToView:(NSArray *)array
{
    for (int i=0; i<[array count]; i++) {
        NSDateFormatter *dateFormat1=[[NSDateFormatter alloc]init];
        [dateFormat1 setDateFormat:@"HH:mm"];
        
        NSDate* date11 = [dateFormat1 dateFromString:[NSString stringWithFormat:@"%@",self.arrayEvents[selectedIndex-7][@"Proj"][i][@"from_time"]]];
        NSDate* date12 = [dateFormat1 dateFromString:[NSString stringWithFormat:@"%@",self.arrayEvents[selectedIndex-7][@"Proj"][i][@"to_time"]]];
        NSTimeInterval distanceBetweenDates = [date12 timeIntervalSinceDate:date11];
        double secondsInAnHour = 3600;
        NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
        
        if (hoursBetweenDates==10)
        {
            [self.allDayProjectArray addObject:[[NSString stringWithFormat:@"%@",self.arrayEvents[selectedIndex-7][@"Proj"][i][@"title"]] stringByConvertingHTMLToPlainText]];
        }
        
        [self addProjectScrollToView];
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            if (screenSize.height > 480.0f)
            {
                self.scrollViewMain.frame=CGRectMake(0, (self.allDayProjectArray.count>0)?110:80, 320, 344);
                self.scrollViewMain.contentSize=CGSizeMake(2880, 344);
            }
            else
            {
                self.scrollViewMain.frame=CGRectMake(0, (self.allDayProjectArray.count>0)?110:80, 320, 256);
                self.scrollViewMain.contentSize=CGSizeMake(2880, 256);
            }
        }
    }
}

-(void)changeDatebyScroll:(int)flag
{
    selectedIndex=flag-100;
    
    NSDateFormatter *dateFormet=[[NSDateFormatter alloc] init];
    [dateFormet setDateFormat:@"dd MMM YYYY"];
    
    
    NSArray *arrayProjects=(selectedIndex>=7 && selectedIndex<14)?self.arrayEvents[selectedIndex-7][@"Proj"]:nil;
    
    if ( arrayProjects.count>0) {
        self.allDayProjectArray=[NSMutableArray new];
        [self addLoopToView:arrayProjects];
    }
    else
    {
        [self.allDayProjectArray removeAllObjects];
        Add=NO;
        if (self.projectScroll) {
            NSArray *allView=[self.projectScroll subviews];
            for (id views in allView) {
                [views removeFromSuperview];
            }
            [self.projectScroll removeFromSuperview];
            self.projectScroll=nil;
        }
    }
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (screenSize.height > 480.0f)
        {
            self.scrollViewMain.frame=CGRectMake(0, (self.allDayProjectArray.count>0)?110:80, 320, 344);
            self.scrollViewMain.contentSize=CGSizeMake(2880, 344);
        }
        else
        {
            self.scrollViewMain.frame=CGRectMake(0, (self.allDayProjectArray.count>0)?110:80, 320, 256);
            self.scrollViewMain.contentSize=CGSizeMake(2880, 256);
        }
    }

    
    for (UIButton *button in self.scrollViewTopBar.subviews)
    {
        
        if (button.tag>106 && button.tag <114)
        {
            [button setBackgroundColor:[UIColor clearColor]];
            
            if ((button.tag-100)%7==0 || (button.tag-100)%7==6  )
                [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            else
                [button setTitleColor:[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f] forState:UIControlStateNormal];
            
            if ([[dateFormet stringFromDate:self.arrayDates[button.tag-100]] isEqualToString:[dateFormet stringFromDate:[NSDate date]]])
                [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        
        if (button.tag==flag)
        {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor colorWithRed:0.0000 green:0.478 blue:1.000 alpha:1.000f]];
            
            
            if ([[dateFormet stringFromDate:self.arrayDates[flag-100 ]] isEqualToString:[dateFormet stringFromDate:[NSDate date]] ])
            {
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button setBackgroundColor:[UIColor redColor]];
            }
        }
    }
    
    NSDateFormatter *dateFormet2=[[NSDateFormatter alloc] init];
//    [dateFormet2 setDateFormat:@"EEEE  d MMMM YYYY"];
    [dateFormet2 setDateFormat:@"dd-MM-YYYY"];
    self.labelCurrentDate.text=[dateFormet2 stringFromDate:self.arrayDates[flag-100]];
}


-(void)refreshCalendar
{
    if (refreshDate!=nil) {
        [self getEventoftheWeek:refreshDate];
    }
    else
    {
        unsigned unitFlags = NSYearCalendarUnit   |  NSCalendarUnitDay  | NSWeekdayCalendarUnit | NSCalendarUnitWeekOfYear;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:[NSDate date]];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setWeekOfYear:components.weekOfYear];
        [comps setWeekday:1];
        [comps setYear:components.year];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *resultDate = [gregorian dateFromComponents:comps];
        
        NSLog(@"result Date %@",resultDate);
        [self getEventoftheWeek:resultDate];


    }
}

-(void)getEventoftheWeek:(NSDate *)firstDateOfWeek
{
    [self showLoadingView];
    
    NSLog(@"date %@",firstDateOfWeek);
    
    self.addproject=[NSMutableArray new];
    
    unsigned unitFlags = NSYearCalendarUnit   |  NSCalendarUnitDay  | NSWeekdayCalendarUnit | NSCalendarUnitWeekOfYear;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:firstDateOfWeek];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setWeekOfYear:components.weekOfYear];
    [comps setWeekday:1];
    [comps setYear:components.year];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *resultDate = [gregorian dateFromComponents:comps];
    
    NSLog(@"result Date %@",resultDate);
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];

//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSError *error;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc] init];
    [postDict setObject:[PersistentStore getWorkerID] forKey:@"worker_id"];
    [postDict setObject:[dateFormatter stringFromDate:resultDate] forKey:@"date"];

    if (APP_DELEGATE.isServerReachable) {
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://fieldo.se/api/workercalenderweek.php"]];
    [urlRequest setTimeoutInterval:180];
    NSString *requestBody = [NSString stringWithFormat:@"JsonObject=%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
         NSLog(@"%@",object);
         if (error)
         {
             NSLog(@"Error: %@",[error description]);
         }
         if ([object isKindOfClass:[NSDictionary class]] == YES)
         {
             NSMutableArray *objEvents=object[@"data"];
             self.arrayEvents=objEvents;
             [self performSelectorOnMainThread:@selector(drawContentAndMainScrollView) withObject:nil waitUntilDone:YES];
         }
        }];
    }
    else
    {
        [self hideLoadingView];
        [[[UIAlertView alloc]initWithTitle:@"Fieldo" message:[Language get:@"Internet connection is not available. Please try again." alter:@"!Internet connection is not available. Please try again."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }

}

-(void)updateCalendarData
{

}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   // NSLog(@"%f ,%f",scrollView.contentOffset.x,scrollView.contentOffset.y);
}

-(void)viewDidAppear:(BOOL)animated
{
    self.navigationItem.title=[Language get:@"Calendar" alter:@"!Calendar"];
}


-(void)loadView
{
    [super loadView];
    
    CGRect rect= CGRectMake(0, 100, 320, 380);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenSize.height > 480.0f)
            rect=CGRectMake(0, 100, 320, 468);
    }
    UIView *view=[[UIView alloc] initWithFrame:rect];
    
    view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main.png"]];
    
    self.view=view;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
