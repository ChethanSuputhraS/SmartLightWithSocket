//
//  ResetSocketVC.m
//  SmartLightApp
//
//  Created by Vithamas Technologies on 04/03/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import "ResetSocketVC.h"
#import "BLEService.h"
#import "MNMPullToRefreshView.h"
#import "HomeCell.h"


@interface ResetSocketVC ()<UITableViewDelegate,UITableViewDataSource,CBCentralManagerDelegate,MNMPullToRefreshManagerClient,FCAlertViewDelegate>
{
    UITableView * tblDeviceList;
    int globalStatusHeight;
    UILabel * lblScanning,*lblNoDevice;
    MNMPullToRefreshManager * topPullToRefreshManager;
    FCAlertView *alert, * timeOutAlert;
    NSTimer * disconnectionTimer,*connectionTimer,*advertiseTimer,*deviceRestedCheckTimer,*timertoStopIndicator;
    CBPeripheral * classPeripheral;
    CBCentralManager * centralManager;
    NSString * strSelectedAddress;
    NSInteger resetDeviceCount;
}
@end

@implementation ResetSocketVC

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
    
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [advertiseTimer invalidate];
    advertiseTimer = nil;
    advertiseTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(AdvertiseTimerMethod) userInfo:nil repeats:NO];
    
    [APP_DELEGATE startHudProcess:@"Scanning..."];
    
    [self setNavigationViewFrames];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    isSearchingfromSocketFactory = YES;

    [self InitialBLE];
    [self refreshBtnClick];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    currentScreen = @"SocketReset";

    [[[BLEManager sharedManager] nonConnectArr] removeAllObjects];
    [[BLEManager sharedManager] startScan];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:currentScreen object:nil];

}
-(void)viewWillDisappear:(BOOL)animated
{
    isSearchingfromSocketFactory = NO;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateUTCtime" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateCurrentGPSlocation" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DiscoverDevicesforSocketReset" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidConnectNotificationSocket" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidDisConnectNotificationSocket" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ResetSocketAuthenticationCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowSocketTurnOnOffPopup" object:nil];

    [super viewWillDisappear:YES];
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    int yy = 44;
    if (IS_IPHONE_X)
    {
        yy = 44;
    }
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy+globalStatusHeight)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.5;
    [viewHeader addSubview:lblBack];

    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, globalStatusHeight, DEVICE_WIDTH-120, yy)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Power socket"];
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

    UIImageView * imgRefresh = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-30, 20+13, 18, 18)];
    [imgRefresh setImage:[UIImage imageNamed:@"refresh_icon.png"]];
    [imgRefresh setContentMode:UIViewContentModeScaleAspectFit];
    imgRefresh.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:imgRefresh];
    
    UIButton * refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshBtn addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    refreshBtn.frame = CGRectMake(DEVICE_WIDTH-60, 0, 60, 64);
    refreshBtn.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:refreshBtn];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, globalStatusHeight + yy - 1, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = [UIColor darkGrayColor];
//    [viewHeader addSubview:line];
    
    tblDeviceList = [[UITableView alloc] initWithFrame:CGRectMake(0, yy+globalStatusHeight, DEVICE_WIDTH, DEVICE_HEIGHT-yy-globalStatusHeight)];
    tblDeviceList.delegate = self;
    tblDeviceList.dataSource= self;
    tblDeviceList.separatorStyle = UITableViewCellSelectionStyleNone;
    [tblDeviceList setShowsVerticalScrollIndicator:NO];
    tblDeviceList.backgroundColor = [UIColor clearColor];
    tblDeviceList.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblDeviceList.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:tblDeviceList];
    
    topPullToRefreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:tblDeviceList withClient:self];
    [topPullToRefreshManager setPullToRefreshViewVisible:YES];
    [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];
    
    yy = yy+30;
    
    lblScanning = [[UILabel alloc] initWithFrame:CGRectMake((DEVICE_WIDTH/2)-50, yy, 100, 44)];
    [lblScanning setBackgroundColor:[UIColor clearColor]];
    [lblScanning setText:@"Scanning..."];
    [lblScanning setTextAlignment:NSTextAlignmentCenter];
    [lblScanning setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [lblScanning setTextColor:[UIColor blackColor]];
    lblScanning.hidden = true;
    [self.view addSubview:lblScanning];

    lblNoDevice = [[UILabel alloc]initWithFrame:CGRectMake(30, (DEVICE_HEIGHT-100)/2, (DEVICE_WIDTH)-60, 100)];
    lblNoDevice.backgroundColor = UIColor.clearColor;
    [lblNoDevice setTextAlignment:NSTextAlignmentCenter];
    [lblNoDevice setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lblNoDevice setTextColor:[UIColor whiteColor]];
    lblNoDevice.text = @"No Devices Found.";
    [self.view addSubview:lblNoDevice];
    
    
}
#pragma mark- UITableView Methods
#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, 30)];
    headerView.backgroundColor = [UIColor clearColor];
    
    if (tableView == tblDeviceList)
    {
        UILabel *lblmenu=[[UILabel alloc]init];
        lblmenu.text = @" Tap on Connect button to reset device";
        [lblmenu setTextColor:[UIColor whiteColor]];
        [lblmenu setFont:[UIFont fontWithName:CGRegular size:textSizes-1]];
        lblmenu.frame = CGRectMake(10,0, DEVICE_WIDTH-20, 30);
        lblmenu.backgroundColor = UIColor.clearColor;
        [headerView addSubview:lblmenu];
        
        return headerView;
    }
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
    return [[[BLEManager sharedManager] arrSocketFactoryResetDevices] count];//
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[HomeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
        cell.lblConnect.frame = CGRectMake(DEVICE_WIDTH/2, 0, DEVICE_WIDTH/2-5, 60);
        cell.lblConnect.textAlignment = NSTextAlignmentRight;
        cell.lblConnect.text= @"Tap here to reset";
        
        NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
        arrayDevices =[[BLEManager sharedManager] arrSocketFactoryResetDevices];

        cell.lblDeviceName.frame = CGRectMake(18, 0, DEVICE_WIDTH-36, 35);
        cell.lblAddress.frame = CGRectMake(18, 30,  DEVICE_WIDTH-36, 25);
        [cell.lblDeviceName setFont:[UIFont fontWithName:CGRegular size:textSizes+3]];
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"peripheral"];
        if (p.state == CBPeripheralStateConnected)
        {
            cell.lblConnect.text= @"Tap here to reset";

        }
        cell.lblDeviceName.text = @"Vithamas Socket";
        cell.lblAddress.text = [[[arrayDevices  objectAtIndex:indexPath.row]valueForKey:@"ble_address"] uppercaseString];
        cell.backgroundColor = UIColor.clearColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        if ([[[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"isAdded"] isEqualToString:@"1"])
        {
            cell.lblAddress.textColor = [UIColor colorWithRed:18/255.0f green:188.0/255.0f blue:0 alpha:1];
        }
        else
        {
            cell.lblAddress.textColor = [UIColor whiteColor];
        }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] arrSocketFactoryResetDevices];
    if ([arrayDevices count]>0)
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"peripheral"];
        classPeripheral = p;
        strSelectedAddress = [[[arrayDevices  objectAtIndex:indexPath.row]valueForKey:@"ble_address"] uppercaseString];
        if (p.state == CBPeripheralStateConnected)
        {
            [[BLEService sharedInstance] sendNotificationsSKT:classPeripheral withType:NO withUUID:@"0000AB00-2687-4433-2208-ABF9B34FB000"];
            [[BLEService sharedInstance] EnableNotificationsForCommandSKT:classPeripheral withSocketReset:YES];
            [[BLEService sharedInstance] EnableNotificationsForDATASKT:classPeripheral withSocketReset:YES];
            [[BLEService sharedInstance] GetAuthcodeforSocket:classPeripheral withValue:@"1" isforSocketReset:YES];//Ask for
        }
        else
        {
            NSLog(@"Add_Socket_Device_Peripheral = %@",p);

            [connectionTimer invalidate];
            connectionTimer = nil;
            connectionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(ConnectionTimeOutMethod) userInfo:nil repeats:NO];
            
            [APP_DELEGATE endHudProcess];
            [APP_DELEGATE startHudProcess:@"Connecting..."];
            [[BLEManager sharedManager] connectDevice:p];
        }
    }
}
#pragma mark- All Buttons deligate
-(void)refreshBtnClick
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"PairedDevices"];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSMutableArray * arrPreviouslyFound = [[NSMutableArray alloc] initWithArray:array];
    NSArray * tmparr = [[BLEManager sharedManager] getLastSocketConnected];
    
    [[[BLEManager sharedManager] arrSocketFactoryResetDevices] removeAllObjects];
    [[BLEManager sharedManager] rescan];
    [tblDeviceList reloadData];

    NSLog(@"Array=%@",tmparr);
    NSLog(@"Array 111=%@",arrPreviouslyFound);

    for (int i=0; i<tmparr.count; i++)
    {
        CBPeripheral * p = [tmparr objectAtIndex:i];
        NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",p.identifier];
        if ([[arrPreviouslyFound valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
        {
            NSInteger  foudIndex = [[arrPreviouslyFound valueForKey:@"identifier"] indexOfObject:strCurrentIdentifier];
            if (foudIndex != NSNotFound)
            {
                if ([arrPreviouslyFound count] > foudIndex)
                {
                    if (![[[[BLEManager sharedManager] arrSocketFactoryResetDevices] valueForKey:@"peripheral"] containsObject:p])
                    {
                        NSMutableDictionary * dict = [arrPreviouslyFound objectAtIndex:foudIndex];
                        [dict setValue:p forKey:@"peripheral"];
                        [[[BLEManager sharedManager] arrSocketFactoryResetDevices] addObject:dict];
                    }
                }
            }
        }
    }
    if ( [[[BLEManager sharedManager] arrSocketFactoryResetDevices] count] >0)
    {
        tblDeviceList.hidden = false;
        lblNoDevice.hidden = true;
        [tblDeviceList reloadData];
    }
    else
    {
        tblDeviceList.hidden = true;
        lblNoDevice.hidden = false;
    }
}
-(void)btnBackClick
{
    currentScreen = @"NA";

    NSArray * arrResetDevices = [[BLEManager sharedManager] arrSocketFactoryResetDevices];
    for (int i =0; i < [arrResetDevices count]; i++)
    {
        CBPeripheral * p = [[arrResetDevices objectAtIndex:i] objectForKey:@"peripheral"];
        if (p.state == CBPeripheralStateConnected)
        {
            [[BLEManager sharedManager] disconnectDevice:p];
        }
    }
    isSearchingfromSocketFactory = NO;
    [deviceRestedCheckTimer invalidate];
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - BLE Methods
-(void)InitialBLE
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DiscoverDevicesforSocketReset" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidConnectNotificationSocket" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidDisConnectNotificationSocket" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ResetSocketAuthenticationCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowSocketTurnOnOffPopup" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotifiyDiscoveredDevices:) name:@"DiscoverDevicesforSocketReset" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidConnectNotification:) name:@"DeviceDidConnectNotificationSocket" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidDisConnectNotification:) name:@"DeviceDidDisConnectNotificationSocket" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(AuthenticationCompleted:) name:@"ResetSocketAuthenticationCompleted" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ShowSocketTurnOnOffPopup:) name:@"ShowSocketTurnOnOffPopup" object:nil];

}
-(void)GlobalBLuetoothCheck
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Vithamas" message:@"Please enable Bluetooth Connection. Tap on enable Bluetooth icon by swiping Up." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (@available(iOS 10.0, *)) {
        if (central.state == CBManagerStatePoweredOff)
        {
            [APP_DELEGATE endHudProcess];
            [self GlobalBLuetoothCheck];
        }
    } else
    {
        
    }
}
-(void)NotifiyDiscoveredDevices:(NSNotification*)notification//Update peripheral
{
dispatch_async(dispatch_get_main_queue(), ^(void)
    {
     if ( [[[BLEManager sharedManager] arrSocketFactoryResetDevices] count] >0)
     {
        self->tblDeviceList.hidden = false;
        self->lblNoDevice.hidden = true;
        [self->tblDeviceList reloadData];
//        [APP_DELEGATE endHudProcess];
    }
    else
    {
        self->tblDeviceList.hidden = true;
        self->lblNoDevice.hidden = false;}
        [self->tblDeviceList reloadData];});
}
-(void)DeviceDidConnectNotification:(NSNotification*)notification //Connect periperal
{
    [connectionTimer invalidate];

    CBPeripheral * peripheral = [notification object];
    if (peripheral != nil)
    {
//        [self SendResetFactoryToDevice];
    }
    
    [APP_DELEGATE endHudProcess];
    [tblDeviceList reloadData];
}
-(void)DeviceDidDisConnectNotification:(NSNotification*)notification //Disconnect periperal
{
        dispatch_async(dispatch_get_main_queue(), ^(void){
        [[[BLEManager sharedManager] arrSocketFactoryResetDevices] removeAllObjects];
        [[BLEManager sharedManager] rescan];
        [self->tblDeviceList reloadData];
        [APP_DELEGATE endHudProcess];});
}
#pragma mark:- Add Device BLE Commands
-(void)AuthenticationCompleted:(NSNotification *)notify
{
    [self ShowResetNotification];
//    NSString * strKey = [[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"];
//    NSData * encryptKeyData= [[NSData alloc] init];
//    encryptKeyData = [self getUserKeyconverted:strKey];
//
//        [[BLEService sharedInstance] WriteSocketData:encryptKeyData withOpcode:@"06" withLength:@"16" withPeripheral:peripheral];
}
-(void)SendResetFactoryToDevice
{
    NSInteger intPacket = [@"0" integerValue];
    NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
    [[BLEService sharedInstance] WriteSocketDataToResetSocket:dataPacket withOpcode:@"36" withLength:@"01" withPeripheral:classPeripheral];
}
-(void)ShowResetNotification
{
    [alert removeFromSuperview];
    alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    alert.tag = 333;
//    alert.selectedPeripheral = peripheral;
    alert.delegate = self;
    [alert addButton:@"Yes" withActionBlock:^{
        [self SendResetFactoryToDevice];

    }];
    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
    [alert showAlertInView:self
                 withTitle:@"Vithamas"
              withSubtitle:@"Do you want to Reset this device?"
           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
       withDoneButtonTitle:@"No" andButtons:nil];
}
-(void)ShowSocketTurnOnOffPopup:(NSNotification *)notify
{
    [[[BLEManager sharedManager] arrBLESocketDevices] removeAllObjects];
    
    resetDeviceCount = 0;
    [deviceRestedCheckTimer invalidate];
    deviceRestedCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(CheckDeviceResettedOrNot) userInfo:nil repeats:YES];
    [timeOutAlert removeFromSuperview];
    timeOutAlert = [[FCAlertView alloc] init];
    timeOutAlert.colorScheme = [UIColor blackColor];
    [timeOutAlert makeAlertTypeSuccess];
    timeOutAlert.tag = 1111;
    [timeOutAlert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Please turn off and turn on Power Socket within 15 secs to factory reset while the light is blinking red."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
    timeOutAlert.hideAllButtons = YES;
}
-(void)CheckDeviceResettedOrNot
{
    resetDeviceCount = resetDeviceCount + 1;

    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] arrBLESocketDevices];
    if ([[arrayDevices valueForKey:@"ble_address"] containsObject:strSelectedAddress])
    {
        NSInteger foundIndex = [[arrayDevices valueForKey:@"ble_address"] indexOfObject:strSelectedAddress];
        if (foundIndex != NSNotFound)
        {
            if ([arrayDevices count] > foundIndex)
            {
                if ([[[arrayDevices objectAtIndex:foundIndex] allKeys] containsObject:@"Manufac"])
                {
                    NSString * strManufacture = [[arrayDevices objectAtIndex:foundIndex] valueForKey:@"Manufac"];
                    strManufacture = [strManufacture stringByReplacingOccurrencesOfString:@" " withString:@""];
                    strManufacture = [strManufacture stringByReplacingOccurrencesOfString:@">" withString:@""];
                    strManufacture = [strManufacture stringByReplacingOccurrencesOfString:@"<" withString:@""];
                    NSLog(@"--------CheckDeviceResettedOrNot---------->%@",strManufacture);
                    if ([strManufacture length] >= 22)
                    {
                        NSRange rangeCheck = NSMakeRange(18, 4);
                        NSString * strOpCodeCheck = [strManufacture substringWithRange:rangeCheck];
                        if ([strOpCodeCheck isEqualToString:@"3000"])
                        {
                            [[BLEManager sharedManager] RemoveDevicefromAutoConnection:[NSString stringWithFormat:@"%@",classPeripheral.identifier]];

                            [deviceRestedCheckTimer invalidate];
                            deviceRestedCheckTimer = nil;
                            [timeOutAlert removeFromSuperview];
                            [self ShowSuccessPopup];
                            resetDeviceCount = 0;
                        }
                    }
                }
            }
        }
    }
    if (resetDeviceCount != 0 && resetDeviceCount > 15)
    {
        [timeOutAlert removeFromSuperview];

        [deviceRestedCheckTimer invalidate];
        deviceRestedCheckTimer = nil;
        resetDeviceCount = 0;

        FCAlertView * alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"Device not resetted. Please try again!!!"
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];

    }
}
-(void)ShowSuccessPopup
{
    if (globalDashBoardVC)
    {
        [globalDashBoardVC DeleteSocketDeviceforBLEAddress:strSelectedAddress];
    }
    FCAlertView * alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Device had been reset Successfully."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];

}
#pragma mark - Timer Methods
-(void)ConnectionTimeOutMethod
{
    if (classPeripheral.state == CBPeripheralStateConnected)
    {
    }
    else
    {
        if (classPeripheral == nil)
        {
            return;
        }
        
        [APP_DELEGATE endHudProcess];
        [alert removeFromSuperview];
        alert = [[FCAlertView alloc] init];
        [alert makeAlertTypeCaution];
        alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
        [alert showAlertWithTitle:@"Vithamas" withSubtitle:@"Something went wrong. Please try again later." withCustomImage:[UIImage imageNamed:@"alert-round.png"] withDoneButtonTitle:@"OK" andButtons:nil];
        [self refreshBtnClick];
    }
}
-(void)DisConnectionTimeOutMethod
{
    [disconnectionTimer invalidate];
    disconnectionTimer = nil;
    [APP_DELEGATE endHudProcess];
    [self refreshBtnClick];
}
-(void)AdvertiseTimerMethod
{
    [APP_DELEGATE endHudProcess];
    if ( [[[BLEManager sharedManager] arrSocketFactoryResetDevices] count] >0){
        self->tblDeviceList.hidden = false;
        self->lblNoDevice.hidden = true;
        [self->tblDeviceList reloadData];
    }
    else
    {
        self->tblDeviceList.hidden = true;
        self->lblNoDevice.hidden = false;
    }
        [self->tblDeviceList reloadData];
}
-(void)toStopIndicator
{
    [APP_DELEGATE endHudProcess];
}
-(void)timeOutConnection
{
    [timertoStopIndicator invalidate];

    if (classPeripheral.state == CBPeripheralStateConnected)
    {
    }
    else
    {
        [APP_DELEGATE endHudProcess];
    }
    [APP_DELEGATE endHudProcess];
}

-(void)timeoutMethodClick
{
    [timeOutAlert dismissAlertView];
    [timeOutAlert removeFromSuperview];
    [APP_DELEGATE hudEndProcessMethod];
    [deviceRestedCheckTimer invalidate];
    [APP_DELEGATE endHudProcess];
    [[BLEManager sharedManager] rescan];

}
#pragma mark - FCAlertView Methods

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 222)
    {
        isSearchingfromSocketFactory = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (alertView.tag == 333)
    {
        [timertoStopIndicator invalidate];
        timertoStopIndicator = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(toStopIndicator) userInfo:nil repeats:NO];
        [self SendResetFactoryToDevice];
    }
}

#pragma mark - MEScrollToTopDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [topPullToRefreshManager tableViewScrolled];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y >=360.0f)
    {
    }
    else
        [topPullToRefreshManager tableViewReleased];
}
- (void)pullToRefreshTriggered:(MNMPullToRefreshManager *)manager
{
    [self performSelector:@selector(stoprefresh) withObject:nil afterDelay:1.5];
}
-(void)stoprefresh
{
    [self refreshBtnClick];
    [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];
}

@end
/*
 RESPONSE from MQTT
 
 2021-04-02 16:45:46.467090+0530 SmartLightApp[2065:554913] Socket Detail mqtt didReceiveMessage =(
     11,
     14,
     1,
     0,
     127,
     96,
     102,
     252,
     180,
     96,
     102,
     252,
     240,
     0,
     0,
     0
 )
 2021-04-02 16:45:46.468068+0530 SmartLightApp[2065:554913] ==========ReceivedMQTTResponsefromserver=========(
     11,
     14,
     1,
     0,
     127,
     96,
     102,
     252,
     180,
     96,
     102,
     252,
     240,
     0,
     0,
     0
 )
 */
