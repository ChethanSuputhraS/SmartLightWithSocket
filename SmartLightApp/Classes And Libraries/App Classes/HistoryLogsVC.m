//
//  HistoryLogsVC.m
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 7/21/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import "HistoryLogsVC.h"

@interface HistoryLogsVC ()

@end

@implementation HistoryLogsVC

@synthesize dictHistoryDetails;

#pragma mark - Life Cycle
-(instancetype)init
{
    if (self) {
        self.hidesBottomBarWhenPushed=YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [APP_DELEGATE colorWithHexString:App_Background_color];
    
    arrHistory = [self getHistoryLogsBasedOnHistoryId:[dictHistoryDetails valueForKey:@"history_id"]];
    
    [self setNavigationViewFrames];
    
    [self setContentViewFrames];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInternetAvailabilityNotification:) name:kUpdateInternetAvailabilityNotification object:nil];
    
    [APP_DELEGATE isNetworkreachable];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateInternetAvailabilityNotification object:nil];
}

#pragma mark - Notifications
-(void)updateInternetAvailabilityNotification:(NSNotification*)notification
{
    NSString * strNetworkStatus = (NSString*)notification.object;
    
    if ([strNetworkStatus isEqualToString:@"1"] || [strNetworkStatus isEqualToString:@"2"])
    {
        [imgNetworkStatus setImage:[UIImage imageNamed:@"logo.png"]];
    }
    else
    {
        [imgNetworkStatus setImage:[UIImage imageNamed:@"logo_gray.png"]];
    }
}

#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[APP_DELEGATE colorWithHexString:App_Header_Color]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Logs"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]];
    [lblTitle setTextColor:[APP_DELEGATE colorWithHexString:header_font_color]];
    [viewHeader addSubview:lblTitle];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(0, 20, 50, 44)];
    [btnBack setBackgroundColor:[UIColor clearColor]];
    [btnBack setImage:[UIImage imageNamed:Icon_Back_Button] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(btnBackClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnBack];
    
    imgNetworkStatus = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-70, 32, 60, 20)];
    [imgNetworkStatus setImage:[UIImage imageNamed:@"logo_gray.png"]];
    [imgNetworkStatus setContentMode:UIViewContentModeScaleAspectFit];
    [viewHeader addSubview:imgNetworkStatus];
    
    UILabel * lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 63.5, DEVICE_WIDTH, 0.5)];
    [lblLine setBackgroundColor:[UIColor lightGrayColor]];
    [viewHeader addSubview:lblLine];
}

-(void)setContentViewFrames
{
    tblHistory = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT-64) style:UITableViewStylePlain];
    tblHistory.delegate = self;
    tblHistory.dataSource = self;
    tblHistory.backgroundColor = [UIColor clearColor];
    tblHistory.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblHistory.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:tblHistory];
    
    lblErrorMessage = [[UILabel alloc] initWithFrame:CGRectMake(50, DEVICE_HEIGHT/2-20, DEVICE_WIDTH-100, 40)];
    [lblErrorMessage setText:@"No History Found"];
    [lblErrorMessage setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
    [lblErrorMessage setTextColor:[APP_DELEGATE colorWithHexString:orange_color]];
    [lblErrorMessage setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:lblErrorMessage];
    [lblErrorMessage setHidden:YES];
}

#pragma mark - Button Clicked
-(void)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Set Activity Array
-(NSMutableArray *)getHistoryLogsBasedOnHistoryId:(NSString*)historyId
{
    NSMutableArray * arrCheckHistoryLogs = [[NSMutableArray alloc] init];
    
    NSString * queryCheckStr1 = [NSString stringWithFormat:@"SELECT * FROM HistoryLogs where log_history_id = '%@' AND user_id = '%@'",historyId,CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:queryCheckStr1 resultsArray:arrCheckHistoryLogs];
    
    return arrCheckHistoryLogs;
}

#pragma mark- UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrHistory count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryLogsDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReuseActivityCell"];
    if (cell==nil) {
        cell = [[HistoryLogsDetailsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ReuseActivityCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor whiteColor];
    
    NSString *cmpDateStr = [NSString stringWithFormat:@"%@",[[arrHistory objectAtIndex:indexPath.row] valueForKey:@"history_time"]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *cmpDate1 = [dateFormatter dateFromString:cmpDateStr];
    
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    [format setDateStyle:NSDateFormatterShortStyle];
    [format setDateFormat:@"HH:mm:ss"];
    
    NSString *dateStr = [format stringFromDate:cmpDate1];
    
    cell.lblMessage.text = [NSString stringWithFormat:@"%@ : %@",dateStr,[[arrHistory objectAtIndex:indexPath.row] valueForKey:@"history_description"]];
//    cell.lblExitTime.text = [NSString stringWithFormat:@"Exit : %@",[[arrHistory objectAtIndex:indexPath.row] valueForKey:@"exit_time"]];
    
    if (indexPath.row == [arrHistory count]-1) {
        [cell.lblLine setFrame:CGRectMake(0, 49.5, DEVICE_WIDTH, 0.5)];
    }else{
        [cell.lblLine setFrame:CGRectMake(15, 49.5, DEVICE_WIDTH-15, 0.5)];
    }
    
    //    [cell.btnMap addTarget:self action:@selector(btnMapClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (IS_IPAD) {
        return 40;
    }else{
        return 30;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView;
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 30)];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    [headerView setAlpha:0.9];
    
    UILabel *lblHeader;
    lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH-20, 30)];
    [lblHeader setFont:[UIFont systemFontOfSize:17]];
    lblHeader.backgroundColor = [UIColor clearColor];
    lblHeader.textColor = [UIColor whiteColor];
    [headerView addSubview:lblHeader];
    
    NSString *cmpDateStr = [NSString stringWithFormat:@"%@",[dictHistoryDetails valueForKey:@"date"]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *cmpDate1 = [dateFormatter dateFromString:cmpDateStr];
    
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    [format setDateStyle:NSDateFormatterShortStyle];
    [format setDateFormat:@"EEEE,dd MMMM YYYY"];
    
    NSString *dateStr = [format stringFromDate:cmpDate1];
    lblHeader.text = dateStr;
    return headerView;
}

#pragma mark Calculate Time
- (NSString *)relativeDateStringForDate:(NSDate *)date
{
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //    NSCalendarUnit units = NSDayCalendarUnit | NSWeekOfYearCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSCalendarUnit units = NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear;
    
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units fromDate:date toDate:[NSDate date] options:0];
    
    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ld years ago", (long)components.year];
    } else if (components.month > 0) {
        return [NSString stringWithFormat:@"%ld months ago", (long)components.month];
    } else if (components.weekOfYear > 0) {
        return [NSString stringWithFormat:@"%ld weeks ago", (long)components.weekOfYear];
    } else if (components.day > 0) {
        if (components.day > 1) {
            return [NSString stringWithFormat:@"%ld days ago", (long)components.day];
        } else {
            [df setDateFormat:@"h:mm a"];
            NSString * timestamp = [NSString stringWithFormat:@"Yesterday at %@",[df stringFromDate:date]];
            return timestamp;
        }
    }
    else
    {
        if (components.day<1)
        {
            double ti = [date timeIntervalSinceDate:[NSDate date]];
            
            ti = ti * -1;
            
            
            if (ti < 60) {
                return [NSString stringWithFormat:@"few Seconds ago"];
            } else if (ti < 60*60) {
                int diff = round(ti / 60);
                return [NSString stringWithFormat:@"%d minutes ago", diff];
            } else if (ti < 60*60*24) {
                int diff = round(ti / 60 / 60);
                return[NSString stringWithFormat:@"%d hours ago", diff];
            }
            else{
                return @"Just Now";
            }
        }
        else
        {
            return @"Today";
        }
    }
}

#pragma mark - CleanUp
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
