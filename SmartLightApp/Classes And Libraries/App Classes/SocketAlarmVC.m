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
    UIView *timeBackView;
    UIDatePicker * datePicker;
    
    NSMutableArray * dayArr, * tmpArray;
    NSInteger totalDayCount, hours, minutes, sentCount,selday;
    int tblY;
    BOOL isOnPower, isRepeate;
    NSString * strTimeSelected,*strSelected1,*strSelected2,*strSelected3;
    int totalSyncedCount;
    UILabel * lblTime;
    UIButton * btn0, * btn1,* btn2, *btn3, *btn4, *btn5, *btn6,*btnON,*btnOFF;
    int headerhHeight,viewWidth;

    // css add this
//    UIView *viewBGPicker,*pickerSetting;
//    UIDatePicker * datePicker;
    CBPeripheral * classPeripheral;
    
    UITableView * tblAlarms;
    NSInteger  intIndexPath;
    NSMutableDictionary * dictSw;
    NSTimer * timerForDelete;
    
    NSMutableArray * arryAlrams,*arrDayselect;
    
    NSMutableArray * arrTitle,*arrAlarmDetail;
    NSString * strAlramID1,*strAlramID2;
    int selectedAlarmIndex;

}
@end

@implementation SocketAlarmVC

@synthesize intSelectedSwitch,periphPass,intswitchState,strTAg,strMacaddress;
- (void)viewDidLoad
{
    globalStatusHeight = 20;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSizes = 14;
    }
    if (IS_IPHONE_X)
    {
        globalStatusHeight = 44;
    }

    self.navigationController.navigationBarHidden = true;
    
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

    NSArray * countsArr = [NSArray arrayWithObjects:@"1",@"2",@"4",@"8",@"16",@"32",@"64", nil];
    
    for (int i=0; i<[dateArr count]; i++)
    {
        NSMutableDictionary * dayDict = [[NSMutableDictionary alloc] init];
        NSString * strDay = [dateArr objectAtIndex:i];
        [dayDict setObject:strDay forKey:@"day"];
        [dayDict setObject:@"0" forKey:@"isOff"]; // 1
        [dayDict setObject:[countsArr objectAtIndex:i] forKey:@"counts"];
        [dayDict setObject:[weekArr objectAtIndex:i] forKey:@"dayname"];

        [dayArr addObject:dayDict];//  [dayArr addObject:dayDict];
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
            strAlramID1 = [NSString stringWithFormat:@"select * from Socket_Alarm_Table where ble_address = '%@' and alarm_id = '%ld'",strMacaddress,(long)alarmId];
            [[DataBaseManager dataBaseManager] execute:strAlramID1 resultsArray:arrAlarm];
            
            NSString * strONtime = @"NA";
            NSString * strOFFtime = @"NA";

            [dict setValue:@"NA" forKey:@"OnTimestamp"];
            [dict setValue:@"NA" forKey:@"OffTimestamp"];

            if ([arrAlarm count] > 0)
            {
                strONtime = [[arrAlarm objectAtIndex:0] valueForKey:@"On_original"];
                strOFFtime = [[arrAlarm objectAtIndex:0] valueForKey:@"Off_original"];
                
                [dict setValue:[[arrAlarm objectAtIndex:0] valueForKey:@"OnTimestamp"] forKey:@"OnTimestamp"];
                [dict setValue:[[arrAlarm objectAtIndex:0] valueForKey:@"OffTimestamp"] forKey:@"OffTimestamp"];
            }
            [dict setValue:strONtime forKey:@"On_original"];
            [dict setValue:strOFFtime forKey:@"Off_original"];
        }
        else
        {
            NSInteger alarmId = (intSelectedSwitch * 2) ;
            strAlramID2 = [NSString stringWithFormat:@"select * from Socket_Alarm_Table where ble_address = '%@' and alarm_id = '%ld'",strMacaddress,(long)alarmId];
            [[DataBaseManager dataBaseManager] execute:strAlramID2 resultsArray:arrAlarm];
            
            NSString * strONtime = @"NA";
            NSString * strOFFtime = @"NA";

            [dict setValue:@"NA" forKey:@"OnTimestamp"];
            [dict setValue:@"NA" forKey:@"OffTimestamp"];

            if ([arrAlarm count] > 0)
            {
                strONtime = [[arrAlarm objectAtIndex:0] valueForKey:@"On_original"];
                strOFFtime = [[arrAlarm objectAtIndex:0] valueForKey:@"Off_original"];
                
                [dict setValue:[[arrAlarm objectAtIndex:0] valueForKey:@"OnTimestamp"] forKey:@"OnTimestamp"];
                [dict setValue:[[arrAlarm objectAtIndex:0] valueForKey:@"OffTimestamp"] forKey:@"OffTimestamp"];

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
    
    [arrTitle setValue:@"0" forKey:@"isExpanded"]; //css added

    NSLog(@"All Alarams===>>>>%@",arrAlarmDetail);
    
//    [self btnSaveClick];
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
//    [viewHeader addSubview:lblBack];
    
    UILabel * lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, yy + globalStatusHeight-1, DEVICE_WIDTH,1)];
    [lblLine setBackgroundColor:[UIColor lightGrayColor]];
    [viewHeader addSubview:lblLine];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, globalStatusHeight, DEVICE_WIDTH-100, yy)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:[NSString stringWithFormat:@"Set Alarm for %d",intSelectedSwitch]];
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
    
    UIButton * btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSave.frame = CGRectMake(DEVICE_WIDTH-50, 20, 50, 44);
    btnSave.layer.masksToBounds = YES;
    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnSave.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    [btnSave.titleLabel setFont:[UIFont systemFontOfSize:30 weight:UIFontWeightRegular]];
    [btnSave.titleLabel setFont:[UIFont fontWithName:CGBold size:textSizes]];
    [btnSave addTarget:self action:@selector(btnSaveClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnSave];
    
    tblAlarms = [[UITableView alloc]initWithFrame:CGRectMake(0, yy+globalStatusHeight, DEVICE_WIDTH, DEVICE_HEIGHT-headerhHeight-80)];
    tblAlarms.backgroundColor = UIColor.clearColor;
    tblAlarms.delegate = self;
    tblAlarms.dataSource = self;
    tblAlarms.separatorColor = UIColor.clearColor;
    tblAlarms.scrollEnabled = false;
    [self.view addSubview:tblAlarms];
    
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 88, 88);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        btnSave.frame = CGRectMake(DEVICE_WIDTH-60, 40, 60, 44);
    }
    
    [self setMainViewContentFrame:headerhHeight];
}
-(void)btnTimerSelect:(NSInteger)Tag
{
    [timeBackView removeFromSuperview];
    timeBackView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 250)];
    [timeBackView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:timeBackView];
    
    [datePicker removeFromSuperview];
    datePicker = nil;
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(50, 40, DEVICE_WIDTH-100, 180)];
    [datePicker setBackgroundColor:[UIColor clearColor]];
    datePicker.tag = Tag;
    datePicker.datePickerMode=UIDatePickerModeTime;
    datePicker.timeZone = [NSTimeZone localTimeZone];
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
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
-(void)setMainViewContentFrame:(int)yValue
{
    yValue = yValue+10;
    
    UILabel * lblSubHint = [[UILabel alloc] initWithFrame:CGRectZero];
    lblSubHint.backgroundColor = [UIColor clearColor];
    lblSubHint.frame=CGRectMake(0,yValue, DEVICE_WIDTH, 25);
    lblSubHint.font = [UIFont systemFontOfSize:14];
    lblSubHint.textAlignment = NSTextAlignmentCenter;
    [lblSubHint setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    lblSubHint.textColor = [UIColor whiteColor]; // change this color
    lblSubHint.text = @"Tap on time to change";
//    [self.view addSubview:lblSubHint];
    
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm a"];
    NSString * strCurrentTime = [dateFormat stringFromDate:[NSDate date]];
    

    
      strTimeSelected = strCurrentTime;
//
    lblTime = [[UILabel alloc] initWithFrame:CGRectZero];
    lblTime.backgroundColor = [UIColor clearColor];
    lblTime.frame=CGRectMake(0, yValue+20, DEVICE_WIDTH, 80);
    lblTime.textAlignment = NSTextAlignmentCenter;
    [lblTime setFont:[UIFont fontWithName:CGBold size:textSizes+30]];
    lblTime.textColor = [UIColor whiteColor]; // change this color
    lblTime.text = strCurrentTime;
//    [self.view addSubview:lblTime];
    
    UIButton * btnTimes = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTimes.frame = CGRectMake(0, yValue, DEVICE_WIDTH, 65);
    [btnTimes addTarget:self action:@selector(btnTimerSelect:) forControlEvents:UIControlEventTouchUpInside];
    btnTimes.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:btnTimes];
    
    UIView * dayView = [[UIView alloc] init];
    dayView.frame = CGRectMake(0, yValue+100, DEVICE_WIDTH, 70);
//    [self.view addSubview:dayView];

//    [self setPowerView:yValue];
    
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
    int btnTag = [sender tag];
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
    NSString * strStatus = [dict valueForKey:[NSString stringWithFormat:@"%d",btnTag]];
    
    UIColor * backColor, * txtColor;
    if ([strStatus isEqualToString:@"0"])
    {
        backColor = [UIColor whiteColor];
        txtColor = [UIColor blackColor];
//        [[dayArr objectAtIndex:[sender tag]] setObject:@"1" forKey:@"isOff"];
        [dict setValue:@"1" forKey:[NSString stringWithFormat:@"%d",btnTag]];

    }
    else
    {
        backColor = [UIColor clearColor];
        txtColor = [UIColor whiteColor];
//        [[dayArr objectAtIndex:[sender tag]] setObject:@"0" forKey:@"isOff"];
        [dict setValue:@"0" forKey:[NSString stringWithFormat:@"%d",btnTag]];
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
    int i = 0, len = hexStr.length;
    
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
        return 230;
    }
    else
    {
        return 150;
    }
    return 150;
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
    
//    NSMutableDictionary * dict = [arrTitle objectAtIndex:indexPath.row];
//    [cell UpdateDaysStatus:dict];
    
    int yy = 130;
    
    if ([[[arrTitle objectAtIndex:indexPath.row] valueForKey:@"isExpanded"] isEqualToString:@"1"])
    {
        
        yy = yy +10;
        
        cell.imgCheck.image = [UIImage imageNamed:@"checked.png"];
        cell.dayView.hidden = false;
        cell.lbldays.hidden = false;
        cell.lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 220);
        cell.lblLineParall.frame = CGRectMake(DEVICE_WIDTH/2, yy+20,.8,60);

        cell.lblON.frame = CGRectMake(0, yy,DEVICE_WIDTH/2,30);
        cell.lblOFF.frame = CGRectMake(DEVICE_WIDTH/2, yy,DEVICE_WIDTH/2,30);
        cell.lblONtime.frame = CGRectMake(0, yy+20,DEVICE_WIDTH/2,60);
        cell.lblOFFtime.frame = CGRectMake(DEVICE_WIDTH/2, yy+20,DEVICE_WIDTH/2,60);
        cell.btnONTimer.frame = CGRectMake(0, yy+20,DEVICE_WIDTH/2,60);
        cell.btnOFFTimer.frame = CGRectMake(DEVICE_WIDTH/2, yy+20,DEVICE_WIDTH/2,60);
    }
    else
    {
        yy = yy +30;
        
        cell.imgCheck.image = [UIImage imageNamed:@"checkEmpty.png"];
        cell.dayView.hidden = true;
        cell.lbldays.hidden = true;
        cell.lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 130);

        cell.lblLineParall.frame = CGRectMake(DEVICE_WIDTH/2, 70,.8,60);
        cell.lblON.frame = CGRectMake(0, 60,DEVICE_WIDTH/2,30);
        cell.lblOFF.frame = CGRectMake(DEVICE_WIDTH/2, 60,DEVICE_WIDTH/2,30);
        cell.lblONtime.frame = CGRectMake(0, 80,DEVICE_WIDTH/2,60);
        cell.lblOFFtime.frame = CGRectMake(DEVICE_WIDTH/2, 80,DEVICE_WIDTH/2,60);
        cell.btnONTimer.frame = CGRectMake(0, 80,DEVICE_WIDTH/2,60);
        cell.btnOFFTimer.frame = CGRectMake(DEVICE_WIDTH/2, 80,DEVICE_WIDTH/2,60);

    }
    
     isRepeate = NO;
    
    cell.btnTime.tag = indexPath.row+100;
    cell.btnon.tag = indexPath.row+500;
    cell.btnoff.tag = indexPath.row+600;
    cell.btnDelete.tag = indexPath.row+900;
    cell.btnTime.tag = indexPath.row+100;
    
    
    [cell.btnTime addTarget:self action:@selector(btnTimerClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnDelete addTarget:self action:@selector(btnDeleteClick:) forControlEvents:UIControlEventTouchUpInside];//btndeleteClick
    [cell.btnONTimer addTarget:self action:@selector(btnONTimerClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnOFFTimer addTarget:self action:@selector(btnOFFTimerClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnRepeate addTarget:self action:@selector(btnRepeateClick:) forControlEvents:UIControlEventTouchUpInside];

        if (indexPath.row == 0)
        {
            cell.lblONtime.text = [[arrTitle objectAtIndex:indexPath.row] valueForKey:@"On_original"];
            cell.lblOFFtime.text = [[arrTitle objectAtIndex:indexPath.row] valueForKey:@"Off_original"];
        }
        else
        {
            cell.lblONtime.text = [[arrTitle objectAtIndex:indexPath.row] valueForKey:@"On_original"];;
            cell.lblOFFtime.text = [[arrTitle objectAtIndex:indexPath.row] valueForKey:@"Off_original"];
        }
    
    if (indexPath.row == 0 )
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
    UIButton * btnTmp = [[UIButton alloc] init];
    btnTmp.tag = sender.tag;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:datePicker.date];
    lblTime.text = currentTime;

    strTimeSelected = currentTime;

    [tblAlarms reloadData];
}


#pragma mark - Button Events
-(void)btnDoneClicked:(UIButton *)sender
{
    UIButton * btnTmp = [[UIButton alloc] init];
    btnTmp.tag = sender.tag;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:datePicker.date];
    
    NSTimeInterval timeStamp = [datePicker.date timeIntervalSince1970];
    NSString *decStr = [NSString stringWithFormat:@"%f",timeStamp];
    
    NSLog(@"chethan Timestamp====>>>>%@",decStr);
   
    lblTime.text = [NSString stringWithFormat:@" %@",currentTime]; //1611817185
    
//    strTimeSelected = currentTime;
    
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
-(void)btnTimerClick:(UIButton *)sender
{
    if (sender.tag == 100)
    {
       
    }
    else if (sender.tag == 101)
    {
        [self btnTimerSelect:101];
    }
    else if (sender.tag == 102)
    {
        [self btnTimerSelect:102];
    }
    [tblAlarms reloadData];
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
    if (sender.tag >= 800)//2nd index
    {
        [self btnTimerSelect:sender.tag];
    }
    else
    {
        [self btnTimerSelect:sender.tag];
    }
}
-(void)btnOFFTimerClick:(UIButton *)sender
{
    if (sender.tag == 700)
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
    NSString * strAlD = @"NA";
    if (sender.tag == 900)
    {
        strAlD =[[arrTitle objectAtIndex:0] valueForKey:@"alarm_id"];
    }
    else
    {
        strAlD =[[arrTitle objectAtIndex:1] valueForKey:@"alarm_id"];
    }
    NSMutableArray * tmpArry = [[NSMutableArray alloc]init];
    NSString * strQuery = [NSString stringWithFormat:@"select * from Socket_Alarm_Table where ble_address = '%@' and alarm_id = '%@'",strMacaddress,strAlD];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:tmpArry];
    
    if ([tmpArry count] > 0)
    {
        if (sender.tag == 900)
        {
            NSString * strAlID = [[arrTitle objectAtIndex:0] valueForKey:@"alarm_id"];
            NSInteger intPacket = [strAlID integerValue];
            NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
            [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"12" withLength:@"01" withPeripheral:periphPass];
            selectedAlarmIndex = 0;

        }
        else if (sender.tag == 901)
        {
            NSString * strAlID = [[arrTitle objectAtIndex:1] valueForKey:@"alarm_id"];
            NSInteger intPacket = [strAlID integerValue];
            NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
            [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"12" withLength:@"01" withPeripheral:periphPass];
            selectedAlarmIndex = 1;
        }
    }
    else
    {
        [self AlertViewFCTypeCautionCheck:@"No alarm set."];
    }

}
-(void)btnSaveClick
{
    int alarm1Check = [self getStatusOfSavedAlarm:0];
    int alarm2Check = [self getStatusOfSavedAlarm:1];

    if (alarm1Check == 0 && alarm2Check == 0)
    {
        //both are empty, show error that select time 
        [self AlertViewFCTypeCautionCheck:@"Please select ON and OFF time"];
    }
    else
    {
        NSString * strRepated1 = [self checkforValidString:[[ arrTitle objectAtIndex:0] valueForKey:@"isExpanded"]];
        NSString * strRepated2 = [self checkforValidString:[[ arrTitle objectAtIndex:1] valueForKey:@"isExpanded"]];

        
        
    }
     if(alarm1Check == 2 && alarm2Check == 2)
    {
        //both are OK save it
        selectedAlarmIndex = 0;
        [self SendAlarmtoDevice:0];
//        [self performSelector:@selector(SendSecondAlarmAfterSomeDelay) withObject:nil afterDelay:2];

    }
    else if(alarm1Check == 2)
    {
        selectedAlarmIndex = 0;
        [self SendAlarmtoDevice:0];

    }
    else if(alarm2Check == 2)
    {
        selectedAlarmIndex = 1;
        [self SendAlarmtoDevice:1];
    }
}
-(void)btnRepeateClick:sender
{
    if ([[[arrTitle objectAtIndex:[sender tag]] valueForKey:@"isExpanded"] isEqualToString:@"1"])
    {
        [[arrTitle objectAtIndex:[sender tag]] setValue:@"0" forKey:@"isExpanded"];
    }
    else
    {
        [[arrTitle objectAtIndex:[sender tag]] setValue:@"1" forKey:@"isExpanded"];
    }
    
    [tblAlarms reloadData];
}
-(void)SendSecondAlarmAfterSomeDelay
{
    [self SendAlarmtoDevice:1];
}
-(int)getStatusOfSavedAlarm:(int)indexx //0 : Both NA, 1 : Any one NA, 2: Both OK
{
    int totalCount = 0;
    if ([[[arrTitle objectAtIndex:indexx] valueForKey:@"OnTimestamp"] isEqualToString:@"NA"] &&  [[[arrTitle objectAtIndex:indexx] valueForKey:@"OffTimestamp"] isEqualToString:@"NA"])
    {
        return  0;
    }
    else if ([[[arrTitle objectAtIndex:indexx] valueForKey:@"OnTimestamp"] isEqualToString:@"NA"] ||  [[[arrTitle objectAtIndex:indexx] valueForKey:@"OffTimestamp"] isEqualToString:@"NA"])
    {
        return 1;
    }
    else
    {
        NSMutableDictionary * dayDict = [[NSMutableDictionary alloc] init];
        
        dayDict = [arrTitle objectAtIndex:indexx];

        NSArray * countsArr = [NSArray arrayWithObjects:@"1",@"2",@"4",@"8",@"16",@"32",@"64", nil]; // 127 all days selected
        
        int correctValue = 200;
        
        if (indexx == 1)
        {
            correctValue = 300;
        }
        for (int j=0; j<[countsArr count]; j++)
        {
            NSString * strStatus = [dayDict valueForKey:[NSString stringWithFormat:@"%d", correctValue + j]];//
            if ([strStatus isEqualToString:@"1"])
            {
                totalCount = totalCount + [[countsArr objectAtIndex:j] intValue];
//                totalCount = totalDayCount;
            }
        }
        [dayDict setValue:[NSString stringWithFormat:@"%d",totalCount] forKey:@"totalCount"];
        [arrTitle replaceObjectAtIndex:indexx withObject:dayDict];
        return 2;
    }
}

-(void)AlertViewFCTypeCautionCheck:(NSString *)strMsg
{
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
-(void)SendAlarmtoDevice:(int)selectedIndex
{
    NSString * strAlarmType = @"Alarm 1";
    NSString * strMsg = @"";
    if (selectedIndex == 1)
    {
        strAlarmType = @"Alarm 2";
    }
    
    if ([[[arrTitle objectAtIndex:selectedIndex] valueForKey:@"totalCount"] isEqual:@"0"])
    {
        [self AlertViewFCTypeCautionCheck:[NSString stringWithFormat:@"Please select day for %@.",strAlarmType]];
        return;
    }
    
    NSString * strOnTimestamp = [self checkforValidString:[[arrTitle objectAtIndex:selectedIndex] valueForKey:@"On_original"]];
    NSString * strOFFTimestamp = [self checkforValidString:[[arrTitle objectAtIndex:selectedIndex] valueForKey:@"Off_original"]];
    
    NSString *time1 = strOnTimestamp;
    NSString *time2 = strOFFTimestamp;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm a"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];

    NSDate *date1= [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];

    NSComparisonResult result = [date1 compare:date2];

    BOOL isDateCorrect = YES;
    if(result == NSOrderedSame)
    {
        isDateCorrect = NO;
        strMsg = [NSString stringWithFormat:@"%@'s On Time and Off Time should not be same.",strAlarmType];
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
        
        NSInteger strSktID = intSelectedSwitch ; // - 1
        NSData * dataSocketID = [[NSData alloc] initWithBytes:&strSktID length:1]; // switch index
        [arrTitle setValue:[NSString stringWithFormat:@"%ld",(long)intSelectedSwitch] forKey:@"socket_id"];
        
        NSInteger strDayID = 0;
        strDayID = [[[arrTitle objectAtIndex:selectedIndex] valueForKey:@"totalCount"] intValue];
        
       
        NSData * dataDaytID = [[NSData alloc] initWithBytes:&strDayID length:1];
        
        NSInteger totallength = -1;
        NSData * dataStartTime  = [[NSData alloc] initWithBytes:&totallength length:4];

        if (![strOnTimestamp isEqualToString:@"NA"])
        {
            double  intStartTime = [[[arrTitle objectAtIndex:selectedIndex] valueForKey:@"OnTimestamp"] doubleValue];//1611663180; //  ON timestap
            NSString *decStr = [NSString stringWithFormat:@"%f",intStartTime];
            NSString *hexStr = [NSString stringWithFormat:@"%llX", (long long)[decStr integerValue]];
            NSString * strDate = hexStr;
            dataStartTime = [self dataFromHexString:strDate];
        }
        
        
        
        NSData * dataEndTime = [[NSData alloc] initWithBytes:&totallength length:4];
        if (![strOFFTimestamp isEqualToString:@"NA"])
        {
             double intEndTime = [[[arrTitle objectAtIndex:selectedIndex] valueForKey:@"OffTimestamp"] doubleValue];//1611663180; //  ON timestap
             NSString * decStr = [NSString stringWithFormat:@"%f",intEndTime];
             NSString * hexStr = [NSString stringWithFormat:@"%llX", (long long)[decStr integerValue]];
             NSString * strDate = hexStr;
            dataEndTime = [self dataFromHexString:strDate];
        }


        
        NSMutableData *completeData = [dataAlarmID mutableCopy];
        [completeData appendData:dataSocketID];
        [completeData appendData:dataDaytID];
        [completeData appendData:dataStartTime];
        [completeData appendData:dataEndTime];

        NSString * StrData = [NSString stringWithFormat:@"%@",completeData];
        StrData = [StrData stringByReplacingOccurrencesOfString:@" " withString:@""];
        StrData = [StrData stringByReplacingOccurrencesOfString:@"<" withString:@""];
        StrData = [StrData stringByReplacingOccurrencesOfString:@">" withString:@""];

        NSLog(@"Alram Compleate Data =====>>>>>%@",completeData);
        [[BLEService sharedInstance] WriteSocketData:completeData withOpcode:@"11" withLength:@"11" withPeripheral:periphPass];// 0b0b01017fOntimeOfftim

    }
}
-(void)InsertAndUpdateTheAlaramTable:(NSDictionary *)dictData
{
    NSString * strAlarmId = [self stringFroHex:[dictData valueForKey:@"alarm_id"]];
    NSString * strsocketID = [dictData valueForKey:@"socket_id"];
    NSString * strdayValue = [dictData valueForKey:@"totalCount"];
    NSString * strOnTime =  [dictData valueForKey:@"OnTimestamp"];
    NSString * strOffTime = [dictData valueForKey:@"OffTimestamp"];
    NSString * stralarmState = @"1";
    NSString * strONoriginal = [dictData valueForKey:@"On_original"];
    NSString * strOffOriginal = [dictData valueForKey:@"Off_original"];
    NSString * strDaySelected = @"NA";
    
    
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

        NSString * update = [NSString stringWithFormat:@"update Socket_Alarm_Table set alarm_id = '%@', socket_id ='%@',day_value='%@', OnTimestamp ='%@', OffTimestamp = '%@', On_original = '%@', Off_original = '%@', alarm_state = '%@',  day_selected = '%@' where ble_address = '%@' and alarm_id = '%@'",strAlarmId,strsocketID,strdayValue,strOnTime,strOffTime,strONoriginal,strOffOriginal,stralarmState,strDayStatus,strMacaddress,strAlarmId];
        [[DataBaseManager dataBaseManager] execute:update];
    }
    else
    {
        NSString * strInsert  =[NSString stringWithFormat:@"insert into 'Socket_Alarm_Table'('alarm_id','socket_id','day_value','OnTimestamp','OffTimestamp','On_original','Off_original','alarm_state','ble_address','day_selected') values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",strAlarmId,strsocketID,strdayValue,strOnTime,strOffTime,strONoriginal,strOffOriginal,stralarmState,strMacaddress,strDayStatus];
        [[DataBaseManager dataBaseManager] executeSw:strInsert];
    }
}
-(void)ALaramSuccessResponseFromDevie
{
    if ([arrTitle count] > selectedAlarmIndex)
    {
        [self InsertAndUpdateTheAlaramTable:[arrTitle objectAtIndex:selectedAlarmIndex]];
    }
    
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
        int alarm2Check = [self getStatusOfSavedAlarm:1];
        if (alarm2Check == 2)
        {
            selectedAlarmIndex = 1;
            [self SendAlarmtoDevice:1];
        }
        else
        {
            //show successpopup saying alarm saved
            dispatch_async(dispatch_get_main_queue(), ^{
                [APP_DELEGATE endHudProcess];
                [self AlertViewFCTypeSuccess:[NSString stringWithFormat:@"Alarm set for socket %ld succcessfully",(long)self->intSelectedSwitch]];
            });
        }
    }
}
-(void)DeleteAlarmConfirmFromDevice:(NSMutableDictionary *)dictDeleteCofirmID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[dictDeleteCofirmID  valueForKey:@"deleteSate"] isEqual:@"01"])
        {
            [self AlertViewFCTypeSuccess:@"Alarm deleted sucessfully..."];
            NSString * strALid = [dictDeleteCofirmID valueForKey:@"alarm_id"];
            NSInteger inrval = [strALid integerValue];
            [self DeleteAlarmInDatabase:inrval];
            
            if ([arrTitle count] > selectedAlarmIndex)
            {
                [[arrTitle objectAtIndex:selectedAlarmIndex] setValue:@"NA" forKey:@"On_original"];
                [[arrTitle objectAtIndex:selectedAlarmIndex] setValue:@"NA" forKey:@"Off_original"];
                [[arrTitle objectAtIndex:selectedAlarmIndex] setValue:@"NA" forKey:@"OnTimeStamp"];
                [[arrTitle objectAtIndex:selectedAlarmIndex] setValue:@"NA" forKey:@"OffTimestamp"];
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
-(void)DeleteAlarmInDatabase:(NSInteger)strAlaramID
{
    NSString * deleteQuery =[NSString stringWithFormat:@"delete from Socket_Alarm_Table where ble_address = '%@' and alarm_id = '%ld'",strMacaddress,(long)strAlaramID];
    [[DataBaseManager dataBaseManager] execute:deleteQuery];
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

@end
