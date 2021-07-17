//
//  SocketDetailVC.m
//  SmartLightApp
//
//  Created by Kalpesh Panchasara on 06/01/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import "SocketDetailVC.h"
#import "SocketCell.h"
#import "SocketAlarmVC.h"
#import "BLEManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ResetSocketVC.h"
#import "CollectionCustomCell.h"

@interface SocketDetailVC ()<UITableViewDelegate,UITableViewDataSource,CBCentralManagerDelegate, CocoaMQTTDelegate, BLEManagerDelegate,FCAlertViewDelegate,URLManagerDelegate, SocketWifiSettingDelegate, SocketAlarmDelegate,UITextFieldDelegate,UIActionSheetDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>
{
    NYSegmentedControl * blueSegmentedControl;
    UIView  *controlView,*settingsView;
    UITableView * tblSettings;
    UIImageView * imgBack;
    NSMutableArray * arrMQTTalarmState;
    NSString * strVersionNo,* strOTAstring;
    
    UIView * viewForCollectionBG,*viewForCollectionImgView;
    UICollectionView *collectionView;;
    
    NSArray *ArrImgForCollectionView,* arrImgHeight,*arrImgWidth;;
    NSInteger selectedSocketIndex;

//    NSMutableArray * arraySelctedImgs;
    NSMutableDictionary * dictImgs ;
//    NSString * strSocketName;
 
    UIView * viewForsocketNameBG,*viewForTxtName;
    UIButton *btnCancelName,*btnSave;
    UITextField *txtName;
    
//    long imgIdCollectionView;
    
    NSIndexPath * selectedIndexPath;
    
    CBCentralManager * mangerSate;
    NSMutableDictionary * dictImgAndSize;
     


}
@end

@implementation SocketDetailVC
@synthesize classMqttObj, deviceDetail, isMQTTselect,classPeripheral ,strMacAddress,strWifiConnect, delegate;

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    isTopicSubscribed = NO;
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
    
    dictFromHomeSwState = [[NSMutableDictionary alloc] init];
    arryDevices = [[NSMutableArray alloc] init];
    arrMQTTalarmState = [[NSMutableArray alloc] init];

    dictSocketDetail = [[NSMutableArray alloc] init];
    NSString * strQuery = [NSString stringWithFormat:@"select * from Socket_NameImg_Table  where ble_address = '%@'",strMacAddress];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:dictSocketDetail];
   
    arrSocketNames = [[NSMutableArray alloc] init];
    for (int i =0; i < 7; i++)
    {
        if ([[dictSocketDetail valueForKey:@"socket_id"] containsObject:[NSString stringWithFormat:@"%ld",(long)i]])
        {
            NSInteger foundIndex = [[dictSocketDetail valueForKey:@"socket_id"] indexOfObject:[NSString stringWithFormat:@"%ld",(long)i]];
            if (foundIndex != NSNotFound)
            {
                if ([dictSocketDetail count] > foundIndex)
                {
                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                    [dict setValue:[[dictSocketDetail objectAtIndex:foundIndex] valueForKey:@"socket_name"] forKey:@"socket_name"];
                    [dict setValue:[[dictSocketDetail objectAtIndex:foundIndex] valueForKey:@"image_type"] forKey:@"image_type"];
                    [dict setValue:[NSString stringWithFormat:@"%d",i] forKey:@"socket_id"];

                    [arrSocketNames addObject:dict];
                }
            }
        }
        else
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setValue:[NSString stringWithFormat:@"Socket %d",i+1] forKey:@"socket_name"];
            [dict setValue:@"0" forKey:@"image_type"];
            [dict setValue:[NSString stringWithFormat:@"%d",i] forKey:@"socket_id"];
            [arrSocketNames addObject:dict];
        }
    }

    [self setNavigationViewFrames];
    
    [self ConnectPeripheralIfnotConnected];
       
    imgNotConnected = [[UIImageView alloc]init];
    imgNotConnected.image = [UIImage imageNamed:@"blegray.png"];
    imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 32, 30, 22);
    imgNotConnected.contentMode = UIViewContentModeScaleAspectFit;
    imgNotConnected.layer.masksToBounds = true;
    [self.view addSubview:imgNotConnected];
    
    imgWifiNotConnected = [[UIImageView alloc]init];
    imgWifiNotConnected.image = [UIImage imageNamed:@"wifigray.png"];
    imgWifiNotConnected.frame = CGRectMake(DEVICE_WIDTH-60, 32, 30, 22);
    imgWifiNotConnected.contentMode = UIViewContentModeScaleAspectFit;
    imgWifiNotConnected.layer.masksToBounds = true;
    [self.view addSubview:imgWifiNotConnected];
    
    
    NSInteger intPacket = [@"0" integerValue];
    NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
    [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"25" withLength:@"00" withPeripheral:classPeripheral];

    if (classPeripheral)
    {
        if (classPeripheral.state == CBPeripheralStateConnected)
        {
            [[BLEService sharedInstance] sendNotificationsSKT:classPeripheral withType:NO withUUID:@"0000AB00-2687-4433-2208-ABF9B34FB000"];
            [[BLEService sharedInstance] EnableNotificationsForCommandSKT:classPeripheral withSocketReset:NO];
            [[BLEService sharedInstance] EnableNotificationsForDATASKT:classPeripheral withSocketReset:NO];
        }
    }
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
    initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.1; //seconds
    lpgr.delegate = self;
    [tblView addGestureRecognizer:lpgr];
    
    
    if (IS_USER_SKIPPED == NO)
    {
        [self GetSocketNameandImgefromServer:deviceDetail];
    }
    
    ArrImgForCollectionView = [NSArray arrayWithObjects:@"1.png",@"2.png",@"3.png",@"4.png",@"5.png",@"6.png",@"7.png",@"8.png",@"9.png",@"10.png",@"11.png",@"12.png",@"13.png",@"14.png",@"15.png",@"16.png", nil];

    mangerSate = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

    [[BLEManager sharedManager] setDelegate:self];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    if (classPeripheral.state == CBPeripheralStateConnected) // css commented for testing
    {
        NSInteger intPacket = [@"0" integerValue];
        NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
        [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"05" withLength:@"00" withPeripheral:classPeripheral];
    }

    if (imgNotConnected && imgWifiNotConnected)
    {
        if (IS_IPHONE_X)
        {
            imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 55, 30, 22);
        }
        
        if (classPeripheral.state == CBPeripheralStateConnected)
        {
            imgNotConnected.image = [UIImage imageNamed:@"Connected_icon.png"];
        }
        else
        {
            if (mangerSate.state == CBCentralManagerStatePoweredOn)
            {
//                imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
            }
            else if(mangerSate.state == CBCentralManagerStatePoweredOff)
            {
                imgNotConnected.image = [UIImage imageNamed:@"blegray.png"];
            }
            else if(mangerSate.state == CBCentralManagerStateUnknown)
            {
//                imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
            }
        }
        
            if ([[self checkforValidString:[deviceDetail valueForKey:@"wifi_configured"]] isEqual:@"1"])
            {
                if ([APP_DELEGATE isNetworkreachable])
                {
                    isMQTTConfigured = YES;
                    imgWifiNotConnected.image = [UIImage imageNamed:@"wifiGreen.png"];
                }
                else
                {
                    isMQTTConfigured = NO;
                    imgWifiNotConnected.image = [UIImage imageNamed:@"wifired.png"];
                }
                
            }
            else
            {
//                if ([APP_DELEGATE isNetworkreachable])
//                {
//                    isMQTTConfigured = NO;
//                    imgWifiNotConnected.image = [UIImage imageNamed:@"wifiGreen.png"];
//
//                }
//                else
//                {
                    imgWifiNotConnected.image = [UIImage imageNamed:@"wifired.png"];// gray
//                }
            }
            
        
            if ([[arrSocketDevices valueForKey:@"BLE_WIFI_CONFIG_STATUS"] containsObject:@"1"])
            {
                if ([APP_DELEGATE isNetworkreachable])
                {
                    isMQTTConfigured = YES;
                    imgWifiNotConnected.image = [UIImage imageNamed:@"wifiGreen.png"];
                }
                else
                {
                    isMQTTConfigured = NO;
                    imgWifiNotConnected.image = [UIImage imageNamed:@"wifired.png"];
                }
         
            }
        else
        {
//            if ([APP_DELEGATE isNetworkreachable])
//            {
                imgWifiNotConnected.image = [UIImage imageNamed:@"wifired.png"];
//            }
//            else
//            {
//                isMQTTConfigured = NO;
//                imgWifiNotConnected.image = [UIImage imageNamed:@"wifigray.png"];
//            }
//        }
    }
    
//    if (![APP_DELEGATE isNetworkreachable]) // css commented
//    {
//        imgWifiNotConnected.image = [UIImage imageNamed:@"wifigray.png"];
//        isMQTTConfigured = NO;
//    }
    
//    if (mangerSate.state == CBCentralManagerStatePoweredOn)
//    {
//        imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
//    }
//    else if(mangerSate.state == CBCentralManagerStatePoweredOff)
//    {
//        imgNotConnected.image = [UIImage imageNamed:@"blegray.png"];
//    }
//    else
//    {
//
//    }
//
}
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [[BLEManager sharedManager] setDelegate:self];
}
-(void)setNavigationViewFrames
{
    int yy = 44;
    if (IS_IPHONE_X)
    {
        yy = 44;
    }
    self.navigationController.navigationBarHidden = true;

    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy + globalStatusHeight)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.5;
    [viewHeader addSubview:lblBack];

    UILabel * lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, yy + globalStatusHeight-1, DEVICE_WIDTH,1)];
    [lblLine setBackgroundColor:[UIColor lightGrayColor]];
//    [viewHeader addSubview:lblLine];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, globalStatusHeight, DEVICE_WIDTH-100, yy)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:[NSString stringWithFormat:@"%@ control",[deviceDetail valueForKey:@"device_name"]]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 70, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];
    
    [blueSegmentedControl removeFromSuperview];
    blueSegmentedControl =[[NYSegmentedControl alloc] initWithItems:@[@"Socket cotrol",@"Settings"]];
    blueSegmentedControl.titleTextColor = [UIColor colorWithRed:0.38f green:0.68f blue:0.93f alpha:1.0f];
    blueSegmentedControl.titleTextColor = global_brown_color;
    blueSegmentedControl.selectedTitleTextColor = [UIColor whiteColor];
    blueSegmentedControl.segmentIndicatorBackgroundColor = global_brown_color;
    blueSegmentedControl.backgroundColor = [UIColor whiteColor];
    blueSegmentedControl.borderWidth = 0.0f;
    blueSegmentedControl.segmentIndicatorBorderWidth = 0.0f;
    blueSegmentedControl.segmentIndicatorInset = 2.0f;
    blueSegmentedControl.segmentIndicatorBorderColor = self.view.backgroundColor;
    blueSegmentedControl.cornerRadius = 20;
    blueSegmentedControl.usesSpringAnimations = YES;
    [blueSegmentedControl addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventValueChanged];
    [blueSegmentedControl setFrame:CGRectMake(20,globalStatusHeight+yy+10, DEVICE_WIDTH-40, 40)];
    blueSegmentedControl.layer.cornerRadius = 20;
    blueSegmentedControl.layer.masksToBounds = YES;
    [self.view addSubview:blueSegmentedControl];

    if (IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        blueSegmentedControl.cornerRadius = 20 * approaxSize;
        [blueSegmentedControl setFrame:CGRectMake(20,globalStatusHeight+yy+10, DEVICE_WIDTH-40, 40 * approaxSize)];
        blueSegmentedControl.layer.cornerRadius = 20 * approaxSize;
    }
    
    controlView = [[UIView alloc] init];
    controlView.frame = CGRectMake(0, globalStatusHeight+yy+10, DEVICE_WIDTH, DEVICE_HEIGHT-yy-globalStatusHeight-10);
    controlView.backgroundColor = UIColor.clearColor;
    controlView.userInteractionEnabled = true;
    controlView.hidden = false;
    [self.view addSubview:controlView];
    
    UIImageView * imgBacksc = [[UIImageView alloc]initWithFrame:CGRectMake(10,10, DEVICE_WIDTH-20, 70)];
    imgBacksc.image = [UIImage imageNamed:@"SocketStatusImage.png"];
    imgBacksc.backgroundColor = UIColor.clearColor;
    [controlView addSubview:imgBacksc];
    
    settingsView = [[UIView alloc] init];
    settingsView.frame = CGRectMake(0, globalStatusHeight+yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy-globalStatusHeight);
    settingsView.backgroundColor = UIColor.clearColor;
    settingsView.userInteractionEnabled = true;
    settingsView.hidden = true;
    [self.view addSubview:settingsView];
    
    if (IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        controlView.frame = CGRectMake(0, globalStatusHeight+yy+50, DEVICE_WIDTH, DEVICE_HEIGHT-yy-globalStatusHeight-60);
        settingsView.frame = CGRectMake(0, globalStatusHeight+yy+60, DEVICE_WIDTH, DEVICE_HEIGHT-yy-globalStatusHeight-60);
    }
    
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, controlView.frame.size.width, controlView.frame.size.height-80)];
    tblView.delegate = self;
    tblView.dataSource= self;
    tblView.backgroundColor = UIColor.clearColor;
    tblView.separatorStyle = UITableViewCellSelectionStyleNone;
    tblView.hidden = false;
    tblView.scrollEnabled = false;
    tblView.separatorColor = UIColor.clearColor;
    [controlView addSubview:tblView];
    
    tblSettings = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, settingsView.frame.size.width, settingsView.frame.size.height)];
    tblSettings.delegate = self;
    tblSettings.dataSource= self;
    tblSettings.backgroundColor = UIColor.clearColor;
    tblSettings.separatorStyle = UITableViewCellSelectionStyleNone;
    tblSettings.hidden = false;
    tblSettings.scrollEnabled = false;
    tblSettings.separatorColor = UIColor.clearColor;
    [settingsView addSubview:tblSettings];
    
}
-(void)segmentClick:(NYSegmentedControl *) sender
{
    if (sender.selectedSegmentIndex==0)
    {
        controlView.hidden = false;
        settingsView.hidden = true;
    }
    else if (sender.selectedSegmentIndex==1)
    {
        controlView.hidden = true;
        settingsView.hidden = false;
    }
}
#pragma mark- Check Peripheral Connection & MQTT Available
-(void)ConnectPeripheralIfnotConnected
{
    arrAlarmIdsofDevices = [[NSMutableArray alloc] init];
    strMacAddress = [[deviceDetail valueForKey:@"ble_address"] uppercaseString];
        
//    if ([[self checkforValidString:[deviceDetail valueForKey:@"wifi_configured"]] isEqual:@"1"])
//    {
//        imgWifiNotConnected.image = [UIImage imageNamed:@"wifiGreen.png"];
//    }
//    else
//    {
//        if ([APP_DELEGATE isNetworkreachable])
//        {
//            imgWifiNotConnected.image = [UIImage imageNamed:@"wifired.png"];
//        }
//        else
//        {
//            imgWifiNotConnected.image = [UIImage imageNamed:@"wifigray.png"];
//        }
//    }
    
    [statusCheckTimer invalidate];
    statusCheckTimer = nil;

    [intialConnectHud removeFromSuperview];
    intialConnectHud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:intialConnectHud];

    if (classPeripheral.state == CBPeripheralStateConnected)
    {
        intialConnectHud.labelText = @"Connecting...";
        statusCheckTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(TimeOutforWifiConfiguration) userInfo:nil repeats:NO]; // 4
    }
    else
    {
        if([APP_DELEGATE isNetworkreachable])
        {
            intialConnectHud.labelText = @"Checking Status...";
        }
        statusCheckTimer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(TimeOutforWifiConfiguration) userInfo:nil repeats:NO];
    }
    [intialConnectHud show:YES];

    if (classMqttObj == nil)
    {
        [self ConnecttoMQTTSocketServer];
    }
    else
    {
        if ([classMqttObj connState] == 2)
        {
                NSString * publishTopic = [NSString stringWithFormat:@"/vps/app/%@",strMacAddress];
                UInt16 subTop = [classMqttObj subscribe:publishTopic qos:2];

                isMQTTConfigured = NO;
                classMqttObj.delegate = self;
                classMqttObj.autoReconnect = YES;

                if (classPeripheral.state != CBPeripheralStateConnected)
                {
                    NSString * strTopic = [NSString stringWithFormat:@"/vps/device/%@",[strMacAddress uppercaseString]];
                    NSArray * arrPackets = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:16],[NSNumber numberWithInt:0], nil];
                    [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];

                    arrMQTTalarmState = [[NSMutableArray alloc] init];
                    NSArray * arrAlarm = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:21],[NSNumber numberWithInt:0], nil];
                    [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrAlarm];
                }
            }
            else if ([classMqttObj connState] == 3)
            {
                [self ConnecttoMQTTSocketServer];
            }
        }
        
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidConnectNotificationSocket" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidDisConnectNotificationSocket" object:nil];
        
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidConnectNotification:) name:@"DeviceDidConnectNotificationSocket" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidDisConnectNotification:) name:@"DeviceDidDisConnectNotificationSocket" object:nil];

    if (classPeripheral == nil)
    {
        NSMutableArray * arrCnt = [[NSMutableArray alloc] init];
        arrCnt = [[BLEManager sharedManager] arrBLESocketDevices];
        BOOL isPeriphealFound = NO;
        if ([arrCnt count] > 0)
        {
            for (int i=0; i<[arrCnt count]; i++)
            {
                if ([[[arrCnt objectAtIndex:i] valueForKey:@"ble_address"] isEqualToString:strMacAddress])
                {
                    CBPeripheral * tmpPerphrl = [[arrCnt objectAtIndex:i] objectForKey:@"peripheral"];
                    [self setPeripheraltoCheckKeyUsage:tmpPerphrl];
                    classPeripheral = tmpPerphrl;
                    [[BLEManager sharedManager] connectDevice:tmpPerphrl];
                    isPeriphealFound = YES;
                        
                    [self performSelector:@selector(ConnectionTimeOutCall) withObject:nil afterDelay:6];
                        
                    if ([[arrSocketDevices valueForKey:@"ble_address"] containsObject:[[[arrCnt objectAtIndex:i] valueForKey:@"ble_address"] uppercaseString]])
                    {
                        NSInteger idxAddress = [[arrSocketDevices valueForKey:@"ble_address"] indexOfObject:[[arrCnt objectAtIndex:i] valueForKey:@"ble_address"]];
                        if (idxAddress != NSNotFound)
                        {
                            if (idxAddress < [arrSocketDevices count])
                            {
                                [[arrSocketDevices objectAtIndex:idxAddress]setObject:tmpPerphrl forKey:@"peripheral"];
                                [[arrSocketDevices objectAtIndex:idxAddress]setValue:[NSString stringWithFormat:@"%@",tmpPerphrl.identifier] forKey:@"identifier"];
                                if (tmpPerphrl.state == CBPeripheralStateConnected)
                                {
                                    classPeripheral = tmpPerphrl;
                                    [self setPeripheraltoCheckKeyUsage:tmpPerphrl];
                                }
                                else
                                {
                                    classPeripheral = tmpPerphrl;
                                    [self setPeripheraltoCheckKeyUsage:tmpPerphrl];
                                    [[BLEManager sharedManager] connectDevice:tmpPerphrl];
                                }
                            }
                        }
                    }
                    break;
                }
            }
        }
        if (isPeriphealFound == NO)
        {
            NSArray * tmparr = [[BLEManager sharedManager] getLastSocketConnected];
            NSString * strDeviceIdentifier = [self checkforValidString:[deviceDetail valueForKey:@"identifier"]];
                
            for (int i=0; i<tmparr.count; i++)
            {
                CBPeripheral * p = [tmparr objectAtIndex:i];
                NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",p.identifier];
                if ([strDeviceIdentifier isEqualToString:@"NA"])
                {
                    if ([[arrSocketDevices valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
                    {
                        NSInteger idxAddress = [[arrSocketDevices valueForKey:@"identifier"] indexOfObject:strCurrentIdentifier];
                        if (idxAddress != NSNotFound)
                        {
                            if (idxAddress < [arrSocketDevices count])
                            {
                                strDeviceIdentifier = [[arrSocketDevices objectAtIndex:idxAddress] valueForKey:@"identifier"];
                            }
                        }
                    }
                }
                if ([strDeviceIdentifier isEqualToString:strCurrentIdentifier])
                {
                    if (p.state == CBPeripheralStateConnected)
                    {
                        classPeripheral = p;
                        [self setPeripheraltoCheckKeyUsage:p];
                    }
                    else
                    {
                        classPeripheral = p;
                        [self setPeripheraltoCheckKeyUsage:p];
                        [[BLEManager sharedManager] connectDevice:p];
                    }
                    break;
                }
            }
        }
    }
    else
    {
        if (classPeripheral.state != CBPeripheralStateConnected)
        {
            [self performSelector:@selector(ConnectionTimeOutCall) withObject:nil afterDelay:6];
            [self setPeripheraltoCheckKeyUsage:classPeripheral];
            [[BLEManager sharedManager] connectDevice:classPeripheral];
        }
        else if(classPeripheral.state == CBPeripheralStateConnected)
        {
            NSInteger intPacket = [@"0" integerValue];
            NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
            
            arrAlarmIdsofDevices = [[NSMutableArray alloc] init];
            [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"05" withLength:@"00" withPeripheral:classPeripheral];
            [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"21" withLength:@"00" withPeripheral:classPeripheral];
        }
    }
}

#pragma mark- BLE Connection States

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn)
    {
//        imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
    }
    else if(central.state == CBCentralManagerStatePoweredOff)
    {
        imgNotConnected.image = [UIImage imageNamed:@"blegray.png"];
    }
    else
    {
        imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
    }
}
-(void)setPeripheraltoCheckKeyUsage:(CBPeripheral *)tmpPerphrl
{
    if ([[arrPeripheralsCheck valueForKey:@"identifier"] containsObject:[NSString stringWithFormat:@"%@",tmpPerphrl.identifier]])
    {
        NSInteger foundIndex = [[arrPeripheralsCheck valueForKey:@"identifier"] indexOfObject:[NSString stringWithFormat:@"%@",tmpPerphrl.identifier]];
        if (foundIndex != NSNotFound)
        {
            if ([arrPeripheralsCheck count] > foundIndex)
            {
                NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:@"1700", @"status", [NSString stringWithFormat:@"%@",tmpPerphrl.identifier],@"identifier", nil];
                [arrPeripheralsCheck replaceObjectAtIndex:foundIndex withObject:dict];
            }
        }
    }
    else
    {
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:@"1700", @"status", [NSString stringWithFormat:@"%@",tmpPerphrl.identifier],@"identifier", nil];
        [arrPeripheralsCheck addObject:dict];
    }
}
-(void)ConnectionTimeOutCall
{
    [APP_DELEGATE endHudProcess];
    if (classPeripheral.state == CBPeripheralStateConnected)
    {
    }
    else
    {
        //show popup something went wrong please check device is nearby or turn on.
    }
}

#pragma mark- UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblView)
    {
        return 7;
    }
    else
    {
        return 6;
    }
    return  7; // array have to pass
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblView)
    {
        return 65;
    }
    else
    {
        return 65;
    }
    
    return 65;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    SocketCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[SocketCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    
    
    [cell.swSocket addTarget:self action:@selector(switchSocketStateClick:) forControlEvents:UIControlEventValueChanged];
    [cell.btnAlaram addTarget:self action:@selector(btnAlarmClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnAlaram.tag = indexPath.row;
    
    cell.btnMore.hidden = false;
    [cell.btnMore addTarget:self action:@selector(btnMoreClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnMore.tag = indexPath.row;
    
//    cell.btnSocket.hidden = false;
//    [cell.btnSocket addTarget:self action:@selector(btnSocketClick:) forControlEvents:UIControlEventTouchUpInside];
//    cell.btnSocket.tag = indexPath.row;

    
    NSInteger indexNo = indexPath.row + 1;
//    NSString * strSocketName = [NSString stringWithFormat:@"Socket %ld",(long)indexNo];
    
    cell.swSocket.tag = 100 + indexPath.row + 1;
    NSString * strSwitchStatus = [NSString stringWithFormat:@"Switch%ld",(long)indexNo];
    int swithcStatus = [[dictFromHomeSwState valueForKey:strSwitchStatus] intValue];
    
    if (swithcStatus == 1)
    {
        [cell.swSocket setOn:YES animated:YES];
    }
    else
    {
        [cell.swSocket setOn:NO animated:YES];
    }

    if (indexPath.row == 6)
    {
        cell.lblDeviceName.text = @"All sockets ON/OFF";
        cell.swSocket.tag = 107;
        cell.imgSwitch.hidden = true;
        cell.lblDeviceName.frame = CGRectMake(10, 0, DEVICE_WIDTH-20, 60);
        cell.btnAlaram.hidden = true;
        cell.btnMore.hidden = true;
        cell.btnSocket.hidden = true;
        [self handleLongPress:nil];
        
        NSArray * allValues = [dictFromHomeSwState allValues];
        NSString * strAllSwitches = [allValues componentsJoinedByString:@""];
        
        if ([strAllSwitches isEqualToString:@"111111"] || [strAllSwitches isEqualToString:@"010101010101"])
        {
            [cell.swSocket setOn:YES animated:YES];
        }
        else
        {
            [cell.swSocket setOn:NO animated:YES];
        }
    }
    else
    {
        if (![[[arrSocketNames objectAtIndex:indexPath.row] valueForKey:@"image_type"] isEqual:@"0"])
        {
            cell.imgSwitch.image = [UIImage imageNamed:[[arrSocketNames objectAtIndex:indexPath.row] valueForKey:@"image_type"]];
            cell.lblDeviceName.text = [[arrSocketNames objectAtIndex:indexPath.row] valueForKey:@"socket_name"];
        }
        else
        {
            cell.imgSwitch.image = [UIImage imageNamed:@"sw.png"];
            cell.lblDeviceName.text = [[arrSocketNames objectAtIndex:indexPath.row] valueForKey:@"socket_name"];
        }
    }
    
    if (tableView == tblSettings)
    {
        cell.lblSettings.hidden = false;
        cell.lblDeviceName.hidden = true;
        cell.imgSwitch.hidden = false;
        cell.swSocket.hidden = true;
        cell.btnAlaram.hidden = true;
        cell.imgArrow.hidden = false;
        cell.lblLineLower.hidden = true;
        cell.btnMore.hidden = true;

        cell.lblBack.frame = CGRectMake (20, 0,DEVICE_WIDTH-40,60);
        cell.lblBack.layer.borderColor = UIColor.lightGrayColor.CGColor;
        
        cell.imgSwitch.frame =  CGRectMake(10, 20, 20, 20);
        NSArray * imgArr = [[NSArray alloc]initWithObjects:@"wifiWhite.png",@"delete_icon.png",@"reset.png",@"",@"",@"", nil];
        cell.imgSwitch.image =  [UIImage imageNamed:[NSString stringWithFormat:@"%@",[imgArr objectAtIndex:indexPath.row]]];

        if (indexPath.row == 0)
        {
            cell.lblSettings.text = @"Wi-Fi setting";
        }
        else if (indexPath.row == 1)
        {
            cell.lblSettings.text = @"Delete device";
        }
        else if (indexPath.row == 2)
        {
            cell.lblSettings.text = @"Reset device";
        }
        else if (indexPath.row == 3)
        {
            cell.lblSettings.text = [NSString stringWithFormat:@"Hardware Version - %@",strVersionNo];
        }
        else if (indexPath.row == 4)
        {
            cell.lblSettings.text = @"Factory test Dileep";
        }
        else if (indexPath.row == 5)
        {
            cell.lblSettings.text = @"OTA Dileep";
        }
    }
    
    cell.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblSettings)
    {
        if (indexPath.row == 0)
        {
            NSString * strWifiConfig = [deviceDetail valueForKey:@"wifi_configured"];
            NSString * strMacaddress = [deviceDetail  valueForKey:@"ble_address"];

            SocketWiFiSetupVC * socketWifi = [[SocketWiFiSetupVC alloc] init];
            socketWifi.classPeripheral = classPeripheral;
            socketWifi.strBleAddress = strMacaddress;
            socketWifi.isWIFIconfig = strWifiConfig; 
            socketWifi.dictData = deviceDetail;
            socketWifi.delegate = self;
            [self.navigationController pushViewController:socketWifi animated:true];
        }
        else if (indexPath.row == 1)
        {
            NSString * msgStr = [NSString stringWithFormat:@"Are you sure. You want to delete this device ?"];
            
//            if (classPeripheral.state ==CBPeripheralStateConnected)
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeWarning];
                [alert addButton:@"Yes" withActionBlock:^{
                    
                    [APP_DELEGATE startHudProcess:@"Deleting..."];

                    if ([IS_USER_SKIPPED isEqualToString:@"NO"])
                    {
                        if ([APP_DELEGATE isNetworkreachable])
                        {
//                            isRequestfor = @"DeleteDeviceCheck";
                            [self CheckUserCredentialDetials];
                        }
                    }
                    [self performSelector:@selector(timeOutForDeleteDevice) withObject:nil afterDelay:5];
                    // Put your action here
                    if ([deviceDetail count]> 0)
                    {
                        if ([[deviceDetail  valueForKey:@"device_type"] isEqual:@"4"])
                        {
                            if ([deviceDetail count]> 0)
                            {
                                [self deleteSocketDevice];
                            }
                        }
                    }
                }];
                
                alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:msgStr
                       withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
                   withDoneButtonTitle:@"No" andButtons:nil];
            }
//            else
            {
//                [self AlertViewFCTypeCautionCheck:@"Please conncet device."];
            }
        }
        else if (indexPath.row == 2)
        {
            ResetSocketVC * rstSVC = [[ResetSocketVC alloc] init];
            [self.navigationController pushViewController:rstSVC animated:true];
        }
        else if (indexPath.row == 4)
        {
            NSInteger intPacket = [@"0" integerValue];
            NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
            [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"35" withLength:@"00" withPeripheral:classPeripheral];
        }
        else if (indexPath.row == 5)
        {
            [self OTAFordileep];
        }
    }
}
#pragma mark- Socket Switch Status & Buton Click Events
-(void)switchSocketStateClick:(id)sender
{
    UISwitch* RecntSwitch = [[UISwitch alloc] init];
    RecntSwitch = (UISwitch *)sender; // UISwitch *RecntSwitch
    
    long intTagval = RecntSwitch.tag ;
    NSLog(@"%ld",(long)intTagval);
    
    NSString * strTopic = [NSString stringWithFormat:@"/vps/device/%@",[strMacAddress uppercaseString]]; // going from device
    NSString * strSlectedIndex = [NSString stringWithFormat:@"%ld",intTagval - 101];
    NSInteger intIndex = [strSlectedIndex integerValue];
    NSData * dataIndex = [[NSData alloc] initWithBytes:&intIndex length:1];

    int index = [strSlectedIndex intValue];
    NSInteger switchStatus = [@"00" integerValue];

    if ([RecntSwitch isOn])
    {
        switchStatus = [@"01" integerValue];
    }
    
    NSData * dataSwitchStatus = [[NSData alloc] initWithBytes:&switchStatus length:1];
    
    NSMutableData *completeData = [dataIndex mutableCopy];
    [completeData appendData:dataSwitchStatus];
    
    NSInteger intPacket = [@"0" integerValue];
    NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];

    NSString * strIndex = [NSString stringWithFormat:@"%02ld",intTagval - 101];
    
    if (classPeripheral.state  == CBPeripheralStateConnected)
    {
        if ([strIndex  isEqual: @"06"])
        {
            [[BLEService sharedInstance] WriteSocketData:dataSwitchStatus withOpcode:@"10" withLength:@"1" withPeripheral:classPeripheral];
//            [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"05" withLength:@"00" withPeripheral:classPeripheral];
        }
        else
        {
            [[BLEService sharedInstance] WriteSocketData:completeData withOpcode:@"09" withLength:@"2" withPeripheral:classPeripheral];
//            [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"05" withLength:@"00" withPeripheral:classPeripheral];
        }
    }
    else //MQTT
    {
        if (isMQTTConfigured == YES)
        {
            [APP_DELEGATE endHudProcess];
            [APP_DELEGATE startHudProcess:@"Please Wait..."];
            [mqttRequestTimeOut invalidate];
            mqttRequestTimeOut = nil;
            mqttRequestTimeOut = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(TimeOutForSwithStatus) userInfo:nil repeats:NO];

            if ([strIndex  isEqual: @"06"])
            {
                NSArray * arrPackets =[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:10],[NSNumber numberWithInt:1],[NSNumber numberWithInteger:switchStatus], nil];
                [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];
                mqttSwithPreviousStatus = [NSString stringWithFormat:@"10:%@",[NSNumber numberWithInteger:switchStatus]];
//                arrPackets =[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5], nil];
//                [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];
            }
            else
            {
                NSArray * arrPackets =[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:9],[NSNumber numberWithInt:2],[NSNumber numberWithInt:index],[NSNumber numberWithInteger:switchStatus], nil];
                [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];
                mqttSwithPreviousStatus = [NSString stringWithFormat:@"%@:%@",[NSNumber numberWithInt:index+1], [NSNumber numberWithInteger:switchStatus]];

//                arrPackets =[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5], nil];
//                [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];
            }
        }
        else
        {
            
            [APP_DELEGATE endHudProcess];
            
            [self TostNotification:@"Please conect with bluetooth or internet."];

            if ([RecntSwitch isOn])
            {
                [RecntSwitch setOn:NO];
            }
            else
            {
                [RecntSwitch setOn:YES];
            }
            [tblView reloadData];
        }
    }
}
-(void)TimeOutForSwithStatus
{
    NSArray * arrTemp = [mqttSwithPreviousStatus componentsSeparatedByString:@":"];
    if ([arrTemp count] >=2)
    {
        NSString * strIndex = [arrTemp objectAtIndex:0];
        NSString * strStatus = [arrTemp objectAtIndex:1];
        
        if ([strStatus isEqualToString:@"1"])
        {
            strStatus = @"0";
        }
        else
        {
            strStatus = @"1";
        }
        
        if ([strIndex isEqualToString:@"10"])
        {
            for (int i =0; i < 6; i++)
            {
                [dictFromHomeSwState setValue:[NSString stringWithFormat:@"%@",strStatus] forKey:[NSString stringWithFormat:@"Switch%d",i+1 ]];
            }
        }
        else
        {
            [dictFromHomeSwState setValue:[NSString stringWithFormat:@"%@",strStatus] forKey:[NSString stringWithFormat:@"Switch%@",strIndex ]];
        }

    }
    [APP_DELEGATE endHudProcess];
    [tblView reloadData];
}
-(void)btnBackClick
{
//    NSLog(@"terwe=%@",[[NSArray new] objectAtIndex:3]);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidConnectNotificationSocket" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidDisConnectNotificationSocket" object:nil];
    [self.navigationController popViewControllerAnimated:true];
}

-(void)btnAlarmClick:(UIButton *)sender
{
    globalSocketAlarmVC  = [[SocketAlarmVC alloc] init];
    globalSocketAlarmVC.intSelectedSwitch = sender.tag + 1; 
    globalSocketAlarmVC.periphPass = classPeripheral;
    globalSocketAlarmVC.strMacaddress  = strMacAddress;
    globalSocketAlarmVC.delegate = self;
    globalSocketAlarmVC.dictDeviceDetail = deviceDetail;
    [self.navigationController pushViewController:globalSocketAlarmVC animated:true];
}
-(void)timeOutForDeleteDevice
{
    [APP_DELEGATE endHudProcess];
}
-(void)btnMoreClick:(id)sender
{
    [self btnAction:sender];
    selectedSocketIndex = [sender tag];
    [dictImgs setValue:[NSString stringWithFormat:@"%ld",(long)selectedSocketIndex] forKey:@"Index"];
}

-(void)btnAction:(UIButton *)sender
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Vithamas socket" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Alarm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
        //  alarm.
        
            globalSocketAlarmVC  = [[SocketAlarmVC alloc] init];
            globalSocketAlarmVC.intSelectedSwitch = sender.tag + 1;
            globalSocketAlarmVC.periphPass = classPeripheral;
            globalSocketAlarmVC.strMacaddress  = strMacAddress;
            globalSocketAlarmVC.delegate = self;
            globalSocketAlarmVC.dictDeviceDetail = deviceDetail;
            [self.navigationController pushViewController:globalSocketAlarmVC animated:true];

            // Code for Alarm
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Set Name & image" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        [self SetupForSetSocketNameImages:[sender tag]];
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
    {   }]];
    
    [actionSheet setModalPresentationStyle:UIModalPresentationPopover];

    UIPopoverPresentationController *popPresenter = [actionSheet popoverPresentationController];
    popPresenter.sourceView = sender;
    popPresenter.sourceRect = sender.bounds; // You can set position of popover
    [self presentViewController:actionSheet animated:TRUE completion:nil];
}
-(void)CheckUserCredentialDetials
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
    [dict setValue:CURRENT_USER_PASS forKey:@"password"];

    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"CheckUserDetails";
    manager.delegate = self;
    NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/check_user_details";
    [manager urlCall:strServerUrl withParameters:dict];
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
#pragma mark- Recieve Data from BLE
-(void)AlarmListStoredinDevice:(NSMutableDictionary *)arrDictDetails
{
    [arrAlarmIdsofDevices addObject:arrDictDetails];
    
    if ([arrAlarmIdsofDevices count] >= 12)
    {
//        NSLog(@"Received Alarm from Device=%@",arrAlarmIdsofDevices);
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            for (int i = 0; i < [arrAlarmIdsofDevices count]; i++)
            {
                NSString * strOnTime = [self checkforValidString:[[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"onTime"]];
                NSString * strOffTime = [self checkforValidString:[[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"offTime"]];
                NSString * stralarmState = [[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"alarmState"];

                if ([stralarmState isEqualToString:@"01"])
                {
                    
                }
                if ([strOnTime isEqualToString:@"ffffffff"] && [strOffTime isEqualToString:@"ffffffff"])
                {
                    strOnTime = @"NA";
                    strOffTime = @"NA";
                }
                else if([strOnTime isEqualToString:@"ffffffff"] || [strOffTime isEqualToString:@"ffffffff"])
                {
                    if ([strOnTime isEqualToString:@"ffffffff"])
                    {
                        strOnTime = @"NA";
                    }
                    if([strOffTime isEqualToString:@"ffffffff"])
                    {
                        strOffTime = @"NA";
                    }
                }
                
                NSString * strOnOriginal = @"NA";
                NSString * strOffOriginal= @"NA";
                NSString * strTotalDaysCount = [[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"dayValue"];

                if (![strOnTime isEqualToString:@"NA"])
                {
                    strOnTime = [self stringFroHex:[[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"onTime"]];
                    strOnOriginal = [self getHoursfromString:strOnTime withDaysCount:strTotalDaysCount];
                }
                if (![strOffTime isEqualToString:@"NA"])
                {
                    strOffTime = [self stringFroHex:[[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"offTime"]];
                    strOffOriginal = [self getHoursfromString:strOffTime withDaysCount:strTotalDaysCount];
                }
                
                NSString * strAlarmId = [[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"alaramID"];
                NSString * strsocketID = [[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"socketID"];
                NSString * strdayValue = [self getSelectedDaysforDayByteValue:[[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"dayValue"]];

                NSMutableArray * arrdata = [[NSMutableArray alloc] init];
                NSString * strQuery = [NSString stringWithFormat:@"select * from Socket_Alarm_Table  where ble_address = '%@' and alarm_id = '%@'",strMacAddress,strAlarmId];
                [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:arrdata];

                
                if ([arrdata count] == 0)
                {
                    if (![[[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"alaramID"] isEqual:@"0"])
                    {
                        NSString * strInsert  =[NSString stringWithFormat:@"insert into 'Socket_Alarm_Table'('alarm_id','socket_id','day_selected','OnTimestamp','OffTimestamp','alarm_state','ble_address','On_original','Off_original') values('%@','%@','%@','%@','%@','%@','%@','%@','%@')",strAlarmId,strsocketID,strdayValue,strOnTime,strOffTime,stralarmState,strMacAddress,strOnOriginal,strOffOriginal];
                        [[DataBaseManager dataBaseManager] execute:strInsert];
                    }
                }
                else
                {
                    if (![[[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"alaramID"] isEqual:@"0"])
                    {
                        NSString * update = [NSString stringWithFormat:@"update Socket_Alarm_Table set alarm_id = '%@', socket_id ='%@',day_selected='%@', onTimestamp ='%@', offTimestamp = '%@', alarm_state = '%@', On_original = '%@', Off_original = '%@' where ble_address = '%@' and alarm_id = '%@'",strAlarmId,strsocketID,strdayValue,strOnTime,strOffTime,stralarmState,strOnOriginal,strOffOriginal,strMacAddress,[[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"alaramID"]];
                        [[DataBaseManager dataBaseManager] execute:update];
                    }
                }
            }
        });
    }
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
        [dateformatter setDateFormat:@"dd/MM/yyyy hh:mm aa"];
    }
    else
    {
        [dateformatter setDateFormat:@"hh:mm aa"];
    }
    NSString *dateString=[dateformatter stringFromDate:date];
    return dateString;
}
-(void)ReceiveAllSoketONOFFState:(NSString *)strState withStatus:(BOOL)isSuccess;
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
            for (int i =0; i < 6; i++)
            {
                if ([strState length] >= 12)
                {
                    [dictFromHomeSwState setValue:[NSString stringWithFormat:@"%@",[strState substringWithRange:NSMakeRange(i * 2, 2)]] forKey:[NSString stringWithFormat:@"Switch%d",i+1 ]];
                }
            }
        if (([strState length] >= 12) && isSuccess == YES)
        {
            [tblView reloadData];
            if (globalDashBoardVC)
            {
                if ([[strState substringWithRange:NSMakeRange(0, 12)] isEqualToString:@"010101010101"])
                {
                    [globalDashBoardVC UpdateSocketSwithwithBLE:YES withMacAddress:strMacAddress];
                }
                else
                {
                    [globalDashBoardVC UpdateSocketSwithwithBLE:NO withMacAddress:strMacAddress];
                }
            }
        }
    });
}
-(void)ReceivedSwitchStatusfromDevice:(NSMutableDictionary *)dictSwitch;
{
    [APP_DELEGATE endHudProcess];
    dictFromHomeSwState = dictSwitch;
    if (globalDashBoardVC)
    {
        NSArray * allValues = [dictSwitch allValues];
        
        NSMutableArray  * arrStatus = [[NSMutableArray alloc] init];
        [arrStatus addObject:@"5"];
        [arrStatus addObject:@"6"]; //6

        for (int i =0 ; i < [allValues count]; i++)
        {
            NSInteger intValue = [[allValues objectAtIndex:i] integerValue];
            [arrStatus addObject:[NSString stringWithFormat:@"%ld",(long)intValue]];
        }
        [globalDashBoardVC UpdateSocketSwithchStatus:arrStatus withMacAddress:strMacAddress];
    }
    [tblView reloadData];
}
-(void)ReceivedFirmwareVersionFromDevice:(NSString *)strVersion
{
    NSString * strVer = [strVersion substringWithRange:NSMakeRange(0, 2)];
    NSString * strVer1 = [strVersion substringWithRange:NSMakeRange(2, 1)];
    NSString * strVer2 = [strVersion substringWithRange:NSMakeRange(3, 1)];

    
    strVer = [strVer stringByReplacingOccurrencesOfString:@"0" withString:@""];
    strVer1  = [strVer1 stringByReplacingOccurrencesOfString:@"0" withString:@""];

    strVersionNo = [NSString stringWithFormat:@"%@.%@",strVer,strVer2];
    [tblSettings reloadData];
}
-(void)ReceivedMQTTStatus:(NSDictionary *)dictSwitch
{
    
}
-(void)ConnecttoMQTTSocketServer
{
    NSUUID *uuid = [NSUUID UUID];
    NSString *strClientId = [uuid UUIDString];

    classMqttObj = [[CocoaMQTT alloc] initWithClientID:strClientId host:@"iot.vithamastech.com" port:8883];
    classMqttObj.delegate = self;
    [classMqttObj selfSignedSSLSetting];
    classMqttObj.autoReconnect = YES;
    BOOL isConnected =  [classMqttObj connect];
    if (isConnected)
    {
        NSLog(@"MQTT is CONNECTING....");
    }
}
-(void)TimeOutforWifiConfiguration
{
    [intialConnectHud hide:YES];
    [intialConnectHud removeFromSuperview];
    intialConnectHud=nil;
    
    if (isMQTTConfigured == YES)
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
            imgWifiNotConnected.image = [UIImage imageNamed:@"wifiGreen.png"];
        }
        else
        {
            imgWifiNotConnected.image = [UIImage imageNamed:@"wifired.png"];
        }
    }
    else
    {
//        if ([APP_DELEGATE isNetworkreachable])
//        {
//            imgWifiNotConnected.image = [UIImage imageNamed:@"wifired.png"];
//        }
//        else
//        {
//            imgWifiNotConnected.image = [UIImage imageNamed:@"wifigray.png"];
//        }
//        [APP_DELEGATE endHudProcess];
    }
}
#pragma mark - Common Method to Publish on MQTT
-(void)PublishMessageonMQTTwithTopic:(NSString *)strTopic withDataArray:(NSArray *)arrData
{
//    [APP_DELEGATE startHudProcess:@"Conneting..."];
    NSLog(@"===========================================================================================%hhu",[classMqttObj connState]);
    CocoaMQTTMessage * msg = [[CocoaMQTTMessage alloc] initWithTopic:strTopic payload:arrData qos:2 retained:NO dup:NO];
    UInt16 subTop = [classMqttObj publish:msg];
    NSLog(@"MQTT MSG Sent==%hu",subTop);
}
#pragma mark :- MQTT Delegate Methods
-(void)mqtt:(CocoaMQTT *)mqtt didReceive:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler
{
    NSLog(@"Trust==%@",trust);
    if (completionHandler)
    {
        completionHandler(YES);
    }
}
-(void)mqtt:(CocoaMQTT *)mqtt didConnectAck:(enum CocoaMQTTConnAck)ack
{
    [APP_DELEGATE endHudProcess];

//    imgWifiNotConnected.image = [UIImage imageNamed:@"wifiGreen.png"];
    NSString * publishTopic = [NSString stringWithFormat:@"/vps/app/%@",strMacAddress];
    UInt16 subTop = [mqtt subscribe:publishTopic qos:2];
    NSLog(@"%d",subTop);
    NSLog(@"MQTT Connected --->");
    [self.delegate ConnectedSocketfromSocketDetailPage:mqtt];
    if (globalSocketAlarmVC)
    {
        
    }
}
-(void)mqtt:(CocoaMQTT *)mqtt didPublishMessage:(CocoaMQTTMessage *)message id:(uint16_t)id
{
    NSArray * arrAck = [message payload];
    if([arrAck count]>0)
    {
        NSString * strAck = [arrAck componentsJoinedByString:@","];
        NSLog(@"Socket Detail mqtt didPublishMessage =%@",strAck);
    }
}
-(void)mqtt:(CocoaMQTT *)mqtt didPublishAck:(uint16_t)id
{
}
-(void)mqtt:(CocoaMQTT *)mqtt didReceiveMessage:(CocoaMQTTMessage *)message id:(uint16_t)id
{
    //Whenever message received we will send it to socketdtailvc.
//    NSLog(@"Socket Detail mqtt didReceiveMessage =%@",[message payload]);
    NSString * strTopic = [self checkforValidString:[message topic]];
    NSArray * arrTopics = [strTopic componentsSeparatedByString:@"/"];
    NSString * strAddress = @"NA";
    if([arrTopics count]>= 4) // 3 previously
    {
        strAddress = [arrTopics lastObject];
    }
    
    NSArray * arrReceive = [message payload];
    if([arrReceive count]>0)
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setValue:arrReceive forKey:@"data"];
        [dict setValue:strAddress forKey:@"ble_address"];
        [self ReceivedMQTTResponsefromserver:dict];
    }
}
-(void)mqtt:(CocoaMQTT *)mqtt didSubscribeTopic:(NSArray<NSString *> *)topics
{
    NSLog(@"Topic Subscried successfully Socket Detail=%@",topics);
    
//    [deviceDetail setValue:@"1" forKey:@"wifi_configured"];
    
    isTopicSubscribed = YES;
    
    if (classPeripheral)
    {
        if (classPeripheral.state != CBPeripheralStateConnected)
        {
            NSString * strTopic = [NSString stringWithFormat:@"/vps/device/%@",[strMacAddress uppercaseString]];
            NSArray * arrPackets =[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:16],[NSNumber numberWithInt:0], nil];
            [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];
            arrMQTTalarmState = [[NSMutableArray alloc] init];
            NSArray * arrAlarm = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:21],[NSNumber numberWithInt:0], nil];
            [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrAlarm];
        }
    }
}
-(void)mqtt:(CocoaMQTT *)mqtt didUnsubscribeTopic:(NSString *)topic
{
    NSLog(@"Topic didUnsubscribeTopic =%@",topic);
}
-(void)mqtt:(CocoaMQTT *)mqtt didStateChangeTo:(enum CocoaMQTTConnState)state
{
//    NSLog(@"State Changed===>%hhu",state);
    if (state == 3)
    {
        isTopicSubscribed = NO;
    }
}
-(void)mqttDidDisconnect:(CocoaMQTT *)mqtt withError:(NSError *)err
{
    isTopicSubscribed = NO;

    NSDictionary * dictError = [err userInfo];
    if ([[dictError allKeys] containsObject:@"NSLocalizedDescription"])
    {
        isMQTTConfigured = NO;
        if ([[[err userInfo] valueForKey:@"NSLocalizedDescription"] isEqualToString:@"nodename nor servname provided, or not known"])
        {
            if ([APP_DELEGATE isNetworkreachable])
            {
                imgWifiNotConnected.image = [UIImage imageNamed:@"wifired.png"];
            }
            else
            {
                imgWifiNotConnected.image = [UIImage imageNamed:@"wifigray.png"];
            }
        }
    }
    else
    {
//        NSUUID *uuid = [NSUUID UUID];
//        NSString *strClientId = [uuid UUIDString];

        //        classMqttObj = [[CocoaMQTT alloc] initWithClientID:strClientId host:@"iot.vithamastech.com" port:8883];
//        classMqttObj.delegate = self;
//        [classMqttObj selfSignedSSLSetting];
//        BOOL isConnected =  [classMqttObj connect];
//        if (isConnected)
//        {
//            NSLog(@"MQTT is CONNECTING....");
//        }
    }
//    NSLog(@"Disconnect Errore===>%@",err.description);
}
-(void)mqttDidPing:(CocoaMQTT *)mqtt
{
    
}
-(void)mqttDidReceivePong:(CocoaMQTT *)mqtt
{
    
}
#pragma mark - BLE Delegate Callback Methods
-(void)DeviceDidConnectNotification:(NSNotification*)notification //Connect periperal
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [APP_DELEGATE endHudProcess];
        
        if (classPeripheral.state == CBPeripheralStateConnected)
        {
            NSInteger intPacket = [@"0" integerValue];
            NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
            [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"05" withLength:@"00" withPeripheral:classPeripheral];
        }
    });
}
-(void)DeviceDidDisConnectNotification:(NSNotification*)notification //Disconnect periperal
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [APP_DELEGATE endHudProcess];
        [[[BLEManager sharedManager] arrBLESocketDevices] removeAllObjects];
        [[BLEManager sharedManager] rescan];
        [APP_DELEGATE endHudProcess];});
}
-(void)AuthenticationCompleted:(CBPeripheral *)peripheral
{
    classPeripheral = peripheral;
    //Here you have to ask for device name... Save click call SAVE DEVICE API and save it to database.
    //After that Ask user to whether they want wifi configration.
}
- (NSData *)dataFromHexString:(NSString*)hexStr
{
    const char *chars = [hexStr UTF8String];
    int i = 0, len = hexStr.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
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
-(NSString*)stringFroHex:(NSString *)hexStr
{
    unsigned long long startlong;
    NSScanner* scanner1 = [NSScanner scannerWithString:hexStr];
    [scanner1 scanHexLongLong:&startlong];
    double unixStart = startlong;
    NSNumber * startNumber = [[NSNumber alloc] initWithDouble:unixStart];
    return [startNumber stringValue];
}
-(NSString*)hexFromStr:(NSString*)str
{
    NSData* nsData = [str dataUsingEncoding:NSUTF8StringEncoding];
    const char* data = [nsData bytes];
    NSUInteger len = nsData.length;
    NSMutableString* hex = [NSMutableString string];
    for(int i = 0; i < len; ++i)
        [hex appendFormat:@"%02X", data[i]];
    NSLog(@"HEX valueeeee====>>>%@",hex);
    return hex;
}

-(void)dateChanged
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm aa"];
    NSString *currentTime = [dateFormatter stringFromDate:datePicker.date];
    NSLog(@"Selected Date From user==>>%@", currentTime);
    
    selectedDate = currentTime;
    [tblView reloadData];
    if (classPeripheral.state == CBPeripheralStateConnected)
    {
      
    }
}
#pragma mark :- MQTT Acknowledgement from Server
-(void)ReceivedMQTTResponsefromserver:(NSMutableDictionary *)dictData
{
//    [APP_DELEGATE endHudProcess];
    NSString * strReceivedAddress = [[self checkforValidString:[dictData valueForKey:@"ble_address"]] uppercaseString];
    if([strReceivedAddress isEqualToString:[strMacAddress uppercaseString]])
    {
        NSArray * arrData = [dictData valueForKey:@"data"];
        if([arrData count] >= 1)
        {
            NSString * strOpcode = [self checkforValidString:[NSString stringWithFormat:@"%@",[arrData objectAtIndex:0]]];
            if (![strOpcode isEqualToString:@"21"])
            {
                NSLog(@"==========ReceivedMQTTResponsefromserver=========%@",arrData);
            }
            if([strOpcode isEqualToString:@"5"])
            {
                if([arrData count] >= 8)
                {
                    
                    if (globalDashBoardVC)
                    {
                        [globalDashBoardVC UpdateSocketSwithchStatus:arrData withMacAddress:strReceivedAddress];
                    }
                    [self UpdateSwitchStatusfromMQTT:arrData];
                }
                [APP_DELEGATE endHudProcess];
                [mqttRequestTimeOut invalidate];
                mqttRequestTimeOut = nil;
            }
            else if([strOpcode isEqualToString:@"7"])
            {
                NSString * strCurrentTopic = [NSString stringWithFormat:@"/vps/app/%@",strReceivedAddress];
                UInt16 subTop = [classMqttObj unsubscribe:strCurrentTopic];
            }
            else if([strOpcode isEqualToString:@"9"])
            {
                [APP_DELEGATE endHudProcess];
                [mqttRequestTimeOut invalidate];
                mqttRequestTimeOut = nil;

                for (int i =2; i < 8; i++)
                {
                    if (i < [arrData count])
                    {
                        int swchstatus = [[arrData objectAtIndex:i] intValue];
                        [dictFromHomeSwState setValue:[NSString stringWithFormat:@"%0d",swchstatus] forKey:[NSString stringWithFormat:@"Switch%d",i -1 ]];
                    }
                }
                if (globalDashBoardVC)
                {
                    [globalDashBoardVC UpdateSocketSwithchStatus:arrData withMacAddress:strReceivedAddress];
                }

                [tblView reloadData];
            }
            else if([strOpcode isEqualToString:@"10"])
            {
                [APP_DELEGATE endHudProcess];
                [mqttRequestTimeOut invalidate];
                mqttRequestTimeOut = nil;
                for (int i =2; i < 8; i++)
                {
                    if (i < [arrData count])
                    {
                        int swchstatus = [[arrData objectAtIndex:i] intValue];
                        [dictFromHomeSwState setValue:[NSString stringWithFormat:@"%0d",swchstatus] forKey:[NSString stringWithFormat:@"Switch%d",i -1 ]];
                    }
                }
                if (globalDashBoardVC)
                {
                    [globalDashBoardVC UpdateSocketSwithchStatus:arrData withMacAddress:strReceivedAddress];
                }
                [tblView reloadData];
            }
            else if([strOpcode isEqualToString:@"16"])
            {
                NSString * strStatus = [arrData componentsJoinedByString:@""];
                if ([strStatus length] >= 5)
                {
                    if ([[strStatus substringWithRange:NSMakeRange(0, 5)] isEqualToString:@"16212"])
                    {
                        isMQTTConfigured = YES;
    //                    [APP_DELEGATE endHudProcess];
                        [mqttRequestTimeOut invalidate];
                        mqttRequestTimeOut = nil;
                        imgWifiNotConnected.image = [UIImage imageNamed:@"wifiGreen.png"];
                        
                        if (classPeripheral.state == CBPeripheralStateDisconnected)
                        {
                            if (isTopicSubscribed == YES) // no
                            {
                                NSString * strTopic = [NSString stringWithFormat:@"/vps/device/%@",[strMacAddress uppercaseString]];
                                NSArray * arrPackets =[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5], nil];
                                [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];
                            }
                        }
                    }
                    else
                    {
                        if ([APP_DELEGATE isNetworkreachable])
                        {
                            imgWifiNotConnected.image = [UIImage imageNamed:@"wifired.png"];
                        }
                        else
                        {
                            imgWifiNotConnected.image = [UIImage imageNamed:@"wifigray.png"];
                        }
                    }
                }
            }
            else if([strOpcode isEqualToString:@"11"])
            {
                BOOL isAlarmSuccess = NO;
                if ([arrData count] >= 16)
                {
                    NSString * strStatus = [NSString stringWithFormat:@"%@",[arrData objectAtIndex:15]];
                    if ([strStatus isEqualToString:@"1"])
                    {
                        isAlarmSuccess = YES;
                    }
                }
                if (globalSocketAlarmVC)
                {
                    [globalSocketAlarmVC MqttAlarmStatusfromServer:isAlarmSuccess withServerResponse:arrData withMacAddress:strReceivedAddress];
                }
                else
                {
                    [self UpdateDatabaseforAlarm:arrData withBleAddress:strReceivedAddress];
                }
            }
            else if([strOpcode isEqualToString:@"12"])
            {
                if ([arrData count] >= 6)
                {
                    NSString * strStatus = [NSString stringWithFormat:@"%@",[arrData objectAtIndex:5]];
                    if ([strStatus isEqualToString:@"1"])
                    {
                        if (globalSocketAlarmVC)
                        {
                            [globalSocketAlarmVC MqttDeleteAlarmStatusfromServer:YES withServerResponse:arrData withMacaddress:strReceivedAddress];
                        }
                        else
                        {
                            NSInteger alarmId = -1;
                            if ([arrData count] >= 6)
                            {
                                alarmId = [[arrData objectAtIndex:2] integerValue];
                            }
                            if (alarmId != -1)
                            {
                                NSString * deleteQuery =[NSString stringWithFormat:@"delete from Socket_Alarm_Table where ble_address = '%@' and alarm_id = '%ld'",strReceivedAddress,(long)alarmId];
                                [[DataBaseManager dataBaseManager] execute:deleteQuery];
                            }

                        }
                    }
                    else
                    {
                        if (globalSocketAlarmVC)
                        {
                            [globalSocketAlarmVC MqttDeleteAlarmStatusfromServer:NO withServerResponse:arrData withMacaddress:strReceivedAddress];
                        }
                    }
                }
            }
            else if([strOpcode isEqualToString:@"21"])// stored alram from device
            {
                if ([arrData count] >= 14) // 8 previosly
                {
                    [arrMQTTalarmState addObject:arrData];
                    
                    if ([arrMQTTalarmState count] >= 1) // 12
                    {
                        for (int i = 0; i < [arrMQTTalarmState count]; i++)
                        {
                            NSArray * arrAlarm = [arrMQTTalarmState objectAtIndex:i];
                            
                            if ([arrAlarm count] >= 14)
                            {
                                NSString * strCheckStatus = [arrAlarm componentsJoinedByString:@""];
                                if ([strCheckStatus isEqualToString:@"21,12,0,0,0,0,0,0,0,0,0,0,0,0"])
                                {
                                   return;
                                }
                                else
                                {
//                                    150c01007f265c2659d2dcd2280100000000
                                    NSString * strDecimalOnTime = [ self GetDecimalValueofAlarm:arrAlarm withType:0];
                                    NSString * strDecimalOffTime = [ self GetDecimalValueofAlarm:arrAlarm withType:1];

                                    NSString * strCheckOnTime = [self checkforValidString:strDecimalOnTime];
                                    NSString * strCheckOffTime = [self checkforValidString:strDecimalOffTime];
                                    
                                    if ([strCheckOnTime isEqualToString:@"ffffffff"] && [strCheckOffTime isEqualToString:@"ffffffff"])
                                    {
                                        strCheckOnTime = @"NA";
                                        strCheckOffTime = @"NA";
                                    }
                                    else if([strCheckOnTime isEqualToString:@"ffffffff"] || [strCheckOffTime isEqualToString:@"ffffffff"])
                                    {
                                        if ([strCheckOnTime isEqualToString:@"ffffffff"])
                                        {
                                            strCheckOnTime = @"NA";
                                        }
                                        if([strCheckOffTime isEqualToString:@"ffffffff"])
                                        {
                                            strCheckOffTime = @"NA";
                                        }
                                    }
                                    
                                    NSString * strOnOriginal = @"NA";
                                    NSString * strOffOriginal= @"NA";
                                    NSString * strOnTime, * strOffTime;
                                    
                                    NSString * strTotalDaysCount = [self checkforValidString:[NSString stringWithFormat:@"%@",[arrAlarm objectAtIndex:4]]];
                                    if (![strCheckOnTime isEqualToString:@"NA"])
                                    {
                                        strOnTime = [self stringFroHex:[NSString stringWithFormat:@"%@",strCheckOnTime]];
                                        strOnOriginal = [self getHoursfromString:strOnTime withDaysCount:strTotalDaysCount];
                                    }
                                    if (![strCheckOffTime isEqualToString:@"NA"])
                                    {
                                        strOffTime = [self stringFroHex:[self checkforValidString:[NSString stringWithFormat:@"%@",strCheckOffTime]]];
                                        strOffOriginal = [self getHoursfromString:strOffTime withDaysCount:strTotalDaysCount];
                                    }
                                    
                                    NSString * strAlarmId = [self checkforValidString:[NSString stringWithFormat:@"%@",[arrAlarm objectAtIndex:2]]];
                                    NSString * strsocketID = [self checkforValidString:[NSString stringWithFormat:@"%@",[arrAlarm objectAtIndex:3]]];
                                    NSString * strdayValue = [self getSelectedDaysforDayByteValue:[self checkforValidString:[NSString stringWithFormat:@"%@",[arrAlarm objectAtIndex:4]]]];
                                    NSString * stralarmState = [self checkforValidString:[NSString stringWithFormat:@"0%@",[arrAlarm objectAtIndex:13]]];

                                    NSMutableArray * arrdata = [[NSMutableArray alloc] init];
                                    NSString * strQuery = [NSString stringWithFormat:@"select * from Socket_Alarm_Table  where ble_address = '%@' and alarm_id = '%@'",strMacAddress,strAlarmId];
                                    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:arrdata];

                                    if ([arrdata count] == 0)
                                    {
                                        if (![strAlarmId isEqual:@"0"])
                                        {
                                            NSString * strInsert  =[NSString stringWithFormat:@"insert into 'Socket_Alarm_Table'('alarm_id','socket_id','day_selected','OnTimestamp','OffTimestamp','alarm_state','ble_address','On_original','Off_original') values('%@','%@','%@','%@','%@','%@','%@','%@','%@')",strAlarmId,strsocketID,strdayValue,strOnTime,strOffTime,stralarmState,strMacAddress,strOnOriginal,strOffOriginal];
                                            [[DataBaseManager dataBaseManager] execute:strInsert];
                                        }
                                    }
                                    else
                                    {
                                        if (![strAlarmId isEqual:@"0"])
                                        {
                                            NSString * update = [NSString stringWithFormat:@"update Socket_Alarm_Table set alarm_id = '%@', socket_id ='%@',day_selected='%@', onTimestamp ='%@', offTimestamp = '%@', alarm_state = '%@', On_original = '%@', Off_original = '%@' where ble_address = '%@' and alarm_id = '%@'",strAlarmId,strsocketID,strdayValue,strOnTime,strOffTime,stralarmState,strOnOriginal,strOffOriginal,strMacAddress,strAlarmId];
                                            [[DataBaseManager dataBaseManager] execute:update];
                                        }
                                    }
                                }

                            }
                        }
                    }
                }
            }
        }
    }
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
-(void)UpdateSwitchStatusfromMQTT:(NSArray *)arrData
{
    NSMutableDictionary * dictSwitcState = [[NSMutableDictionary alloc] init];
    for(int i =2; i < 8; i++)
    {
        int switchStatus = [[arrData objectAtIndex:i] intValue];
        [dictSwitcState setValue:[NSString stringWithFormat:@"%0d",switchStatus] forKey:[NSString stringWithFormat:@"Switch%d",i - 1]];
    }
    NSLog(@"UpdateSwitchStatusfromMQTT=====%@",dictSwitcState);
    [self ReceivedSwitchStatusfromDevice:dictSwitcState];
}
  
#pragma mark - BLEManager Delegate
-(void) didDisconnectDevice:(CBPeripheral *)device;
{
    
}
-(void) didFailToConnectDevice:(CBPeripheral*)device error:(NSError*)error;
{
    
}
-(void) didDiscoveredDevice:(CBPeripheral *)device withRSSI:(NSNumber *)RSSI
{
    
}
-(void)didDeviceDisconnectedCallback:(CBPeripheral *)peripheral
{
    NSString * strRecievedIdentifier = [NSString stringWithFormat:@"%@",peripheral.identifier];
    NSString * strClassIdentifier = [NSString stringWithFormat:@"%@",[self checkforValidString:[deviceDetail valueForKey:@"identifier"]]];

    if (peripheral.identifier == classPeripheral.identifier)
    {
        classPeripheral = peripheral;
        
        if (mangerSate.state == CBCentralManagerStatePoweredOn)
        {
            if (peripheral)
            {
                if (peripheral.identifier == classPeripheral.identifier)
                {
                    classPeripheral = peripheral;
                    imgNotConnected.image = [UIImage imageNamed:@"Connected_icon.png"];
                }
                else if ([strRecievedIdentifier isEqualToString:strClassIdentifier])
                {
                    classPeripheral = peripheral;
                    imgNotConnected.image = [UIImage imageNamed:@"Connected_icon.png"];
                }
            }
            else
            {
                imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
            }
        
        }
        else if(mangerSate.state == CBCentralManagerStatePoweredOff)
        {
            imgNotConnected.image = [UIImage imageNamed:@"blegray.png"];
        }
        else
        {
            imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
        }
    }
    else if ([strRecievedIdentifier isEqualToString:strClassIdentifier])
    {
        classPeripheral = peripheral;
        
        
        if (mangerSate.state == CBCentralManagerStatePoweredOn)
        {
        }
        else if(mangerSate.state == CBCentralManagerStatePoweredOff)
        {
            imgNotConnected.image = [UIImage imageNamed:@"blegray.png"];
        }
        else
        {
            imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
        }
    }
}
-(void)didDeviceConnectedCallback:(CBPeripheral *)peripheral
{
    NSString * strRecievedIdentifier = [NSString stringWithFormat:@"%@",peripheral.identifier];
    NSString * strClassIdentifier = [NSString stringWithFormat:@"%@",[self checkforValidString:[deviceDetail valueForKey:@"identifier"]]];

            [[BLEService sharedInstance] sendNotificationsSKT:peripheral withType:NO withUUID:@"0000AB00-2687-4433-2208-ABF9B34FB000"];
            [[BLEService sharedInstance] EnableNotificationsForCommandSKT:peripheral withSocketReset:NO];
            [[BLEService sharedInstance] EnableNotificationsForDATASKT:peripheral withSocketReset:NO];
    if (peripheral.identifier == classPeripheral.identifier)
    {
        classPeripheral = peripheral;
        imgNotConnected.image = [UIImage imageNamed:@"Connected_icon.png"];
    }
    else if ([strRecievedIdentifier isEqualToString:strClassIdentifier])
    {
        classPeripheral = peripheral;
        imgNotConnected.image = [UIImage imageNamed:@"Connected_icon.png"];
    }
}
-(void)bluetoothPowerState:(NSString*)state;
{
    NSLog(@"====bluetoothPowerState===%@",state);
    if ([state isEqualToString:@"Bluetooth is currently powered off."])
    {
        imgNotConnected.image = [UIImage imageNamed:@"blegray.png"];
    }
}
-(void)deleteSocketDevice
{
    NSString * strBleAddress = [[deviceDetail  valueForKey:@"ble_address"] uppercaseString];
    NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set status ='2',is_sync = '0', wifi_configured = '0' where ble_address = '%@'",strBleAddress];
    [[DataBaseManager dataBaseManager] execute:strUpdate];
    
    NSString * strDeleteAlarm = [NSString stringWithFormat:@"delete from Socket_Alarm_Table where ble_address ='%@'",strBleAddress];
    [[DataBaseManager dataBaseManager] execute:strDeleteAlarm];

    if ([deviceDetail count] > 0)
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        dict = deviceDetail;
        [dict setObject:@"0" forKey:@"status"];
        [self SaveDeviceDetailstoServer:dict];
        [APP_DELEGATE hudEndProcessMethod];
        
        [tblView reloadData];
    }
    [APP_DELEGATE endHudProcess];

    
    if ([[arrSocketDevices valueForKey:@"ble_address"] containsObject:strBleAddress])
    {
        NSInteger foundIndex = [[arrSocketDevices valueForKey:@"ble_address"] indexOfObject:strBleAddress];
        if (foundIndex != NSNotFound)
        {
            if ([arrSocketDevices count] > foundIndex)
            {
                NSMutableDictionary * dict = [arrSocketDevices objectAtIndex:foundIndex];
                NSArray * allKeys = [dict allKeys];
                if ([allKeys containsObject:@"peripheral"])
                {
                    CBPeripheral * p = [[arrSocketDevices objectAtIndex:foundIndex] valueForKey:@"peripheral"];
                    NSInteger intPacket = [@"0" integerValue];
                    NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
                    [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"07" withLength:@"01" withPeripheral:p];
                    [arrSocketDevices removeObjectAtIndex:foundIndex];
                }
            }
        }
    }
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"PairedDevices"];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSMutableArray * arrPreviouslyFound = [[NSMutableArray alloc] initWithArray:array];
    
    if([[arrPreviouslyFound valueForKey:@"ble_address"] containsObject:strBleAddress])
    {
        NSInteger foundIndex = [[arrPreviouslyFound valueForKey:@"ble_address"] indexOfObject:strBleAddress];
        if (foundIndex != NSNotFound)
        {
            if ([arrPreviouslyFound count] > foundIndex)
            {
                [arrPreviouslyFound removeObjectAtIndex:foundIndex];
            }
        }
    }
    
    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:arrPreviouslyFound];
    [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"PairedDevices"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSString * strTopic = [NSString stringWithFormat:@"/vps/device/%@",[strBleAddress uppercaseString]];
    NSArray * arrPackets =[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:7],[NSNumber numberWithInt:1], nil];
    [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];

    [APP_DELEGATE endHudProcess];
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    alert.tag = 6767;
    alert.delegate = self;
    [alert makeAlertTypeSuccess];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Device has been deleted successfully."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
    

}
- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 6767)
    {
        [self.navigationController popViewControllerAnimated:true];
    }
   else if (alertView.tag == 123)
     {

         NSInteger intOpcode = [@"33" integerValue];
         NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpcode length:1];

         NSInteger intLegth = [@"33" integerValue];
         NSData * dataPacketLegth = [[NSData alloc] initWithBytes:&intLegth length:1];

         NSInteger intPacket = [strOTAstring intValue];
         NSData * dataPacketData = [[NSData alloc] initWithBytes:&intPacket length:strOTAstring.length];

         
         NSMutableData * compleateData = [dataOpcode mutableCopy];
         [compleateData appendData:dataPacketLegth];
         [compleateData appendData:dataPacketData];

         [[BLEService sharedInstance] SendDatatoPeripheral:compleateData withPeripheral:classPeripheral];

     }
}
- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
}

#pragma mark-Collection view setup
-(void)SetupForSetSocketNameImages:(NSInteger)selectedSocket
{
    int yy = 20;
    int viewWidth = DEVICE_WIDTH;
    
    if (DEVICE_HEIGHT >= 812)
    {
        yy = 40;
    }

    NSString * strSocketName = [NSString stringWithFormat:@"Socket %ld",(long)selectedSocket + 1];
    NSString * strSocketImgType = @"1";
    currentSocketSelectedImage = 0;
    
    if ([[arrSocketNames valueForKey:@"socket_id"] containsObject:[NSString stringWithFormat:@"%ld",(long)selectedSocket]])
    {
        NSInteger foundIndex = [[arrSocketNames valueForKey:@"socket_id"] indexOfObject:[NSString stringWithFormat:@"%ld",(long)selectedSocket]];
        if (foundIndex != NSNotFound)
        {
            if ([arrSocketNames count] > foundIndex)
            {
                strSocketName = [[arrSocketNames objectAtIndex:foundIndex] valueForKey:@"socket_name"];
                strSocketImgType = [[arrSocketNames objectAtIndex:foundIndex] valueForKey:@"image_type"];
                currentSocketSelectedImage = [strSocketImgType integerValue];
            }
        }
    }
    [viewForCollectionBG removeFromSuperview];
    viewForCollectionBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    viewForCollectionBG .backgroundColor = UIColor.blackColor;
    viewForCollectionBG.alpha = 0.7;
    [self.view addSubview:viewForCollectionBG];

    viewForCollectionImgView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH-0, DEVICE_HEIGHT)];
    viewForCollectionImgView .backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7];
    viewForCollectionImgView.layer.cornerRadius = 6;
    viewForCollectionImgView.clipsToBounds = true;
    [self.view addSubview:viewForCollectionImgView];
    
    UILabel * lblMenu = [[UILabel alloc] initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, 60)];
    lblMenu.text= @"Customize Socket";
    lblMenu.textColor = UIColor.whiteColor;
    lblMenu.backgroundColor = global_brown_color;
    lblMenu.textAlignment = NSTextAlignmentCenter;
    lblMenu.font = [UIFont fontWithName:CGRegular size:textSizes+2];
    [viewForCollectionImgView addSubview:lblMenu];

    UIButton*  btnCancelImgs = [[UIButton alloc]init];
    btnCancelImgs.frame = CGRectMake(0, yy, 55, 60);
    [btnCancelImgs addTarget:self action:@selector(btnCancelImgs) forControlEvents:UIControlEventTouchUpInside];
    [btnCancelImgs setImage:[UIImage imageNamed:@"Cancel.png"] forState:UIControlStateNormal];
    [btnCancelImgs setTitleColor:UIColor.whiteColor forState:normal];
    btnCancelImgs.backgroundColor = [UIColor clearColor]; //[UIColor colorWithRed:192.0/255.0f green:57.0/255.0f blue:43.0/255.0f alpha:1.0];
    btnCancelImgs.layer.cornerRadius = 6;
    btnCancelImgs.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+5];
    [viewForCollectionImgView addSubview:btnCancelImgs];
    
    UIButton*  btnSaveNameImgs = [[UIButton alloc]init];
    btnSaveNameImgs.frame = CGRectMake(DEVICE_WIDTH - 55, yy, 55, 60);
    [btnSaveNameImgs addTarget:self action:@selector(btnSaveNameImgClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnSaveNameImgs setImage:[UIImage imageNamed:@"Save.png"] forState:UIControlStateNormal];
    [btnSaveNameImgs setTitleColor:UIColor.whiteColor forState:normal];
    btnSaveNameImgs.backgroundColor = [UIColor clearColor];//UIColor.redColor;
    btnSaveNameImgs.layer.cornerRadius = 6;
    btnSaveNameImgs.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+5];
    [viewForCollectionImgView addSubview:btnSaveNameImgs];    
    
    yy = yy + 70;

    txtName = [[UITextField alloc] initWithFrame:CGRectMake(10, yy, viewWidth-20, 50)];
    txtName.backgroundColor = UIColor.whiteColor;
    txtName.placeholder = @"  Enter Socket Name";
    txtName.delegate = self;
    txtName.text = strSocketName;
    txtName.returnKeyType = UIReturnKeyDone;
    [viewForCollectionImgView addSubview:txtName];

    yy = yy +50;
    
    UILabel * lblMenuImg = [[UILabel alloc] initWithFrame:CGRectMake(10, yy, viewForCollectionImgView.frame.size.width, 50)];
    lblMenuImg.text= @"Choose  Picture";
    lblMenuImg.textColor = UIColor.whiteColor;
    lblMenuImg.backgroundColor = UIColor.clearColor;
    lblMenuImg.font = [UIFont fontWithName:CGRegular size:textSizes+2];
    [viewForCollectionImgView addSubview:lblMenuImg];
    
    yy = yy + 45;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
       collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, yy, viewForCollectionImgView.frame.size.width-20, viewForCollectionImgView.frame.size.height-yy) collectionViewLayout:layout];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];

    [collectionView registerClass:[CollectionCustomCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [collectionView setBackgroundColor:[UIColor clearColor]];
     collectionView.hidden = false;
    [viewForCollectionImgView addSubview:collectionView];
    
    
    
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
       {
       self-> viewForCollectionImgView.frame = CGRectMake(0, (DEVICE_HEIGHT-(DEVICE_HEIGHT))/2, DEVICE_WIDTH-0, DEVICE_HEIGHT);
       }
       completion:(^(BOOL finished)
       {
      })];
}
#pragma mark - Collection Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return ArrImgForCollectionView.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat vWidth = (viewForCollectionImgView.frame.size.width/5);
    return CGSizeMake(vWidth, vWidth );
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
        CollectionCustomCell *cell=[collectionView  dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.layer.borderColor = UIColor.whiteColor.CGColor;
        cell.layer.borderWidth = 0.6;

        CGFloat vWidth = (viewForCollectionImgView.frame.size.width/5);
        CGFloat vHeight = vWidth ;
    

        cell.imgViewpProfile.frame = CGRectMake(10, 10,vWidth-20, vHeight-20);
        cell.imgViewpProfile.contentMode = UIViewContentModeScaleAspectFill;
        [cell.imgViewpProfile setImage:[UIImage imageNamed:[ArrImgForCollectionView objectAtIndex:indexPath.row]]];
    
      //check if the the checkmark image is hidden then change it to visible
        cell.imgViewpProfile.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.imgViewpProfile.layer.cornerRadius = 0.5;
        cell.imgViewpProfile.layer.masksToBounds = YES;
    
    
      cell.checkMarkImage.frame = CGRectMake(vWidth - 22, vHeight - 22, 17, 17);
      if (currentSocketSelectedImage == indexPath.row)
      {
        cell.checkMarkImage.hidden = NO;
        cell.checkMarkImage.image = [UIImage imageNamed:@"Save.png"];
      }
      else
      {
        cell.checkMarkImage.hidden = YES;
      }

    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.alpha = 1.0;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCustomCell * cell  = (CollectionCustomCell *)[collectionView cellForItemAtIndexPath:selectedIndexPath];
    cell.checkMarkImage.hidden = false;
    currentSocketSelectedImage = indexPath.row;
    
    cell  = (CollectionCustomCell *)[collectionView cellForItemAtIndexPath:indexPath];
    {
        if (indexPath.row == currentSocketSelectedImage)
        {
            cell.checkMarkImage.hidden = NO;
            cell.checkMarkImage.image = [UIImage imageNamed:@"tick.png"];
        }
        else
        {
            cell.checkMarkImage.hidden = YES;
        }
    }
    
    selectedIndexPath = indexPath;
    [collectionView reloadData];

    [self.view endEditing:true];
    
//    [cell setSelected:YES];
    
    NSLog(@"selected index=%ld %ld", (long)indexPath.item, (long)indexPath.row);
}
#pragma mark- long Press
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self->tblView];
    
    NSIndexPath * indexPath = [self->tblView indexPathForRowAtPoint:p];
    
//    NSLog(@"lindex path----->%ld", (long)indexPath.row);

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (indexPath.row == 6)
        {
        }
        else
        {
            [self SetupForSetSocketNameImages:indexPath.row];
        }
    }
}
#pragma mark-CollectionView buttons
-(void)btnCancelImgs
{
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
    self-> viewForCollectionImgView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH-0, DEVICE_HEIGHT-50);
    }
        completion:(^(BOOL finished)
      {
        [self-> viewForCollectionBG removeFromSuperview];
    })];
}
-(void)btnSaveNameImgClick:(id)sender
{
    if ([txtName.text isEqual:@""])
    {
        [self AlertViewFCTypeCautionCheck:@"Please enter socket name"];
    }
    else if(currentSocketSelectedImage == -1)
    {
        [self AlertViewFCTypeCautionCheck:@"Select any image"];
    }
    else
    {
        if ([IS_USER_SKIPPED isEqualToString:@"NO"])
        {
            if ([APP_DELEGATE isNetworkreachable])
            {
                [self SaveSocketDetailstoServer];
            }
            else
            {
                [self AlertViewFCTypeCautionCheck:@"There is no internet connection. Please connect to internet first then try again later."];
            }
        }
        else
        {
            NSInteger  intIMGtype = currentSocketSelectedImage + 1 ;

            if ([arrSocketNames count] > selectedSocketIndex)
            {
                [[arrSocketNames objectAtIndex:selectedSocketIndex] setValue:txtName.text forKey:@"socket_name"];
                [[arrSocketNames objectAtIndex:selectedSocketIndex] setValue:[NSString stringWithFormat:@"%ld",intIMGtype] forKey:@"image_type"];
                [tblView reloadData];
            }
            NSMutableArray * arrdata = [[NSMutableArray alloc] init];
            NSString * strQuery = [NSString stringWithFormat:@"select * from Socket_NameImg_Table  where ble_address = '%@' and socket_id = '%ld' ",strMacAddress,(long)selectedSocketIndex];
            [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:arrdata];
                
            if (arrdata.count > 0)
            {
                NSString * update = [NSString stringWithFormat:@"update Socket_NameImg_Table set socket_name = '%@' , socket_id = '%ld', image_type = '%ld',ble_address = '%@'",txtName.text,selectedSocketIndex,intIMGtype,strMacAddress];
                [[DataBaseManager dataBaseManager] execute:update];
            }
            else
            {
                NSString * strInsert  = [NSString stringWithFormat:@"insert into 'Socket_NameImg_Table'('socket_name','socket_id','image_type','ble_address','device_id') values('%@','%ld','%ld','%@','%@')",txtName.text,selectedSocketIndex,intIMGtype,strMacAddress, [self checkforValidString:[deviceDetail valueForKey:@"device_id"]]];
                [[DataBaseManager dataBaseManager] execute:strInsert];
            }
        }

            
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
         {
            self-> viewForCollectionImgView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH-0, DEVICE_HEIGHT);
        }
                        completion:(^(BOOL finished)
                                    {
            [self-> viewForCollectionBG removeFromSuperview];
        })];
        
        [tblView reloadData];
        [self.view endEditing:true];
    }
}
#pragma mark- Get device name and image from server
-(void)GetSocketNameandImgefromServer:(NSMutableDictionary *)dict
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        NSMutableDictionary * dictVal = [[NSMutableDictionary alloc] init];
        [dictVal setValue:[dict valueForKey:@"server_device_id"] forKey:@"device_id"];
        
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"getSocketDetail";
        manager.delegate = self;
        NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/device_socket_details"; //
        [manager urlCall:strServerUrl withParameters:dictVal]; // for post method use this urlCall
    }
    else
    {
        [self AlertViewFCTypeCautionCheck:@"Please check internet connectivity."];
    }
}


-(void)SaveDeviceDetailstoServer:(NSMutableDictionary *)inforDict
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        if ([IS_USER_SKIPPED isEqualToString:@"NO"])
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                {
                    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
                    [args setObject:CURRENT_USER_ID forKey:@"user_id"];
                    [args setObject:[inforDict valueForKey:@"device_id"] forKey:@"device_id"];
                    [args setObject:[inforDict valueForKey:@"hex_device_id"] forKey:@"hex_device_id"];
                    [args setObject:[inforDict valueForKey:@"device_name"] forKey:@"device_name"];
                    [args setObject:[inforDict valueForKey:@"device_type"] forKey:@"device_type"];
                    [args setObject:[[inforDict valueForKey:@"ble_address"]uppercaseString] forKey:@"ble_address"];
                    [args setObject:[inforDict valueForKey:@"status"] forKey:@"status"];
                    [args setObject:[inforDict valueForKey:@"is_favourite"] forKey:@"is_favourite"];
                    [args setObject:@"1" forKey:@"is_update"];
                    [args setValue:@"0" forKey:@"remember_last_color"];
                    [args setValue:[inforDict valueForKey:@"identifier"] forKey:@"identifier"];
                    [args setValue:[inforDict valueForKey:@"wifi_configured"] forKey:@"wifi_configured"];

                    if ([[self checkforValidString:[inforDict valueForKey:@"server_device_id"]] isEqualToString:@"NA"])
                    {
                        [args setObject:@"0" forKey:@"is_update"];
                    }
                    NSString *deviceToken =deviceTokenStr;
                    if (deviceToken == nil || deviceToken == NULL)
                    {
                        [args setValue:@"123456789" forKey:@"device_token"];
                    }
                    else
                    {
                        [args setValue:deviceToken forKey:@"device_token"];
                    }
                    AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
                    //[manager1.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
                    NSString *token=[[NSUserDefaults standardUserDefaults]valueForKey:@"globalCode"];
                    NSString *authorization = [NSString stringWithFormat: @"Basic %@",token];
                    [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
                    [manager1.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                    //manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
                    
                    AFHTTPRequestOperation *op = [manager1 POST:@"http://vithamastech.com/smartlight/api/save_device" parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                        dictID = [responseObject mutableCopy];
                        if ([dictID valueForKey:@"data"] == [NSNull null] || [dictID valueForKey:@"data"] == nil)
                        {
                                                          
                        }
                        else
                        {
                            NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set is_sync ='1' where device_id='%@'",[[dictID valueForKey:@"data"]valueForKey:@"device_id"]];
                            [[DataBaseManager dataBaseManager] execute:strUpdate];
                        }
                    }
                                                        failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        if (error)
                        {
                            //NSLog(@"Servicer error = %@", error);
                        }
                    }];
                    [op start];
                }
                // Perform async operation
                // Call your method/function here
                // Example:
                dispatch_sync(dispatch_get_main_queue(), ^{
                    //Method call finish here
                });
            });
        }
    }
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    NSLog(@"=======Result=======%@",result);
    [APP_DELEGATE endHudProcess];
    
   if ([[result valueForKey:@"commandName"] isEqualToString:@"CheckUserDetails"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"false"])
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Password not matching with database."])
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                alert.delegate =self;
                alert.tag = 345;
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:@"Authentication session expired. Please login again."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
        }
       else
        {
            NSLog(@"<-------onResult------>%@",result);
            [APP_DELEGATE endHudProcess];

            if ([deviceDetail count]> 0)
            {
                if ([[deviceDetail  valueForKey:@"device_type"] isEqual:@"4"])
                {
                    return;
                }
                else
                {
                    [APP_DELEGATE endHudProcess];
                    FCAlertView *alert = [[FCAlertView alloc] init];
                    alert.colorScheme = [UIColor blackColor];
                    [alert makeAlertTypeSuccess];
                    [alert showAlertInView:self
                                 withTitle:@"Smart Light"
                              withSubtitle:@"Device has been deleted successfully."
                           withCustomImage:[UIImage imageNamed:@"logo.png"]
                       withDoneButtonTitle:nil
                                andButtons:nil];
                }
            }
        }
    }
   else if ([[result valueForKey:@"commandName"] isEqualToString:@"getSocketDetail"])
   {
       if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
       {
           dictSocketDetail = [[result valueForKey:@"result"] valueForKey:@"data"];
       }
       else
       {
           NSLog(@"From Server socket data====%@",dictSocketDetail);
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
-(void)UpdateWifiSetupfromWifiSetting:(NSMutableDictionary *)mqttObject;
{
    deviceDetail = [mqttObject mutableCopy];
    if ([[mqttObject allKeys] containsObject:@"wifi_configured"])
    {
        if ([[mqttObject valueForKey:@"wifi_configured"] isEqualToString:@"1"])
        {
            isMQTTConfigured = YES;
            imgWifiNotConnected.image = [UIImage imageNamed:@"wifiGreen.png"];
            
                    if (classMqttObj == nil)
                    {
                        [self ConnecttoMQTTSocketServer];
                    }
                    else
                    {
                        if ([classMqttObj connState] == 2)
                        {
                            isMQTTConfigured = NO;
                            classMqttObj.delegate = self;
                            
                            if (classPeripheral)
                            {
                                if (classPeripheral.state != CBPeripheralStateConnected)
                                {
                                    NSString * strTopic = [NSString stringWithFormat:@"/vps/device/%@",[strMacAddress uppercaseString]];
                                    NSArray * arrPackets =[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:16],[NSNumber numberWithInt:0], nil];
                                    [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];
                                    arrMQTTalarmState = [[NSMutableArray alloc] init];
                                    NSArray * arrAlarm = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:21],[NSNumber numberWithInt:0], nil];
                                    [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrAlarm];
                                    
                                    [mqttRequestTimeOut invalidate];
                                    mqttRequestTimeOut = nil;
                                    mqttRequestTimeOut = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(TimeOutforWifiConfiguration) userInfo:nil repeats:NO];
                                }
                            }
                        }
                        else if ([classMqttObj connState] == 3)
                        {
                            [self ConnecttoMQTTSocketServer];
                        }
                    }
        }
        else
        {
            isMQTTConfigured = NO;
            
            if ([APP_DELEGATE isNetworkreachable])
            {
                imgWifiNotConnected.image = [UIImage imageNamed:@"wifired.png"];
            }
            else
            {
                imgWifiNotConnected.image = [UIImage imageNamed:@"wifgray.png"];
            }
        }
    }
}
#pragma mark - Alarm MQTT Setup & Receive Methods
-(void)SetupAlarm:(NSMutableData *)alarmDict
{
    NSLog(@"===========================================================================================%@",alarmDict);

    if (classMqttObj)
    {
        NSString * strTopic = [NSString stringWithFormat:@"/vps/device/%@",[strMacAddress uppercaseString]];
        CocoaMQTTMessage * msg = [[CocoaMQTTMessage alloc] initWithTopic:strTopic alarmpayload:alarmDict qos:2 retained:NO dup:NO];
        UInt16 subTop = [classMqttObj publish:msg];
        NSLog(@"MQTT MSG Sent==%hu",subTop);
    }
}
-(void)DeleteAlarm:(NSMutableData *)alarmDict;
{
    if (classMqttObj)
    {
        NSString * strTopic = [NSString stringWithFormat:@"/vps/device/%@",[strMacAddress uppercaseString]];
        CocoaMQTTMessage * msg = [[CocoaMQTTMessage alloc] initWithTopic:strTopic alarmpayload:alarmDict qos:2 retained:NO dup:NO];
        UInt16 subTop = [classMqttObj publish:msg];
        NSLog(@"MQTT MSG Sent==%hu",subTop);
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}
-(void)OTAFordileep
{
    NSString * msgPlaceHolder = [NSString stringWithFormat:@"Enter Device Name"];
    
    [APP_DELEGATE endHudProcess];
    
    FCAlertView * alert;
    [alert removeFromSuperview];
    alert = [[FCAlertView alloc] init];
    alert.delegate = self;
    alert.tag = 123;
    alert.colorScheme = global_brown_color;
    
    UITextField *customField = [[UITextField alloc] init];
    customField.placeholder = msgPlaceHolder;
    customField.keyboardAppearance = UIKeyboardAppearanceAlert;
    customField.textColor = [UIColor blackColor];
    [APP_DELEGATE getPlaceholderText:customField andColor:[UIColor lightGrayColor]];

    [alert addTextFieldWithCustomTextField:customField andPlaceholder:nil andTextReturnBlock:^(NSString *text)
     {
        strOTAstring = customField.text ;
    }];
    [alert showAlertInView:self
                 withTitle:@"Smart socket"
              withSubtitle:@"Enter UTA string"
           withCustomImage:nil
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)UpdateDatabaseforAlarm:(NSArray *)arrResponse withBleAddress:(NSString *)strBleAdress
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
        NSString * strAlarmStatus = [NSString stringWithFormat:@"0%@",[arrResponse objectAtIndex:13]];

        NSMutableArray * tmpArry = [[NSMutableArray alloc]init];
        NSString * strQuery = [NSString stringWithFormat:@"select * from Socket_Alarm_Table where ble_address = '%@' and alarm_id = '%@'",strBleAdress,strAlarmId];
        [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:tmpArry];
        
        if ([tmpArry count] == 0)
        {
            NSString * strInsert  =[NSString stringWithFormat:@"insert into 'Socket_Alarm_Table'('alarm_id','socket_id','day_selected','OnTimestamp','OffTimestamp','alarm_state','ble_address','On_original','Off_original') values('%@','%@','%@','%@','%@','%@','%@','%@','%@')",strAlarmId,strSocketId,strdayValue,strOnTime,strOffTime,strAlarmStatus,strBleAdress,strOnOriginal,strOffOriginal];
            [[DataBaseManager dataBaseManager] execute:strInsert];
        }
        else
        {
            NSString * update = [NSString stringWithFormat:@"update Socket_Alarm_Table set alarm_id = '%@', socket_id ='%@',day_selected='%@', onTimestamp ='%@', offTimestamp = '%@', alarm_state = '%@', On_original = '%@', Off_original = '%@' where ble_address = '%@' and alarm_id = '%@'",strAlarmId,strSocketId,strdayValue,strOnTime,strOffTime,strAlarmStatus,strOnOriginal,strOffOriginal,strBleAdress,strAlarmId];
            [[DataBaseManager dataBaseManager] execute:update];
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
#pragma mark- Socket detain Imge name save to server
-(void)SaveSocketDetailstoServer
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        if ([IS_USER_SKIPPED isEqualToString:@"NO"])
        {
            NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
            [args setObject:[self checkforValidString:[NSString stringWithFormat:@"%@",txtName.text]] forKey:@"socket_name"];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                {
                    
                    [args setObject:[self checkforValidString:[deviceDetail valueForKey:@"server_device_id"]] forKey:@"device_id"];
                    [args setObject:[self checkforValidString:[NSString stringWithFormat:@"%ld",(long)selectedSocketIndex]] forKey:@"socket_id"];
               
                    [args setObject:[self checkforValidString:[NSString stringWithFormat:@"%ld",(long)currentSocketSelectedImage + 1]] forKey:@"image_type"];

                    AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
                    [manager1.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                        
                        AFHTTPRequestOperation *op = [manager1 POST:@"http://vithamastech.com/smartlight/api/save_socket_details" parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                            NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                            dictID = [responseObject mutableCopy];
                            
                            NSMutableArray * arrdata = [[NSMutableArray alloc] init];
                            NSString * strQuery = [NSString stringWithFormat:@"select * from Socket_NameImg_Table  where ble_address = '%@' and socket_id = '%ld' ",strMacAddress,(long)selectedSocketIndex];
                            [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:arrdata];
                           
                            NSInteger  intIMGtype = currentSocketSelectedImage + 1 ;

                            if (arrdata.count > 0)
                            {
                                NSString * update = [NSString stringWithFormat:@"update Socket_NameImg_Table set socket_name = '%@' , socket_id = '%ld', image_type = '%ld',ble_address = '%@'",txtName.text,selectedSocketIndex,intIMGtype,strMacAddress];
                                [[DataBaseManager dataBaseManager] execute:update];
                            }
                            else
                            {
                                NSString * strInsert  = [NSString stringWithFormat:@"insert into 'Socket_NameImg_Table'('socket_name','socket_id','image_type','ble_address','device_id') values('%@','%ld','%ld','%@','%@')",txtName.text,selectedSocketIndex,intIMGtype,strMacAddress, [self checkforValidString:[deviceDetail valueForKey:@"device_id"]]];
                                [[DataBaseManager dataBaseManager] execute:strInsert];
                            }

                            if ([arrSocketNames count] > selectedSocketIndex)
                            {
                                [[arrSocketNames objectAtIndex:selectedSocketIndex] setValue:txtName.text forKey:@"socket_name"];
                                [[arrSocketNames objectAtIndex:selectedSocketIndex] setValue:[NSString stringWithFormat:@"%ld",intIMGtype] forKey:@"image_type"];
                            }
                            [tblView reloadData];
                        }
                                                      
                    failure:^(AFHTTPRequestOperation *operation, NSError *error)
                        {
                            if (error)
                            {
                                //NSLog(@"Servicer error = %@", error);
                            }
                        }];
                        [op start];
                    }
                    // Perform async operation
                    // Call your method/function here
                    // Example:
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        //Method call finish here
                    });
                });
            }
        }
}
-(void)TostNotification:(NSString *)StrToast
{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = StrToast;
        hud.margin = 10.f;
        hud.yOffset = -180.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:0.9];
}

@end
/*
 
 //2021-03-23 18:07:13.972 SmartLightApp[6168:830814] ====ALARM STATE======010042ffffffff6059e1280100000000

 {
 alaramID = 1;
 alarmState = 01;
 dayValue = 66;
 offTime = 6059e128;
 onTime = ffffffff;
 socketID = 00;
 )
 */
