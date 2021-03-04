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

@interface SocketDetailVC ()<UITableViewDelegate,UITableViewDataSource,CBCentralManagerDelegate, CocoaMQTTDelegate, BLEManagerDelegate,FCAlertViewDelegate,URLManagerDelegate>
{
    NYSegmentedControl * blueSegmentedControl;
    UIView  *controlView,*settingsView;
    UITableView * tblSettings;
    UIImageView * imgBack;

}
@end

@implementation SocketDetailVC
@synthesize classMqttObj, deviceDetail, isMQTTselect,classPeripheral ,strMacAddress,strWifiConnect, delegate;

#pragma mark - View Life Cycle
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
    
    dictFromHomeSwState = [[NSMutableDictionary alloc] init];
    arryDevices = [[NSMutableArray alloc] init];

    [self setNavigationViewFrames];
    
    [self ConnectPeripheralIfnotConnected];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    if (classPeripheral.state == CBPeripheralStateConnected)
    {
        NSInteger intPacket = [@"0" integerValue];
        NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
        [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"05" withLength:@"00" withPeripheral:classPeripheral];
    }

    imgNotConnected = [[UIImageView alloc]init];
    imgNotConnected.image = [UIImage imageNamed:@"notconnect_iconWhite.png"];
    imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 32, 30, 22);
    imgNotConnected.contentMode = UIViewContentModeScaleAspectFit;
    imgNotConnected.layer.masksToBounds = true;
    [self.view addSubview:imgNotConnected];
    
    imgNotWifiConnected = [[UIImageView alloc]init];
    imgNotWifiConnected.image = [UIImage imageNamed:@"wifigreen.png"];
    imgNotWifiConnected.frame = CGRectMake(DEVICE_WIDTH-60, 32, 30, 22);
    imgNotWifiConnected.contentMode = UIViewContentModeScaleAspectFit;
    imgNotWifiConnected.layer.masksToBounds = true;
    [self.view addSubview:imgNotWifiConnected];
    
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
        imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
    }
    
    if ([[self checkforValidString:[deviceDetail valueForKey:@"wifi_configured"]] isEqual:@"1"])
    {
        imgNotWifiConnected.image = [UIImage imageNamed:@"wifiGreen.png"];
    }
    else
    {
        imgNotWifiConnected.image = [UIImage imageNamed:@"wifired.png"];
    }
    
    if ([[arrSocketDevices valueForKey:@"BLE_WIFI_CONFIG_STATUS"] containsObject:@"1"])
    {
        imgNotWifiConnected.image = [UIImage imageNamed:@"wifiGreen.png"];
        isMQTTConfigured = YES;
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
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy + globalStatusHeight)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, yy + globalStatusHeight-1, DEVICE_WIDTH,1)];
    [lblLine setBackgroundColor:[UIColor lightGrayColor]];
    [viewHeader addSubview:lblLine];
    
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
//        
//    }
//    else
    {
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
                
//                [APP_DELEGATE endHudProcess];
//                [APP_DELEGATE startHudProcess:@"Checking Status..."];
                
                NSString * strTopic = [NSString stringWithFormat:@"/vps/device/%@",[strMacAddress uppercaseString]];
                NSArray * arrPackets =[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:16],[NSNumber numberWithInt:0], nil];
                [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];
                
                [mqttRequestTimeOut invalidate];
                mqttRequestTimeOut = nil;
                mqttRequestTimeOut = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(TimeOutforWifiConfiguration) userInfo:nil repeats:NO];
            }
            else if ([classMqttObj connState] == 3)
            {
                [self ConnecttoMQTTSocketServer];
            }
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
//        imgNotConnected.image = [UIImage imageNamed:@"Connected_icon.png"];

    } else if(central.state == CBCentralManagerStatePoweredOff)
    {
        imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
    }
}
-(void)setPeripheraltoCheckKeyUsage:(CBPeripheral *)tmpPerphrl
{
    if ([[arrPeripheralsCheck valueForKey:@"identifier"] containsObject:tmpPerphrl.identifier])
    {
        NSInteger foundIndex = [[arrPeripheralsCheck valueForKey:@"identifier"] indexOfObject:tmpPerphrl.identifier];
        if (foundIndex != NSNotFound)
        {
            if ([arrPeripheralsCheck count] > foundIndex)
            {
                NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:@"1700", @"status", tmpPerphrl.identifier,@"identifier", nil];
                [arrPeripheralsCheck replaceObjectAtIndex:foundIndex withObject:dict];
            }
        }
    }
    else
    {
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:@"1700", @"status", tmpPerphrl.identifier,@"identifier", nil];
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
        return 3;
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
        return 55;
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
    
    NSInteger indexNo = indexPath.row + 1;
    NSString * strSocketName = [NSString stringWithFormat:@"Socket %ld",(long)indexNo];
    cell.lblDeviceName.text = strSocketName;
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
    
    if (tableView == tblSettings)
    {
        cell.lblSettings.hidden = false;
        cell.lblDeviceName.hidden = true;
        cell.imgSwitch.hidden = false;
        cell.swSocket.hidden = true;
        cell.btnAlaram.hidden = true;
        cell.imgArrow.hidden = false;
        cell.lblLineLower.hidden = true;
        cell.lblBack.frame = CGRectMake (20, 0,DEVICE_WIDTH-40,50);
        cell.lblBack.layer.borderColor = UIColor.lightGrayColor.CGColor;
        
        cell.imgSwitch.frame =  CGRectMake(10, 15, 20, 20);
        NSArray * imgArr = [[NSArray alloc]initWithObjects:@"wifiWhite.png",@"delete_icon.png",@"reset.png", nil];
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

            globalSocketWIFiSEtup = [[SocketWiFiSetupVC alloc] init];
            globalSocketWIFiSEtup.peripheralPss = globalSocketPeripheral;

            if ([[arrSocketDevices valueForKey:@"ble_address"] containsObject:strMacaddress])
            {
                NSInteger foundindex = [[arrSocketDevices valueForKey:@"ble_address"] indexOfObject:strMacaddress];
                if (foundindex != NSNotFound)
                {
                    if ([arrSocketDevices count] > foundindex)
                    {
                        if ([[arrSocketDevices objectAtIndex:foundindex] objectForKey:@"peripheral"])
                        {
                            CBPeripheral * p = [[arrSocketDevices objectAtIndex:foundindex] objectForKey:@"peripheral"];
                            globalSocketWIFiSEtup.peripheralPss = p;
                        }
                    }
                }
            }

            globalSocketWIFiSEtup.strBleAddress = strMacaddress;
            globalSocketWIFiSEtup.strWifiConfig = strWifiConfig;
            globalSocketWIFiSEtup = [[SocketWiFiSetupVC alloc] init];
            [self.navigationController pushViewController:globalSocketWIFiSEtup animated:true];
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
                        if ([[deviceDetail  valueForKey:@"device_type"] isEqual:@"4"])
                        {
                            if ([deviceDetail count] > 0)
                            {
                                [self deleteSocketDevice];
                            }
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
            [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"05" withLength:@"00" withPeripheral:classPeripheral];
        }
        else
        {
            [[BLEService sharedInstance] WriteSocketData:completeData withOpcode:@"09" withLength:@"2" withPeripheral:classPeripheral];
            [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"05" withLength:@"00" withPeripheral:classPeripheral];
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
                
                arrPackets =[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5], nil];
                [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];
            }
            else
            {
                NSArray * arrPackets =[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:9],[NSNumber numberWithInt:2],[NSNumber numberWithInt:index],[NSNumber numberWithInteger:switchStatus], nil];
                [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];
                arrPackets =[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5], nil];
                [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];
            }
        }
        else
        {
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
    [APP_DELEGATE endHudProcess];
}
-(void)btnBackClick
{
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
    [self.navigationController pushViewController:globalSocketAlarmVC animated:true];
}
-(void)timeOutForDeleteDevice
{
    [APP_DELEGATE endHudProcess];
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
#pragma mark- Recieve Data from BLE

-(void)AlarmListStoredinDevice:(NSMutableDictionary *)arrDictDetails
{
    [arrAlarmIdsofDevices addObject:arrDictDetails];
    
    if ([arrAlarmIdsofDevices count] >= 12)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            NSMutableArray * arrdata = [[NSMutableArray alloc] init];
            NSString * strQuery = [NSString stringWithFormat:@"select * from Socket_Alarm_Table  where ble_address = '%@' ",strMacAddress];
            [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:arrdata];
            
            for (int i = 0; i < [arrAlarmIdsofDevices count]; i++)
            {
                NSString * strAlarmId = [self stringFroHex:[[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"alaramID"]];
                NSString * strsocketID = [[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"socketID"];
                NSString * strdayValue = [[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"dayValue"];
                NSString * strOnTime = [self stringFroHex:[[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"onTime"]];
                NSString * strOffTime = [self stringFroHex:[[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"offTime"]];
                NSString * stralarmState = [[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"alarmState"];
                
                if ([arrdata count] == 0)
                {
                    if (![[[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"alaramID"] isEqual:@"0"])
                    {
                        NSString * strInsert  =[NSString stringWithFormat:@"insert into 'Socket_Alarm_Table'('alarm_id','socket_id','day_value','OnTimestamp','OffTimestamp','alarm_state','ble_address') values('%@','%@','%@','%@','%@','%@','%@')",strAlarmId,strsocketID,strdayValue,strOnTime,strOffTime,stralarmState,strMacAddress];
                        [[DataBaseManager dataBaseManager] execute:strInsert];
                    }
                }
                else
                {
                    if (![[[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"alaramID"] isEqual:@"0"])
                    {
                        NSString * update = [NSString stringWithFormat:@"update Socket_Alarm_Table set alarm_id = '%@', socket_id ='%@',day_value='%@', onTimestamp ='%@', offTimestamp = '%@', alarm_state = '%@' where ble_address = '%@' and alarm_id = '%@'",strAlarmId,strsocketID,strdayValue,strOnTime,strOffTime,stralarmState,strMacAddress,[[arrAlarmIdsofDevices objectAtIndex:i] valueForKey:@"alaramID"]];
                        [[DataBaseManager dataBaseManager] execute:update];
                    }
                }
            }
        });
    }
}
-(void)ReceiveAllSoketONOFFState:(NSString *)strState
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
        self->strAllSwSatate = strState;
    });
}
-(void)ReceivedSwitchStatusfromDevice:(NSMutableDictionary *)dictSwitch;
{
    [APP_DELEGATE endHudProcess];
    dictFromHomeSwState = dictSwitch;
    [tblView reloadData];
}
-(void)ReceivedMQTTStatus:(NSDictionary *)dictSwitch
{
    
}
-(void)ConnecttoMQTTSocketServer
{
    NSString * strClientId = [self checkforValidString:deviceTokenStr];
    if ([strClientId isEqualToString:@"NA"])
    {
        strClientId = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    }
    
    classMqttObj = [[CocoaMQTT alloc] initWithClientID:strClientId host:@"iot.vithamastech.com" port:8883];
    classMqttObj.delegate = self;
    [classMqttObj selfSignedSSLSetting];
    BOOL isConnected =  [classMqttObj connect];
    if (isConnected)
    {
        NSLog(@"MQTT is CONNECTING....");
    }
}
-(void)TimeOutforWifiConfiguration
{
    if (isMQTTConfigured == YES)
    {
        
    }
    else
    {
        [APP_DELEGATE endHudProcess];
    }
}
#pragma mark - Common Method to Publish on MQTT
-(void)PublishMessageonMQTTwithTopic:(NSString *)strTopic withDataArray:(NSArray *)arrData
{
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
    NSString * publishTopic = [NSString stringWithFormat:@"/vps/app/%@",strMacAddress];
    UInt16 subTop = [mqtt subscribe:publishTopic qos:2];
    NSLog(@"%d",subTop);
    NSLog(@"MQTT Connected --->");
    [self.delegate ConnectedSocketfromSocketDetailPage:mqtt];
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
    NSLog(@"Socket Detail mqtt didReceiveMessage =%@",[message payload]);
    NSString * strTopic = [self checkforValidString:[message topic]];
    NSArray * arrTopics = [strTopic componentsSeparatedByString:@"/"];
    NSString * strAddress = @"NA";
    if([arrTopics count]>= 3)
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
    NSLog(@"Topic Subscried successfully =%@",topics);
    NSString * strTopic = [NSString stringWithFormat:@"/vps/device/%@",[strMacAddress uppercaseString]];
    NSArray * arrPackets =[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:16],[NSNumber numberWithInt:0], nil];
    [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];
}
-(void)mqtt:(CocoaMQTT *)mqtt didUnsubscribeTopic:(NSString *)topic
{
    NSLog(@"Topic didUnsubscribeTopic =%@",topic);
}
-(void)mqtt:(CocoaMQTT *)mqtt didStateChangeTo:(enum CocoaMQTTConnState)state
{
    NSLog(@"State Changed===>%hhu",state);
    if (state == 3)
    {
        NSString * strClientId = [self checkforValidString:deviceTokenStr];
        if ([strClientId isEqualToString:@"NA"])
        {
            strClientId = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        }
        
        classMqttObj = [[CocoaMQTT alloc] initWithClientID:strClientId host:@"iot.vithamastech.com" port:8883];
        classMqttObj.delegate = self;
        [classMqttObj selfSignedSSLSetting];
        BOOL isConnected =  [classMqttObj connect];
        if (isConnected)
        {
            NSLog(@"MQTT is CONNECTING....");
        }
    }
}
-(void)mqttDidDisconnect:(CocoaMQTT *)mqtt withError:(NSError *)err
{
    NSLog(@"Disconnect Errore===>%@",err.description);
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
    globalSocketPeripheral = peripheral;
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
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
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
    NSString * strReceivedAddress = [[self checkforValidString:[dictData valueForKey:@"ble_address"]] uppercaseString];
    if([strReceivedAddress isEqualToString:[strMacAddress uppercaseString]])
    {
        NSArray * arrData = [dictData valueForKey:@"data"];
        if([arrData count] >= 1)
        {
            NSString * strOpcode = [self checkforValidString:[NSString stringWithFormat:@"%@",[arrData objectAtIndex:0]]];
            if([strOpcode isEqualToString:@"5"])
            {
                if([arrData count] >= 8)
                {
                    [self UpdateSwitchStatusfromMQTT:arrData];
                }
            }
            else if([strOpcode isEqualToString:@"9"])
            {
                NSString * strStatus = [arrData componentsJoinedByString:@""];

                if ([strStatus isEqualToString:@"911"])
                {
                    [APP_DELEGATE endHudProcess];
                    [mqttRequestTimeOut invalidate];
                    mqttRequestTimeOut = nil;
                }
            }
            else if([strOpcode isEqualToString:@"10"])
            {
                NSString * strStatus = [arrData componentsJoinedByString:@""];

                if ([strStatus isEqualToString:@"1011"])
                {
//                    [APP_DELEGATE endHudProcess];
                    [mqttRequestTimeOut invalidate];
                    mqttRequestTimeOut = nil;
                }
            }
            else if([strOpcode isEqualToString:@"16"])
            {
                NSString * strStatus = [arrData componentsJoinedByString:@""];
                if ([strStatus isEqualToString:@"16212"])
                {
                    isMQTTConfigured = YES;
                    [APP_DELEGATE endHudProcess];
                    [mqttRequestTimeOut invalidate];
                    mqttRequestTimeOut = nil;
                    imgNotWifiConnected.image = [UIImage imageNamed:@"wifiGreen.png"];
                }
                else
                {
                    imgNotWifiConnected.image = [UIImage imageNamed:@"wifired.png"];
                }
                if (classPeripheral.state == CBPeripheralStateDisconnected)
                {
                    NSString * strTopic = [NSString stringWithFormat:@"/vps/device/%@",[strMacAddress uppercaseString]];
                    NSArray * arrPackets =[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5], nil];
                    [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];
                }
            }
        }
    }
}
-(void)UpdateSwitchStatusfromMQTT:(NSArray *)arrData
{
    NSMutableDictionary * dictSwitcState = [[NSMutableDictionary alloc] init];
    for(int i =2; i < [arrData count]; i++)
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
        imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
    }
    else if ([strRecievedIdentifier isEqualToString:strClassIdentifier])
    {
        classPeripheral = peripheral;
        imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
    }
}
-(void)didDeviceConnectedCallback:(CBPeripheral *)peripheral
{
    NSString * strRecievedIdentifier = [NSString stringWithFormat:@"%@",peripheral.identifier];
    NSString * strClassIdentifier = [NSString stringWithFormat:@"%@",[self checkforValidString:[deviceDetail valueForKey:@"identifier"]]];

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
-(void) bluetoothPowerState:(NSString*)state;
{
    NSLog(@"====bluetoothPowerState===%@",state);
    if ([state isEqualToString:@"Bluetooth is currently powered off."])
    {
        imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
    }
}
-(void)deleteSocketDevice
{
    NSString * strBleAddress = [[deviceDetail  valueForKey:@"ble_address"] uppercaseString];
    NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set status ='2',is_sync = '0', wifi_configured = '0' where ble_address = '%@'",strBleAddress];
    [[DataBaseManager dataBaseManager] execute:strUpdate];
    
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
}
- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
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
@end
