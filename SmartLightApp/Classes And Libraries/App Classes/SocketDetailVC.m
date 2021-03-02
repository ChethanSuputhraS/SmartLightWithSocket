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

@interface SocketDetailVC ()<UITableViewDelegate,UITableViewDataSource,CBCentralManagerDelegate, CocoaMQTTDelegate>
{
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

//    [imgNotConnected removeFromSuperview];
    imgNotConnected = [[UIImageView alloc]init];
    imgNotConnected.image = [UIImage imageNamed:@"notconnect_iconWhite.png"];
    imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 32, 30, 22);
    imgNotConnected.contentMode = UIViewContentModeScaleAspectFit;
    imgNotConnected.layer.masksToBounds = true;
    [self.view addSubview:imgNotConnected];
    
//    [imgNotWifiConnected removeFromSuperview];
    imgNotWifiConnected = [[UIImageView alloc]init];
    imgNotWifiConnected.image = [UIImage imageNamed:@"wifigreen.png"];
    imgNotWifiConnected.frame = CGRectMake(DEVICE_WIDTH-60, 32, 30, 22);
    imgNotWifiConnected.contentMode = UIViewContentModeScaleAspectFit;
    imgNotWifiConnected.layer.masksToBounds = true;
    [self.view addSubview:imgNotWifiConnected];
    
//    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
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
    [lblTitle setText:@"Switch control"];
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
    
    UIImageView * imgBacksc = [[UIImageView alloc]initWithFrame:CGRectMake(10,globalStatusHeight+yy+20, DEVICE_WIDTH-20, 60)];
    imgBacksc.image = [UIImage imageNamed:@"SocketStatusImage.png"];
    imgBacksc.backgroundColor = UIColor.clearColor;
    [self.view addSubview:imgBacksc];
    
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, yy+globalStatusHeight+100, DEVICE_WIDTH, DEVICE_HEIGHT-yy-globalStatusHeight-100)];
    tblView.delegate = self;
    tblView.dataSource= self;
    tblView.backgroundColor = UIColor.clearColor;
    tblView.separatorStyle = UITableViewCellSelectionStyleNone;
    tblView.hidden = false;
    tblView.scrollEnabled = false;
    tblView.separatorColor = UIColor.clearColor;
    [self.view addSubview:tblView];
    
}
#pragma mark- Check Peripheral Connection & MQTT Available
-(void)ConnectPeripheralIfnotConnected
{
    arrAlarmIdsofDevices = [[NSMutableArray alloc] init];
    strMacAddress = [[deviceDetail valueForKey:@"ble_address"] uppercaseString];
        
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
            
            [APP_DELEGATE endHudProcess];
            [APP_DELEGATE startHudProcess:@"Checking Status..."];
            
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
        imgNotConnected.image = [UIImage imageNamed:@"Connected_icon.png"];

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
    return  7; // array have to pass
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    cell.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
                   

@end
