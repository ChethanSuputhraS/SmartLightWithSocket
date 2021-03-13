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
    FCAlertView * alert;
    NSTimer * disconnectionTimer,*connectionTimer,*advertiseTimer;
    CBPeripheral * classPeripheral;
    CBCentralManager * centralManager;


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
    return [[[BLEManager sharedManager] arrBLESocketDevices] count];//
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
        arrayDevices =[[BLEManager sharedManager] arrBLESocketDevices];

        cell.lblDeviceName.frame = CGRectMake(18, 0, DEVICE_WIDTH-36, 35);
        cell.lblAddress.frame = CGRectMake(18, 30,  DEVICE_WIDTH-36, 25);
        [cell.lblDeviceName setFont:[UIFont fontWithName:CGRegular size:textSizes+3]];
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"peripheral"];
        if (p.state == CBPeripheralStateConnected)
        {
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
    arrayDevices =[[BLEManager sharedManager] arrBLESocketDevices];
    if ([arrayDevices count]>0)
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"peripheral"];
        
        if (p.state == CBPeripheralStateConnected)
        {
            [self AskForResetdevice];
        }
        else
        {
            NSLog(@"Add_Socket_Device_Peripheral = %@",p);

            NSString * strManufacture = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"Manufac"];
            strManufacture = [strManufacture stringByReplacingOccurrencesOfString:@" " withString:@""];
            strManufacture = [strManufacture stringByReplacingOccurrencesOfString:@">" withString:@""];
            strManufacture = [strManufacture stringByReplacingOccurrencesOfString:@"<" withString:@""];
            
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
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
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
-(void)AskForResetdevice
{
    [alert removeFromSuperview];
    alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeCaution];
    alert.delegate = self;
    [alert addButton:@"Yes" withActionBlock:
     ^{
//        [APP_DELEGATE startHudProcess:@"Resetting..."];
//        NSInteger intPacket = [@"0" integerValue];
//        NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
//        [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"" withLength:@"00" withPeripheral:self->classPeripheral];
    }];
    [alert showAlertInView:self
                 withTitle:@"Smart socket"
              withSubtitle:@"Are you sure want to reset device."
           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
       withDoneButtonTitle:@"No" andButtons:nil];
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
//        [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"17" withLength:@"00" withPeripheral:classPeripheral];
        
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
//
//        [[BLEService sharedInstance] WriteSocketData:encryptKeyData withOpcode:@"06" withLength:@"16" withPeripheral:peripheral];
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

@end
