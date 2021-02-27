//
//  AlarmDetailVC.m
//  SmartLightApp
//
//  Created by stuart watts on 28/05/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "AlarmDetailVC.h"
#import "MIRadioButtonGroup.h"
#import "HistoryCell.h"
#import "AlarmColorSelectVC.h"


@interface AlarmDetailVC ()<FCAlertViewDelegate>
{
    NSMutableArray * dayArr, * tmpArray;
    NSInteger totalDayCount, hours, minutes, sentCount;
    int tblY;
    BOOL isOnPower;
    NSString * strTimeSelected;
    int totalSyncedCount;
}
@end

@implementation AlarmDetailVC
@synthesize isFromEdit,detailDict,strIndex;
- (void)viewDidLoad
{

    
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    self.view.backgroundColor = [UIColor blackColor];

    tmpArray = [[NSMutableArray alloc] init];
    arrDevices = [[NSMutableArray alloc] init];
    NSString * strQuery = [NSString stringWithFormat:@"Select * from Device_Table where user_id ='%@' and status = '1' group by ble_address",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:arrDevices];
    [arrDevices setValue:@"No" forKey:@"isSelected"];

    alarmRed = 255;
    alarmGreen = 255;
    alarmBlue = 255;

    dayArr = [[NSMutableArray alloc] init];
    
    NSArray * dateArr = [NSArray arrayWithObjects:@"S",@"M",@"T",@"W",@"T",@"F",@"S", nil];
    NSArray * weekArr = [NSArray arrayWithObjects:@"SUN",@"MON",@"TUE",@"WED",@"THU",@"FRI",@"SAT", nil];

    NSArray * countsArr = [NSArray arrayWithObjects:@"1",@"2",@"4",@"8",@"16",@"32",@"64", nil];
    
    for (int i=0; i<[dateArr count]; i++)
    {
        NSMutableDictionary * dayDict = [[NSMutableDictionary alloc] init];
        NSString * strDay = [dateArr objectAtIndex:i];
        [dayDict setObject:strDay forKey:@"day"];
        [dayDict setObject:@"1" forKey:@"isOff"];
        [dayDict setObject:[NSString stringWithFormat:@"%d",i] forKey:@"tag"];
        [dayDict setObject:[countsArr objectAtIndex:i] forKey:@"counts"];
        [dayDict setObject:[weekArr objectAtIndex:i] forKey:@"dayname"];

        [dayArr addObject:dayDict];
    }
    
    if (isFromEdit)
    {
        NSString * strTmpDays = [detailDict valueForKey:@"alarm_days"];
        NSArray * arrss = [strTmpDays componentsSeparatedByString:@","];
        for (int i=0; i<[arrss count]; i++)
        {
            for (int j=0; j<[dayArr count]; j++)
            {
                if ([[arrss objectAtIndex:i] isEqualToString:[[dayArr objectAtIndex:j]valueForKey:@"counts"]])
                {
                    [[dayArr objectAtIndex:j] setObject:@"0" forKey:@"isOff"];
                }
            }
        }
        
        strHexAlarmColor = [detailDict valueForKey:@"alarm_color"];
        
        NSMutableArray * arrSelectedTmp = [[NSMutableArray alloc] init];
        NSString * strMain = [NSString stringWithFormat:@"Select * from Alarm_devices where user_id ='%@' and alarm_id = '%@' and status = '1' ",CURRENT_USER_ID,[detailDict valueForKey:@"id"]];
        [[DataBaseManager dataBaseManager] execute:strMain resultsArray:arrSelectedTmp];

        for (int i=0; i<[arrSelectedTmp count]; i++)
        {
            for (int j=0; j<[arrDevices count]; j++)
            {
                if ([[[arrSelectedTmp objectAtIndex:i]valueForKey:@"device_id"] isEqualToString:[[arrDevices objectAtIndex:j]valueForKey:@"device_id"]])
                {
                    [[arrDevices objectAtIndex:j] setObject:@"Yes" forKey:@"isSelected"];
                    [[arrDevices objectAtIndex:j] setObject:@"added" forKey:@"UpdatedStatus"];

                }
            }
        }
    }
    else
    {
        [dayArr setValue:@"0" forKey:@"isOff"];
        strHexAlarmColor = [NSString stringWithFormat:@"#%02lX%02lX%02lX",
                            lroundf(1 * 255),
                            lroundf(1 * 255),
                            lroundf(1 * 255)];
    }

    [self setNavigationViewFrames];

    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{

    
    isNonConnectScanning = YES;
    
    [self InitialBLE];
    [APP_DELEGATE hideTabBar:self.tabBarController];
    currentScreen = @"AlarmDetail";
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetAlarmColors" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetAlarmColors:) name:@"GetAlarmColors" object:nil];
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    self.view.backgroundColor = [UIColor colorWithRed:19/255.0 green:24/255.0 blue:27/255.0 alpha:1.0];
    
    headerhHeight = 64;
    if (IS_IPHONE_X)
    {
        headerhHeight = 88;
    }
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, headerhHeight)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, headerhHeight)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.5;
    [viewHeader addSubview:lblBack];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Set Alarm"];
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
    [btnSave.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [btnSave addTarget:self action:@selector(btnSaveClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnSave];
    
    /*statusImg = [[UIImageView alloc] init];
    statusImg.image = [UIImage imageNamed:@"Connected_icon.png"];
    statusImg.frame = CGRectMake(DEVICE_WIDTH-36, 11+20, 12, 22);
    //    [viewHeader addSubview:statusImg];
    if (globalConnStatus)
    {
        statusImg.image = [UIImage imageNamed:@"Connected_icon.png"];
    }
    else
    {
        statusImg.image = [UIImage imageNamed:@"notconnect_icon.png"];
    }*/
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
-(void)setMainViewContentFrame:(int)yValue
{
    UILabel * lblSubHint = [[UILabel alloc] initWithFrame:CGRectZero];
    lblSubHint.backgroundColor = [UIColor clearColor];
    lblSubHint.frame=CGRectMake(0,yValue, DEVICE_WIDTH, 25);
    lblSubHint.font = [UIFont systemFontOfSize:14];
    lblSubHint.textAlignment = NSTextAlignmentCenter;
    [lblSubHint setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    lblSubHint.textColor = [UIColor whiteColor]; // change this color
    lblSubHint.text = @"Tap on time to change";
    [self.view addSubview:lblSubHint];
    
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm a"];
    NSString * strCurrentTime = [dateFormat stringFromDate:[NSDate date]];
    if (isFromEdit)
    {
        strCurrentTime = [detailDict valueForKey:@"alarm_time"];
        NSDate * tmpDate = [dateFormat dateFromString:strCurrentTime];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:tmpDate];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];
        hours = hour;
        minutes = minute;
    }
    strTimeSelected = strCurrentTime;

    lblTime = [[UILabel alloc] initWithFrame:CGRectZero];
    lblTime.backgroundColor = [UIColor clearColor];
    lblTime.frame=CGRectMake(0, yValue+10, DEVICE_WIDTH, 70);
    lblTime.textAlignment = NSTextAlignmentCenter;
    [lblTime setFont:[UIFont fontWithName:CGBold size:textSizes+15]];
    lblTime.textColor = [UIColor whiteColor]; // change this color
    lblTime.text = strCurrentTime;
    [self.view addSubview:lblTime];
    
    UIButton * btnTimes = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTimes.frame = CGRectMake(0, yValue, DEVICE_WIDTH, 65);
    [btnTimes addTarget:self action:@selector(btnTimerSelect) forControlEvents:UIControlEventTouchUpInside];
    btnTimes.backgroundColor = [UIColor clearColor];
    [self.view addSubview:btnTimes];
    
    UIView * dayView = [[UIView alloc] init];
    dayView.frame = CGRectMake(0, yValue+70, DEVICE_WIDTH, 70);
    [self.view addSubview:dayView];

    int wh = DEVICE_WIDTH/7;

    for (int i=0; i<7; i++)
    {
        UILabel * lblBack = [[UILabel alloc] init];
        lblBack.frame = CGRectMake(i*wh, 0, wh, wh);
        lblBack.userInteractionEnabled = YES;
        [dayView addSubview:lblBack];
        
        if (i==0)
        {
            btn0  = [UIButton buttonWithType:UIButtonTypeCustom];
            btn0.tag = i;
            [btn0 setTitle:@"S" forState:UIControlStateNormal];
            [self setButtonContent:btn0 withTag:i];
            [lblBack addSubview:btn0];
        }
        else if (i==1)
        {
            btn1  = [UIButton buttonWithType:UIButtonTypeCustom];
            btn1.tag = i;
            [btn1 setTitle:@"M" forState:UIControlStateNormal];
            [self setButtonContent:btn1 withTag:i];
            [lblBack addSubview:btn1];
        }
        else if (i==2)
        {
            btn2  = [UIButton buttonWithType:UIButtonTypeCustom];
            btn2.tag = i;
            [btn2 setTitle:@"T" forState:UIControlStateNormal];
            [self setButtonContent:btn2 withTag:i];
            [lblBack addSubview:btn2];
        }
        else if (i==3)
        {
            btn3  = [UIButton buttonWithType:UIButtonTypeCustom];
            btn3.tag = i;
            [btn3 setTitle:@"W" forState:UIControlStateNormal];
            [self setButtonContent:btn3 withTag:i];
            [lblBack addSubview:btn3];
        }
        else if (i==4)
        {
            btn4  = [UIButton buttonWithType:UIButtonTypeCustom];
            btn4.tag = i;
            [btn4 setTitle:@"T" forState:UIControlStateNormal];
            [self setButtonContent:btn4 withTag:i];
            [lblBack addSubview:btn4];
        }
        else if (i==5)
        {
            btn5  = [UIButton buttonWithType:UIButtonTypeCustom];
            btn5.tag = i;
            [btn5 setTitle:@"F" forState:UIControlStateNormal];
            [self setButtonContent:btn5 withTag:i];
            [lblBack addSubview:btn5];
        }
        else if (i==6)
        {
            btn6  = [UIButton buttonWithType:UIButtonTypeCustom];
            btn6.tag = i;
            [btn6 setTitle:@"S" forState:UIControlStateNormal];
            [self setButtonContent:btn6 withTag:i];
            [lblBack addSubview:btn6];
        }
    }
    
    [self setPowerView:yValue];
    
    yValue = yValue +130+ 40;
    [self setColorView:yValue];
    
    [self TurnOffView];
    
    yValue = yValue + 40 + 10;
    [self setTableview:yValue];
}
-(void)setPowerView:(int)yValue
{
    UILabel * lblOffBack = [[UILabel alloc] init];
    lblOffBack.backgroundColor = [UIColor blackColor];
    lblOffBack.alpha = 0.5;
    lblOffBack.frame =CGRectMake(0, yValue+130, DEVICE_WIDTH, 40);
    [self.view addSubview:lblOffBack];
    
    UILabel * lblInfo = [[UILabel alloc] init];
    lblInfo.frame = CGRectMake(10, yValue+125, DEVICE_WIDTH, 50);
    lblInfo.text = @"Power State";
    lblInfo.font = [UIFont fontWithName:CGRegular size:textSizes];
    lblInfo.textColor = [UIColor whiteColor];
    [self.view addSubview:lblInfo];
    
    btnON = [UIButton buttonWithType:UIButtonTypeCustom];
    btnON.frame = CGRectMake(DEVICE_WIDTH/2, yValue+125, 70, 50);
    btnON.backgroundColor = [UIColor clearColor];
    [btnON setTitle:@" ON" forState:UIControlStateNormal];
    [btnON setImage:[UIImage imageNamed:@"RadioON.png"] forState:UIControlStateNormal];
    btnON.tag = 121;
    btnON.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes];
    [btnON addTarget:self action:@selector(btnOnOffClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnON];
    
    btnOFF = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOFF.frame = CGRectMake((DEVICE_WIDTH/2) + 80, yValue+125, 70, 50);
    btnOFF.backgroundColor = [UIColor clearColor];
    [btnOFF setTitle:@" OFF" forState:UIControlStateNormal];
    btnOFF.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes];
    [btnOFF setImage:[UIImage imageNamed:@"RadioOff.png"] forState:UIControlStateNormal];
    btnOFF.tag = 122;
    [btnOFF addTarget:self action:@selector(btnOnOffClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnOFF];
    
}

-(void)setColorView:(int)yValue
{
    colorView = [[UIView alloc] init];
    colorView.frame = CGRectMake(0, yValue+5, DEVICE_WIDTH, 50);
    [self.view addSubview:colorView];
    
    UILabel * lblOffBack = [[UILabel alloc] init];
    lblOffBack.backgroundColor = [UIColor blackColor];
    lblOffBack.alpha = 0.5;
    lblOffBack.frame =CGRectMake(0, 5, DEVICE_WIDTH, 40);
    [colorView addSubview:lblOffBack];
    
    UILabel * lblInfo = [[UILabel alloc] init];
    lblInfo.frame = CGRectMake(10, 0, DEVICE_WIDTH, 50);
    lblInfo.text = @"Choose color :";
    lblInfo.font = [UIFont fontWithName:CGRegular size:textSizes];
    lblInfo.textColor = [UIColor whiteColor];
    lblInfo.userInteractionEnabled = YES;
    [colorView addSubview:lblInfo];
    
    lblSelecColor = [[UILabel alloc] init];
    lblSelecColor.backgroundColor = [UIColor whiteColor];
    lblSelecColor.frame = CGRectMake(DEVICE_WIDTH-60, 13, 24, 24);
    lblSelecColor.layer.masksToBounds = YES;
    lblSelecColor.layer.cornerRadius = 12;
    [lblInfo addSubview:lblSelecColor];
    
    UIImageView * imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-30, 15, 13, 20)];
    [imgArrow setImage:[UIImage imageNamed:@"right_gray_arrow.png"]];
    [lblInfo addSubview:imgArrow];
    
    UIButton * btnColor = [UIButton buttonWithType:UIButtonTypeCustom];
    btnColor.frame = CGRectMake(0, 0, DEVICE_WIDTH, 50);
    [btnColor addTarget:self action:@selector(btnColorSelect) forControlEvents:UIControlEventTouchUpInside];
    [lblInfo addSubview:btnColor];
    isOnPower = YES;
    

    if (isFromEdit)
    {
        if ([[detailDict valueForKey:@"isOn"] isEqualToString:@"1"])
        {
            [btnON setImage:[UIImage imageNamed:@"RadioON.png"] forState:UIControlStateNormal];
            [btnOFF setImage:[UIImage imageNamed:@"RadioOff.png"] forState:UIControlStateNormal];
            UIColor * rgbColor = [self colorWithHexString:[detailDict valueForKey:@"alarm_color"]];
            lblSelecColor.backgroundColor = rgbColor;
            
            const  CGFloat *_components = CGColorGetComponents(rgbColor.CGColor);
            CGFloat red   = _components[0];
            CGFloat green = _components[1];
            CGFloat blue   = _components[2];
            
            alarmRed = red * 255;
            alarmGreen = green * 255;
            alarmBlue = blue * 255;
        }
        else
        {
            [btnON setImage:[UIImage imageNamed:@"RadioOff.png"] forState:UIControlStateNormal];
            [btnOFF setImage:[UIImage imageNamed:@"RadioON.png"] forState:UIControlStateNormal];
            alarmRed = 0; alarmGreen = 0; alarmBlue = 0;
            isOnPower = NO;
            
//            [btnON setImage:[UIImage imageNamed:@" "] forState:UIControlStateNormal];
//            [btnOFF setImage:[UIImage imageNamed:@"refresh_icon.png"] forState:UIControlStateNormal];
            
            colorView.hidden = YES;
            tblView.frame = CGRectMake(0,tblY-50+60,DEVICE_WIDTH,DEVICE_HEIGHT-tblY-50-60);
        }
    }
}
-(void)TurnOffView
{
    turnOffView = [[UIView alloc]init];
  //  turnOffView.frame = CGRectMake(0, yValue+5, DEVICE_WIDTH, 50);
    turnOffView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:turnOffView];
    
    if (isOnPower)
    {
        turnOffView.frame = CGRectMake(0, colorView.frame.origin.y+colorView.frame.size.height,DEVICE_WIDTH, 50);
    }
    else
    {
        turnOffView.frame = CGRectMake(0,colorView.frame.origin.y, DEVICE_WIDTH, 50);
    }
    UILabel * lblOffBack3 = [[UILabel alloc] init];
    lblOffBack3.backgroundColor = [UIColor blackColor];
    lblOffBack3.alpha = 0.5;
    lblOffBack3.frame =CGRectMake(0, 5, DEVICE_WIDTH, 40);
    lblOffBack3.userInteractionEnabled = YES;
    [turnOffView addSubview:lblOffBack3];
    
    
    lblSlowTurnOff = [[UILabel alloc] init];
    lblSlowTurnOff.frame = CGRectMake(10,0,DEVICE_WIDTH-20, 50);
    lblSlowTurnOff.text = @"Slow Wake Up?";
    lblSlowTurnOff.font = [UIFont fontWithName:CGRegular size:textSizes];
    lblSlowTurnOff.textColor = [UIColor whiteColor];
    lblSlowTurnOff.userInteractionEnabled = YES;
    [turnOffView addSubview:lblSlowTurnOff];
    
    imgCheckBox2 = [[UIImageView alloc] initWithFrame:CGRectMake(lblSlowTurnOff.frame.size.width-30, 13, 24, 24)];
    [imgCheckBox2 setImage:[UIImage imageNamed:@"checkEmpty.png"]];
    imgCheckBox2.userInteractionEnabled = true;
    [lblSlowTurnOff addSubview:imgCheckBox2];
    
    UIButton *btnSlowTurnOff = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSlowTurnOff.frame = CGRectMake(0,0,lblSlowTurnOff.frame.size.width,50);
    btnSlowTurnOff.backgroundColor = UIColor.clearColor;
    [btnSlowTurnOff addTarget:self action:@selector(btnSlowTurnOffAction) forControlEvents:UIControlEventTouchUpInside];
    [lblSlowTurnOff addSubview:btnSlowTurnOff];
    
    if (isFromEdit)
    {
        if ([[detailDict valueForKey:@"isWakeUp"]isEqualToString:@"1"])
        {
            isWakeUpClicked = true;
            [imgCheckBox2 setImage:[UIImage imageNamed:@"checked.png"]];
        }
        else
        {
            isWakeUpClicked = false;
            [imgCheckBox2 setImage:[UIImage imageNamed:@"checkEmpty.png"]];
        }
    }
}
-(void)btnSlowTurnOffAction
{
    if (isWakeUpClicked == false)
    {
        isWakeUpClicked = true;
        [imgCheckBox2 setImage:[UIImage imageNamed:@"checked.png"]];
    }
    else
    {
        isWakeUpClicked = false;
        [imgCheckBox2 setImage:[UIImage imageNamed:@"checkEmpty.png"]];
    }
}
-(void)setTableview:(int)yValue
{
    [tblView removeFromSuperview];
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(0,yValue+60,DEVICE_WIDTH,DEVICE_HEIGHT-yValue-60) style:UITableViewStylePlain];
    tblView.delegate = self;
    tblView.dataSource = self;
//    tblView.scrollEnabled = false;
    tblView.backgroundColor = [UIColor clearColor];
    tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblView.tableFooterView = [UIView new];
    [self.view addSubview:tblView];
    
    if (IS_IPHONE_X)
    {
        tblView.frame = CGRectMake(0, yValue+60, DEVICE_WIDTH, DEVICE_HEIGHT-yValue-45-60);
    }
    tblY = yValue;
    if (isFromEdit)
    {
        if ([[detailDict valueForKey:@"isOn"] isEqualToString:@"0"])
        {
            tblView.frame = CGRectMake(0,tblY-50+60,DEVICE_WIDTH,DEVICE_HEIGHT-tblY-50-60);
        }
    }
}
-(void)setButtonContent:(UIButton *)btn withTag:(int)btnTag
{
    btn.layer.masksToBounds = YES;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.layer.borderWidth=1.0;
    [btn addTarget:self action:@selector(btnDayClick:) forControlEvents:UIControlEventTouchUpInside];
    
    int wh = (DEVICE_WIDTH/7)-10;
    btn.frame = CGRectMake(5, 5, wh, wh);
    btn.layer.cornerRadius = wh/2;
    btn.backgroundColor = [UIColor whiteColor];
    btn.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes-2];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    if ([[[dayArr objectAtIndex:btnTag] valueForKey:@"isOff"] isEqualToString:@"1"])
    {
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else
    {
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}
-(void)btnDayClick:(id)sender
{
    UIColor * backColor, * txtColor;
    if ([[[dayArr objectAtIndex:[sender tag]] valueForKey:@"isOff"] isEqualToString:@"0"])
    {
        backColor = [UIColor clearColor];
        txtColor = [UIColor whiteColor];
        [[dayArr objectAtIndex:[sender tag]] setObject:@"1" forKey:@"isOff"];
    }
    else
    {
        backColor = [UIColor whiteColor];
        txtColor = [UIColor blackColor];
        [[dayArr objectAtIndex:[sender tag]] setObject:@"0" forKey:@"isOff"];
    }
    
    
    if ([sender tag]==0)
    {
        btn0.backgroundColor = backColor;
        [btn0 setTitleColor:txtColor forState:UIControlStateNormal];
    }
    else if ([sender tag]==1)
    {
        btn1.backgroundColor = backColor;
        [btn1 setTitleColor:txtColor forState:UIControlStateNormal];
    }
    else if ([sender tag]==2)
    {
        btn2.backgroundColor = backColor;
        [btn2 setTitleColor:txtColor forState:UIControlStateNormal];
    }
    else if ([sender tag]==3)
    {
        btn3.backgroundColor = backColor;
        [btn3 setTitleColor:txtColor forState:UIControlStateNormal];
    }
    else if ([sender tag]==4)
    {
        btn4.backgroundColor = backColor;
        [btn4 setTitleColor:txtColor forState:UIControlStateNormal];
    }
    else if ([sender tag]==5)
    {
        btn5.backgroundColor = backColor;
        [btn5 setTitleColor:txtColor forState:UIControlStateNormal];
    }
    else if ([sender tag]==6)
    {
        btn6.backgroundColor = backColor;
        [btn6 setTitleColor:txtColor forState:UIControlStateNormal];
    }
}
-(void)btnOnOffClick:(id)sender
{
    if ([sender tag]==121)
    {
        alarmRed = 255; alarmGreen = 255; alarmBlue = 255;
        [btnON setImage:[UIImage imageNamed:@"RadioON.png"] forState:UIControlStateNormal];
        [btnOFF setImage:[UIImage imageNamed:@"RadioOff.png"] forState:UIControlStateNormal];
        
        colorView.hidden = NO;
        isOnPower = YES;
        turnOffView.frame = CGRectMake(0, colorView.frame.origin.y+colorView.frame.size.height,DEVICE_WIDTH, 50);
        lblSlowTurnOff.text = @"Slow Wake Up?";
        tblView.frame = CGRectMake(0,tblY+60,DEVICE_WIDTH,DEVICE_HEIGHT-tblY-60);
    }
    else if ([sender tag]==122)
    {
        alarmRed = 0; alarmGreen = 0; alarmBlue = 0;
        isOnPower = NO;

        [btnON setImage:[UIImage imageNamed:@"RadioOff.png"] forState:UIControlStateNormal];
        [btnOFF setImage:[UIImage imageNamed:@"RadioON.png"] forState:UIControlStateNormal];
        
        colorView.hidden = YES;
        lblSlowTurnOff.text = @"Slow Turn Off?";
        turnOffView.frame = CGRectMake(0, colorView.frame.origin.y,DEVICE_WIDTH, 50);
        tblView.frame = CGRectMake(0,tblY-50+60,DEVICE_WIDTH,DEVICE_HEIGHT-tblY+50-60);
    }
}

-(void)btnColorSelect
{
    AlarmColorSelectVC  * alarmColor = [[AlarmColorSelectVC alloc] init];
    alarmColor.isFromAlarm = YES;
    alarmColor.isFromEdit = isFromEdit;
    [self.navigationController pushViewController:alarmColor animated:YES];
}
-(void)btnBackClick
{
    isNonConnectScanning = NO;
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)btnTimerSelect
{
    [timeBackView removeFromSuperview];
    timeBackView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 250)];
    [timeBackView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:timeBackView];
    
    [datePicker removeFromSuperview];
    datePicker = nil;
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 34, DEVICE_WIDTH, 216)];
    [datePicker setBackgroundColor:[UIColor clearColor]];
    datePicker.tag=124;
    datePicker.datePickerMode=UIDatePickerModeTime;
    datePicker.timeZone = [NSTimeZone localTimeZone];
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [timeBackView addSubview:datePicker];
    
    UIButton * btnDone2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone2 setFrame:CGRectMake(0 , 0, DEVICE_WIDTH, 44)];
    [btnDone2 setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDone2 setTag:124];
    btnDone2.backgroundColor = global_brown_color;
    btnDone2.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes];
    [btnDone2 addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    [timeBackView addSubview:btnDone2];
    
    [self ShowPicker:YES andView:timeBackView];
}
- (void)dateChanged:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:datePicker.date];
    lblTime.text = currentTime;
}
-(void)btnSaveClick
{
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        BOOL isAny = NO;
        sentCount = 0;
        totalSyncedCount = 0;
        for (int i=0; i<[arrDevices count]; i++)
        {
            if ([[[arrDevices objectAtIndex:i] valueForKey:@"isSelected"] isEqualToString:@"Yes"])
            {
                isAny = YES;
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [arrDevices objectAtIndex:i];
                [tmpDict setObject:@"0" forKey:@"sent"];
                [tmpArray addObject:tmpDict];
            }
        }
        if (isAny)
        {
            [APP_DELEGATE startHudProcess:@"Saving Alarm..."];
            for (int i=0; i<[dayArr count]; i++)
            {
                if ([[[dayArr objectAtIndex:i] valueForKey:@"isOff"] isEqualToString:@"0"])
                {
                    NSInteger dayIntCount = [[[dayArr objectAtIndex:i] valueForKey:@"counts"] integerValue];
                    totalDayCount = totalDayCount + dayIntCount;
                }
            }
            //        [self performSelector:@selector(timeOutCallMethod) withObject:nil afterDelay:[dayArr count]];
            [self sendDeviceonebyone];
        }
        else
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"Please select atleast one device to save Alarm."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
    else
    {
        [self ConnectionValidationPopup];
    }
}
#pragma mark - NSNotification Methods
-(void)GetAlarmColors:(NSNotification *)notify
{
    UIColor * rgbColor = [self colorWithHexString:strHexAlarmColor];
    lblSelecColor.backgroundColor = rgbColor;

//     UIColor * newColor = (UIColor*) notify.object;
//    lblSelecColor.backgroundColor = newColor;
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
-(void)btnDoneClicked:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:datePicker.date];
    lblTime.text = [NSString stringWithFormat:@"  %@",currentTime];
    strTimeSelected = currentTime;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:datePicker.date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    hours = hour;
    minutes = minute;
    [self ShowPicker:NO andView:timeBackView];
}
#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 30)];
    headerView.backgroundColor = [UIColor blackColor];
    
    UILabel *lblmenu=[[UILabel alloc]init];
    lblmenu.text = @"Select device to set for this routine";
    if ([arrDevices count]==0)
    {
        lblmenu.text = @"No device found";
    }
    [lblmenu setTextColor:[UIColor whiteColor]];
    [lblmenu setFont:[UIFont fontWithName:CGRegular size:textSizes-1]];
    lblmenu.frame = CGRectMake(10, 0, DEVICE_WIDTH, 30);
    [headerView addSubview:lblmenu];
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrDevices count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReuseActivityCell"];
    if (cell==nil)
    {
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ReuseActivityCell"];
    }
    
    int rowHeight = 50-4;
    
    cell.lblConnect.text = @"Add";
//    cell.lblAddress.hidden = NO;
//    cell.lblAddress.text = @"NA";
    cell.imgIcon.hidden = NO;
    
    cell.lblBack.frame = CGRectMake(7, 0,DEVICE_WIDTH-14,rowHeight);
    cell.imgIcon.frame = CGRectMake(7+10, (rowHeight-30)/2, 30, 30);
    cell.lblDeviceName.frame = CGRectMake(55, 7, DEVICE_WIDTH-70, 30);
//    cell.lblAddress.frame = CGRectMake(55, 22, DEVICE_WIDTH-70, 18);

    cell.lblDeviceName.font = [UIFont fontWithName:CGRegular size:textSizes+2];
//    cell.lblAddress.font = [UIFont fontWithName:CGRegular size:textSizes-2];
    [cell.lblConnect setFont:[UIFont fontWithName:CGRegular size:textSizes-2]];
    cell.lblConnect.frame = CGRectMake(DEVICE_WIDTH-60, 0, DEVICE_WIDTH-60, rowHeight);
    
        cell.lblDeviceName.text = [[arrDevices objectAtIndex:indexPath.row] valueForKey:@"device_name"];;
//        cell.lblAddress.text = [[[arrDevices objectAtIndex:indexPath.row] valueForKey:@"ble_address"] uppercaseString];
    
        if ([[[arrDevices objectAtIndex:indexPath.row] valueForKey:@"isSelected"]  isEqualToString:@"No"])
        {
            cell.lblConnect.text = @"Add";
            [cell.lblConnect setTextColor:[UIColor whiteColor]];
        }
        else
        {
            cell.lblConnect.text = @"Remove";
            [cell.lblConnect setTextColor:[UIColor redColor]];
            cell.lblConnect.frame = CGRectMake(DEVICE_WIDTH-80, 0, DEVICE_WIDTH-60, rowHeight);
        }
        
        NSString * strType = [[arrDevices objectAtIndex:indexPath.row] valueForKey:@"device_type"];
        if ([strType isEqualToString:@"1"])
        {
            cell.imgIcon.image = [UIImage imageNamed:@"default_pic.png"];
        }
        else if ([strType isEqualToString:@"2"])
        {
            cell.imgIcon.image = [UIImage imageNamed:@"default_pic.png"];
        }
        else if ([strType isEqualToString:@"3"])
        {
            cell.imgIcon.image = [UIImage imageNamed:@"default_switch_icon.png"];
        }
        else if ([strType isEqualToString:@"4"])
        {
            cell.imgIcon.image = [UIImage imageNamed:@"default_socket_icon.png"];
        }
        else if ([strType isEqualToString:@"5"])
        {
            cell.imgIcon.image = [UIImage imageNamed:@"default_fan_icon.png"];
        }
        else if ([strType isEqualToString:@"6"])
        {
            cell.imgIcon.image = [UIImage imageNamed:@"stripwhite.png"];
        }
        else if ([strType isEqualToString:@"7"])
        {
            cell.imgIcon.image = [UIImage imageNamed:@"default_lamp.png"];
        }
        else if ([strType isEqualToString:@"8"])
        {
            cell.imgIcon.image = [UIImage imageNamed:@"default_powerstrip_icon.png"];
        }
    cell.lblDeviceName.frame = CGRectMake(65, 7, 180, 30);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ([arrDevices count]>0)
    {
        if ([[[arrDevices objectAtIndex:indexPath.row] valueForKey:@"isSelected"]  isEqualToString:@"No"])
        {
            [[arrDevices objectAtIndex:indexPath.row] setValue:@"Yes" forKey:@"isSelected"];
            if ([[[arrDevices objectAtIndex:indexPath.row] valueForKey:@"UpdatedStatus"] isEqualToString:@"delete"])
            {
                [[arrDevices objectAtIndex:indexPath.row] setValue:@"added" forKey:@"UpdatedStatus"];
            }
            else
            {
                [[arrDevices objectAtIndex:indexPath.row] setValue:@"add" forKey:@"UpdatedStatus"];
            }
        }
        else
        {
            [[arrDevices objectAtIndex:indexPath.row] setValue:@"No" forKey:@"isSelected"];
            if ([[[arrDevices objectAtIndex:indexPath.row] valueForKey:@"UpdatedStatus"] isEqualToString:@"added"])
            {
                [[arrDevices objectAtIndex:indexPath.row] setValue:@"delete" forKey:@"UpdatedStatus"];
            }
        }
        
    }
    [tblView reloadData];
}

-(void)sendDeviceonebyone
{
    if ([tmpArray count]>sentCount)
    {
        if ([[[tmpArray objectAtIndex:sentCount] valueForKey:@"UpdatedStatus"] isEqualToString:@"delete"])
        {
            [self RemoveAlarmRequesttoBLE:[[tmpArray objectAtIndex:sentCount]valueForKey:@"device_id"]];
        }
        else
        {
            [self SendAlarmRequesttoBle:[[tmpArray objectAtIndex:sentCount]valueForKey:@"device_id"]];
        }
        sentCount = sentCount  + 1;
        [self performSelector:@selector(sendDeviceonebyone) withObject:nil afterDelay:1];
    }
    else
    {
        [self performSelector:@selector(CheckforSavedAlarms) withObject:nil afterDelay:1];
    }
}
-(void)CheckforSavedAlarms
{
    if (isFromEdit)
    {
        NSMutableArray * daysSelectArr = [[NSMutableArray alloc] init];
        NSMutableArray * daysNameArr = [[NSMutableArray alloc] init];
        
        for (int i=0; i<[dayArr count]; i++)
        {
            if ([[[dayArr objectAtIndex:i] valueForKey:@"isOff"] isEqualToString:@"0"])
            {
                [daysSelectArr addObject:[[dayArr objectAtIndex:i] valueForKey:@"counts"]];
                [daysNameArr addObject:[[dayArr objectAtIndex:i] valueForKey:@"dayname"]];
            }
        }
        
        NSString * strDaysCount = [daysSelectArr componentsJoinedByString:@","];
        NSString * strDayNames = [daysNameArr componentsJoinedByString:@", "];
        NSString * strPowerStatus = @"1";
        NSString *strWakeUp = @"0";
        if (isOnPower)
        {
            strPowerStatus = @"1";
        }
        else
        {
            strPowerStatus = @"0";
        }
        if (isWakeUpClicked == true)
        {
            strWakeUp = @"1";
        }
        else
        {
            strWakeUp = @"0";
        }
        NSString * strUpdateAlarm = [NSString stringWithFormat:@"update 'Alarm_Table' set 'alarm_time' = '%@','alarm_days'= '%@','alarm_color' = '%@','status' ='%@','isOn'='%@','normal_alarm_days'='%@','isWakeUp'='%@' where id ='%@' and user_id='%@'",strTimeSelected,strDaysCount,strHexAlarmColor,@"1",strPowerStatus,strDayNames,strWakeUp,[detailDict valueForKey:@"id"],CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:strUpdateAlarm];
        
        for (int i=0; i<[arrDevices count]; i++)
        {
            //        if ([[[tmpArray objectAtIndex:i] valueForKey:@"synced"] isEqualToString:@"Yes"])
//            if ([[[tmpArray objectAtIndex:i] valueForKey:@"isSelected"] isEqualToString:@"Yes"])
            {
                NSString * strDeviceID = [[arrDevices objectAtIndex:i] valueForKey:@"device_id"];
                NSString * strHexID = [[arrDevices objectAtIndex:i] valueForKey:@"hex_device_id"];
                
                if ([[[arrDevices objectAtIndex:i] valueForKey:@"UpdatedStatus"] isEqualToString:@"delete"])
                {
                    NSString * strDeleteAlarm = [NSString stringWithFormat:@"delete from Alarm_devices where device_id =  '%@' and alarm_id ='%@' and user_id = '%@'",strDeviceID,[detailDict valueForKey:@"id"],CURRENT_USER_ID];
                    [[DataBaseManager dataBaseManager] execute:strDeleteAlarm];
                }
                else if ([[[arrDevices objectAtIndex:i] valueForKey:@"UpdatedStatus"] isEqualToString:@"added"])
                {
                    
                }
                else
                {
                    if ([[[arrDevices objectAtIndex:i] valueForKey:@"isSelected"]  isEqualToString:@"Yes"])
                    {
                        NSString * strAlarmDevice = [NSString stringWithFormat:@"insert into 'Alarm_devices'('user_id','alarm_id','device_id','hex_device_id','created_date','status') values('%@','%@','%@','%@','%@','%@')",CURRENT_USER_ID,[detailDict valueForKey:@"id"],strDeviceID,strHexID,[NSDate date],@"1"];
                        [[DataBaseManager dataBaseManager] execute:strAlarmDevice];
                    }
                }
            }
        }
        
        NSString * strMsg = [NSString stringWithFormat:@"Alarm has been updated successfully."];
        [APP_DELEGATE hudEndProcessMethod];
        
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeSuccess];
        alert.delegate = self;
        alert.tag = 222;
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:strMsg
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
    else
    {
//        if (totalSyncedCount>0)
        {
            NSMutableArray * daysSelectArr = [[NSMutableArray alloc] init];
            NSMutableArray * daysNameArr = [[NSMutableArray alloc] init];
            
            for (int i=0; i<[dayArr count]; i++)
            {
                if ([[[dayArr objectAtIndex:i] valueForKey:@"isOff"] isEqualToString:@"0"])
                {
                    [daysSelectArr addObject:[[dayArr objectAtIndex:i] valueForKey:@"counts"]];
                    [daysNameArr addObject:[[dayArr objectAtIndex:i] valueForKey:@"dayname"]];
                }
            }
            NSString * strDaysCount = [daysSelectArr componentsJoinedByString:@","];
            NSString * strDayNames = [daysNameArr componentsJoinedByString:@", "];
            NSString * strPowerStatus = @"1";
            NSString * strWakeUp = @"0";
            if (isOnPower)
            {
                strPowerStatus = @"1";
            }
            else
            {
                strPowerStatus = @"0";
            }
            
            if ([[self checkforValidString:strHexAlarmColor]isEqualToString:@"NA"])
            {
                strHexAlarmColor = @"#FFFFFF";
            }
            if (isWakeUpClicked == true)
            {
                strWakeUp = @"1";
            }
            else
            {
                strWakeUp = @"0";
            }
            
            NSString * strUpdateAlarm = [NSString stringWithFormat:@"update 'Alarm_Table' set 'user_id' = '%@','alarm_time' = '%@','alarm_days'= '%@','alarm_color' = '%@','status' ='%@','isOn'='%@','normal_alarm_days'='%@',created_date = '%@','isWakeUp'='%@' where AlarmIndex ='%@' and user_id='%@'",CURRENT_USER_ID,strTimeSelected,strDaysCount,strHexAlarmColor,@"1",strPowerStatus,strDayNames,[NSDate date],strWakeUp,strIndex,CURRENT_USER_ID];

            [[DataBaseManager dataBaseManager] execute:strUpdateAlarm];
            NSString * strAlarmTblId = [NSString stringWithFormat:@"%@",[detailDict valueForKey:@"id"]];
            
            for (int i=0; i<[tmpArray count]; i++)
            {
                if ([[[tmpArray objectAtIndex:i] valueForKey:@"isSelected"] isEqualToString:@"Yes"])
                {
                    NSString * strDeviceID = [[tmpArray objectAtIndex:i] valueForKey:@"device_id"];
                    NSString * strHexID = [[tmpArray objectAtIndex:i] valueForKey:@"hex_device_id"];
                    NSString * strAlarmDevice = [NSString stringWithFormat:@"insert into 'Alarm_devices'('user_id','alarm_id','device_id','hex_device_id','created_date','status') values('%@','%@','%@','%@','%@','%@')",CURRENT_USER_ID,strAlarmTblId,strDeviceID,strHexID,[NSDate date],@"1"];
                    [[DataBaseManager dataBaseManager] execute:strAlarmDevice];
                }
            }
            NSString * strMsg = [NSString stringWithFormat:@"Alarm has been added successfully."];
            [APP_DELEGATE hudEndProcessMethod];
            
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeSuccess];
            alert.delegate = self;
            alert.tag = 222;
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:strMsg
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
//        else
//        {
//            FCAlertView *alert = [[FCAlertView alloc] init];
//            alert.colorScheme = [UIColor blackColor];
//            [alert makeAlertTypeWarning];
//            [alert showAlertInView:self
//                         withTitle:@"Smart Light"
//                      withSubtitle:@"There is no device added for this Alarm. Please make sure devices are on and in range of Bluetooth."
//                   withCustomImage:[UIImage imageNamed:@"logo.png"]
//               withDoneButtonTitle:nil
//                        andButtons:nil];
//        }
    }
}
#pragma mark- BLE Methods
-(void)SendAlarmRequesttoBle:(NSString *)strDeviceID
{
    NSInteger int1 = [@"100" integerValue];
    NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];//TTL
    
    globalCount = globalCount + 1;
    NSInteger int2 = globalCount;
    NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2]; //Sequence Count
    
    NSInteger int3 = [@"9000" integerValue];
    NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2]; //Source ID for mobile
    
    NSInteger int4 = [strDeviceID integerValue];
    NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2]; //Destination ID
    
    NSInteger int5 = [@"0" integerValue];
    NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2]; // CRC
    
    NSInteger intOpCode = [@"97" integerValue];
    NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpCode length:2]; //Opcode
    
    NSInteger intIndex = [strIndex integerValue];
//    NSInteger intIndex = 5;

    NSData * dataIndex = [[NSData alloc] initWithBytes:&intIndex length:1];
    
    NSInteger intDays = totalDayCount;
//    NSInteger intDays = 127;

    NSData * dataDays = [[NSData alloc] initWithBytes:&intDays length:1];

    NSInteger intHrs = hours;
    NSData * dataHrs = [[NSData alloc] initWithBytes:&intHrs length:1];

    NSInteger intMins = minutes;
    NSData * dataMins = [[NSData alloc] initWithBytes:&intMins length:1];

    NSInteger intRed = alarmRed;
    NSData * dataRed = [[NSData alloc] initWithBytes:&intRed length:1];

    NSInteger intGreen = alarmGreen;
    NSData * dataGreen = [[NSData alloc] initWithBytes:&intGreen length:1];

    NSInteger intBlue = alarmBlue;
    NSData * dataBlue = [[NSData alloc] initWithBytes:&intBlue length:1];
    
    NSInteger intWakeUp = 0;
    if (isWakeUpClicked == true)
    {
        intWakeUp = 1;
    }
    NSData * dataWakeUp = [[NSData alloc] initWithBytes:&intWakeUp length:1];


    NSMutableData * completeData = [[NSMutableData alloc] init];
    [completeData appendData:data2];
    [completeData appendData:data3];
    [completeData appendData:data4];
    [completeData appendData:data5];
    [completeData appendData:dataOpcode];
    [completeData appendData:dataIndex];
    [completeData appendData:dataDays];
    [completeData appendData:dataHrs];
    [completeData appendData:dataMins];
    [completeData appendData:dataRed];
    [completeData appendData:dataGreen];
    [completeData appendData:dataBlue];
    [completeData appendData:dataWakeUp];

    NSData * checkCountData = [APP_DELEGATE GetCountedCheckSumData:completeData];
    
    NSMutableData * finalData = [[NSMutableData alloc] init];
    finalData = [data1 mutableCopy];
    [finalData appendData:data2];
    [finalData appendData:data3];
    [finalData appendData:data4];
    [finalData appendData:checkCountData];
    [finalData appendData:dataOpcode];
    [finalData appendData:dataIndex];
    [finalData appendData:dataDays];
    [finalData appendData:dataHrs];
    [finalData appendData:dataMins];
    [finalData appendData:dataRed];
    [finalData appendData:dataGreen];
    [finalData appendData:dataBlue];
    [finalData appendData:dataWakeUp];

    NSString * StrData = [NSString stringWithFormat:@"%@",finalData.debugDescription];
    StrData = [StrData stringByReplacingOccurrencesOfString:@" " withString:@""];
    StrData = [StrData stringByReplacingOccurrencesOfString:@"<" withString:@""];
    StrData = [StrData stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSString * strEncryptedKey = [APP_DELEGATE getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"passKey"]];
    NSString * strFinalData = [APP_DELEGATE getStringConvertedinUnsigned:StrData];
    
    NSData * requestData = [APP_DELEGATE GetEncryptedKeyforData:strFinalData withKey:strEncryptedKey withLength:finalData.length];

    [[BLEService sharedInstance] writeValuetoDeviceMsg:requestData with:globalPeripheral];
    [[NSUserDefaults standardUserDefaults] setInteger:globalCount forKey:@"GlobalCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)RemoveAlarmRequesttoBLE:(NSString *)strDeviceId
{
    NSInteger int1 = [@"50" integerValue];
    NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];//TTL
    
    globalCount = globalCount + 1;
    NSInteger int2 = globalCount;
    NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2]; //Sequence Count
    
    NSInteger int3 = [@"9000" integerValue];
    NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2]; //Source ID for mobile
    
    NSInteger int4 = [strDeviceId integerValue];
    NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2]; //Destination ID
    
    NSInteger int5 = [@"0" integerValue];
    NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2]; // CRC
    
    NSInteger intOpCode = [@"99" integerValue];
    NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpCode length:2]; //Opcode
    
    NSInteger intIndex = [strIndex integerValue]; // Alarm Index
    NSData * dataIndex = [[NSData alloc] initWithBytes:&intIndex length:1];

    NSMutableData * completeData = [[NSMutableData alloc] init];
//    completeData = [data1 mutableCopy];
    [completeData appendData:data2];
    [completeData appendData:data3];
    [completeData appendData:data4];
    [completeData appendData:data5];
    [completeData appendData:dataOpcode];
    [completeData appendData:dataIndex];
    
    NSData * checkCountData = [APP_DELEGATE GetCountedCheckSumData:completeData];
    
    NSMutableData * finalData = [[NSMutableData alloc] init];
    finalData = [data1 mutableCopy];
    [finalData appendData:data2];
    [finalData appendData:data3];
    [finalData appendData:data4];
    [finalData appendData:checkCountData];
    [finalData appendData:dataOpcode];
    [finalData appendData:dataIndex];

    [APP_DELEGATE sendSignalViaScan:@"DeleteAlarmUUID" withDeviceID:strDeviceId withValue:strIndex];
    
    NSString * StrData = [NSString stringWithFormat:@"%@",finalData.debugDescription];
    StrData = [StrData stringByReplacingOccurrencesOfString:@" " withString:@""];
    StrData = [StrData stringByReplacingOccurrencesOfString:@"<" withString:@""];
    StrData = [StrData stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSString * strEncryptedKey = [APP_DELEGATE getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"passKey"]];
    NSString * strFinalData = [APP_DELEGATE getStringConvertedinUnsigned:StrData];
    
    NSData * requestData = [APP_DELEGATE GetEncryptedKeyforData:strFinalData withKey:strEncryptedKey withLength:finalData.length];

    
    [[BLEService sharedInstance] writeValuetoDeviceMsg:requestData with:globalPeripheral];
    [[NSUserDefaults standardUserDefaults] setInteger:globalCount forKey:@"GlobalCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

#pragma mark - BLE Methods
-(void)InitialBLE
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallNotificationforNonConnect" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CallNotificationforNonConnect:) name:@"CallNotificationforNonConnect" object:nil];
}
-(void)specificNotify:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
}

#pragma mark - SCANNED DEVICE AFTER SENT REQUEST RESULT APPEAR HERE...LOGIC TO CHECK SCANNED DEVICE

-(void)CallNotificationforNonConnect:(NSNotification*)notification//Update peripheral
{
    NSDictionary *dict = [notification userInfo];
    NSData *nameData = [dict valueForKey:@"kCBAdvDataManufacturerData"];
    NSString * checkStr = [NSString stringWithFormat:@"%@",nameData.debugDescription];

    NSArray * tmpArr = [checkStr componentsSeparatedByString:@"0a00"];
    if ([tmpArr count]>1)
    {
        NSString * kpstr = [tmpArr objectAtIndex:1];
        if ([tmpArr count]>2)
        {
            NSRange range71 = NSMakeRange(4, [checkStr length]-4);
            kpstr = [checkStr substringWithRange:range71];
        }
        kpstr = [kpstr stringByReplacingOccurrencesOfString:@" " withString:@""];
        kpstr = [kpstr stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        if ([kpstr rangeOfString:@"0062"].location != NSNotFound)
        {
            for (int i =0; i<[tmpArray count]; i++)
            {
                NSString * strCompare = [[tmpArray objectAtIndex:i] valueForKey:@"hex_device_id"];
                if ([kpstr rangeOfString:strCompare].location == NSNotFound)
                {
                }
                else
                {
                    [[tmpArray objectAtIndex:i] setObject:@"Yes" forKey:@"synced"];
                    totalSyncedCount = totalSyncedCount + 1;
                }
            }
        }
        else if ([kpstr rangeOfString:@"0064"].location != NSNotFound)
        {
            for (int i =0; i<[tmpArray count]; i++)
            {
                NSString * strCompare = [[tmpArray objectAtIndex:i] valueForKey:@"hex_device_id"];
                if ([kpstr rangeOfString:strCompare].location == NSNotFound)
                {
                }
                else
                {
                    [[tmpArray objectAtIndex:i] setObject:@"Yes" forKey:@"synced"];
                    totalSyncedCount = totalSyncedCount + 1;
                }
            }
        }
    }
}

- (UIColor *)colorWithHexString:(NSString *)str
{
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [self colorWithHex:x];
}
- (UIColor *)colorWithHex:(UInt32)col
{
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    
    
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}
-(void)timeOutCallMethod
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeCaution];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"There is something went wrong. Please try again later."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 222)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)ConnectionValidationPopup
{
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeCaution];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Your IOS device is not connected with SmartLight device. Please connect first with device."
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
    return strValid;
}


//CREATE TABLE "Alarm_Table" ( `id` INTEGER NOT NULL, `user_id` TEXT, `alarm_time` TEXT, `alarm_days` TEXT, `alarm_color` TEXT, `server_alarm_id` TEXT, `status` TEXT DEFAULT 1, `isOn` TEXT, `created_date` TEXT, `updated_date` TEXT, `timestamp` TEXT, `normal_alarm_days` TEXT, `is_sync` TEXT, PRIMARY KEY(`id`) )

//CREATE TABLE `Alarm_devices` ( `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, `alarm_id` TEXT, `user_id` TEXT, `alarm_server_id` TEXT, `device_id` TEXT, `hex_device_id` TEXT, `created_date` TEXT, `is_sync` TEXT )
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
