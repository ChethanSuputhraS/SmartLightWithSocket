//
//  AlarmVC.m
//  SmartLightApp
//
//  Created by stuart watts on 05/04/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "AlarmVC.h"
#import "DashboardCell.h"
#import "AlarmDetailVC.h"
#import "BridgeVC.h"
#import "VCFloatingActionButton.h"

@interface AlarmVC ()<ORBSwitchDelegate,URLManagerDelegate,floatMenuDelegate>
{
    NSInteger requestedIndex, totalSyncedCount, totalSentCount,sentCount;
    NSMutableArray * tmpDevicesArr, * syncedDevicesArr;
    VCFloatingActionButton *addFloatButton;

}
@end

@implementation AlarmVC

- (void)viewDidLoad
{

    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    tmpDevicesArr = [[NSMutableArray alloc] init];
    
    [self setNavigationViewFrames];
    
//    if (![IS_USER_SKIPPED isEqualToString:@"YES"])
    {
//        [self GetAllAlarms];
    }

//    [self getDatafromDatabase];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:YES];
    isNonConnectScanning = NO; 
    [APP_DELEGATE stopAdvertisingBaecons];
    [APP_DELEGATE showTabBar:self.tabBarController];
    
    [self InitialBLE];

    currentScreen = @"Scheduler";
    
    [self getDatafromDatabase];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FloatButtonTapped" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(btnAddClick) name:@"FloatButtonTapped" object:nil];
    [imgNotConnected removeFromSuperview];
    imgNotConnected = [[UIImageView alloc]init];
    imgNotConnected.image = [UIImage imageNamed:@"notconnect_iconWhite.png"];
    imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 32, 30, 22);
    imgNotConnected.contentMode = UIViewContentModeScaleAspectFit;
    imgNotConnected.layer.masksToBounds = true;
    [self.view addSubview:imgNotConnected];
    
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        imgNotConnected.image = [UIImage imageNamed:@"Connected_icon.png"];
    }
    if (IS_IPHONE_X)
    {
        imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 55, 30, 22);

    }
    else
    {
        if (updatedRSSI >= -70)
        {
            if (updatedRSSI < 0)
            {
                imgNotConnected.image = [UIImage imageNamed:@"notconnect_iconOrange.png"];
            }
            else
            {
                imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
            }
        }
        else if (updatedRSSI < -70)
        {
            if (updatedRSSI >= 100)
            {
                imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
                
            }
        }
    }

}

#pragma mark - Set View Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.5;
    [viewHeader addSubview:lblBack];

    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"My Routine"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+3]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * imgMenu = [[UIImageView alloc]initWithFrame:CGRectMake(10,20+7, 33, 30)];
    imgMenu.image = [UIImage imageNamed:@"menu.png"];
    imgMenu.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgMenu];
    
    UIButton * btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMenu setFrame:CGRectMake(0, 0, 80, 64)];
    [btnMenu addTarget:self action:@selector(btnMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnMenu];
    
//    btnAddAlarm = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnAddAlarm.frame = CGRectMake(DEVICE_WIDTH-50, 20, 50, 44);
//    btnAddAlarm.layer.masksToBounds = YES;
//    [btnAddAlarm setImage:[UIImage imageNamed:@"addalarm.png"] forState:UIControlStateNormal];
//    [btnAddAlarm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    btnAddAlarm.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [btnAddAlarm.titleLabel setFont:[UIFont systemFontOfSize:30 weight:UIFontWeightRegular]];
//    [btnAddAlarm addTarget:self action:@selector(btnAddClick) forControlEvents:UIControlEventTouchUpInside];
//    [viewHeader addSubview:btnAddAlarm];
    
    lblNoAlarm = [[UILabel alloc] initWithFrame:CGRectMake(0, (DEVICE_HEIGHT-100)/2, DEVICE_WIDTH, 100)];
    [lblNoAlarm setBackgroundColor:[UIColor clearColor]];
    [lblNoAlarm setText:@"No routine set. \nPlease click on Add button to set routine."];
    [lblNoAlarm setTextAlignment:NSTextAlignmentCenter];
    [lblNoAlarm setFont:[UIFont fontWithName:CGRegular size:textSizes+4]];
    lblNoAlarm.numberOfLines = 0;
    [lblNoAlarm setTextColor:[UIColor whiteColor]];
    lblNoAlarm.hidden = YES;
    [viewHeader addSubview:lblNoAlarm];
    
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64+10, DEVICE_WIDTH, DEVICE_HEIGHT-45-64-10) style:UITableViewStylePlain];
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblView.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:tblView];
    
    addFloatButton = [[VCFloatingActionButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-70, DEVICE_HEIGHT-100, 60,60) normalImage:[UIImage imageNamed:@"addalarm.png"] andPressedImage:[UIImage imageNamed:@"addalarm.png"] withScrollview:tblView];

    addFloatButton.backgroundColor = global_brown_color;
    addFloatButton.layer.masksToBounds = true;
    addFloatButton.layer.cornerRadius = 30;
    addFloatButton.delegate = self;
    addFloatButton.hideWhileScrolling = YES;
    [self.view addSubview:addFloatButton];
    
    
    if (IS_IPHONE_X)
    {
        lblBack.frame = CGRectMake(0, 44, DEVICE_WIDTH, 88);
        imgMenu.frame = CGRectMake(10,44+7, 33, 30);
        [btnMenu setFrame:CGRectMake(0, 0, 88, 88)];
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 44, DEVICE_WIDTH-100, 44);
        tblView.frame = CGRectMake(0, 88+10, DEVICE_WIDTH, DEVICE_HEIGHT-45-88-40-10);
    }
}
#pragma mark - float Button Delegate
-(void) didSelectMenuOptionAtIndex:(NSInteger)row
{
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        NSMutableArray * spareAlArr = [[NSMutableArray alloc] init];
        NSString * strQuery = [NSString stringWithFormat:@"Select * from Alarm_Table where user_id = '%@' and status = '2'",CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:spareAlArr];
        
        if ([spareAlArr count]>0)
        {
            NSString * strIndexs = [NSString stringWithFormat:@"%@",[[spareAlArr objectAtIndex:0]valueForKey:@"AlarmIndex"]];
            AlarmDetailVC * alarmVc = [[AlarmDetailVC alloc] init];
            alarmVc.detailDict = [spareAlArr objectAtIndex:0];
            alarmVc.strIndex = strIndexs;
            [self.navigationController pushViewController:alarmVc animated:YES];
        }
        else
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"You have exceed maximum alarm creation limimt.You can add maximum 6 alarms."
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
//-(void)btnAddClick
//{
//    NSMutableArray * spareAlArr = [[NSMutableArray alloc] init];
//    NSString * strQuery = [NSString stringWithFormat:@"Select * from Alarm_Table where user_id = '%@' and status = '2'",CURRENT_USER_ID];
//    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:spareAlArr];
//
//    NSString * strIndexs = [NSString stringWithFormat:@"0"];
//    AlarmDetailVC * alarmVc = [[AlarmDetailVC alloc] init];
//    alarmVc.detailDict = [spareAlArr objectAtIndex:0];
//    alarmVc.strIndex = strIndexs;
//    [self.navigationController pushViewController:alarmVc animated:YES];
    
//    if (globalPeripheral.state == CBPeripheralStateConnected)
//    {
//        NSLog(@"Total Arr count=%lu",(unsigned long)[alarmArr count]);
//
//        NSMutableArray * spareAlArr = [[NSMutableArray alloc] init];
//        NSString * strQuery = [NSString stringWithFormat:@"Select * from Alarm_Table where user_id = '%@' and status = '2'",CURRENT_USER_ID];
//        [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:spareAlArr];
//
//        if ([spareAlArr count]>0)
//        {
//            NSString * strIndexs = [NSString stringWithFormat:@"%@",[[spareAlArr objectAtIndex:0]valueForKey:@"AlarmIndex"]];
//            AlarmDetailVC * alarmVc = [[AlarmDetailVC alloc] init];
//            alarmVc.detailDict = [spareAlArr objectAtIndex:0];
//            alarmVc.strIndex = strIndexs;
//            [self.navigationController pushViewController:alarmVc animated:YES];
//        }
//        else
//        {
//            FCAlertView *alert = [[FCAlertView alloc] init];
//            alert.colorScheme = [UIColor blackColor];
//            [alert makeAlertTypeCaution];
//            [alert showAlertInView:self
//                         withTitle:@"Smart Light"
//                      withSubtitle:@"You have exceed maximum alarm creation limimt.You can add maximum 6 alarms."
//                   withCustomImage:[UIImage imageNamed:@"logo.png"]
//               withDoneButtonTitle:nil
//                        andButtons:nil];
//        }
//    }
//    else
//    {
//        [self ConnectionValidationPopup];
//    }
//
//}
-(void)btnDeleteClick:(id)sender
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    [alert addButton:@"Yes" withActionBlock:^{
        
        if (globalPeripheral.state == CBPeripheralStateConnected)
        {
            [APP_DELEGATE startHudProcess:@"Removing Alarm..."];
            // Put your action here
            isNonConnectScanning = YES;
            
            totalSentCount = 0;
            totalSyncedCount = 0;
            sentCount = 0;
            requestedIndex = [sender tag];
            tmpDevicesArr = [[NSMutableArray alloc] init];
            syncedDevicesArr = [[NSMutableArray alloc] init];
            
            NSString * strMain = [NSString stringWithFormat:@"Select * from Alarm_devices where user_id ='%@' and alarm_id = '%@'",CURRENT_USER_ID,[[alarmArr objectAtIndex:requestedIndex]valueForKey:@"id"]];
            [[DataBaseManager dataBaseManager] execute:strMain resultsArray:tmpDevicesArr];
            
            [self sendDeviceonebyone];
        }
    }];
    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Are you sure want to delete this Alarm?"
           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
       withDoneButtonTitle:@"No" andButtons:nil];
    

}
#pragma mark - All button click events
-(void)btnMenuClicked:(id)sender
{
    [self.menuContainerViewController setMenuSlideAnimationFactor:0.5f];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];}
#pragma mark - Database Methods
-(void)getDatafromDatabase
{
    alarmArr = [[NSMutableArray alloc] init];
    NSString * strQuery = [NSString stringWithFormat:@"Select * from Alarm_Table where user_id = '%@' and status = '1' order by alarm_time",CURRENT_USER_ID];
//    NSString * strQuery = [NSString stringWithFormat:@"Select * from Alarm_Table"];

    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:alarmArr];
    [tblView reloadData];
    if ([alarmArr count]==0)
    {
//        tblView.hidden = YES;
        lblNoAlarm.hidden = NO;
    }
    else
    {
        tblView.hidden = NO;
        lblNoAlarm.hidden = YES;
        [tblView reloadData];
    }
}
#pragma mark- UITableView Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [alarmArr count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DashboardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DashboardCell"];
    if (cell==nil)
    {
        cell = [[DashboardCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DashboardCell"];
    }
    
    cell.imgStatus.hidden = NO;
    cell._switchLight.hidden = YES;
    cell.btnMore.hidden = NO;

    cell.lblName.frame = CGRectMake(55, 0,DEVICE_WIDTH-80,45);
    cell.lblDays.frame = CGRectMake(20, 40,DEVICE_WIDTH-80,20);
    cell.imgStatus.frame = CGRectMake(20,13,25,23);

    [cell.lblName setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    cell.imgStatus.image = [UIImage imageNamed:@"active_alarm_icon.png"];
    cell.lblName.text = [[alarmArr objectAtIndex:indexPath.row] valueForKey:@"alarm_time"];
    cell.lblDays.text = [[alarmArr objectAtIndex:indexPath.row] valueForKey:@"normal_alarm_days"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if ([[[alarmArr objectAtIndex:indexPath.row]valueForKey:@"isOn"] isEqualToString:@"1"])
    {
        UIColor * rgbColor = [self colorWithHexString:[[alarmArr objectAtIndex:indexPath.row] valueForKey:@"alarm_color"]];
        cell.lblColors.backgroundColor = rgbColor;
        cell.lblColors.text = @" ";
        cell.lblColors.frame = CGRectMake(DEVICE_WIDTH-100, 18, 25, 25);

    }
    else
    {
        cell.lblColors.backgroundColor = [UIColor clearColor];
        cell.lblColors.text = @"OFF";
        cell.lblColors.frame = CGRectMake(DEVICE_WIDTH-100, 18, 100, 25);
    }

    cell.btnMore.tag = indexPath.row;
    cell.lblColors.hidden = NO;
    [cell.btnMore addTarget:self action:@selector(btnDeleteClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString * strIndexes = [[alarmArr objectAtIndex:indexPath.row] valueForKey:@"AlarmIndex"];
    AlarmDetailVC * alDetail = [[AlarmDetailVC alloc] init];
    alDetail.detailDict = [alarmArr objectAtIndex:indexPath.row];
    alDetail.isFromEdit = YES;
    alDetail.strIndex = strIndexes;
    [self.navigationController pushViewController:alDetail animated:YES];
}
#pragma mark - ORBSwitchDelegate
- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue
{
    if (switchObj.tag==123)
    {
        tmpSwtch = switchObj;
        isAlldevicePowerOn = newValue;
    }
    else
    {
        CGPoint buttonPosition = [switchObj convertPoint:CGPointZero toView:tblView];
        NSIndexPath *index = [tblView indexPathForRowAtPoint:buttonPosition];
        
        NSString * deviceID = @"NA";
        deviceID = [[alarmArr objectAtIndex:index.row] valueForKey:@"device_id"];
        
        tmpSwtch = switchObj;
    }
}

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj
{
    [switchObj setCustomKnobImage:[UIImage imageNamed:(switchObj.isOn) ? @"on_icon" : @"off_icon"]
          inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]
            activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//user_id:3
//alarm_time:12:30 PM
//alarm_days:1001001
//status:1
//devices:1,2,3,4

-(void)GetAllAlarms
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
//    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
    [dict setValue:@"1" forKey:@"user_id"];

    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"GetAllAlarms";
    manager.delegate = self;
    NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/get_all_alarm";
    [manager urlCall:strServerUrl withParameters:dict];
}

#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];
//    NSLog(@"The result is...%@", result);
    if ([[result valueForKey:@"commandName"] isEqualToString:@"GetAllAlarms"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if([[result valueForKey:@"result"] valueForKey:@"data"]!=[NSNull null] || [[result valueForKey:@"result"] valueForKey:@"data"] != nil)
            {
                NSMutableArray * arrTemp = [[NSMutableArray alloc] init];
                arrTemp = [[result valueForKey:@"result"] valueForKey:@"alarm"];
                if ([arrTemp count]>0)
                {
                    for (int i = 0; i<[arrTemp count]; i++)
                    {
                        [self saveAlarmsintoDatabase:[arrTemp objectAtIndex:i]];
                    }
                    [self getDatafromDatabase];
                }

            }
        }
        else
        {
            NSString * strMsg = [[result valueForKey:@"result"] valueForKey:@"message"];
            
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:strMsg
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
}

- (void)onError:(NSError *)error
{
    [APP_DELEGATE endHudProcess];
    
//    NSLog(@"The error is...%@", error);
    
    
    NSInteger ancode = [error code];
    
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
//    NSLog(@"errorDict===%@",errorDict);
    
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009) {
//        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
    } else {
//        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
    }
    
    
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
//        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
    }
}

#pragma mark - Save Install records to Database
-(void)saveAlarmsintoDatabase:(NSMutableDictionary *)dictHistory
{
    NSString * strServerAlarmId = [self checkforValidString:[dictHistory valueForKey:@"alarm_id"]];
    NSString * strAlarmTime = [self checkforValidString:[dictHistory valueForKey:@"alarm_time"]];
    NSString * strAlarmDays = [self checkforValidString:[dictHistory valueForKey:@"alarm_days"]];
    NSString * strStatus = [self checkforValidString:[dictHistory valueForKey:@"status"]];
    NSString * strUserId = CURRENT_USER_ID;
    NSString * strCreatedDate = [self checkforValidString:[dictHistory valueForKey:@"created_date"]];
    NSString * strUpdatedDate = [self checkforValidString:[dictHistory valueForKey:@"updated_date"]];
    NSString * strTimeStamp = [self checkforValidString:[dictHistory valueForKey:@"timestamp"]];
    
    NSString * selectStr  =[NSString stringWithFormat:@"Select * from Alarm_Table where user_id ='%@' and server_alarm_id = '%@'",CURRENT_USER_ID,strServerAlarmId];
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:selectStr resultsArray:tmpArr];

    if ([tmpArr count]>0)
    {
        NSString *  strQuery =[NSString stringWithFormat:@"update 'Alarm_Table' set 'user_id' = \"%@\",'alarm_time' = \"%@\",'alarm_days' = \"%@\",'status' = \"%@\",'updated_date' = \"%@\",'timestamp' = \"%@\",'normal_alarm_days' = \"%@\", is_sync = '1' where user_id ='%@' and server_alarm_id = '%@'",strUserId,strAlarmTime,strAlarmDays,strStatus,strUpdatedDate,strTimeStamp,strAlarmDays,strUserId,strServerAlarmId];
        [[DataBaseManager dataBaseManager] execute:strQuery];
        
        NSString * strDel = [NSString stringWithFormat:@"delete from Alarm_Devices where server_alarm_id = '%@' and user_id ='%@'",strServerAlarmId,strUserId];
        [[DataBaseManager dataBaseManager] execute:strDel];
        
        NSString * alarmTabId = [NSString stringWithFormat:@"%@",[[tmpArr objectAtIndex:0]valueForKey:@"id"]];

        NSMutableArray * deviceArr = [[NSMutableArray alloc] init];
        deviceArr = [[dictHistory valueForKey:@"device_details"] mutableCopy];
        for (int i =0; i<[deviceArr count]; i++)
        {
            NSString * strServerDeviceId = [self checkforValidString:[dictHistory valueForKey:@"server_device_id"]];
            NSString * strDeviceId = [self checkforValidString:[dictHistory valueForKey:@"device_id"]];
            NSString * strHexDeviceId = [self checkforValidString:[dictHistory valueForKey:@"hex_device_id"]];
            NSString * strDeviceName = [self checkforValidString:[dictHistory valueForKey:@"device_name"]];
            NSString * strBleAddress = [[self checkforValidString:[dictHistory valueForKey:@"ble_address"]] uppercaseString];
            NSString * strDeviceType = [self checkforValidString:[dictHistory valueForKey:@"device_type"]];
            NSString * strDeviceTypeName = [self checkforValidString:[dictHistory valueForKey:@"device_type_name"]];
            NSString * strAlarmTabId = [NSString stringWithFormat:@"%@",alarmTabId];
            
            NSString * requestStr =[NSString stringWithFormat:@"insert into 'Alarm_Devices'('user_id','alarm_id','device_id','hex_device_id','device_server_id','device_name','device_type','ble_address','created_date','updated_date','timestamp','device_type_name') values(\"%@\",\"%@\",'%@',\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",'%@','%@','%@')",strUserId,strAlarmTabId,strDeviceId,strHexDeviceId,strServerDeviceId,strDeviceName,strDeviceType,strBleAddress,strCreatedDate,strUpdatedDate,strTimeStamp,strDeviceTypeName];
            [[DataBaseManager dataBaseManager] execute:requestStr];
        }
    }
    else
    {
        NSString * requestStr =[NSString stringWithFormat:@"insert into 'Alarm_Table'('user_id','alarm_time','alarm_days','server_alarm_id','status','created_date','updated_date','timestamp','normal_alarm_days','is_sync') values(\"%@\",\"%@\",'%@',\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",'1')",strUserId,strAlarmTime,strAlarmDays,strServerAlarmId,strStatus,strCreatedDate,strUpdatedDate,strTimeStamp,strAlarmDays];
        int alarmid = [[DataBaseManager dataBaseManager] executeSw:requestStr];
        
        NSMutableArray * deviceArr = [[NSMutableArray alloc] init];
        deviceArr = [[dictHistory valueForKey:@"device_details"] mutableCopy];
        for (int i =0; i<[deviceArr count]; i++)
        {
            NSString * strServerDeviceId = [self checkforValidString:[dictHistory valueForKey:@"server_device_id"]];
            NSString * strDeviceId = [self checkforValidString:[dictHistory valueForKey:@"device_id"]];
            NSString * strHexDeviceId = [self checkforValidString:[dictHistory valueForKey:@"hex_device_id"]];
            NSString * strDeviceName = [self checkforValidString:[dictHistory valueForKey:@"device_name"]];
            NSString * strBleAddress = [[self checkforValidString:[dictHistory valueForKey:@"ble_address"]] uppercaseString];
            NSString * strDeviceType = [self checkforValidString:[dictHistory valueForKey:@"device_type"]];
            NSString * strDeviceTypeName = [self checkforValidString:[dictHistory valueForKey:@"device_type_name"]];
            NSString * strAlarmTabId = [NSString stringWithFormat:@"%d",alarmid];
            
            NSString * requestStr =[NSString stringWithFormat:@"insert into 'Alarm_Devices'('user_id','alarm_id','device_id','hex_device_id','device_server_id','device_name','device_type','ble_address','created_date','updated_date','timestamp','device_type_name') values(\"%@\",\"%@\",'%@',\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",'%@','%@','%@')",strUserId,strAlarmTabId,strDeviceId,strHexDeviceId,strServerDeviceId,strDeviceName,strDeviceType,strBleAddress,strCreatedDate,strUpdatedDate,strTimeStamp,strDeviceTypeName];
             [[DataBaseManager dataBaseManager] execute:requestStr];
        }
    }
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

-(void)sendDeviceonebyone
{
    if ([tmpDevicesArr count]>sentCount)
    {
//        if ([[[tmpDevicesArr objectAtIndex:sentCount] valueForKey:@"UpdatedStatus"] isEqualToString:@"delete"])
        {
            totalSentCount = totalSentCount + 1;
            NSString * strDeviceId = [[tmpDevicesArr objectAtIndex:sentCount] valueForKey:@"device_id"];
            NSString * strIndexs = [[alarmArr objectAtIndex:requestedIndex] valueForKey:@"AlarmIndex"];
            
            [self RemoveAlarmRequesttoBLE:strDeviceId withAarlmIndex:strIndexs];
            [APP_DELEGATE sendSignalViaScan:@"DeleteAlarmUUID" withDeviceID:strDeviceId withValue:strIndexs];
        }
        sentCount = sentCount  + 1;
        [self performSelector:@selector(sendDeviceonebyone) withObject:nil afterDelay:1];
    }
    else
    {
        [self performSelector:@selector(CheckForDeleteaAlarm) withObject:nil afterDelay:1];
    }
}
-(void)CheckForDeleteaAlarm
{
    isNonConnectScanning = NO;

    [APP_DELEGATE hudEndProcessMethod];
//    if (totalSyncedCount == totalSentCount)
    {
//        NSString * strDelete = [NSString stringWithFormat:@"Delete from Alarm_Table where id = '%@' and user_id ='%@'",[[alarmArr objectAtIndex:requestedIndex]valueForKey:@"id"],CURRENT_USER_ID];
        NSString * strDelete = [NSString stringWithFormat:@"update Alarm_Table set status = '2' where id = '%@' and user_id ='%@' ",[[alarmArr objectAtIndex:requestedIndex]valueForKey:@"id"],CURRENT_USER_ID];

        [[DataBaseManager dataBaseManager] execute:strDelete];
        [alarmArr removeObjectAtIndex:requestedIndex];
        [tblView reloadData];
        
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeSuccess];
        alert.tag = 222;
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"Alarm has been removed successfully."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];

    }
//    else
//    {
//        NSString * strMsg = [NSString stringWithFormat:@"There are few devices which are not in range. So we can't delete the alarm now."];
//        FCAlertView *alert = [[FCAlertView alloc] init];
//        alert.colorScheme = [UIColor blackColor];
//        [alert makeAlertTypeCaution];
//        [alert showAlertInView:self
//                     withTitle:@"Smart Light"
//                  withSubtitle:strMsg
//               withCustomImage:[UIImage imageNamed:@"logo.png"]
//           withDoneButtonTitle:nil
//                    andButtons:nil];
//    }
}
-(void)RemoveAlarmRequesttoBLE:(NSString *)strDeviceId withAarlmIndex:(NSString *)strAlarmIndex
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
    NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2]; //
    
    NSInteger intOpCode = [@"99" integerValue];
    NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpCode length:2]; //Opcode
    
    NSInteger intIndex = [strAlarmIndex integerValue]; // Alarm Index
    NSData * dataIndex = [[NSData alloc] initWithBytes:&intIndex length:1];
    
    NSMutableData * checkData = [[NSMutableData alloc] init];
    [checkData appendData:data2];
    [checkData appendData:data3];
    [checkData appendData:data4];
    [checkData appendData:data5];//CRC as 0
    [checkData appendData:dataOpcode];
    [checkData appendData:dataIndex];
    
    NSData * checksumData = [APP_DELEGATE GetCountedCheckSumData:checkData];
    
    NSMutableData * completeData = [[NSMutableData alloc] init];
    completeData = [data1 mutableCopy];
    [completeData appendData:data2];
    [completeData appendData:data3];
    [completeData appendData:data4];
    [completeData appendData:checksumData];
    [completeData appendData:dataOpcode];
    [completeData appendData:dataIndex];
    
    NSString * StrData = [NSString stringWithFormat:@"%@",completeData.debugDescription];
    StrData = [StrData stringByReplacingOccurrencesOfString:@" " withString:@""];
    StrData = [StrData stringByReplacingOccurrencesOfString:@"<" withString:@""];
    StrData = [StrData stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSString * strEncryptedKey = [APP_DELEGATE getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"passKey"]];
    NSString * strFinalData = [APP_DELEGATE getStringConvertedinUnsigned:StrData];
    
    NSData * requestData = [APP_DELEGATE GetEncryptedKeyforData:strFinalData withKey:strEncryptedKey withLength:completeData.length];
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
        
        if ([kpstr rangeOfString:@"0064"].location != NSNotFound)
        {
            for (int i=0; i<[tmpDevicesArr count]; i++)
            {
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                [tmpDict setObject:[[tmpDevicesArr objectAtIndex:i] valueForKey:@"device_id"] forKey:@"device_id"];
                
                if (![[syncedDevicesArr valueForKey:@"device_id"] containsObject:[[tmpDevicesArr objectAtIndex:i] valueForKey:@"device_id"]])
                {
                    NSString * strUpdate  = [NSString stringWithFormat:@"delete from Alarm_devices where device_id = '%@' and alarm_id = '%@'",[[tmpDevicesArr objectAtIndex:i] valueForKey:@"device_id"],[[tmpDevicesArr objectAtIndex:i] valueForKey:@"alarm_id"]];
                    [[DataBaseManager dataBaseManager] execute:strUpdate];
                    
                    [syncedDevicesArr addObject:tmpDict];
                    totalSyncedCount = totalSyncedCount + 1;
                }
            }
        }
    }
}
-(void)ConnectionValidationPopup
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeCaution];
    [alert addButton:@"Go to Connect" withActionBlock:^{
        BridgeVC * bridge = [[BridgeVC alloc] init];
        [self.navigationController pushViewController:bridge animated:YES];
    }];
    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Your IOS device is not connected with SmartLight device. Please connect first with device."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:@"Ok"
                andButtons:nil];
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

/*
 CREATE TABLE "Alarm_Table" ( `id` INTEGER NOT NULL, `user_id` TEXT, `alarm_time` TEXT, `alarm_days` TEXT, `server_alarm_id` TEXT, `status` TEXT, `created_date` TEXT, `updated_date` TEXT, `timestamp` TEXT, PRIMARY KEY(`id`) )
 
 CREATE TABLE `Alarm_Devices` ( `id` TEXT NOT NULL, `alarm_id` TEXT, `device_id` TEXT, `hex_device_id` TEXT, `device_server_id` TEXT, `device_name` TEXT, `device_type` TEXT, `ble_address` TEXT, `created_date` TEXT, `updated_date` TEXT, `timestamp` TEXT, PRIMARY KEY(`id`) )
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
