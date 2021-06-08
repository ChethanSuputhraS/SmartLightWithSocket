//
//  SocketAlarmVC.m
//  SmartLightApp
//
//  Created by Kalpesh Panchasara on 06/01/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import "SocketAlarmVC.h"
#import "SwitchesCell.h"

@interface SocketAlarmVC ()<UITableViewDelegate,UITableViewDataSource>
{
    
}
@end

@implementation SocketAlarmVC

@synthesize intSelectedSwitch,periphPass,intswitchState,strTAg,strMacaddress,delegate, dictDeviceDetail;
- (void)viewDidLoad
{
    isViewDisapeared = NO;
    isAlarmRequested = NO;
    globalStatusHeight = 20;
    int yy = 40;
    
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSizes = 14;
    }
    
    if (IS_IPHONE_X)
    {
        globalStatusHeight = 44;
        
    }

    self.navigationController.navigationBarHidden = true;
    
    scrllView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy)];
    scrllView.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT);
    scrllView.backgroundColor = UIColor.clearColor;
    [scrllView setScrollEnabled:true];
//    [self.view addSubview:scrllView];
    
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.contentMode = UIViewContentModeScaleAspectFit;
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];

    [self setNavigationViewFrames];

    UIImageView * imgBackA = [[UIImageView alloc]initWithFrame:CGRectMake(10,globalStatusHeight+11, 14, 22)];
    imgBackA.image = [UIImage imageNamed:@"arrow.png"];
    imgBackA.backgroundColor = UIColor.clearColor;
    [self.view addSubview:imgBackA];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(0, 0, 80, 44+globalStatusHeight)];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];
    
    dictSw = [[NSMutableDictionary alloc] init];
    
    dayArr = [[NSMutableArray alloc] init];
    
    arrDayselect = [[NSMutableArray alloc] init];
    
    NSArray * dateArr = [NSArray arrayWithObjects:@"S",@"M",@"T",@"W",@"T",@"F",@"S", nil];
    NSArray * weekArr = [NSArray arrayWithObjects:@"SUN",@"MON",@"TUE",@"WED",@"THU",@"FRI",@"SAT", nil];

    NSArray * countsArr = [NSArray arrayWithObjects:@"64",@"32",@"16",@"8",@"4",@"2",@"1", nil];//,,,
    
    for (int i=0; i<[dateArr count]; i++)
    {
        NSMutableDictionary * dayDict = [[NSMutableDictionary alloc] init];
        NSString * strDay = [dateArr objectAtIndex:i];
        [dayDict setObject:strDay forKey:@"day"];
        [dayDict setObject:@"0" forKey:@"isOff"]; // 1
        [dayDict setObject:[countsArr objectAtIndex:i] forKey:@"counts"];
        [dayDict setObject:[weekArr objectAtIndex:i] forKey:@"dayname"];

        [dayArr addObject:dayDict]; //  [dayArr addObject:dayDict];
    }
    
    arrTitle = [[NSMutableArray alloc] init];
    arrAlarmDetail = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 2; i++)
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[NSString stringWithFormat:@"Alarm %d",i+1] forKey:@"name"];
        NSMutableArray * arrAlarm = [[NSMutableArray alloc] init];

        if (i == 0)
        {
            NSInteger alarmId = (intSelectedSwitch * 2) - 1;
            strAlramID1 = [NSString stringWithFormat:@"select * from Socket_Alarm_Table where ble_address = '%@' and alarm_id = '%ld' and alarm_state = '01'",strMacaddress,(long)alarmId];
            [[DataBaseManager dataBaseManager] execute:strAlramID1 resultsArray:arrAlarm];
            
            NSString * strONtime = @"NA";
            NSString * strOFFtime = @"NA";

            [dict setValue:@"NA" forKey:@"OnTimestamp"];
            [dict setValue:@"NA" forKey:@"OffTimestamp"];
            
            [dict setValue:@"0" forKey:@"isExpanded"];
            
            if ([arrAlarm count] > 0)
            {
                strONtime = [[arrAlarm objectAtIndex:0] valueForKey:@"On_original"];
                strOFFtime = [[arrAlarm objectAtIndex:0] valueForKey:@"Off_original"];
                
                [dict setValue:[[arrAlarm objectAtIndex:0] valueForKey:@"OnTimestamp"] forKey:@"OnTimestamp"];
                [dict setValue:[[arrAlarm objectAtIndex:0] valueForKey:@"OffTimestamp"] forKey:@"OffTimestamp"];
                
                if ([[[arrAlarm  objectAtIndex:0] valueForKey:@"day_selected"] isEqualToString:@"0,0,0,0,0,0,0"])
                {
                    [dict setValue:@"0" forKey:@"isExpanded"];
                }
                else
                {
                    [dict setValue:@"1" forKey:@"isExpanded"];
                }
                
                if ([[[arrAlarm  objectAtIndex:0] valueForKey:@"day_selected"] isEqualToString:@"0,0,0,0,0,0,0"])
                {
                    NSInteger savedOnTime = [[[arrAlarm objectAtIndex:0] valueForKey:@"OnTimestamp"] integerValue];
                    NSInteger savedOffTime = [[[arrAlarm objectAtIndex:0] valueForKey:@"OffTimestamp"] integerValue];
                    NSInteger currentTime = [[NSDate date] timeIntervalSince1970];
                    NSLog(@"ONTIME =%ld  OFFTIME=%ld   Current=%ld",(long)savedOnTime,(long)savedOffTime,(long)currentTime);
                    if (currentTime > savedOnTime && currentTime > savedOffTime)
                    {
                        NSString * strQuery = [NSString stringWithFormat:@"delete from Socket_Alarm_Table where ble_address = '%@' and alarm_id = '%ld'",strMacaddress,alarmId];
                        [[DataBaseManager dataBaseManager] execute:strQuery];
                        [dict setValue:@"NA" forKey:@"OnTimestamp"];
                        [dict setValue:@"NA" forKey:@"OffTimestamp"];
                        [dict setValue:@"NA" forKey:@"On_original"];
                        [dict setValue:@"NA" forKey:@"Off_original"];
                        strONtime = @"NA";
                        strOFFtime = @"NA";
                    }
                }
            }
           
            [dict setValue:strONtime forKey:@"On_original"];
            [dict setValue:strOFFtime forKey:@"Off_original"];
        }
        else
        {
            NSInteger alarmId = (intSelectedSwitch * 2) ;
            strAlramID2 = [NSString stringWithFormat:@"select * from Socket_Alarm_Table where ble_address = '%@' and alarm_id = '%ld' and alarm_state = '01'",strMacaddress,(long)alarmId];
            [[DataBaseManager dataBaseManager] execute:strAlramID2 resultsArray:arrAlarm];
            
            NSString * strONtime = @"NA";
            NSString * strOFFtime = @"NA";

            [dict setValue:@"NA" forKey:@"OnTimestamp"];
            [dict setValue:@"NA" forKey:@"OffTimestamp"];

            [dict setValue:@"0" forKey:@"isExpanded"];

            if ([arrAlarm count] > 0)
            {
                strONtime = [[arrAlarm objectAtIndex:0] valueForKey:@"On_original"];
                strOFFtime = [[arrAlarm objectAtIndex:0] valueForKey:@"Off_original"];
                
                [dict setValue:[[arrAlarm objectAtIndex:0] valueForKey:@"OnTimestamp"] forKey:@"OnTimestamp"];
                [dict setValue:[[arrAlarm objectAtIndex:0] valueForKey:@"OffTimestamp"] forKey:@"OffTimestamp"];
                
                if ([[[arrAlarm  objectAtIndex:0] valueForKey:@"day_selected"] isEqualToString:@"0,0,0,0,0,0,0"])
                {
                    [dict setValue:@"0" forKey:@"isExpanded"];

                }
                else
                {
                    [dict setValue:@"1" forKey:@"isExpanded"];
                }
                if ([[[arrAlarm  objectAtIndex:0] valueForKey:@"day_selected"] isEqualToString:@"0,0,0,0,0,0,0"])
                {
                    NSInteger savedOnTime = [[[arrAlarm objectAtIndex:0] valueForKey:@"OnTimestamp"] integerValue];
                    NSInteger savedOffTime = [[[arrAlarm objectAtIndex:0] valueForKey:@"OffTimestamp"] integerValue];
                    NSInteger currentTime = [[NSDate date] timeIntervalSince1970];
                    NSLog(@"ONTIME =%ld  OFFTIME=%ld   Current=%ld",(long)savedOnTime,(long)savedOffTime,(long)currentTime);
                    if (currentTime > savedOnTime && currentTime > savedOffTime)
                    {
                        NSString * strQuery = [NSString stringWithFormat:@"delete from Socket_Alarm_Table where ble_address = '%@' and alarm_id = '%ld'",strMacaddress,alarmId];
                        [[DataBaseManager dataBaseManager] execute:strQuery];
                        [dict setValue:@"NA" forKey:@"OnTimestamp"];
                        [dict setValue:@"NA" forKey:@"OffTimestamp"];
                        [dict setValue:@"NA" forKey:@"On_original"];
                        [dict setValue:@"NA" forKey:@"Off_original"];
                        strONtime = @"NA";
                        strOFFtime = @"NA";
                    }
                }
            }
            [dict setValue:strONtime forKey:@"On_original"];
            [dict setValue:strOFFtime forKey:@"Off_original"];
        }
        
        NSString * strDayStatus = @"NA";
        NSArray * arrDayStatus = [[NSArray alloc] init];
        if ([arrAlarm count] > 0)
        {
            strDayStatus = [[arrAlarm objectAtIndex:0] valueForKey:@"day_selected"];
            if (![strDayStatus isEqualToString:@"NA"])
            {
                arrDayStatus = [strDayStatus componentsSeparatedByString:@","];
            }
        }
        for (int j =0; j < 7; j ++)
        {
            if (i == 0)
            {
                NSInteger alarmId = (intSelectedSwitch * 2) - 1;
                [dict setObject:[NSString stringWithFormat:@"%ld",(long)alarmId] forKey:@"alarm_id"];
                [dict setObject:@"0" forKey:[NSString stringWithFormat:@"%d",200 + j]];
                
                if ([arrDayStatus count] >j)
                {
                    [dict setObject:[NSString stringWithFormat:@"%@",[arrDayStatus objectAtIndex:j]] forKey:[NSString stringWithFormat:@"%d",200 + j]];
                }
            }
            else
            {
                NSInteger alarmId = (intSelectedSwitch * 2);
                [dict setObject:[NSString stringWithFormat:@"%ld",(long)alarmId] forKey:@"alarm_id"];
                [dict setObject:@"0" forKey:[NSString stringWithFormat:@"%d",300 + j]];
                if ([arrDayStatus count] >j)
                {
                    [dict setObject:[NSString stringWithFormat:@"%@",[arrDayStatus objectAtIndex:j]] forKey:[NSString stringWithFormat:@"%d",300 + j]];
                }
            }
        }
        
        [dict setValue:@"1" forKey:@"isActive"];
        [arrTitle addObject:dict];
    }
    
//    [arrTitle setValue:@"0" forKey:@"isExpanded"];
    
    NSLog(@"All Alarams===>>>>%@",arrAlarmDetail);
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
//    self.view.backgroundColor = UIColor.cyanColor; //[UIColor colorWithRed:19/255.0 green:24/255.0 blue:27/255.0 alpha:1.0];
    
    int yy = 44;
    if (IS_IPHONE_X)
    {
        yy = 44;
    }
    
    headerhHeight = 64;
    if (IS_IPHONE_X)
    {
        headerhHeight = 88;
    }
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy + globalStatusHeight)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy+globalStatusHeight)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.5;
    [viewHeader addSubview:lblBack];
    
    UILabel * lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, yy + globalStatusHeight-1, DEVICE_WIDTH,1)];
    [lblLine setBackgroundColor:[UIColor lightGrayColor]];
//    [viewHeader addSubview:lblLine];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, globalStatusHeight, DEVICE_WIDTH-100, yy)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:[NSString stringWithFormat:@"Set Alarm for Socket %ld",(long)intSelectedSwitch]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+3]];

    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 80, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];
    
 
    tblAlarms = [[UITableView alloc]initWithFrame:CGRectMake(0, yy+globalStatusHeight, DEVICE_WIDTH, DEVICE_HEIGHT-yy+globalStatusHeight)];
    tblAlarms.backgroundColor = UIColor.clearColor;
    tblAlarms.delegate = self;
    tblAlarms.dataSource = self;
    tblAlarms.separatorColor = UIColor.clearColor;
    tblAlarms.scrollEnabled = false;
    [self.view addSubview:tblAlarms];
    
    if (IS_IPHONE_X)
    {
        yy = 64;
        tblAlarms.frame = CGRectMake(0, yy+globalStatusHeight, DEVICE_WIDTH, DEVICE_HEIGHT-yy+globalStatusHeight);
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 88, 88);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
    }
}
-(void)btnTimerSelect:(NSInteger)Tag
{
    [timeBackView removeFromSuperview];
    timeBackView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 250)];
    [timeBackView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:timeBackView];
    
    [datePicker removeFromSuperview];
    datePicker = nil;
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 45, timeBackView.frame.size.width-40, timeBackView.frame.size.height)];
//    [datePicker setBackgroundColor:[UIColor whiteColor]];
    datePicker.tag = Tag;
    datePicker.timeZone = [NSTimeZone localTimeZone];
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
//    datePicker.date = [NSDate date];
     datePicker.backgroundColor = UIColor.whiteColor;
     datePicker.minimumDate = [NSDate date];
    

    if (Tag >= 800)//2nd index
    {
        if ([[[arrTitle objectAtIndex:1] valueForKey:@"isExpanded"] isEqualToString:@"1"])
        {
            datePicker.datePickerMode = UIDatePickerModeTime;
            datePicker.minimumDate = nil;
        }
    }
    else
    {
        if ([[[arrTitle objectAtIndex:0] valueForKey:@"isExpanded"] isEqualToString:@"1"])
        {
            datePicker.datePickerMode = UIDatePickerModeTime;
            datePicker.minimumDate = nil;
        }
    }
    
    if (@available(iOS 13.4, *)) {
        datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    } else {
        // Fallback on earlier versions
    }if (@available(iOS 13.4, *)) {
        datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    } else {
        // Fallback on earlier versions
    }
    [timeBackView addSubview:datePicker];
    
    UIButton * btnDone2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone2 setFrame:CGRectMake(DEVICE_WIDTH/2+0.5 , 0, DEVICE_WIDTH/2-0.5, 44)];
    [btnDone2 setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDone2 setTag:Tag];
    btnDone2.backgroundColor = UIColor.blackColor;
    btnDone2.alpha = 0.6;
    btnDone2.titleLabel.font = [UIFont fontWithName:CGBold size:textSizes+2];
    [btnDone2 addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    [timeBackView addSubview:btnDone2];
    
    UIButton * btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setFrame:CGRectMake(0 , 0, DEVICE_WIDTH/2-0.5, 44)];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCancel setTag:Tag];
    btnCancel.backgroundColor = UIColor.blackColor;
    btnCancel.alpha = 0.6;
    btnCancel.titleLabel.font = [UIFont fontWithName:CGBold size:textSizes+2];
    [btnCancel addTarget:self action:@selector(btnCancelClicked) forControlEvents:UIControlEventTouchUpInside];
    [timeBackView addSubview:btnCancel];
    
    [self ShowPicker:YES andView:timeBackView];

}
-(void)btnBackClick
{
    isAlarmRequested = NO;

    isViewDisapeared = YES;
    
    NSInteger intPacket = [@"0" integerValue];
    NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
    [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"04" withLength:@"01" withPeripheral:periphPass];

    [self.navigationController popViewControllerAnimated:true];
}
#pragma mark - Animations
-(void)ShowPicker:(BOOL)isShow andView:(UIView *)myView
{
    int viewHeight = 250;
    if (IS_IPHONE_4)
    {
        viewHeight = 230;
    }
    if (isShow == YES)
    {
        [UIView transitionWithView:myView duration:0.4
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            [myView setFrame:CGRectMake(0, DEVICE_HEIGHT-viewHeight,DEVICE_WIDTH, viewHeight)];
        }
                        completion:^(BOOL finished)
         {
         }];
    }
    else
    {
        [UIView transitionWithView:myView duration:0.4
                           options:UIViewAnimationOptionTransitionNone
                        animations:^{
            [myView setFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, viewHeight)];
        }
                        completion:^(BOOL finished)
        {
         }];
    }
}

-(void)setPowerView:(int)yValue
{
    yValue = yValue+10;
    
    UILabel * lblOffBack = [[UILabel alloc] init];
    lblOffBack.backgroundColor = [UIColor blackColor];
    lblOffBack.alpha = 0.5;
    lblOffBack.frame =CGRectMake(0, yValue+150, DEVICE_WIDTH, 50);
    [self.view addSubview:lblOffBack];
    
    UILabel * lblInfo = [[UILabel alloc] init];
    lblInfo.frame = CGRectMake(10, yValue+150, DEVICE_WIDTH, 50);
    lblInfo.text = @"Power State";
    lblInfo.font = [UIFont fontWithName:CGRegular size:textSizes];
    lblInfo.textColor = [UIColor whiteColor];
    [self.view addSubview:lblInfo];
    
    btnON = [UIButton buttonWithType:UIButtonTypeCustom];
    btnON.frame = CGRectMake(DEVICE_WIDTH/2, yValue+150, 70, 50);
    btnON.backgroundColor = [UIColor clearColor];
    [btnON setTitle:@" ON" forState:UIControlStateNormal];
    [btnON setImage:[UIImage imageNamed:@"RadioON.png"] forState:UIControlStateNormal];
    btnON.tag = 121;
    btnON.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes];
    [btnON addTarget:self action:@selector(btnOnOffClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnON];
    
    btnOFF = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOFF.frame = CGRectMake((DEVICE_WIDTH/2) + 80, yValue+150, 70, 50);
    btnOFF.backgroundColor = [UIColor clearColor];
    [btnOFF setTitle:@" OFF" forState:UIControlStateNormal];
    btnOFF.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes];
    [btnOFF setImage:[UIImage imageNamed:@"RadioOff.png"] forState:UIControlStateNormal];
    btnOFF.tag = 122;
    [btnOFF addTarget:self action:@selector(btnOnOffClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnOFF];
    
}
-(void)setButtonContent:(UIButton *)btn withTag:(long)btnTag withBtnIndex:(int)btnIndex
{
    btn.layer.masksToBounds = YES;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.layer.borderWidth = 1.0;
    [btn addTarget:self action:@selector(btnDayClick:) forControlEvents:UIControlEventTouchUpInside];
    
    int correctValue = 200;
    if (btnTag == 0)
    {
        btn.tag = btnIndex + 200;
    }
    else
    {
        correctValue = 300;
        btn.tag = btnIndex + 300;
    }
//    int wh = (DEVICE_WIDTH/7)-10;
//    btn.frame = CGRectMake(5, 5, wh, wh);
//    btn.layer.cornerRadius = wh/2;
    btn.backgroundColor = [UIColor whiteColor];
    btn.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes-2];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    NSMutableDictionary * dict = [arrTitle objectAtIndex:btnTag];
    NSString * strStatus = [dict valueForKey:[NSString stringWithFormat:@"%d",correctValue + btnIndex]];
    
    if ([strStatus isEqualToString:@"1"])
    {
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else
    {
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}
-(void)btnDayClick:(id)sender
{
    NSInteger btnTag = [sender tag];
    int correctValue = 0;
    int arrIndx = 0;
    
    if (btnTag - 300 >= 0)
    {
        arrIndx = 1;
        correctValue = 300;
    }
    else if(btnTag - 200 >= 0)
    {
        correctValue = 200;
    }
    
    NSMutableDictionary * dict = [arrTitle objectAtIndex:arrIndx];
    NSString * strStatus = [dict valueForKey:[NSString stringWithFormat:@"%ld",(long)btnTag]];
    
    UIColor * backColor, * txtColor;
    if ([strStatus isEqualToString:@"0"])
    {
        backColor = [UIColor whiteColor];
        txtColor = [UIColor blackColor];
//        [[dayArr objectAtIndex:[sender tag]] setObject:@"1" forKey:@"isOff"];
        [dict setValue:@"1" forKey:[NSString stringWithFormat:@"%ld",(long)btnTag]];

    }
    else
    {
        backColor = [UIColor clearColor];
        txtColor = [UIColor whiteColor];
//        [[dayArr objectAtIndex:[sender tag]] setObject:@"0" forKey:@"isOff"];
        [dict setValue:@"0" forKey:[NSString stringWithFormat:@"%ld",(long)btnTag]];
    }
    [arrTitle replaceObjectAtIndex:arrIndx withObject:dict];

    [tblAlarms reloadData];
}
-(void)btnOnOffClick:(id)sender
{
    if ([sender tag]==121)
    {
        [btnON setImage:[UIImage imageNamed:@"RadioON.png"] forState:UIControlStateNormal];
        [btnOFF setImage:[UIImage imageNamed:@"RadioOff.png"] forState:UIControlStateNormal];
        isOnPower = YES;
    }
    else if ([sender tag]==122)
    {
        isOnPower = NO;
        [btnON setImage:[UIImage imageNamed:@"RadioOff.png"] forState:UIControlStateNormal];
        [btnOFF setImage:[UIImage imageNamed:@"RadioON.png"] forState:UIControlStateNormal];
    }
}
-(NSString*)hexFromStr:(NSString*)str
{
    NSData* nsData = [str dataUsingEncoding:NSUTF8StringEncoding];
    const char* data = [nsData bytes];
    NSUInteger len = nsData.length;
    NSMutableString* hex = [NSMutableString string];
    for(int i = 0; i < len; ++i)
        [hex appendFormat:@"%02X", data[i]];
    return hex;
}
- (NSData *)dataFromHexString:(NSString*)hexStr
{
    const char *chars = [hexStr UTF8String];
    NSInteger i = 0, len = hexStr.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len)
    {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}
-(NSString*)stringFroHex:(NSString *)hexStr
{
    unsigned long long startlong;
    NSScanner* scanner1 = [NSScanner scannerWithString:hexStr];
    [scanner1 scanHexLongLong:&startlong];
    double unixStart = startlong;
    NSNumber * startNumber = [[NSNumber alloc] initWithDouble:unixStart];
    return [startNumber stringValue];
}
-(void)AlertViewFCTypeSuccess:(NSString *)strPopup
{
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeSuccess];
        [alert showAlertInView:self
                     withTitle:@"Vithamas"
                  withSubtitle:strPopup
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
}
#pragma mark- UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrTitle count]; // array have to pass
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[arrTitle objectAtIndex:indexPath.row] valueForKey:@"isExpanded"] isEqualToString:@"1"])
    {
        return 290;
    }
    else
    {
        return  220;
    }
    return 290;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
        SwitchesCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
        if (cell == nil)
        {
            cell = [[SwitchesCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
        }
    
    [self setButtonContent:cell.btn0 withTag:indexPath.row withBtnIndex:0];
    [self setButtonContent:cell.btn1 withTag:indexPath.row withBtnIndex:1];
    [self setButtonContent:cell.btn2 withTag:indexPath.row withBtnIndex:2];
    [self setButtonContent:cell.btn3 withTag:indexPath.row withBtnIndex:3];
    [self setButtonContent:cell.btn4 withTag:indexPath.row withBtnIndex:4];
    [self setButtonContent:cell.btn5 withTag:indexPath.row withBtnIndex:5];
    [self setButtonContent:cell.btn6 withTag:indexPath.row withBtnIndex:6];
    cell.btnRepeate.tag = indexPath.row;
    
    int yy = 130;
    NSMutableAttributedString * attrStringOnOriginal ; //On_original
    NSMutableAttributedString * stringOffOriginal ;// Off_original

    
    cell.lblONtime.text = @"NA";
    cell.lblOFFtime.text = @"NA" ;

    if ([[[arrTitle objectAtIndex:indexPath.row] valueForKey:@"isExpanded"] isEqualToString:@"1"])
    {
        yy = yy +10;
        
        cell.imgCheck.image = [UIImage imageNamed:@"checked.png"];
        cell.dayView.hidden = false;
        cell.lbldays.hidden = false;
        cell.lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 280);
        cell.lblLineParall.frame = CGRectMake(DEVICE_WIDTH/2, yy+20,.8,60);

        cell.lblON.frame = CGRectMake(0, yy,DEVICE_WIDTH/2,30);
        cell.lblOFF.frame = CGRectMake(DEVICE_WIDTH/2, yy,DEVICE_WIDTH/2,30);
        cell.lblONtime.frame = CGRectMake(0, yy+20,DEVICE_WIDTH/2,60);
        cell.lblOFFtime.frame = CGRectMake(DEVICE_WIDTH/2, yy+20,DEVICE_WIDTH/2,60);
        cell.btnONTimer.frame = CGRectMake(0, yy+20,DEVICE_WIDTH/2,60);
        cell.btnOFFTimer.frame = CGRectMake(DEVICE_WIDTH/2, yy+20,DEVICE_WIDTH/2,60);
        cell.btnSave.frame = CGRectMake(10, yy+90,DEVICE_WIDTH-20,44);
        
        cell.lblONtime.numberOfLines = 2;
        cell.lblOFFtime.numberOfLines = 2;

        [cell.lblONtime setFont:[UIFont fontWithName:CGRegular size:textSizes+15]];
        [cell.lblOFFtime setFont:[UIFont fontWithName:CGRegular size:textSizes+15]];
        
        cell.lblONtime.text = [[arrTitle objectAtIndex:indexPath.row] valueForKey:@"On_original"];
        cell.lblOFFtime.text = [[arrTitle objectAtIndex:indexPath.row] valueForKey:@"Off_original"];


    }
    else
    {
        yy = yy +30;
        
        cell.imgCheck.image = [UIImage imageNamed:@"checkEmpty.png"];
        cell.dayView.hidden = true;
        cell.lbldays.hidden = true;
        cell.lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 215);

        cell.lblLineParall.frame = CGRectMake(DEVICE_WIDTH/2, 100,.8,60);
        cell.lblON.frame = CGRectMake(0, 55,DEVICE_WIDTH/2,30);
        cell.lblOFF.frame = CGRectMake(DEVICE_WIDTH/2, 55,DEVICE_WIDTH/2,30);
        
        cell.lblONtime.frame = CGRectMake(10, 90,(DEVICE_WIDTH/2) - 20,70);
        cell.lblOFFtime.frame = CGRectMake((DEVICE_WIDTH/2) + 10, 90,(DEVICE_WIDTH/2) - 20,70);
        
        cell.btnONTimer.frame = CGRectMake(0, 80,DEVICE_WIDTH/2,70);
        cell.btnOFFTimer.frame = CGRectMake(DEVICE_WIDTH/2, 80,DEVICE_WIDTH/2,70);
        
        cell.btnSave.frame = CGRectMake(10, 170,DEVICE_WIDTH-20,44);
        
        cell.lblONtime.numberOfLines = 0;
        cell.lblOFFtime.numberOfLines = 0;

        [cell.lblONtime setFont:[UIFont fontWithName:CGRegular size:textSizes + 15]];
        [cell.lblOFFtime setFont:[UIFont fontWithName:CGRegular size:textSizes + 15]];
        
        
        if (![[self checkforValidString:[[arrTitle objectAtIndex:indexPath.row] valueForKey:@"On_original"]] isEqual:@"NA"])
        {
            attrStringOnOriginal = [[NSMutableAttributedString alloc] initWithString:[[arrTitle objectAtIndex:indexPath.row] valueForKey:@"On_original"]];
            [attrStringOnOriginal addAttribute:NSFontAttributeName value:[UIFont fontWithName:CGRegular size:textSizes] range:NSMakeRange(0, attrStringOnOriginal.length)];
            [attrStringOnOriginal addAttribute:NSFontAttributeName value:[UIFont fontWithName:CGRegular size:textSizes+20] range:NSMakeRange(attrStringOnOriginal.length-8, 8)];
        }

        
        if (![[self checkforValidString:[[arrTitle objectAtIndex:indexPath.row] valueForKey:@"Off_original"]] isEqual:@"NA"])
        {
            stringOffOriginal = [[NSMutableAttributedString alloc] initWithString:[[arrTitle objectAtIndex:indexPath.row] valueForKey:@"Off_original"]];
            [stringOffOriginal addAttribute:NSFontAttributeName value:[UIFont fontWithName:CGRegular size:textSizes] range:NSMakeRange(0, stringOffOriginal.length)];
            [stringOffOriginal addAttribute:NSFontAttributeName value:[UIFont fontWithName:CGRegular size:textSizes+20] range:NSMakeRange(stringOffOriginal.length-8, 8)];
        }
        if (attrStringOnOriginal != nil)
        {
            cell.lblONtime.attributedText = attrStringOnOriginal;
        }
    
    if (stringOffOriginal != nil)
    {
        cell.lblOFFtime.attributedText = stringOffOriginal;
    }

    }
     isRepeate = NO;
    
    cell.btnTime.tag = indexPath.row+100;
    cell.btnon.tag = indexPath.row+500;
    cell.btnoff.tag = indexPath.row+600;
    cell.btnDelete.tag = indexPath.row+200;
    cell.btnTime.tag = indexPath.row+100;
    cell.btnSave.tag = indexPath.row+200;

    [cell.btnDelete addTarget:self action:@selector(btnDeleteClick:) forControlEvents:UIControlEventTouchUpInside];//btndeleteClick
    [cell.btnONTimer addTarget:self action:@selector(btnONTimerClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnOFFTimer addTarget:self action:@selector(btnOFFTimerClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnRepeate addTarget:self action:@selector(btnRepeateClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnSave addTarget:self action:@selector(btnSaveClick:) forControlEvents:UIControlEventTouchUpInside];



    if (indexPath.row == 0)
    {
        cell.btnONTimer.tag = 700;
        cell.btnOFFTimer.tag = 701; //700
        cell.lblAlarms.text = @"Alarm 1";
    }
    else if (indexPath.row == 1)
    {
        cell.btnONTimer.tag = 800;
        cell.btnOFFTimer.tag = 801; // 800
        cell.lblAlarms.text = @"Alarm 2";
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)btnDaysAction:(id)sender
{
    
}
-(void)SetupforDayView
{
    viewForBG = [[UIView alloc]init];
    viewForBG.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    viewForBG.backgroundColor = [UIColor colorWithRed:0 green:(CGFloat)0 blue:0 alpha:0.8];
    [self.view addSubview:viewForBG];
    
    viewForDay = [[UIView alloc] init];
    viewForDay.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 130);
    viewForDay.backgroundColor = UIColor.clearColor;
    [self.view addSubview:viewForDay];
    
    UIButton * btnDayDone = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, DEVICE_WIDTH-10, 50)];
    btnDayDone.backgroundColor = UIColor.whiteColor;
//    btnDayDone.alpha = 0.5;
    [btnDayDone setTitle:@"Done" forState:UIControlStateNormal];
    [btnDayDone addTarget:self action:@selector(btnDayDoneClick:) forControlEvents:UIControlEventTouchUpInside];
    btnDayDone.layer.borderColor = UIColor.whiteColor.CGColor;
    btnDayDone.layer.borderWidth = 0.5;
    btnDayDone.layer.cornerRadius = 6;
    [btnDayDone setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
//    [viewForDay addSubview:btnDayDone];
    
    UIView * dayView = [[UIView alloc] init];
    dayView.frame = CGRectMake(0, 50, DEVICE_WIDTH, 70);
    [viewForDay addSubview:dayView];

    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        self->viewForDay.frame = CGRectMake(0, (DEVICE_HEIGHT-130)/2, DEVICE_WIDTH, 130);
    }
        completion:NULL];
}
- (void)dateChanged:(UIButton *)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    BOOL isExpanded = NO;
    if (sender.tag >= 800)
    {
        if ([[[arrTitle objectAtIndex:1] valueForKey:@"isExpanded"] isEqualToString:@"1"])
        {
            isExpanded = YES;
        }
    }
    else
    {
        if ([[[arrTitle objectAtIndex:0] valueForKey:@"isExpanded"] isEqualToString:@"1"])
        {
            isExpanded = YES;
        }
    }
    if (isExpanded == NO)
    {
        [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm aa"];
    }
    else
    {
        [dateFormatter setDateFormat:@"hh:mm aa"];
    }
    
    NSString *currentTime = [dateFormatter stringFromDate:datePicker.date];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    lblTime.text = currentTime;

    strTimeSelected = currentTime;

    [tblAlarms reloadData];
}
#pragma mark - Button Events
-(void)btnDoneClicked:(UIButton *)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
 
    BOOL isExpanded = NO;
    if (sender.tag >= 800)
    {
        if ([[[arrTitle objectAtIndex:1] valueForKey:@"isExpanded"] isEqualToString:@"1"])
        {
            isExpanded = YES;
        }
    }
    else
    {
        if ([[[arrTitle objectAtIndex:0] valueForKey:@"isExpanded"] isEqualToString:@"1"])
        {
            isExpanded = YES;
        }
    }
    if (isExpanded == NO)
    {
        [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm aa"];
    }
    else
    {
        [dateFormatter setDateFormat:@"hh:mm aa"];
    }
    
    NSDate * datetime = datePicker.date;
    NSTimeInterval  timeinterval = floor(datetime.timeIntervalSinceReferenceDate / 60) * 60;
    datetime = [NSDate dateWithTimeIntervalSinceReferenceDate:timeinterval];

    NSString *currentTime = [dateFormatter stringFromDate:datetime];
    
    NSTimeInterval timeStamp = [datetime timeIntervalSince1970];
    NSString *decStr = @"NA";
    decStr = [NSString stringWithFormat:@"%f",timeStamp];

    if (sender.tag == 700)
    {
        [[arrTitle objectAtIndex:0] setObject:decStr forKey:@"OnTimestamp"];
        [[arrTitle objectAtIndex:0] setObject:currentTime forKey:@"On_original"];
    }
   else if (sender.tag == 701)
   {
       [[arrTitle objectAtIndex:0] setObject:decStr forKey:@"OffTimestamp"];
       [[arrTitle objectAtIndex:0] setObject:currentTime forKey:@"Off_original"];
   }
   else if (sender.tag == 800)
   {
       [[arrTitle objectAtIndex:1] setObject:decStr forKey:@"OnTimestamp"];
       [[arrTitle objectAtIndex:1] setObject:currentTime forKey:@"On_original"];
   }
   else if (sender.tag == 801)
   {
       [[arrTitle objectAtIndex:1] setObject:decStr forKey:@"OffTimestamp"];
       [[arrTitle objectAtIndex:1] setObject:currentTime forKey:@"Off_original"];
   }
    else
    {
        strTimeSelected = currentTime;
    }
    
    [tblAlarms reloadData];
   
    [self ShowPicker:NO andView:timeBackView];
}
-(void)btnCancelClicked
{
    [self ShowPicker:NO andView:timeBackView];
}
-(void)btnDayDoneClick:(UIButton *)sender
{
     [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
        {
            self-> viewForDay.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 130);
        }
                     completion:(^(BOOL finished)
    {
         [self-> viewForBG removeFromSuperview];
     })];
}
-(void)btnONTimerClick:(UIButton *)sender
{
    [self btnTimerSelect:sender.tag];
}
-(void)btnOFFTimerClick:(UIButton *)sender
{
    if (sender.tag >= 700)
    {
        [self btnTimerSelect:sender.tag];
    }
    else
    {
        [self btnTimerSelect:sender.tag];
    }
}
-(void)btnDeleteClick:(UIButton *)sender
{
        int isSourcetoConnectAvailable = 0;
    
        if (periphPass != nil || periphPass.state == CBPeripheralStateConnected)
        {
            isSourcetoConnectAvailable = 1;
        }
        else if([[dictDeviceDetail valueForKey:@"wifi_configured"] isEqualToString:@"1"])
        {
            isSourcetoConnectAvailable = 2;
        }
         if( isSourcetoConnectAvailable == 2 && [APP_DELEGATE isNetworkreachable] == NO)
        {
            isSourcetoConnectAvailable = 0;
        }
        if (isSourcetoConnectAvailable == 0)
        {
            [self AlertViewFCTypeCautionCheck:@"Please connect device with Bluetooth or Configure device with WIFI to set alarm."];
        }
        else
        {
            NSInteger tagValue = [sender tag] - 200;
            isDeletedManually = YES;
            [self DeleteAlarmWithIndex:tagValue];
        }
}
-(void)DeleteAlarmWithIndex:(NSInteger)sender
{
    NSInteger tagValue = sender;

    if ([arrTitle count] > tagValue)
    {
        NSString *  strAlD =[[arrTitle objectAtIndex:tagValue] valueForKey:@"alarm_id"];
        NSMutableArray * tmpArry = [[NSMutableArray alloc]init];
        NSString * strQuery = [NSString stringWithFormat:@"select * from Socket_Alarm_Table where ble_address = '%@' and alarm_id = '%@' and alarm_state = '01'",strMacaddress,strAlD];
        [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:tmpArry];
        
        if ([tmpArry count] > 0)
        {
            [APP_DELEGATE startHudProcess:@"Deleting Alarm..."];
            NSString * strAlID = [[arrTitle objectAtIndex:tagValue] valueForKey:@"alarm_id"];
            NSInteger intPacket = [strAlID integerValue];
            NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
            
            deleteRandomNumber = [self getRandomNumberBetween:1 to:255];
            NSInteger random2 = 0;
            NSData * dataRandomNumber1  = [[NSData alloc] initWithBytes:&deleteRandomNumber length:1];
            NSData * dataRandomNumber2  = [[NSData alloc] initWithBytes:&random2 length:1];

            NSMutableData *completeData = [dataPacket mutableCopy];
            [completeData appendData:dataRandomNumber1];
            [completeData appendData:dataRandomNumber2];

            selectedAlarmIndex = tagValue;

            if (periphPass.state == CBPeripheralStateDisconnected || periphPass == nil)
            {
                [self DeleteAlaramViaMQTT:selectedAlarmIndex];
            }
            else
            {
                [[BLEService sharedInstance] WriteSocketData:completeData withOpcode:@"12" withLength:@"03" withPeripheral:periphPass];
            }
        }
        else
        {
            if (isDeletedManually == YES)
            {
                [self AlertViewFCTypeCautionCheck:@"No alarm set."];
            }
        }
    }
}
-(void)btnSaveClick:(id)sender
{
       NSInteger tagValue = [sender tag] - 200;
       int isSourcetoConnectAvailable = 0;
   
       if (periphPass != nil || periphPass.state == CBPeripheralStateConnected)
       {
           isSourcetoConnectAvailable = 1;
       }
       else if([[dictDeviceDetail valueForKey:@"wifi_configured"] isEqualToString:@"1"])
       {
           isSourcetoConnectAvailable = 2;
       }
        if( isSourcetoConnectAvailable == 2 && [APP_DELEGATE isNetworkreachable] == NO)
       {
           isSourcetoConnectAvailable = 0;
       }
       if (isSourcetoConnectAvailable == 0)
       {
           [self AlertViewFCTypeCautionCheck:@"Please connect device with Bluetooth or Configure device with WIFI to set alarm."];
       }
       else
       {
           NSInteger alarm1Check = [self getStatusOfSavedAlarm:tagValue];

           if (alarm1Check == 0)
           {
               [APP_DELEGATE endHudProcess];
               //both are empty, show error that select time
               [self AlertViewFCTypeCautionCheck:@"Please select ON and OFF time"];
           }
           else
           {
               if(isSourcetoConnectAvailable == 2)
               {
                   if ([APP_DELEGATE isNetworkreachable])
                   {
                       selectedAlarmIndex = tagValue;
                       [self SendAlarmtoDevice:tagValue];
                   }
                   else
                   {
                       [self AlertViewFCTypeCautionCheck:@"Please check your Internet Connection."];
                   }
               }
               else
               {
                   selectedAlarmIndex = tagValue;
                   [self SendAlarmtoDevice:tagValue];
               }
           }
       }
   [self ShowPicker:NO andView:timeBackView];
}
-(void)btnRepeateClick:sender
{
    [[arrTitle objectAtIndex:[sender tag]] setValue:@"NA" forKey:@"On_original"];
    [[arrTitle objectAtIndex:[sender tag]] setValue:@"NA" forKey:@"Off_original"];
    [[arrTitle objectAtIndex:[sender tag]] setValue:@"NA" forKey:@"OnTimestamp"];
    [[arrTitle objectAtIndex:[sender tag]] setValue:@"NA" forKey:@"OffTimestamp"];
    int tagValue = 200;
    if ([sender tag] == 1)
    {
        tagValue = 300;
    }
    for (int i =0; i < 7; i++)
    {
        [[arrTitle objectAtIndex:[sender tag]] setValue:@"0" forKey:[NSString stringWithFormat:@"%d",tagValue + i]];
    }
    
    if ([[[arrTitle objectAtIndex:[sender tag]] valueForKey:@"isExpanded"] isEqualToString:@"1"])
    {
        [[arrTitle objectAtIndex:[sender tag]] setValue:@"0" forKey:@"isExpanded"];
    }
    else
    {
        [[arrTitle objectAtIndex:[sender tag]] setValue:@"1" forKey:@"isExpanded"];
    }
    [tblAlarms reloadData];
    [self ShowPicker:NO andView:timeBackView];
}
#pragma mark :- DATABASE METHODS
-(void)InsertAndUpdateTheAlaramTable:(NSDictionary *)dictData
{
    NSString * strAlarmId = [dictData valueForKey:@"alarm_id"];
    NSString * strsocketID = [dictData valueForKey:@"socket_id"];
//    NSString * strdayValue = [dictData valueForKey:@"totalCount"];
    NSString * strOnTime =  [dictData valueForKey:@"OnTimestamp"];
    NSString * strOffTime = [dictData valueForKey:@"OffTimestamp"];
    NSString * stralarmState = @"01";
    NSString * strONoriginal = [dictData valueForKey:@"On_original"];
    NSString * strOffOriginal = [dictData valueForKey:@"Off_original"];
//    NSString * strDaySelected = @"NA";
    
    NSMutableArray * tmpArry = [[NSMutableArray alloc]init];
    NSString * strQuery = [NSString stringWithFormat:@"select * from Socket_Alarm_Table where ble_address = '%@' and alarm_id = '%@'",strMacaddress,strAlarmId];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:tmpArry];
    
    int correctValue = 200;
    if (selectedAlarmIndex == 1)
    {
        correctValue = 300;
    }
    
    NSMutableArray * arrDayStatus = [[NSMutableArray alloc] init];
    for (int j=0; j<7; j++)
    {
        NSString * strStatus = [dictData valueForKey:[NSString stringWithFormat:@"%d", correctValue + j]];//
        [arrDayStatus addObject:strStatus];
    }
    
    NSString * strDayStatus = @"NA";
    if ([arrDayStatus count] >= 7)
    {
        strDayStatus = [arrDayStatus componentsJoinedByString:@","];
    }
    
    if ([tmpArry count] > 0)
    {
        NSString * update = [NSString stringWithFormat:@"update Socket_Alarm_Table set alarm_id = '%@', socket_id ='%@', OnTimestamp ='%@', OffTimestamp = '%@', On_original = '%@', Off_original = '%@', alarm_state = '%@',  day_selected = '%@' where ble_address = '%@' and alarm_id = '%@'",strAlarmId,strsocketID,strOnTime,strOffTime,strONoriginal,strOffOriginal,stralarmState,strDayStatus,strMacaddress,strAlarmId];
        [[DataBaseManager dataBaseManager] execute:update];
    }
    else
    {
        NSString * strInsert  =[NSString stringWithFormat:@"insert into 'Socket_Alarm_Table'('alarm_id','socket_id','OnTimestamp','OffTimestamp','On_original','Off_original','alarm_state','ble_address','day_selected') values('%@','%@','%@','%@','%@','%@','%@','%@','%@')",strAlarmId,strsocketID,strOnTime,strOffTime,strONoriginal,strOffOriginal,stralarmState,strMacaddress,strDayStatus];
        [[DataBaseManager dataBaseManager] executeSw:strInsert];
    }
}
-(void)DeleteAlarmInDatabase:(NSInteger)strAlaramID
{
    NSString * deleteQuery =[NSString stringWithFormat:@"delete from Socket_Alarm_Table where ble_address = '%@' and alarm_id = '%ld'",strMacaddress,(long)strAlaramID];
    [[DataBaseManager dataBaseManager] execute:deleteQuery];
}
#pragma mark :- Method to Set Alarm for BLE & MQTT
-(void)SendAlarmtoDevice:(NSInteger)selectedIndex
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Saving Alarm..."];

    NSString * strAlarmType = @"Alarm 1";
    NSString * strMsg = @"";
    if (selectedIndex == 1)
    {
        strAlarmType = @"Alarm 2";
    }
    NSInteger daysCountPrefix = 200;
    if (selectedIndex == 1)
    {
        daysCountPrefix = 300;
    }
    NSInteger daysATotalCount = 0;
    NSArray * countsArr = [NSArray arrayWithObjects:@"64",@"32",@"16",@"8",@"4",@"2",@"1", nil];

    for (int i = 0; i < 7; i++)
    {
        NSString * strKey = [NSString stringWithFormat:@"%ld",daysCountPrefix + i];
        if ([[[arrTitle objectAtIndex:selectedIndex] valueForKey:strKey] isEqualToString:@"1"])
        {
            daysATotalCount = daysATotalCount + [[countsArr objectAtIndex:i] intValue];
        }
    }
   
    NSString * strOnTimestamp = [self checkforValidString:[[arrTitle objectAtIndex:selectedIndex] valueForKey:@"On_original"]];
    NSString * strOffTimestamp = [self checkforValidString:[[arrTitle objectAtIndex:selectedIndex] valueForKey:@"Off_original"]];
    
    NSString *time1 = strOnTimestamp;
    NSString *time2 = strOffTimestamp;
//    @"isExpanded"
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm aa"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    if ([[[arrTitle objectAtIndex:selectedIndex] valueForKey:@"isExpanded"] isEqualToString:@"0"] && daysATotalCount == 0)
    {
        [formatter setDateFormat:@"dd/mm/yyyy hh:mm aa"];
    }
    
    NSDate *date1= [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];

    NSComparisonResult result = [date1 compare:date2];

    BOOL isDateCorrect = YES;
    if (![strOnTimestamp  isEqualToString:@"NA"] &&  ![strOffTimestamp  isEqualToString:@"NA"])
    {
        if(result == NSOrderedSame)
        {
            isDateCorrect = NO;
            strMsg = [NSString stringWithFormat:@"%@'s On Time and Off Time should not be same.",strAlarmType];
        }
    }

    if (isDateCorrect == NO)
    {
        [self AlertViewFCTypeCautionCheck:strMsg];
    }
    else
    {
        NSString * strAlarmID = [[arrTitle objectAtIndex:selectedIndex] valueForKey:@"alarm_id"];
        NSInteger intAlarmID = [strAlarmID intValue];
        NSData * dataAlarmID = [[NSData alloc] initWithBytes:&intAlarmID length:1];// alaram ID
        
        NSInteger strSktID = intSelectedSwitch - 1 ; // - 1
        NSData * dataSocketID = [[NSData alloc] initWithBytes:&strSktID length:1]; // switch index
        [arrTitle setValue:[NSString stringWithFormat:@"%ld",(long)intSelectedSwitch] forKey:@"socket_id"];
        
        NSInteger intDayID = 0;

        if ([[[arrTitle objectAtIndex:selectedIndex] valueForKey:@"isExpanded"] isEqual:@"1"])
        {
            if (daysATotalCount == 0)
            {
                [self AlertViewFCTypeCautionCheck:@"Please select which day you want to repeate alarm."];
                return;
            }
            else
            {
                intDayID = daysATotalCount;
            }
        }
        
        NSData * dataDaytID = [[NSData alloc] initWithBytes:&intDayID length:1];
        
        NSInteger totallength = -1;
        NSData * dataStartTime  = [[NSData alloc] initWithBytes:&totallength length:4];
        double  intStartTime = 0;
        if (![strOnTimestamp isEqualToString:@"NA"])
        {
              intStartTime = [[[arrTitle objectAtIndex:selectedIndex] valueForKey:@"OnTimestamp"] doubleValue];//1611663180; //  ON timestap
            NSString *decStr = [NSString stringWithFormat:@"%f",intStartTime];
            NSString *hexStr = [NSString stringWithFormat:@"%llX", (long long)[decStr integerValue]];
            NSString * strDate = hexStr;
            dataStartTime = [self dataFromHexString:strDate];
        }
        
        NSData * dataEndTime = [[NSData alloc] initWithBytes:&totallength length:4];
        double intEndTime = 0;
        if (![strOffTimestamp isEqualToString:@"NA"])
        {
            intEndTime = [[[arrTitle objectAtIndex:selectedIndex] valueForKey:@"OffTimestamp"] doubleValue];//1611663180; //  ON timestap
            NSString * decStr = [NSString stringWithFormat:@"%f",intEndTime];
            NSString * hexStr = [NSString stringWithFormat:@"%llX", (long long)[decStr integerValue]];
            NSString * strDate = hexStr;
            dataEndTime = [self dataFromHexString:strDate];
        }
         saveRandomNumber = [self getRandomNumberBetween:1 to:255];
        NSInteger random2 = 0;
        NSData * dataRandomNumber1  = [[NSData alloc] initWithBytes:&saveRandomNumber length:1];
        NSData * dataRandomNumber2  = [[NSData alloc] initWithBytes:&random2 length:1];

        NSMutableData *completeData = [dataAlarmID mutableCopy];
        [completeData appendData:dataSocketID];
        [completeData appendData:dataDaytID];
        [completeData appendData:dataStartTime];
        [completeData appendData:dataEndTime];
        [completeData appendData:dataRandomNumber1];
        [completeData appendData:dataRandomNumber2];

        isAlarmSavedSucessfully = NO;
        [timerForSaveAlarm invalidate];
        timerForSaveAlarm = nil;
        timerForSaveAlarm = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(RequestTimeOutofBLEMQTT) userInfo:nil repeats:NO];
        
        if (periphPass.state == CBPeripheralStateDisconnected || periphPass == nil)
        {
            NSInteger intLength = 13;
            NSData * dataLength = [[NSData alloc] initWithBytes:&intLength length:1];

            NSInteger intOpcode = 11;
            NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpcode length:1];

            NSMutableData *completeData = [dataOpcode mutableCopy];
            [completeData appendData:dataLength];
            [completeData appendData:dataAlarmID];
            [completeData appendData:dataSocketID];
            [completeData appendData:dataDaytID];
            [completeData appendData:dataStartTime];
            [completeData appendData:dataEndTime];
            [completeData appendData:dataRandomNumber1];
            [completeData appendData:dataRandomNumber2];

            NSLog(@"MQTT Alram Compleate Data =====>>>>>%@ and Number =%ld",completeData,(long)saveRandomNumber);
            
            isDeletedManually = NO;
            
            bleAlarmData =  [[NSMutableData alloc] init];
            mqttAlarmData = [completeData mutableCopy];
            
            isAlarmRequested = YES;
            [delegate SetupAlarm:mqttAlarmData];

            return;
        }
        NSString * StrData = [NSString stringWithFormat:@"%@",completeData];
        StrData = [StrData stringByReplacingOccurrencesOfString:@" " withString:@""];
        StrData = [StrData stringByReplacingOccurrencesOfString:@"<" withString:@""];
        StrData = [StrData stringByReplacingOccurrencesOfString:@">" withString:@""];

        NSLog(@"Alram Compleate Data =====>>>>>%@",completeData);
        isDeletedManually = NO;
        mqttAlarmData =  [[NSMutableData alloc] init];
        bleAlarmData = [completeData mutableCopy];
        [[BLEService sharedInstance] WriteSocketData:bleAlarmData withOpcode:@"11" withLength:@"13" withPeripheral:periphPass];
    }
}
-(NSInteger)getRandomNumberBetween:(int)from to:(int)to
{
    return (NSInteger)from + arc4random() % (to-from+1);
}
-(void)SendSecondAlarmAfterSomeDelay
{
    [self SendAlarmtoDevice:1];
}
-(void)ALaramSuccessResponseFromDevie
{
    isAlarmSavedSucessfully = YES;
    if ([arrTitle count] > selectedAlarmIndex)
    {
        [self InsertAndUpdateTheAlaramTable:[arrTitle objectAtIndex:selectedAlarmIndex]];
    }
    saveRandomNumber = -1;

    if (selectedAlarmIndex == 1)
    {
        //show successpopup saying alarm saved
        dispatch_async(dispatch_get_main_queue(), ^{
            [APP_DELEGATE endHudProcess];
            [self AlertViewFCTypeSuccess:[NSString stringWithFormat:@"Alarm set for socket %ld succcessfully",(long)self->intSelectedSwitch]];
        });
    }
    else if(selectedAlarmIndex == 0)
    {
        //show successpopup saying alarm saved
        dispatch_async(dispatch_get_main_queue(), ^{
            [APP_DELEGATE endHudProcess];
            [self AlertViewFCTypeSuccess:[NSString stringWithFormat:@"Alarm set for socket %ld succcessfully",(long)self->intSelectedSwitch]];
        });
    }
}
-(void)DeleteAlarmConfirmFromDevice:(NSMutableDictionary *)dictDeleteCofirmID
{
    [APP_DELEGATE endHudProcess];

    if (isDeletedManually == YES)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[dictDeleteCofirmID  valueForKey:@"deleteSate"] isEqual:@"01"])
            {
                deleteRandomNumber = -1;
                [self AlertViewFCTypeSuccess:@"Alarm deleted sucessfully..."];
                NSString * strALid = [self stringFroHex:[dictDeleteCofirmID valueForKey:@"alarm_id"]];
                NSInteger inrval = [strALid integerValue];
                [self DeleteAlarmInDatabase:inrval];
               
                if ([arrTitle count] > selectedAlarmIndex)
                {
                    [[arrTitle objectAtIndex:selectedAlarmIndex] setValue:@"NA" forKey:@"On_original"];
                    [[arrTitle objectAtIndex:selectedAlarmIndex] setValue:@"NA" forKey:@"Off_original"];
                    [[arrTitle objectAtIndex:selectedAlarmIndex] setValue:@"NA" forKey:@"OnTimestamp"];
                    [[arrTitle objectAtIndex:selectedAlarmIndex] setValue:@"NA" forKey:@"OffTimestamp"];
                    [[arrTitle objectAtIndex:selectedAlarmIndex] setValue:@"0" forKey:@"isExpanded"];
                    [tblAlarms reloadData];
                    selectedAlarmIndex = 0;
                }
            }
            else
            {
                [self AlertViewFCTypeCautionCheck:@"Something went wrong."];
            }
        });
    }
    else
    {
        [[BLEService sharedInstance] WriteSocketData:bleAlarmData withOpcode:@"11" withLength:@"11" withPeripheral:periphPass];
    }
}
-(NSInteger)getStatusOfSavedAlarm:(NSInteger)indexx //0 : Both NA, 1 : Any one NA, 2: Both OK
{
    if ([[[arrTitle objectAtIndex:indexx] valueForKey:@"OnTimestamp"] isEqualToString:@"NA"] &&  [[[arrTitle objectAtIndex:indexx] valueForKey:@"OffTimestamp"] isEqualToString:@"NA"])
    {
        return  0;
    }
    else if (![[[arrTitle objectAtIndex:indexx] valueForKey:@"OnTimestamp"] isEqualToString:@"NA"] ||  ![[[arrTitle objectAtIndex:indexx] valueForKey:@"OffTimestamp"] isEqualToString:@"NA"])
    {
        return 1;
    }
    return 0;
}
#pragma mark - MQTT Callbacks
-(void)MqttDeleteAlarmStatusfromServer:(BOOL)isSuccess withServerResponse:(NSArray *)arrResponse withMacaddress:(NSString *)strBleaddress
{
    [APP_DELEGATE endHudProcess];

    BOOL isShowPopup = NO;
    if ([arrResponse count] >= 4)
    {
        NSString * strRandomNumber = @"";
        for (int i = 4; i > 2; i--)
        {
            NSInteger intPacket = [[NSString stringWithFormat:@"%@",[arrResponse objectAtIndex:i]] integerValue];
            NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
            NSString * strPacket = [NSString stringWithFormat:@"%@",dataPacket.debugDescription];
            strPacket = [strPacket stringByReplacingOccurrencesOfString:@" " withString:@""];
            strPacket = [strPacket stringByReplacingOccurrencesOfString:@">" withString:@""];
            strPacket = [strPacket stringByReplacingOccurrencesOfString:@"<" withString:@""];
            if ([strRandomNumber length]==3)
            {
                strRandomNumber = strPacket;
            }
            else
            {
                strRandomNumber = [strRandomNumber stringByAppendingString:strPacket];
            }
        }
        if (![strRandomNumber isEqualToString:@""])
        {
            NSString * strFinalSent = [self stringFroHex:strRandomNumber];
            NSInteger finalSentRandom = [strFinalSent integerValue];
            
            if (finalSentRandom == deleteRandomNumber)
            {
                isShowPopup = YES;
            }
        }
    }
    if (isShowPopup == YES)
    {
        if (isDeletedManually == YES)
        {
            [self AlertViewFCTypeSuccess:@"Alarm deleted sucessfully..."];
            
            deleteRandomNumber = -1;

            [[arrTitle objectAtIndex:selectedAlarmIndex] setValue:@"NA" forKey:@"On_original"];
            [[arrTitle objectAtIndex:selectedAlarmIndex] setValue:@"NA" forKey:@"Off_original"];
            [[arrTitle objectAtIndex:selectedAlarmIndex] setValue:@"NA" forKey:@"OnTimestamp"];
            [[arrTitle objectAtIndex:selectedAlarmIndex] setValue:@"NA" forKey:@"OffTimestamp"];
            [[arrTitle objectAtIndex:selectedAlarmIndex] setValue:@"0" forKey:@"isExpanded"];
            [tblAlarms reloadData];
            
            NSInteger alarmId = -1;
            if ([arrTitle count]>selectedAlarmIndex)
            {
                if ([[[arrTitle objectAtIndex:selectedAlarmIndex] allKeys] containsObject:@"alarm_id"])
                {
                    alarmId = [[[arrTitle objectAtIndex:selectedAlarmIndex] valueForKey:@"alarm_id"] integerValue];
                }
            }
            if (alarmId == -1)
            {
                if ([arrResponse count] >= 6)
                {
                    alarmId = [[arrResponse objectAtIndex:2] integerValue];
                }
            }
            if (alarmId != -1)
            {
                [self DeleteAlarmInDatabase:alarmId];
            }
        }
        else
        {
            [delegate SetupAlarm:mqttAlarmData];
        }
    }
    else
    {
        NSInteger alarmId = -1;
        if ([arrResponse count] >= 6)
        {
            alarmId = [[arrResponse objectAtIndex:2] integerValue];
        }
        if (alarmId != -1)
        {
            NSString * deleteQuery =[NSString stringWithFormat:@"delete from Socket_Alarm_Table where ble_address = '%@' and alarm_id = '%ld'",strBleaddress,(long)alarmId];
            [[DataBaseManager dataBaseManager] execute:deleteQuery];
        }
    }
}
-(void)MqttAlarmStatusfromServer:(BOOL)isSuccess withServerResponse:(NSArray *)arrResponse withMacAddress:(NSString *)strBleAddress
{
    BOOL isShowPopup = NO;
    if ([arrResponse count] >= 16)
    {
        NSString * strRandomNumber = @"";
        for (int i = 14; i > 12; i--)
        {
            NSInteger intPacket = [[NSString stringWithFormat:@"%@",[arrResponse objectAtIndex:i]] integerValue];
            NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
            NSString * strPacket = [NSString stringWithFormat:@"%@",dataPacket.debugDescription];
            strPacket = [strPacket stringByReplacingOccurrencesOfString:@" " withString:@""];
            strPacket = [strPacket stringByReplacingOccurrencesOfString:@">" withString:@""];
            strPacket = [strPacket stringByReplacingOccurrencesOfString:@"<" withString:@""];
            if ([strRandomNumber length]==14)
            {
                strRandomNumber = strPacket;
            }
            else
            {
                strRandomNumber = [strRandomNumber stringByAppendingString:strPacket];
            }
        }
        if (![strRandomNumber isEqualToString:@""])
        {
            NSString * strFinalSent = [self stringFroHex:strRandomNumber];
            NSInteger finalSentRandom = [strFinalSent integerValue];
            
            NSLog(@"======MqttAlarmStatusfromServer====%ld and sent =%ld",(long)finalSentRandom,(long)saveRandomNumber);
            if (finalSentRandom == saveRandomNumber)
            {
                isShowPopup = YES;
            }
        }
    }
    
    if (isShowPopup == YES)
    {
        if (isSuccess == YES)
        {
            saveRandomNumber = -1;
            isAlarmSavedSucessfully = YES;
            [self ALaramSuccessResponseFromDevie];
        }
        else
        {
            isAlarmSavedSucessfully = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [APP_DELEGATE endHudProcess];
                [self AlertViewFCTypeCautionCheck:@"Alarm not set properly. Please try again."];
            });
        }
    }
    else
    {
        if ([arrResponse count] >= 16)
        {
            NSString * strAlarmId = [NSString stringWithFormat:@"%@",[arrResponse objectAtIndex:2]];
            NSString * strSocketId = [NSString stringWithFormat:@"%@",[arrResponse objectAtIndex:3]];
            NSString * strOnTime = [self stringFroHex:[ self GetDecimalValueofAlarm:arrResponse withType:0]];;
            NSString * strOffTime = [self stringFroHex:[ self GetDecimalValueofAlarm:arrResponse withType:1]];;
            NSString * strTotalDaysCount = [NSString stringWithFormat:@"%@",[arrResponse objectAtIndex:4]];
            NSString * strOnOriginal = [self getHoursfromString:strOnTime withDaysCount:strTotalDaysCount];
            NSString * strOffOriginal = [self getHoursfromString:strOffTime withDaysCount:strTotalDaysCount];
            NSString * strdayValue = [self getSelectedDaysforDayByteValue:[NSString stringWithFormat:@"%@",[arrResponse objectAtIndex:4]]];

            NSMutableArray * tmpArry = [[NSMutableArray alloc]init];
            NSString * strQuery = [NSString stringWithFormat:@"select * from Socket_Alarm_Table where ble_address = '%@' and alarm_id = '%@'",strBleAddress,strAlarmId];
            [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:tmpArry];
            
            if ([tmpArry count] == 0)
            {
                NSString * strInsert  =[NSString stringWithFormat:@"insert into 'Socket_Alarm_Table'('alarm_id','socket_id','day_selected','OnTimestamp','OffTimestamp','alarm_state','ble_address','On_original','Off_original') values('%@','%@','%@','%@','%@','%@','%@','%@','%@')",strAlarmId,strSocketId,strdayValue,strOnTime,strOffTime,@"01",strBleAddress,strOnOriginal,strOffOriginal];
                [[DataBaseManager dataBaseManager] execute:strInsert];
            }
            else
            {
                NSString * update = [NSString stringWithFormat:@"update Socket_Alarm_Table set alarm_id = '%@', socket_id ='%@',day_selected='%@', onTimestamp ='%@', offTimestamp = '%@', alarm_state = '%@', On_original = '%@', Off_original = '%@' where ble_address = '%@' and alarm_id = '%@'",strAlarmId,strSocketId,strdayValue,strOnTime,strOffTime,@"01",strOnOriginal,strOffOriginal,strBleAddress,strAlarmId];
                [[DataBaseManager dataBaseManager] execute:update];
            }


        }
    }
}


-(NSString *)getHexaofofDecimalTimefromIndex:(int)indexx withArr:(NSArray *)arrResponse
{
    NSString * strHexStart;

    for (int i = indexx; i < indexx + 4; i ++)
    {
        NSInteger int1 = [[arrResponse objectAtIndex:i] integerValue];
        NSData *d = [[NSData alloc] initWithBytes:&int1 length:1];
        NSString * strHex1 = [NSString stringWithFormat:@"%@",d.debugDescription];
        strHex1 = [strHex1 stringByReplacingOccurrencesOfString:@" " withString:@""];
        strHex1 = [strHex1 stringByReplacingOccurrencesOfString:@"<" withString:@""];
        strHex1 = [strHex1 stringByReplacingOccurrencesOfString:@">" withString:@""];

        if (strHexStart.length == 0)
        {
            strHexStart = strHex1;
        }
        else
        {
            strHexStart = [strHexStart stringByAppendingString:strHex1];
        }
    }
    return strHexStart;
}
-(void)RequestTimeOutofBLEMQTT
{
    if (isViewDisapeared == NO)
    {
        if (isAlarmSavedSucessfully == NO)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
            [APP_DELEGATE endHudProcess];
            [self AlertViewFCTypeCautionCheck:@"Alarm not set properly. Please try again."];
            });
        }
    }
}
#pragma mark :- Extra Methods
-(void)AlertViewFCTypeCautionCheck:(NSString *)strMsg
{
    [APP_DELEGATE endHudProcess];
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"Vithamas"
                  withSubtitle:strMsg
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
}
-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""])
        {
            strValid = strRequest;
        }
        else
        {
            strValid = @"NA";
        }
    }
    else
    {
        strValid = @"NA";
    }
    strValid = [strValid stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    return strValid;
}
-(NSString *)getHoursfromString:(NSString *)strTimestamp withDaysCount:(NSString *)strDayCount
{
    double timeStamp = [strTimestamp intValue];
    NSTimeInterval timeInterval=timeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    if ([strDayCount isEqualToString:@"0"] || [strDayCount isEqualToString:@"00"])
    {
        date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
        [dateformatter setDateFormat:@"dd/mm/yyyy hh:mm aa"];
    }
    else
    {
        [dateformatter setDateFormat:@"hh:mm aa"];
    }
    NSString *dateString=[dateformatter stringFromDate:date];
    return dateString;
}
-(void)DeleteAlaramViaMQTT:(NSInteger)selectedIndex
{
    NSString * strAlID = [[arrTitle objectAtIndex:selectedIndex] valueForKey:@"alarm_id"];
    NSInteger intPacket = [strAlID integerValue];
    NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
    
    NSInteger intDeleteOpcode = 12;
    NSData * dataDeleteOpcode = [[NSData alloc] initWithBytes:&intDeleteOpcode length:1];

    NSInteger intDeleteLength = 3;
    NSData * dataDeleteLength = [[NSData alloc] initWithBytes:&intDeleteLength length:1];

    NSInteger random2 = 0;
    NSData * dataRandomNumber1  = [[NSData alloc] initWithBytes:&deleteRandomNumber length:1];
    NSData * dataRandomNumber2  = [[NSData alloc] initWithBytes:&random2 length:1];

    NSMutableData * deleteDataPackets = [dataDeleteOpcode mutableCopy];
    [deleteDataPackets appendData:dataDeleteLength];
    [deleteDataPackets appendData:dataPacket];
    [deleteDataPackets appendData:dataRandomNumber1];
    [deleteDataPackets appendData:dataRandomNumber2];

    [delegate DeleteAlarm:deleteDataPackets];
    isAlarmRequested = YES;
}
-(NSString *)getSelectedDaysforDayByteValue:(NSString *)strDayValue
{
    NSInteger intMsg = [strDayValue intValue];
    NSData * data = [[NSData alloc] initWithBytes:&intMsg length:1];
    const char *byte = [data bytes];
    unsigned int length = [data length];
    NSString * strBits;

    for (int i=0; i<length; i++)
    {
        char n = byte[i];
        char buffer[9];
        buffer[8] = 0; //for null
        int j = 8;
        while(j > 0)
        {
            if(n & 0x01)
            {
                buffer[--j] = '1';
            } else
        {
            buffer[--j] = '0';
        }
        n >>= 1;
        }
        strBits = [NSString stringWithFormat:@"%s",buffer];
//        NSLog(@"opopoppopop=%@",strBits);
    }
    NSMutableArray * arrSelected = [[NSMutableArray alloc] init];

    for (int i = 0; i < strBits.length; i++)
    {
        NSString * strStatus = [strBits substringWithRange:NSMakeRange((i*1), 1)];
//        NSLog(@"KAKPKPKPK=%@",[strBits substringWithRange:NSMakeRange((i*1), 1)]);
        if ([strStatus isEqualToString:@"1"])
        {
            [arrSelected addObject:@"1"];
        }
        else
        {
            [arrSelected addObject:@"0"];
        }
    }
    if ([arrSelected count] > 0)
    {
        [arrSelected removeObjectAtIndex:0];
    }
    NSString * strDaySelected = [arrSelected componentsJoinedByString:@","];
    return strDaySelected;
}
-(NSString *)GetDecimalValueofAlarm:(NSArray *)arrData withType:(int)OnOff
{
    NSString * strDecimal = @"";
    if ([arrData count]>= 14)
    {
        int initialValue = 5;
        if (OnOff == 1)
        {
            initialValue = 9;
        }
        //150c01007f 265c2659d2dcd2280100000000
        for (int i = initialValue; i < initialValue + 4; i++)
        {
            if ([arrData count] > i)
            {
                NSInteger intPacket = [[NSString stringWithFormat:@"%@",[arrData objectAtIndex:i]] integerValue];
                NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
                NSString * strPacket = [NSString stringWithFormat:@"%@",dataPacket.debugDescription];
                strPacket = [strPacket stringByReplacingOccurrencesOfString:@" " withString:@""];
                strPacket = [strPacket stringByReplacingOccurrencesOfString:@">" withString:@""];
                strPacket = [strPacket stringByReplacingOccurrencesOfString:@"<" withString:@""];
                strDecimal = [strDecimal stringByAppendingString:strPacket];
            }
        }

    }
    return strDecimal;
}
@end
/*
 11,
 14,
 2,
 0,
 0,
 96,
 116,
 28,
 60,
 96,
 116,
 28,
 120,
 193,
 62,
 1
)
 **/

