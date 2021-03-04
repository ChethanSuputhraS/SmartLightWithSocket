//
//  AddSocketVC.m
//  SmartLightApp
//
//  Created by Kalpesh Panchasara on 06/01/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import "AddSocketVC.h"
#import "HomeCell.h"
#import "BLEService.h"
#import <CocoaMQTT/CocoaMQTT.h>
#import "SocketDetailVC.h"

@import CocoaMQTT;

@interface AddSocketVC ()<UITableViewDelegate,UITableViewDataSource,FCAlertViewDelegate,CBCentralManagerDelegate,UITextFieldDelegate, CocoaMQTTDelegate,URLManagerDelegate, BLEServiceDelegate, BLEServiceAddSocketDelegate>
{
    FCAlertView *alert;
    NSString * strDeviceNames,* strHexIdofDevice;

    NSMutableArray * deviceListArray ;
    BOOL isDeviceResponsed, isCurrentDeviceWIFIConfigured, isShowPasswordEye;
    NSString * strCurrentSelectedAddress;
    NSInteger selectedWifiIndex;
    NSTimer * WifiScanTimer;
    NSMutableArray * arrConnectedSockets;
    NSMutableDictionary * dictConnectedSockets;
    BOOL isWifiListFound, isWifiWritePasswordResponded;
    NSString * strSavedTableID;
    NSMutableDictionary * serverDict;
    BOOL isAfterWifiConfigured, isRequestedforAddDevice;
    int wifiConnectionStatusRetryCount;
    UIButton *btnShowPass;
}

@end

@implementation AddSocketVC

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
    
    dictConnectedSockets = [[NSMutableDictionary alloc] init];
    arrGlobalDevices = [[NSMutableArray alloc] init];
    arrConnectedSockets = [[NSMutableArray alloc] init];
    
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [advertiseTimer invalidate];
    advertiseTimer = nil;
    advertiseTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(AdvertiseTimerMethod) userInfo:nil repeats:NO];
    
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Scanning..."];
    dictSwState = [[NSMutableDictionary alloc] init];
  
    
    NSString * strQuery = [NSString stringWithFormat:@"Select * from Device_Table where user_id ='%@' and status = '1' group by ble_address",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:deviceListArray];
    
    [super viewDidLoad];
    
    [[BLEService sharedInstance] setDelegate:self];
    [[BLEService sharedInstance] setAddSocketdelegate:self];

    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    currentScreen = @"AddSocket";
    [self InitialBLE];
    [self refreshBtnClick];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateUTCtime" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateCurrentGPSlocation" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotifiyDiscoveredDevicesforSockets" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidConnectNotificationSocket" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidDisConnectNotificationSocket" object:nil];

    [super viewWillDisappear:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
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
    [viewHeader addSubview:line];
    
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
#pragma mark- Buttons Click Events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES ];
}
-(void)refreshBtnClick
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"PairedDevices"];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSMutableArray * arrPreviouslyFound = [[NSMutableArray alloc] initWithArray:array];
    NSArray * tmparr = [[BLEManager sharedManager] getLastSocketConnected];
    
    [[[BLEManager sharedManager] arrBLESocketDevices] removeAllObjects];
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
                    if (![[[[BLEManager sharedManager] arrBLESocketDevices] valueForKey:@"peripheral"] containsObject:p])
                    {
                        NSMutableDictionary * dict = [arrPreviouslyFound objectAtIndex:foudIndex];
                        [dict setValue:p forKey:@"peripheral"];
                        [[[BLEManager sharedManager] arrBLESocketDevices] addObject:dict];
                    }
                }
            }
        }
    }
    
    if ( [[[BLEManager sharedManager] arrBLESocketDevices] count] >0)
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
-(void)btnSaveWIFIClick
{
  if ([txtRouterPassword.text isEqual:@""])
    {
        [self AlertViewFCTypeCautionCheck:@"Please enter Wi-Fi password"];
    }
    else
    {
        [APP_DELEGATE startHudProcess:@"Connecting..."];
        // MQTT request to device here 13 for ssid  14 for password and IP = @"13.57.255.95"
        if ([APP_DELEGATE isNetworkreachable])
        {
            isWifiWritePasswordResponded = NO;
            [connectionTimer invalidate];
            connectionTimer = nil;
            connectionTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(ConnectWifiTimeout) userInfo:nil repeats:NO];
            
            NSString * strIndex = [[arrayWifiavl objectAtIndex:selectedWifiIndex] valueForKey:@"Index"];
            NSInteger intPacket = [strIndex integerValue];
            NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
            [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"13" withLength:@"01" withPeripheral:classPeripheral]; // D

            [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self-> viewForTxtBg.frame = CGRectMake(20, DEVICE_HEIGHT, DEVICE_WIDTH-40, 250);
            }completion:(^(BOOL finished){
                [self-> viewTxtfld removeFromSuperview];
            })];
        }
        else
        {
            [self TostNotification:@"Please connect to the internet."];
        }
    }
}
-(void)ConnectWifiTimeout
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [APP_DELEGATE endHudProcess];
        if (isWifiWritePasswordResponded == NO)
        {
            [self AlertViewFCTypeCautionCheck:@"Something went wrong. Please try again!"];
        }
        
        isWifiWritePasswordResponded = NO;
    });

}
-(void)fortestwritepassword
{
    NSString * strPassword  = txtRouterPassword.text;
    [[BLEService sharedInstance] WriteWifiPassword:strPassword];

}
-(void)btnNotNowClick
{
    [self.view endEditing:true];
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
    self-> viewTxtfld.frame = CGRectMake(20, DEVICE_HEIGHT, DEVICE_WIDTH-40, 250);
     }
        completion:(^(BOOL finished)
      {
        [self OnlyAccesswithBluetoothPopup];
    })];
}
-(void)btnCancelClick
{
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
    self-> viewSSIDList.frame = CGRectMake(20, DEVICE_HEIGHT, DEVICE_WIDTH-40, 300);
     }
        completion:(^(BOOL finished)
      {
        [self-> viewSSIDback removeFromSuperview];
        [self OnlyAccesswithBluetoothPopup];
        
    })];
}
-(void)OnlyAccesswithBluetoothPopup
{
    [alert removeFromSuperview];
    alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    alert.tag = 333;
    alert.delegate = self;
    [alert makeAlertTypeCaution];
    [alert showAlertInView:self
                       withTitle:@"Vithamas"
                    withSubtitle:@"You can control this Socket through Bluetooth only."
                 withCustomImage:[UIImage imageNamed:@"logo.png"]
             withDoneButtonTitle:nil
                      andButtons:nil];
}
#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, 30)];
    headerView.backgroundColor = [UIColor clearColor];
    
    if (tableView == tblDeviceList)
    {
        UILabel *lblmenu=[[UILabel alloc]init];
        lblmenu.text = @" Tap on Connect button to pair with device";
        [lblmenu setTextColor:[UIColor whiteColor]];
        [lblmenu setFont:[UIFont fontWithName:CGRegular size:textSizes-1]];
        lblmenu.frame = CGRectMake(10,0, DEVICE_WIDTH-20, 30);
        lblmenu.backgroundColor = UIColor.clearColor;
        [headerView addSubview:lblmenu];
        
        return headerView;
    }
    else if (tableView == tblSSIDList)
    {
        UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, tblSSIDList.frame.size.width, 25)];
        headerView.backgroundColor = [UIColor clearColor];
        
        UILabel *lblmenu=[[UILabel alloc]init];
        lblmenu.text = @"Tap on your Wi-Fi to connect";
        [lblmenu setTextColor:[UIColor blackColor]];
        [lblmenu setFont:[UIFont fontWithName:CGRegular size:textSizes]];
        lblmenu.frame = CGRectMake(0,0, tblSSIDList.frame.size.width, 25);
        lblmenu.backgroundColor = UIColor.whiteColor;
        lblmenu.textAlignment = NSTextAlignmentCenter;
        [headerView addSubview:lblmenu];
        
        return headerView;
    }
    return [UIView new];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == tblDeviceList)
    {
        return 30;
    }
    else if (tableView == tblSSIDList)
    {
        return 25;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblDeviceList)
    {
        return [[[BLEManager sharedManager] arrBLESocketDevices] count];
    }
    else
    {
        if (arrayWifiavl.count >0)
        {
            return arrayWifiavl.count;
        }
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblDeviceList)
    {
        return 70;
    }
    else if (tableView == tblSSIDList)
    {
        return 40;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[HomeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    if (tableView == tblDeviceList)
    {
        cell.lblConnect.text= @"Connect";
        
        NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
        arrayDevices =[[BLEManager sharedManager] arrBLESocketDevices];

        cell.lblDeviceName.frame = CGRectMake(18, 0, DEVICE_WIDTH-36, 35);
        cell.lblAddress.frame = CGRectMake(18, 30,  DEVICE_WIDTH-36, 25);
        [cell.lblDeviceName setFont:[UIFont fontWithName:CGRegular size:textSizes+3]];
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"peripheral"];
        if (p.state == CBPeripheralStateConnected)
        {
            cell.lblConnect.text= @"Disconnect";
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
    }
    else if (tableView == tblSSIDList)
    {
        cell.lblConnect.hidden = true;
        cell.lblBack.hidden = true;
        cell.lblDeviceName.textColor = UIColor.blackColor;
        cell.lblDeviceName.text = [[arrayWifiavl objectAtIndex:indexPath.row] valueForKey:@"SSIDdata"];//;
        cell.lblAddress.hidden = true; //[[arrayWifiList objectAtIndex:indexPath.row] valueForKey:@"SSIDdata"];//@"VithamasTech";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblDeviceList)
    {
        NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
        arrayDevices =[[BLEManager sharedManager] arrBLESocketDevices];
        if ([arrayDevices count]>0)
        {
            CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"peripheral"];
            
            if (p.state == CBPeripheralStateConnected)
            {
                [APP_DELEGATE endHudProcess];
                [APP_DELEGATE startHudProcess:@"Disconnecting..."];
                [[BLEManager sharedManager] disconnectDevice:p];
                [disconnectionTimer invalidate];
                disconnectionTimer = nil;
                disconnectionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(DisConnectionTimeOutMethod) userInfo:nil repeats:NO];
            }
            else
            {
                NSLog(@"Add_Socket_Device_Peripheral = %@",p);

                NSString * strManufacture = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"Manufac"];
                strManufacture = [strManufacture stringByReplacingOccurrencesOfString:@" " withString:@""];
                strManufacture = [strManufacture stringByReplacingOccurrencesOfString:@">" withString:@""];
                strManufacture = [strManufacture stringByReplacingOccurrencesOfString:@"<" withString:@""];
                
                isRequestedforAddDevice = YES;
                
                if ([strManufacture length] >= 22)
                {
                    NSRange rangeCheck = NSMakeRange(18, 4);
                    NSString * strOpCodeCheck = [strManufacture substringWithRange:rangeCheck];
                    
                    if ([[arrPeripheralsCheck valueForKey:@"identifier"] containsObject:p.identifier])
                    {
                        NSInteger foundIndex = [[arrPeripheralsCheck valueForKey:@"identifier"] indexOfObject:p.identifier];
                        if (foundIndex != NSNotFound)
                        {
                            if ([arrPeripheralsCheck count] > foundIndex)
                            {
                                NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:strOpCodeCheck, @"status", p.identifier,@"identifier", nil];
                                [arrPeripheralsCheck replaceObjectAtIndex:foundIndex withObject:dict];
                            }
                        }
                    }
                    else
                    {
                        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:strOpCodeCheck, @"status", p.identifier,@"identifier", nil];
                        [arrPeripheralsCheck addObject:dict];
                    }
                }

                [connectionTimer invalidate];
                connectionTimer = nil;
                connectionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(ConnectionTimeOutMethod) userInfo:nil repeats:NO];
                classPeripheral = p;
//                globalSocketPeripheral = p;
                
                [APP_DELEGATE endHudProcess];
                [APP_DELEGATE startHudProcess:@"Connecting..."];
                [[BLEManager sharedManager] connectDevice:p];
                NSString * strAddress = [[[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"ble_address"] uppercaseString];
                NSString * strManudata = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"Manufac"];
                NSString * strIsAdded = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"isAdded"];
                strCurrentSelectedAddress = strAddress;
                if ([[arrConnectedSockets valueForKey:@"identifier"] containsObject:p.identifier])
                {
                    NSInteger foundIndex = [[arrConnectedSockets valueForKey:@"identifier"] indexOfObject:p.identifier];
                    if (foundIndex != NSNotFound)
                    {
                        if ([arrConnectedSockets count] > foundIndex)
                        {
                            NSDictionary * dict  = [[NSDictionary alloc] initWithObjectsAndKeys:p,@"peripheral",strAddress,@"ble_address",strManudata,@"Manufac", strIsAdded,@"isAdded",nil];
                            [arrConnectedSockets replaceObjectAtIndex:foundIndex withObject:dict];
                        }
                    }
                }
                else
                {
                    NSDictionary * dict  = [[NSDictionary alloc] initWithObjectsAndKeys:p,@"peripheral",strAddress,@"ble_address",strManudata,@"Manufac", strIsAdded,@"isAdded",p.identifier,@"identifier",nil];
                    [arrConnectedSockets addObject:dict];
                }
            }
        }
    }
    else if (tableView == tblSSIDList)
    {
        selectedWifiIndex = indexPath.row;
        strSSID = [[arrayWifiavl objectAtIndex:indexPath.row] valueForKey:@"SSIDdata"];
        [self OpenWIFIViewtoSetPassword:strSSID];

        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self-> viewSSIDList.frame = CGRectMake(20, DEVICE_HEIGHT, DEVICE_WIDTH-40, 300);}
                        completion:(^(BOOL finished){
            [self-> viewSSIDback removeFromSuperview];})];
    }
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
    if ( [[[BLEManager sharedManager] arrBLESocketDevices] count] >0){
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
#pragma mark- Setup For testFielld
-(void)OpenWIFIViewtoSetPassword:(NSString *)strWIFIname
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
    
        [APP_DELEGATE endHudProcess];
        [self-> viewTxtfld removeFromSuperview];

        self->viewForTxtBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
        self->viewForTxtBg .backgroundColor = UIColor.blackColor;
        self->viewForTxtBg.alpha = 0.5;
        [self.view addSubview:self->viewForTxtBg];
    
        self->viewTxtfld = [[UIView alloc] initWithFrame:CGRectMake(20, DEVICE_HEIGHT, DEVICE_WIDTH-40, 250)];
        self->viewTxtfld .backgroundColor = [UIColor colorWithRed:245.0/255 green:1 blue:1 alpha:1]; //
        self->viewTxtfld.layer.cornerRadius = 6;
//        self->viewTxtfld.alpha = 1;
//        self->viewTxtfld.layer.borderColor = UIColor.whiteColor.CGColor;
//        self->viewTxtfld.layer.borderWidth = 0.5;
        self->viewTxtfld.clipsToBounds = true;
        [self.view addSubview:self->viewTxtfld];
    
        UILabel * lblHint = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, self->viewTxtfld.frame.size.width-10, 40)];
        lblHint.text = @"Please Enter password to connect Device with Wi-Fi.";
        lblHint.textColor = UIColor.blackColor;
//    lblHint.backgroundColor = UIColor.lightGrayColor;
        lblHint.textAlignment = NSTextAlignmentCenter;
        lblHint.numberOfLines = 0;
        lblHint.font = [UIFont fontWithName:CGRegular size:textSizes];
        [self->viewTxtfld addSubview:lblHint];
    
        int yy = 00;
        self->txtDeviceName = [[UITextField alloc] initWithFrame:CGRectMake(10, yy, self->viewTxtfld.frame.size.width-20, 50)];
        [self setTextfieldProperties:self->txtDeviceName withPlaceHolderText:@"" withtextSizes:textSizes];
        self->txtDeviceName.returnKeyType = UIReturnKeyNext;
//    [viewTxtfld addSubview:txtDeviceName];
    
        yy = yy+40;
        UILabel * lblRouterName = [[UILabel alloc] initWithFrame:CGRectMake(10, yy, self->viewTxtfld.frame.size.width-20, 60)];
        lblRouterName.textColor= UIColor.blackColor;
        lblRouterName.textAlignment = NSTextAlignmentCenter;
        lblRouterName.numberOfLines = 0;
        lblRouterName.font = [UIFont fontWithName:CGRegular size:textSizes+1];
        lblRouterName.text = @"Connected Wi-Fi";
        [self->viewTxtfld addSubview:lblRouterName];
        
        yy = yy+50;
        UITextField * txtRouterName = [[UITextField alloc] initWithFrame:CGRectMake(10, yy, self->viewTxtfld.frame.size.width-20, 50)];
        [self setTextfieldProperties:txtRouterName withPlaceHolderText:@"" withtextSizes:textSizes];
        txtRouterName.returnKeyType = UIReturnKeyDone;
        txtRouterName.backgroundColor = UIColor.blackColor;
        txtRouterName.text = [NSString stringWithFormat:@" %@",strWIFIname];
        txtRouterName.textColor = UIColor.whiteColor;
        txtRouterName.alpha = 0.7;
        txtRouterName.userInteractionEnabled = NO;
//        txtRouterName.textAlignment = NSTextAlignmentCenter;
        [viewTxtfld addSubview:txtRouterName];
        
        
        yy = yy+55;
        self->txtRouterPassword = [[UITextField alloc] initWithFrame:CGRectMake(10, yy, self->viewTxtfld.frame.size.width-20, 50)];
        [self setTextfieldProperties:self->txtRouterPassword withPlaceHolderText:@" Enter Wi-Fi Password" withtextSizes:textSizes];
        self->txtRouterPassword.returnKeyType = UIReturnKeyDone;
        self->txtRouterPassword.textColor = UIColor.whiteColor;
        self->txtRouterPassword.backgroundColor = UIColor.blackColor;
        self->txtRouterPassword.alpha = 0.7;
        [self->viewTxtfld addSubview:self->txtRouterPassword];
        
        self->btnShowPass = [UIButton buttonWithType:UIButtonTypeCustom];
        self->btnShowPass.frame = CGRectMake(txtRouterPassword.frame.size.width-50, yy, 50, 50);
        self->btnShowPass.backgroundColor = [UIColor clearColor];
        [self->btnShowPass addTarget:self action:@selector(showPassclick) forControlEvents:UIControlEventTouchUpInside];
        [self->btnShowPass setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
        [self->viewTxtfld addSubview:btnShowPass];
    
        isShowPasswordEye = NO;
        
        UIButton *  btnNotNow = [[UIButton alloc]init];
        btnNotNow.frame = CGRectMake(0, self->viewTxtfld.frame.size.height-50, self->viewTxtfld.frame.size.width/2-5, 50);
        [btnNotNow addTarget:self action:@selector(btnNotNowClick) forControlEvents:UIControlEventTouchUpInside];
        [btnNotNow setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        btnNotNow.backgroundColor = [UIColor colorWithRed:1 green:155.0/255 blue:0 alpha:1];//UIColor.yellowColor;
//        btnNotNow.alpha = 0.7;
        [btnNotNow setTitle:@"Not now" forState:normal];
        [btnNotNow setTitleColor:UIColor.whiteColor forState:normal];
        btnNotNow.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+2];
        [self->viewTxtfld addSubview:btnNotNow];
    
        
        UIButton *  btnSave = [[UIButton alloc]init];
        btnSave.frame = CGRectMake(self->viewTxtfld.frame.size.width/2, self->viewTxtfld.frame.size.height-50, self->viewTxtfld.frame.size.width/2, 50);
        [btnSave addTarget:self action:@selector(btnSaveWIFIClick) forControlEvents:UIControlEventTouchUpInside];
        [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        btnSave.backgroundColor = [UIColor colorWithRed:1 green:155.0/255 blue:0 alpha:1];//UIColor.yellowColor;
        [btnSave setTitle:@"Save" forState:normal];
//        btnSave.alpha = 0.7;
        [btnSave setTitleColor:UIColor.whiteColor forState:normal];
        btnSave.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+2];
        [self->viewTxtfld addSubview:btnSave];
    
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
        {
            self->viewTxtfld.frame = CGRectMake(20, (DEVICE_HEIGHT-250)/2, DEVICE_WIDTH-40, 250);
        }
            completion:NULL];
        });
}
#pragma mark-TextField method
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
 if (textField == txtRouterPassword)
 {
     [txtRouterPassword resignFirstResponder];
 }
    return textField;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
        self->viewTxtfld.frame = CGRectMake(20, (DEVICE_HEIGHT-250)/2-100, DEVICE_WIDTH-40, 250);
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
        self->viewTxtfld.frame = CGRectMake(20, (DEVICE_HEIGHT-250)/2, DEVICE_WIDTH-40, 250);
}
#pragma mark- Setup for WIFI List the Showing Available SSID list
-(void)SetupForShowWifiSSIList
{
    dispatch_async(dispatch_get_main_queue(), ^(void){

        [APP_DELEGATE endHudProcess];
        [self->viewSSIDback removeFromSuperview];
        self->viewSSIDback = [[UIView alloc] init];
        self->viewSSIDback.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
        self->viewSSIDback .backgroundColor = UIColor.blackColor;
        self->viewSSIDback.alpha = 0.5;
        [self.view addSubview:self->viewSSIDback];
        
        UIImageView * imgBack = [[UIImageView alloc] init];
        imgBack.contentMode = UIViewContentModeScaleAspectFit;
        imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
        imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
        imgBack.userInteractionEnabled = YES;
//        [self->viewSSIDback addSubview:imgBack];
        
        self->viewSSIDList = [[UIView alloc] initWithFrame:CGRectMake(20, DEVICE_HEIGHT, DEVICE_WIDTH-40, 300)];
        self->viewSSIDList.backgroundColor = UIColor.whiteColor;//[UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // white
        self->viewSSIDList.layer.cornerRadius = 6;
        self->viewSSIDList.alpha = 1;
        self->viewSSIDList.clipsToBounds = true;
       [self.view addSubview:self->viewSSIDList];
    
        self->tblSSIDList = [[UITableView alloc] initWithFrame:CGRectMake(5, 5, self->viewSSIDList.frame.size.width-10, self->viewSSIDList.frame.size.height-50)];
        self->tblSSIDList.backgroundColor = UIColor.clearColor;
        self->tblSSIDList.delegate = self;
        self->tblSSIDList.dataSource = self;
        [self->viewSSIDList addSubview:self->tblSSIDList];
    
        UIButton *  btnCancel = [[UIButton alloc]init];
        btnCancel.frame = CGRectMake(5, self->viewSSIDList.frame.size.height-50, self->viewSSIDList.frame.size.width-10, 45);
        [btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
        [btnCancel setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        btnCancel.backgroundColor = [UIColor colorWithRed:1 green:155.0/255 blue:0 alpha:1];//UIColor.blackColor;
        [btnCancel setTitle:@"Cancel" forState:normal];
        [btnCancel setTitleColor:UIColor.whiteColor forState:normal];
        btnCancel.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+2];
        btnCancel.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self->viewSSIDList addSubview:btnCancel];
    
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
        {
            self->viewSSIDList.frame = CGRectMake(20, (DEVICE_HEIGHT-300)/2, DEVICE_WIDTH-40, 300);
        }
            completion:NULL];
});
}
#pragma mark-textField and Lables And Button Properties
-(void)setTextfieldProperties:(UITextField *)txtfld withPlaceHolderText:(NSString *)strText withtextSizes:(int)textSizes
{
    txtfld.delegate = self;
    txtfld.attributedPlaceholder = [[NSAttributedString alloc] initWithString:strText attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor],NSFontAttributeName: [UIFont fontWithName:CGRegular size:textSizes]}];
    txtfld.textAlignment = NSTextAlignmentLeft;
    txtfld.textColor = [UIColor blackColor];
    txtfld.backgroundColor= UIColor.whiteColor;
//    txtfld.autocorrectionType = UITextAutocorrectionTypeNo;
    txtfld.layer.cornerRadius = 6;
    txtfld.font = [UIFont boldSystemFontOfSize:textSizes];
    txtfld.font = [UIFont fontWithName:CGRegular size:textSizes];
    txtfld.clipsToBounds = true;
    txtfld.delegate = self;
}
-(void)TostNotification:(NSString *)StrToast
{
        dispatch_async(dispatch_get_main_queue(), ^{
            [APP_DELEGATE endHudProcess];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            hud.labelText = StrToast;
            hud.margin = 10.f;
            hud.yOffset = 150.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:0.4];
        });
}
-(void)AlertViewFCTypeCautionCheck:(NSString *)strMsg
    {
        [alert removeFromSuperview];
        alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"Vithamas"
                  withSubtitle:strMsg
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
-(void)AlertViewFCTypeSuccess:(NSString *)strPopup
{
        [alert removeFromSuperview];
        alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeSuccess];
        [alert showAlertInView:self
                     withTitle:@"Vithamas"
                  withSubtitle:strPopup
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
}

#pragma mark - FCAlertview Delegate Callback
- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
   if (alertView.tag == 123)
    {
        [self ValidationforAddedMessage:strDeviceNames];
    }
    else if (alertView.tag == 222)
    {
        if (isCurrentDeviceWIFIConfigured == NO)
        {
            [self AskforWifiConfiguration];
        }
        else if(isCurrentDeviceWIFIConfigured == YES)
        {
            NSString * strUpdate = [NSString stringWithFormat:@"update Device_Table set wifi_configured = '1' where id = '%@'",strSavedTableID];
            [[DataBaseManager dataBaseManager] execute:strUpdate];
            [globalDashBoardVC NewSocketAddedWithWIFIConfigured:strCurrentSelectedAddress withPeripheral:classPeripheral];

            if (![IS_USER_SKIPPED isEqualToString:@"YES"])
            {
                [self UpdateWifiConfigurationStatustoServer];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }

        }
    }
    else if (alertView.tag == 333 )
    {
        [self.navigationController popViewControllerAnimated:true];
    }
    else if (alertView.tag == 999 )
    {
        [alert removeFromSuperview];
        alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        alert.delegate = self;
        alert.tag = 333;
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"Device can controleed over Bluetooth. You can configure device over Wi-Fi by going to device setting later."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];

    }

    else if (alertView.tag == 555)
    {
        if ([[arrSocketDevices valueForKey:@"ble_address"] containsObject:strCurrentSelectedAddress])
        {
            NSInteger idxAddress = [[arrSocketDevices valueForKey:@"ble_address"] indexOfObject:strCurrentSelectedAddress];
            if (idxAddress != NSNotFound)
            {
                if (idxAddress < [arrSocketDevices count])
                {
                    [[arrSocketDevices objectAtIndex:idxAddress]setObject:classPeripheral forKey:@"peripheral"];
                    [[arrSocketDevices objectAtIndex:idxAddress]setValue:[NSString stringWithFormat:@"%@",classPeripheral.identifier] forKey:@"identifier"];
                }
            }
        }
        else
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setValue:classPeripheral forKey:@"peripheral"];
            [dict setValue:[NSString stringWithFormat:@"%@",classPeripheral.identifier] forKey:@"identifier"];
            [dict setValue:strCurrentSelectedAddress forKey:@"ble_address"];
            
            NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",classPeripheral.identifier];
            if (![[arrSocketDevices valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
            {
                [arrSocketDevices addObject:dict];
            }
            else
            {
                if ([[arrSocketDevices valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
                {
                    NSInteger  foudIndex = [[arrSocketDevices valueForKey:@"identifier"] indexOfObject:strCurrentIdentifier];
                    if (foudIndex != NSNotFound)
                    {
                        if ([arrSocketDevices count] > foudIndex)
                        {
                            NSMutableDictionary * dataDict = [arrSocketDevices objectAtIndex:foudIndex];
                            [dataDict setValue:classPeripheral forKey:@"peripheral"];
                            [dataDict setValue:[NSString stringWithFormat:@"%@",classPeripheral.identifier] forKey:@"identifier"];
                            [arrSocketDevices replaceObjectAtIndex:foudIndex withObject:dataDict];
                        }
                    }
                }
            }
        }
        [globalDashBoardVC NewSocketAddedWithWIFIConfigured:strCurrentSelectedAddress withPeripheral:classPeripheral];
        [self.navigationController popViewControllerAnimated:true];
    }
}

#pragma mark - Save Device Methods...
-(void)ShowAlerttoEnterDeviceName
{
    NSString * msgPlaceHolder = [NSString stringWithFormat:@"Enter Device Name"];
    
    [APP_DELEGATE endHudProcess];
    
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

    //                        customField.text = strRename;
    [alert addTextFieldWithCustomTextField:customField andPlaceholder:nil andTextReturnBlock:^(NSString *text) {
        strDeviceNames = text;
    }];
    [alert showAlertInView:self
                 withTitle:@"Smart socket"
              withSubtitle:@"Enter name"
           withCustomImage:nil
       withDoneButtonTitle:nil
                andButtons:nil];

}
-(void)ValidationforAddedMessage:(NSString *)text
{
    if ([[self checkforValidString:text] isEqualToString:@"NA"])
    {
        [alert removeFromSuperview];
        alert = [[FCAlertView alloc] init];
        alert.delegate = self;
        alert.tag = 123;
        alert.colorScheme = global_brown_color;
        
        UITextField *customField = [[UITextField alloc] init];
        customField.placeholder = @"Enter Device Name";
        customField.keyboardAppearance = UIKeyboardAppearanceAlert;
        //                        customField.text = strRename;
        [alert addTextFieldWithCustomTextField:customField andPlaceholder:nil andTextReturnBlock:^(NSString *text) {
            strDeviceNames = text;
        }];
        [alert showAlertInView:self
                     withTitle:@"Smart socket"
                  withSubtitle:@"Please Enter name"
               withCustomImage:nil
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
    else
    {
        [self SaveDevicetoDatabase:strDeviceNames];
    }
}
-(void)SaveDevicetoDatabase:(NSString *)strdeviceName
{
    NSString * strType = @"4";
    NSString * newDeviceID = @"NA";
    NSString * strDeviceType =@"PowerSocket" ;
    NSString * strHexDeviceId = @"NA";
    strMckAddress = [strCurrentSelectedAddress uppercaseString]; // css change to lowercase before  uper case

    NSMutableArray * tmpArr = [[BLEManager sharedManager] arrBLESocketDevices];
    if ([[tmpArr valueForKey:@"peripheral"] containsObject:classPeripheral])
    {
        NSInteger  foudIndex = [[tmpArr valueForKey:@"peripheral"] indexOfObject:classPeripheral];
        if (foudIndex != NSNotFound)
        {
            if ([tmpArr count] > foudIndex)
            {
                NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",classPeripheral.identifier];
                NSString * strName = [[tmpArr  objectAtIndex:foudIndex]valueForKey:@"name"];
                NSString * strAddress = [[[tmpArr  objectAtIndex:foudIndex]valueForKey:@"ble_address"] uppercaseString];
                
                if (![[arrGlobalDevices valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
                {
                    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:strCurrentIdentifier,@"identifier",classPeripheral,@"peripheral",strName,@"name",strAddress,@"ble_address", nil];

                    self->strCurrentTopic = [NSString stringWithFormat:@"/vps/app/%@",[strAddress uppercaseString]];
                    self->strMckAddress = strAddress;
                    [arrGlobalDevices addObject:dict];

                }
        }
    }
    }
    if ([[deviceListArray valueForKey:@"ble_address"] containsObject:strMckAddress])
    {
        NSString * strUpdate = [NSString stringWithFormat:@"update Device_Table set device_name='%@', status ='1', is_sync = '0' where ble_address = '%@'",strdeviceName,strMckAddress];
        [[DataBaseManager dataBaseManager] execute:strUpdate];
        NSInteger foundIndex = [[deviceListArray valueForKey:@"ble_address"] indexOfObject:strMckAddress];
        if (foundIndex != NSNotFound)
        {
            if ([deviceListArray count] > foundIndex)
            {
                strSavedTableID = [[deviceListArray objectAtIndex:foundIndex] valueForKey:@"id"];
            }
        }
    }
    else
    {
        NSString * requestStr =[NSString stringWithFormat:@"insert into 'Device_Table'('device_id','hex_device_id','real_name','device_name','ble_address','device_type','device_type_name','switch_status','user_id','is_favourite','is_sync',status, 'identifier') values('%@','%@','%@',\"%@\",\"%@\",'%@','%@','Yes','%@','2','0','1', \"%@\")",newDeviceID,strHexDeviceId,@"NA",strDeviceNames,strMckAddress  ,strType,strDeviceType,CURRENT_USER_ID, classPeripheral.identifier];
        
        int savedID = [[DataBaseManager dataBaseManager] executeSw:requestStr];
        strSavedTableID = [NSString stringWithFormat:@"%d",savedID];
    }
    
    if (![IS_USER_SKIPPED isEqualToString:@"YES"])
    {
        [self SaveDeviceWebservicedeviceID:newDeviceID hexId:strHexDeviceId devName:strDeviceNames type:strType withAddress:strMckAddress withDeviceArr:nil];
    }
    else
    {
        [APP_DELEGATE hideScannerView];
        [APP_DELEGATE endHudProcess];

        [alert removeFromSuperview];
        alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeSuccess];
        alert.delegate = self;
        alert.tag = 222;
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"Device has been added successfully."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
        [alert doneActionBlock:^{
        }];
    }
}
#pragma mark - Webservice Methods
-(void)SaveDeviceWebservicedeviceID:(NSString *)devID hexId:(NSString*)hexId devName:(NSString *)name type:(NSString *)type withAddress:(NSString *)bleAddress withDeviceArr:(NSMutableArray *)deviveArr
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        serverDict = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
        [dict setValue:devID forKey:@"device_id"];
        [dict setValue:hexId forKey:@"hex_device_id"];
        [dict setValue:name forKey:@"device_name"];
        [dict setValue:type forKey:@"device_type"];
        [dict setValue:[bleAddress uppercaseString] forKey:@"ble_address"];//[bleAddress uppercaseString]
        [dict setValue:@"1" forKey:@"status"];
        [dict setValue:@"2" forKey:@"is_favourite"];
        [dict setValue:@"0" forKey:@"is_update"];
        [dict setValue:@"0" forKey:@"remember_last_color"];
        [dict setValue:@"0" forKey:@"remember_last_color"];
        [dict setValue:@"0" forKey:@"wifi_configured"];

        
        NSString *deviceToken =deviceTokenStr;
        if (deviceToken == nil || deviceToken == NULL)
        {
            [dict setValue:@"123456789" forKey:@"device_token"];
        }
        else
        {
            [dict setValue:deviceToken forKey:@"device_token"];
        }
        
        serverDict = [dict mutableCopy];
        
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"SaveDevice";
        manager.delegate = self;
        NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/save_device";
        [manager urlCall:strServerUrl withParameters:dict];
    }
    else
    {
        [APP_DELEGATE hideScannerView];
        [APP_DELEGATE endHudProcess];
        
        [alert removeFromSuperview];
        alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeSuccess];
        alert.delegate = self;
        alert.tag = 222;
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"Device has been added successfully."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
}
-(void)UpdateWifiConfigurationStatustoServer
{
    if ([serverDict count] >= 11)
    {
        [serverDict setValue:@"1" forKey:@"is_update"];
        [serverDict setValue:@"1" forKey:@"wifi_configured"];

        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"UpdateDevice";
        manager.delegate = self;
        NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/save_device";
        [manager urlCall:strServerUrl withParameters:serverDict];
    }
}
- (void)onResult:(NSDictionary *)result
{
    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];

    [APP_DELEGATE endHudProcess];
    
    if ([[result valueForKey:@"commandName"] isEqualToString:@"SaveDevice"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if([[result valueForKey:@"result"] valueForKey:@"data"]!=[NSNull null] || [[result valueForKey:@"result"] valueForKey:@"data"] != nil)
            {
                NSString * strServerId = [self checkforValidString:[[[result valueForKey:@"result"] valueForKey:@"data"] valueForKey:@"server_device_id"]];
                NSString * strUserId = [self checkforValidString:[[[result valueForKey:@"result"] valueForKey:@"data"] valueForKey:@"user_id"]];
                NSString * strDeviceId = [self checkforValidString:[[[result valueForKey:@"result"] valueForKey:@"data"] valueForKey:@"device_id"]];
                NSString * strCreatedDate = [self checkforValidString:[[[result valueForKey:@"result"] valueForKey:@"data"] valueForKey:@"created_date"]];
                NSString * strUpdatedDate = [self checkforValidString:[[[result valueForKey:@"result"] valueForKey:@"data"] valueForKey:@"updated_date"]];
                NSString * strTimeStamp = [self checkforValidString:[[[result valueForKey:@"result"] valueForKey:@"data"] valueForKey:@"timestamp"]];
                NSString * strBleAddress = [self checkforValidString:[[[result valueForKey:@"result"] valueForKey:@"data"] valueForKey:@"ble_address"]];

                NSString * strQuery = [NSString stringWithFormat:@"update Device_Table set server_device_id = '%@', created_at = '%@', updated_at = '%@', timestamp = '%@',is_sync='1' where user_id = '%@' and ble_address ='%@'",strServerId,strCreatedDate,strUpdatedDate,strTimeStamp,strUserId, strBleAddress];
                [[DataBaseManager dataBaseManager] execute:strQuery];
                
                [alert removeFromSuperview];
                alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeSuccess];
                alert.delegate = self;
                alert.tag = 222;
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:@"Device has been added successfully."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
        }
        else
        {
            [alert removeFromSuperview];
            alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeSuccess];
            alert.delegate = self;
            alert.tag = 222;
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"Device has been added successfully."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"UpdateDevice"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if([[result valueForKey:@"result"] valueForKey:@"data"]!=[NSNull null] || [[result valueForKey:@"result"] valueForKey:@"data"] != nil)
            {
                [alert removeFromSuperview];
                alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeSuccess];
                alert.delegate = self;
                alert.tag = 333;
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:@"You can control Socket with Bluetooth and WIFI as well."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];

            }
        }
    }
}

- (void)onError:(NSError *)error
{
    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];

    [APP_DELEGATE hideScannerView];
    [APP_DELEGATE endHudProcess];
    
    NSInteger ancode = [error code];
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
    
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009)
    {
//        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
    }
    else
    {
//        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
    }
    
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
    }
    [alert removeFromSuperview];
    alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    alert.delegate = self;
    alert.tag = 222;
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Device has been added successfully."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}

#pragma mark - BLE Methods
-(void)InitialBLE
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotifiyDiscoveredDevicesforSockets" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidConnectNotificationSocket" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidDisConnectNotificationSocket" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotifiyDiscoveredDevices:) name:@"NotifiyDiscoveredDevicesforSockets" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidConnectNotification:) name:@"DeviceDidConnectNotificationSocket" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidDisConnectNotification:) name:@"DeviceDidDisConnectNotificationSocket" object:nil];
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
     if ( [[[BLEManager sharedManager] arrBLESocketDevices] count] >0)
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
    dispatch_async(dispatch_get_main_queue(), ^(void){
//        [APP_DELEGATE endHudProcess];
        [connectionTimer invalidate];
        connectionTimer = nil;
        
        NSInteger intPacket = [@"0" integerValue];
        NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
//        [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"25" withLength:@"00" withPeripheral:classPeripheral];
        
        [self->tblDeviceList reloadData];
    });
}
-(void)DeviceDidDisConnectNotification:(NSNotification*)notification //Disconnect periperal
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [[[BLEManager sharedManager] arrBLESocketDevices] removeAllObjects];
        [[BLEManager sharedManager] rescan];
        [self->tblDeviceList reloadData];
        [APP_DELEGATE endHudProcess];});
}
#pragma mark:- Add Device BLE Commands
-(void)AuthenticationCompleted:(CBPeripheral *)peripheral
{
//    globalSocketPeripheral = peripheral;
    NSString * strKey = [[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"];
    NSData * encryptKeyData= [[NSData alloc] init];
    encryptKeyData = [self getUserKeyconverted:strKey];
    
    if (isRequestedforAddDevice == YES)
    {
        [[BLEService sharedInstance] WriteSocketData:encryptKeyData withOpcode:@"06" withLength:@"16" withPeripheral:peripheral];
    }
}
-(void)AssociationCompleted:(BOOL)isSucess;
{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *decStr = [NSString stringWithFormat:@"%f",timeStamp];
    
    NSString *hexStr = [NSString stringWithFormat:@"%llX", (long long)[decStr integerValue]];
    NSString * strDate = hexStr;
    for (int i = 0; i < 16 - ([hexStr length] / 2); i ++)
    {
        strDate = [strDate stringByAppendingString:@"00"];
    }

    NSData * ssidNSData = [self dataFromHexString:strDate];
    [[BLEService sharedInstance] WriteSocketData:ssidNSData withOpcode:@"03" withLength:@"04" withPeripheral:classPeripheral];

    [self ShowAlerttoEnterDeviceName];
    [self CheckRecievedWifiConfiguredStatus];
}
-(void)CheckRecievedWifiConfiguredStatus
{
    isAfterWifiConfigured = NO;
    NSInteger intPacket = [@"0" integerValue];
    NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
    [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"16" withLength:@"00" withPeripheral:classPeripheral];
}
-(void)AskforWifiConfiguration
{
    [alert removeFromSuperview];
    alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeCaution];
    alert.delegate = self;
    alert.tag = 999;
    [alert addButton:@"Yes" withActionBlock:
     ^{
        [APP_DELEGATE startHudProcess:@"Cheking availble Wi-Fi..."];
        NSInteger intPacket = [@"0" integerValue];
        NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
        [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"18" withLength:@"00" withPeripheral:self->classPeripheral];
        isWifiListFound = NO;
        WifiScanTimer = nil;
        wifiConnectionStatusRetryCount = 0;
        WifiScanTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(wifiScanTimeoutMethod) userInfo:nil repeats:NO];
    }];
    [alert showAlertInView:self
                 withTitle:@"Smart socket"
              withSubtitle:@"Do you want to configure Wi-Fi ?"
           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
       withDoneButtonTitle:@"No" andButtons:nil];
}
-(void)wifiScanTimeoutMethod
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [APP_DELEGATE endHudProcess];
        if (isWifiListFound == NO)
        {
            [self AlertViewFCTypeCautionCheck:@"No Wi-Fi available nearby !"];
        }
        
        isWifiListFound = NO;
    });

}
#pragma mark :- BLEService Delegate Methods
-(void)RecievedWifiConfiguredStatus:(NSString *)strStatus
{

    isCurrentDeviceWIFIConfigured = YES;
    if ([strStatus isEqualToString:@"0000"])
    {
        isCurrentDeviceWIFIConfigured = NO;
    }
    else if ([strStatus isEqualToString:@"0100"])
    {
    }
    else if ([strStatus isEqualToString:@"0101"])
    {
    }
    else if ([strStatus isEqualToString:@"0102"])
    {
    }

    if (isAfterWifiConfigured == YES)
    {
        [connectionTimer invalidate];
        connectionTimer = nil;

        if (isCurrentDeviceWIFIConfigured == NO)
        {
            if (wifiConnectionStatusRetryCount == 0)
            {
                wifiConnectionStatusRetryCount = 1;
                connectionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(ConnectWifiTimeout) userInfo:nil repeats:NO];
                [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(CheckforWifiStatus) userInfo:nil repeats:NO];
            }
            else
            {
                [APP_DELEGATE endHudProcess];
                [alert removeFromSuperview];
                alert = [[FCAlertView alloc] init];
                [alert makeAlertTypeCaution];
                alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
                [alert showAlertWithTitle:@"Vithamas" withSubtitle:@"Something went wrong. Please try again later..." withCustomImage:[UIImage imageNamed:@"alert-round.png"] withDoneButtonTitle:@"OK" andButtons:nil];
            }
        }
        else
        {
            NSString * strUpdate = [NSString stringWithFormat:@"update Device_Table set wifi_configured = '1' where id = '%@'",strSavedTableID];
            [[DataBaseManager dataBaseManager] execute:strUpdate];

            if (![IS_USER_SKIPPED isEqualToString:@"YES"])
            {
                [self UpdateWifiConfigurationStatustoServer];
            }
            else
            {
                [APP_DELEGATE endHudProcess];
                [alert removeFromSuperview];
                alert = [[FCAlertView alloc] init];
                [alert makeAlertTypeSuccess];
                alert.tag = 555;
                alert.delegate = self;
                alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
                [alert showAlertWithTitle:@"Vithamas" withSubtitle:@"Wi-Fi configured successfully." withCustomImage:[UIImage imageNamed:@"alert-round.png"] withDoneButtonTitle:@"OK" andButtons:nil];
            }
        }
    }
    else
    {
        
    }
}
-(void)NoWIIFoundNearby
{
    isWifiListFound = YES;
    [WifiScanTimer invalidate];
    WifiScanTimer = nil;
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self AlertViewFCTypeCautionCheck:@"No Wi-Fi available nearby !"];
    });
}
-(void)FoundNumberofWIFI:(NSMutableArray *)arrayWifiList
{
    isWifiListFound = YES;
    [WifiScanTimer invalidate];
    WifiScanTimer = nil;

    arrayWifiavl = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^(void){
    if (arrayWifiList.count > 0)
    {
        self->arrayWifiavl = arrayWifiList;
        [APP_DELEGATE endHudProcess];
        [self SetupForShowWifiSSIList];
        [self->tblSSIDList reloadData];
        NSLog(@"Connected WI fi ===>>%@",arrayWifiList);
    }
    else
    {
        [APP_DELEGATE endHudProcess];
//        [self AlertViewFCTypeCautionCheck:@"There is no Wi-Fi nearby!"];
    }
    });
}
-(void)WifiSSIDIndexAcknowlegement:(NSString *)strStatus
{
    NSString * strPassword  = txtRouterPassword.text;
    [[BLEService sharedInstance] WriteWifiPassword:strPassword];
}
-(void)WifiPasswordAcknowledgement:(NSString *)strStatus
{
    if ([strStatus isEqualToString:@"01"])
    {
        [connectionTimer invalidate];
        connectionTimer = nil;
        connectionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(ConnectWifiTimeout) userInfo:nil repeats:NO];
        
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(CheckforWifiStatus) userInfo:nil repeats:NO];
    }
}
-(void)CheckforWifiStatus
{
    NSLog(@"Sent Opcode 10 after delay");
    isAfterWifiConfigured = YES;
    NSInteger intPacket = [@"0" integerValue];
    NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
    [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"16" withLength:@"00" withPeripheral:classPeripheral];
}
#pragma mark - BLE Received data...
-(void)ReceivedSwitchStatusfromDevice:(NSMutableDictionary *)dictSwitch
{
    dictSwState = dictSwitch;
}


-(void)ShowNowifiAvailablePopUP
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self AlertViewFCTypeCautionCheck:@"No Wi-Fi available nearby !"];
    });
}




-(NSData *)getUserKeyconverted:(NSString *)strAddress
{
    NSMutableData * keyData = [[NSMutableData alloc] init];
    
    for (int i=0; i<16; i++)
    {
        NSRange rangeFirst = NSMakeRange(i*2, 2);
        NSString * strVithCheck = [strAddress substringWithRange:rangeFirst];
        
        unsigned long long startlong;
        NSScanner * scanner1 = [NSScanner scannerWithString:strVithCheck];
        [scanner1 scanHexLongLong:&startlong];
        double unixStart = startlong;
        NSNumber * startNumber = [[NSNumber alloc] initWithDouble:unixStart];
        NSInteger int72 = [startNumber integerValue];
        NSData * data72 = [[NSData alloc] initWithBytes:&int72 length:1];
        if (i==0)
        {
            keyData= [data72 mutableCopy];
        }
        else
        {
            [keyData appendData:data72];
        }
    }

    return keyData;
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
    return strValid;
}
-(void)showPassclick
{
    if (isShowPasswordEye)
    {
        isShowPasswordEye = NO;
        [btnShowPass setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
        txtRouterPassword.secureTextEntry = YES;
    }
    else
    {
        isShowPasswordEye = YES;
        [btnShowPass setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
        txtRouterPassword.secureTextEntry = NO;
    }
}
@end

/*
 {
     NSInteger intPacket = [@"0" integerValue];
     NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
     [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"07" withLength:@"01" withPeripheral:classPeripheral];
     
    // [[BLEService sharedInstance] WriteWifiPassword];
 //    NSInteger intPacket = [@"0" integerValue];
 //    NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
 //    [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"18" withLength:@"00" withPeripheral:classPeripheral];


 //    [[[BLEManager sharedManager] arrBLESocketDevices] removeAllObjects];
 //    [[BLEManager sharedManager] rescan];
 //    [tblDeviceList reloadData];
 //
 //    NSArray * tmparr = [[BLEManager sharedManager]getLastConnected];
 //    for (int i=0; i<tmparr.count; i++)
 //    {
 //        CBPeripheral * p = [tmparr objectAtIndex:i];
 //        NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",p.identifier];
 //        if ([[arrGlobalDevices valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
 //        {
 //            NSInteger  foudIndex = [[arrGlobalDevices valueForKey:@"identifier"] indexOfObject:strCurrentIdentifier];
 //            if (foudIndex != NSNotFound)
 //            {
 //                if ([arrGlobalDevices count] > foudIndex)
 //                {
 //                    if (![[[[BLEManager sharedManager] arrBLESocketDevices] valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
 //                    {
 //                        [[[BLEManager sharedManager] arrBLESocketDevices] addObject:[arrGlobalDevices objectAtIndex:foudIndex]];
 //                    }
 //                }
 //            }
 //        }
 //    }
 //    if ( [[[BLEManager sharedManager] arrBLESocketDevices] count] >0)
 //    {
 //        tblDeviceList.hidden = false;
 //        lblNoDevice.hidden = true;
 ////        [advertiseTimer invalidate];
 ////        advertiseTimer = nil;
 //        [tblDeviceList reloadData];
 //    }
 //    else
 //    {
 //        tblDeviceList.hidden = true;
 //        lblNoDevice.hidden = false;
 ////        [advertiseTimer invalidate];
 ////        advertiseTimer = nil;
 ////        advertiseTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(AdvertiseTimerMethod) userInfo:nil repeats:NO];
 //    }
 }
 **/
