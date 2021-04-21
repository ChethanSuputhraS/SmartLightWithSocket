//
//  FactoryResetVC.m
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 10/10/18.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "FactoryResetVC.h"
#import "HistoryCell.h"
#import "AuthenticationVC.h"
#import "MNMPullToRefreshManager.h"


@interface FactoryResetVC ()<UITableViewDelegate,UITableViewDataSource,FCAlertViewDelegate,MNMPullToRefreshManagerClient,CBCentralManagerDelegate>
{
    UILabel * lblSuccessMsg;
    UITableView * tblView;
    CBPeripheral * myPeripheral;
    NSTimer * timerConnectedCheck;
    UIImageView * statusImg;
    BOOL isforTemp, isCnnectedSucess;
    int totalCounts, connectionCount;
    MNMPullToRefreshManager * topPullToRefreshManager;
    CBCentralManager*centralManager;
    NSTimer * timertoStopIndicator;
    FCAlertView *alert, * timeOutAlert;
    NSTimer * confirmTimer;
    MBProgressHUD * connectionHUD;
    NSMutableArray * arrDevicesConnectable;
}
@end

@implementation FactoryResetVC
@synthesize isFromAddDevice;
- (void)viewDidLoad
{
    arrDevicesConnectable = [[NSMutableArray alloc] init];
    
    isSearchingfromFactory = NO;
    
    [super viewDidLoad];
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

    
    [topPullToRefreshManager setPullToRefreshViewVisible:NO];

    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    isforTemp = NO;
    
    if (isFromAddDevice)
    {
        self.navigationController.navigationBarHidden = YES;
    }
    [self setNavigationViewFrames];
    [self setMessageViewContent];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowResetNotification" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowResetNotification) name:@"ShowResetNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ResetSuccessPopup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ResetSuccessPopup:) name:@"ResetSuccessPopup" object:nil];

    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];

    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    if (@available(iOS 10.0, *)) {
        if (centralManager.state == CBCentralManagerStatePoweredOn || centralManager.state == CBManagerStateUnknown)
        {
            
        }
        else
        {
            [self GlobalBLuetoothCheck];
        }
    } else
    {
        if (centralManager.state == CBCentralManagerStatePoweredOff)
        {
            [self GlobalBLuetoothCheck];
        }
        // Fallback on earlier versions
    }
    [topPullToRefreshManager setPullToRefreshViewVisible:YES];

    currentScreen = @"Bridge";
    isfromBridge = YES;
    isFromFactoryRest = YES;
    [super viewWillAppear:YES];
    
    [self InitialBLE];
    [[[BLEManager sharedManager] nonConnectArr] removeAllObjects];
    [[BLEManager sharedManager] startScan];//Scan Ble devices
    
    [self refreshBtnClick];
//    timerConnectedCheck = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkForConnectedDevice) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:currentScreen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBleStatus) name:currentScreen object:nil];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [timerConnectedCheck invalidate];
    isfromBridge = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallNotificationforNonConnectforAdd" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"deviceDidDisConnectNotificationBridge" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"deviceDidConnectNotificationBridge" object:nil];
    
    [super viewDidDisappear:YES];
}
-(void)updateBleStatus
{
    if (globalConnStatus)
    {
        statusImg.image = [UIImage imageNamed:@"Connected_icon.png"];
    }
    else
    {
        statusImg.image = [UIImage imageNamed:@"notconnect_icon.png"];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    self.view.backgroundColor = [UIColor colorWithRed:19/255.0 green:24/255.0 blue:27/255.0 alpha:1.0];
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.5;
    [viewHeader addSubview:lblBack];
    
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Reset device"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
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
    
    statusImg = [[UIImageView alloc] init];
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
    }
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 88, 88);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        
        imgRefresh.frame = CGRectMake(DEVICE_WIDTH-30, 44 + 13, 18, 18);
        refreshBtn.frame = CGRectMake(DEVICE_WIDTH-60, 0, 60, 88);
        
    }
}

-(void)setMessageViewContent
{
    NSString * sttQuery = [NSString stringWithFormat:@"select * from Device_Table"];
    NSMutableArray * deviceArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:sttQuery resultsArray:deviceArr];
    
    lblSuccessMsg = [[UILabel alloc] initWithFrame:CGRectMake(10, ((DEVICE_HEIGHT-100)/2)-64, DEVICE_WIDTH-20, 100)];
    [lblSuccessMsg setTextColor:[APP_DELEGATE colorWithHexString:dark_gray_color]];
    [lblSuccessMsg setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [lblSuccessMsg setTextAlignment:NSTextAlignmentCenter];
    [lblSuccessMsg setNumberOfLines:3];
    [lblSuccessMsg setText:@"No devices found"];
    [self.view addSubview:lblSuccessMsg];
    
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT-64-45) style:UITableViewStylePlain];
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblView.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:tblView];
    
    if (IS_IPHONE_X)
    {
        tblView.frame = CGRectMake(0, 88, DEVICE_WIDTH, DEVICE_HEIGHT-45-88-40);
    }
    if ([deviceArr count]>0)
    {
        tblView.hidden = NO;
        lblSuccessMsg.hidden = YES;
    }
    else
    {
        tblView.hidden = NO;
        lblSuccessMsg.hidden = YES;
    }
    topPullToRefreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:tblView withClient:self];
    [topPullToRefreshManager setPullToRefreshViewVisible:YES];
    [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];
}
#pragma mark - Button Click
-(void)btnBackClick
{
    [[BLEManager sharedManager] disconnectDevice:globalPeripheral];
    NSArray * tmpArr = [[BLEManager sharedManager] getLastConnected];
    [[BLEManager sharedManager] stopScan];
    [arrDevicesConnectable removeAllObjects];
    for (int i=0; i<tmpArr.count; i++)
    {
        CBPeripheral * p = [tmpArr objectAtIndex:i];
        [[BLEManager sharedManager]disconnectDevice:p];
    }

    isFromFactoryRest = NO;
    isSearchingfromFactory = NO;

    //    [[BLEService sharedInstance] sendNotificationsForOff:globalPeripheral withType:NO];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)refreshBtnClick
{
    totalCounts = 0;
    
    [[[BLEManager sharedManager] foundDevices] removeAllObjects];
    [[BLEManager sharedManager] rescan];
    
    NSArray * tmparr = [[BLEManager sharedManager]getLastConnected];
    for (int i=0; i<tmparr.count; i++)
    {
        CBPeripheral * p = [tmparr objectAtIndex:i];
        NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",p.identifier];
        if ([[arrGlobalDevices valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
        {
            NSInteger  foudIndex = [[arrGlobalDevices valueForKey:@"identifier"] indexOfObject:strCurrentIdentifier];
            if (foudIndex != NSNotFound)
            {
                if ([arrGlobalDevices count] > foudIndex)
                {
                    if (![[[[BLEManager sharedManager] foundDevices] valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
                    {
                        [[[BLEManager sharedManager] foundDevices] addObject:[arrGlobalDevices objectAtIndex:foudIndex]];
                    }
                }
            }
        }
    }
    [tblView reloadData];

    
    //    NSLog(@"Arrrrr=%@",[[BLEManager sharedManager] getLastConnected]);
    
    
    //    [self performSelector:@selector(stopIndicator) withObject:nil afterDelay:5];
}
#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-146, 45)];
    headerView.backgroundColor = [UIColor blackColor];
    
    UILabel *lblmenu=[[UILabel alloc]init];
    lblmenu.text = @" Tap on any device to factory reset and then turn off, and then turn on the main switch.";
    [lblmenu setTextColor:[UIColor whiteColor]];
    lblmenu.numberOfLines = 2;
    lblmenu.textAlignment = NSTextAlignmentCenter;
    [lblmenu setFont:[UIFont fontWithName:CGRegular size:textSizes-1.5]];
    lblmenu.frame = CGRectMake(5, 0, DEVICE_WIDTH, 45);
    [headerView addSubview:lblmenu];
    
    
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrDevicesConnectable count]; // associated array we need to pass
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReuseActivityCell"];
    if (cell==nil)
    {
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ReuseActivityCell"];
    }
    
    cell.imgIcon.image = [UIImage imageNamed:@"default_pic.png"];
    cell.imgIcon.hidden = NO;
    cell.lblConnect.text = @"Connect";
    cell.lblAddress.hidden = NO;
    cell.lblReset.hidden = NO;
    cell.lblConnect.hidden = YES;
    
    cell.lblDeviceName.font = [UIFont fontWithName:CGRegular size:textSizes+2];
    cell.lblAddress.font = [UIFont fontWithName:CGRegular size:textSizes-1];
    cell.lblConnect.font = [UIFont fontWithName:CGRegular size:textSizes-1];
    
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =arrDevicesConnectable;
    
    if ([arrayDevices count]>0)
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"peripheral"];
        cell.lblDeviceName.text = p.name;
        cell.lblAddress.text = [[[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"address"] capitalizedString];
        
    }
    //    if (isforTemp)
    //    {
    ////        [self configureCell:cell atIndexPath:indexPath];
    //    }
    //    else
    {
        //        [self configureCellforNormal:cell atIndexPath:indexPath];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (void)configureCell:(HistoryCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.lblConnect.hidden = YES;
    
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] nonConnectArr];
    
    if ([arrayDevices count]>0)
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"peripheral"];
        cell.lblDeviceName.text = p.name;
        if (p.state == CBPeripheralStateConnected)
        {
            cell.lblConnect.text = @"Disconnect";
        }
        else
        {
            cell.lblConnect.text = @"Connect";
        }
        
        cell.lblConnect.text = [[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"RSSI"];
        
        NSString * manuStr = [[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"Manufac"];
        NSArray * tmpArr = [manuStr componentsSeparatedByString:@"0a00"];
        if ([tmpArr count]>1)
        {
            NSString * kpstr = [tmpArr objectAtIndex:1];
            if ([tmpArr count]>2)
            {
                NSRange range71 = NSMakeRange(4, [manuStr length]-4);
                kpstr = [manuStr substringWithRange:range71];
            }
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@" " withString:@""];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@">" withString:@""];
            cell.lblAddress.text = kpstr;
            if ([[self checkforValidString:kpstr] isEqualToString:@"NA"])
            {
                cell.lblAddress.text = @"NA";
            }
            else
            {
                if ([kpstr length]==12)
                {
                    //                    cell.lblAddress.text = kpstr;
                    cell.lblDeviceName.text = [NSString stringWithFormat:@"%@ (%@)",p.name,kpstr];
                }
                else if ([kpstr length]>12)
                {
                    NSRange range71 = NSMakeRange(0, [kpstr length]-8);
                    NSString * strTitle = [kpstr substringWithRange:range71];
                    //                    cell.lblAddress.text = strTitle;
                    cell.lblDeviceName.text = [NSString stringWithFormat:@"%@ (%@)",p.name,strTitle];
                }
                else
                {
                    //                    cell.lblAddress.text = kpstr;
                    cell.lblDeviceName.text = [NSString stringWithFormat:@"%@ (%@)",p.name,kpstr];
                }
                
                if ([kpstr length]>= 20)
                {
                    NSRange range71 = NSMakeRange(12, 2);
                    NSString * str1 = [kpstr substringWithRange:range71];
                    NSString * strTemp = [self stringFroHex:str1];
                    
                    NSRange range72 = NSMakeRange(14, 2);
                    NSString * str2 = [kpstr substringWithRange:range72];
                    NSString * strRed = [self stringFroHex:str2];
                    
                    NSRange range73 = NSMakeRange(16, 2);
                    NSString * str3 = [kpstr substringWithRange:range73];
                    NSString * strBlue = [self stringFroHex:str3];
                    
                    NSRange range74 = NSMakeRange(18, 2);
                    NSString * str4 = [kpstr substringWithRange:range74];
                    NSString * strWhite = [self stringFroHex:str4];
                    
                    cell.lblAddress.text = [NSString stringWithFormat:@"Temp : %@ | Red : %@ | Blue : %@ | White : %@",strTemp,strRed,strBlue,strWhite];
//                    NSLog(@"TEMP>>%@ ||   RED>>%@ ||  BLUE>>%@ ||  WHITE>>%@",strTemp,strRed,strBlue,strWhite);
                    //                    cell.lblConnect.frame = CGRectMake(80, 50, DEVICE_WIDTH-80, 20);
                }
                
            }
        }
        else
        {
            cell.lblAddress.text = @"NA";
        }
    }
    else
    {
        cell.lblAddress.text = @"NA";
    }
}
- (void)configureCellforNormal:(HistoryCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.lblConnect.hidden = NO;
    
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] nonConnectArr];
    
    if ([arrayDevices count]>0)
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"peripheral"];
        cell.lblDeviceName.text = p.name;
        if (p.state == CBPeripheralStateConnected)
        {
            cell.lblConnect.text = @"Disconnect";
        }
        else
        {
            cell.lblConnect.text = @"Connect";
        }
        
        cell.lblAddress.text = [[self checkforValidString:[[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"address"]] uppercaseString];
        
        
        /*NSString * manuStr = [[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"Manufac"];
         NSArray * tmpArr = [manuStr componentsSeparatedByString:@"0a00"];
         if ([tmpArr count]>1)
         {
         NSString * kpstr = [tmpArr objectAtIndex:1];
         if ([tmpArr count]>2)
         {
         NSRange range71 = NSMakeRange(4, [manuStr length]-4);
         kpstr = [manuStr substringWithRange:range71];
         }
         kpstr = [kpstr stringByReplacingOccurrencesOfString:@" " withString:@""];
         kpstr = [kpstr stringByReplacingOccurrencesOfString:@">" withString:@""];
         cell.lblAddress.text = [kpstr uppercaseString];
         if ([[self checkforValidString:kpstr] isEqualToString:@"NA"])
         {
         cell.lblAddress.text = @"NA";
         }
         else
         {
         if ([kpstr length]==12)
         {
         cell.lblAddress.text = kpstr;
         }
         else if ([kpstr length]>12)
         {
         NSRange range71 = NSMakeRange(0, 12);
         NSString * strTitle = [kpstr substringWithRange:range71];
         cell.lblAddress.text = strTitle;
         }
         else
         {
         cell.lblAddress.text = kpstr;
         }
         }
         }
         else
         {
         cell.lblAddress.text = @"NA";
         }*/
    }
    else
    {
        cell.lblAddress.text = @"NA";
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [timerOut invalidate];
    timerOut = nil;
    timerOut = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timeOutConnection) userInfo:nil repeats:NO];
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =arrDevicesConnectable;
    
    if ([arrayDevices count]>0)
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"peripheral"];
        strSelectedAddress =  [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"address"];
        NSLog(@"Factory Reset Device ==%@ & Peripheral==%@",[[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"address"],p);
        if (p.state == CBPeripheralStateConnected)
        {
            [self SendRequesttoFactoryReset:p];
        }
        else
        {
            connectionCount = 0;
//            [APP_DELEGATE startHudProcess:@"Connecting..."];
            
            connectionHUD = [[MBProgressHUD alloc] initWithView:self.view];
            connectionHUD.labelText = @"Resetting...";
            [self.view addSubview:connectionHUD];
            [connectionHUD show:YES];
            [self performSelector:@selector(sentConnectRequest:) withObject:p afterDelay:0];
        }
    }
}
-(void)SendRequesttoFactoryReset:(CBPeripheral *)peripheral
{
    [[BLEService sharedInstance] sendNotifications:peripheral withType:NO withUUID:@"0001D100-AB00-11E1-9B23-00025B00A5A5"];
    [[BLEService sharedInstance] readAuthValuefromManager:peripheral];
    [self performSelector:@selector(sendFactoryReset:) withObject:peripheral afterDelay:1];

}
-(void)sendFactoryReset:(CBPeripheral *)peripheral
{
    [[BLEService sharedInstance] sendNotifications:peripheral withType:NO withUUID:@"0001D100-AB00-11E1-9B23-00025B00A5A5"];
    [[BLEService sharedInstance] readAuthValuefromManager:peripheral];
    [self ShowResetNotification:peripheral];
}
-(void)sentConnectRequest:(CBPeripheral *)peripheral
{
    if (peripheral.state == CBPeripheralStateConnected)
    {
        [connectionHUD hide:YES];
    }
    else
    {
        if (connectionCount <10)
        {
//            NSLog(@"Sent Connection Request...");
            [self onConnectWithDevice:peripheral];
            connectionCount = connectionCount +1;
            [self performSelector:@selector(sentConnectRequest:) withObject:peripheral afterDelay:1];
        }
        else
        {
            [connectionHUD hide:YES];
        }
    }
}
-(void)timeoutMethodClick
{
    [timeOutAlert dismissAlertView];
    [timeOutAlert removeFromSuperview];
    [APP_DELEGATE hudEndProcessMethod];
    [confirmTimer invalidate];
    [APP_DELEGATE endHudProcess];
    isSearchingfromFactory = NO;
    [[BLEManager sharedManager] rescan];

}
-(void)toStopIndicator
{
    [APP_DELEGATE endHudProcess];
}
#pragma mark - BLE Methods

-(void)InitialBLE
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallNotificationforNonConnectforAdd" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"deviceDidDisConnectNotificationBridge" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"deviceDidConnectNotificationBridge" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"FetchAssociatedDevicesonly" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotifyforBridge:) name:@"CallNotificationforNonConnectforAdd" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidConnectNotification:) name:@"deviceDidConnectNotificationBridge" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidDisConnectNotification:) name:@"deviceDidDisConnectNotificationBridge" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(FetchAssociatedDevicesonly:) name:@"FetchAssociatedDevicesonly" object:nil];

}
-(void)NotifyforBridge:(NSNotification*)notification//Update peripheral
{
    
    NSMutableArray * arrNonConnectable = [[NSMutableArray alloc] init];
    arrNonConnectable = [[BLEManager sharedManager] nonConnectArr];
    
    for (int i =0; i < [[[BLEManager sharedManager] foundDevices] count]; i++)
    {
        NSString * strAddress = [[[[BLEManager sharedManager] foundDevices] objectAtIndex:i] objectForKey:@"address"];
        if ([[arrNonConnectable valueForKey:@"address"] containsObject:strAddress])
        {
            if ([[arrDevicesConnectable valueForKey:@"address"] containsObject:strAddress])
            {
                NSInteger foundIndex = [[arrDevicesConnectable valueForKey:@"address"] indexOfObject:strAddress];
                if (foundIndex != NSNotFound)
                {
                    if ([arrDevicesConnectable count] > foundIndex)
                    {
                        [arrDevicesConnectable replaceObjectAtIndex:foundIndex withObject:[[[BLEManager sharedManager] foundDevices] objectAtIndex:i]];
                    }
                }
            }
            else
            {
                [arrDevicesConnectable addObject:[[[BLEManager sharedManager] foundDevices] objectAtIndex:i]];
            }
        }
    }
    
    [tblView reloadData];
    
}
-(void)FetchAssociatedDevicesonly:(NSNotification *)notification
{
    
}
-(void)ResetSuccessPopup:(NSNotification *)notify
{
    CBPeripheral * sentperipheral = [notify object];
    if (sentperipheral != nil)
    {
        [timeOutAlert dismissAlertView];
        [timeOutAlert removeFromSuperview];
        [APP_DELEGATE hudEndProcessMethod];
        [confirmTimer invalidate];
        [APP_DELEGATE endHudProcess];
        isSearchingfromFactory = NO;
        [[BLEManager sharedManager] rescan];

        [APP_DELEGATE endHudProcess];
        isSearchingfromFactory = NO;
        [alert removeFromSuperview];
        alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeSuccess];
        alert.delegate = self;
        alert.tag = 222;
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"Device has been resetted successfully."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
        
        for (int i=0; i<[[[BLEManager sharedManager] foundDevices]count]; i++)
        {
            CBPeripheral *localperipheral = [[[[BLEManager sharedManager]foundDevices]objectAtIndex:i]valueForKey:@"peripheral"];
            if (localperipheral == sentperipheral)
            {
                strSelectedBleAddress = [[[[BLEManager sharedManager]foundDevices]objectAtIndex:i]valueForKey:@"address"];
                break;
            }
        }
        NSString * str = [NSString stringWithFormat:@"Select * from Device_Table where user_id='%@' and ble_address ='%@' ",CURRENT_USER_ID,[strSelectedBleAddress uppercaseString]];
        NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
        [[DataBaseManager dataBaseManager] execute:str resultsArray:tmpArr];
        
        if (tmpArr.count>0)
        {
            strDeviceID = [[tmpArr objectAtIndex:0]valueForKey:@"device_id"];
            NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set status ='2',is_sync = '0' where ble_address = '%@'",[strSelectedBleAddress uppercaseString]];
            [[DataBaseManager dataBaseManager] execute:strUpdate];
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            dict = [tmpArr objectAtIndex:0];
            [dict setObject:@"0" forKey:@"status"];
            [self SaveDeviceDetailstoServer:dict];
        }
            [APP_DELEGATE hudEndProcessMethod];

    }
}
-(void)DeviceDidConnectNotification:(NSNotification*)notification//Connect periperal
{
        
    CBPeripheral * peripheral = [notification object];
    if (peripheral != nil)
    {
        [self SendRequesttoFactoryReset:peripheral];
    }
    [APP_DELEGATE endHudProcess];
//    [APP_DELEGATE hideScannerView];
    isCnnectedSucess = YES;
    //globalPeripheral = myPeripheral;
    [tblView reloadData];

    if (isFromAddDevice)
    {
        //        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)DeviceDidDisConnectNotification:(NSNotification*)notification//Disconnect periperal
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE hideScannerView];
    [tblView reloadData];
}
-(void)onConnectButton:(NSInteger)sender//Connect & DisconnectClicked
{
    [timertoStopIndicator invalidate];
    timertoStopIndicator = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timeOutConnection) userInfo:nil repeats:NO];
    
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] nonConnectArr];
    
    if ([arrayDevices count]>0)
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:sender] objectForKey:@"peripheral"];
        myPeripheral = p;
        if (p.state == CBPeripheralStateConnected)
        {
            [APP_DELEGATE startHudProcess:@"Disconnecting..."];
            [self onDisconnectWithDevice:p];
        }
        else
        {
            [APP_DELEGATE startHudProcess:@"Resetting..."];
            [self onConnectWithDevice:p];
        }
    }
}
-(void)timeOutConnection
{
    [timertoStopIndicator invalidate];

    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        
    }
    else
    {
        [APP_DELEGATE endHudProcess];
    }
    [APP_DELEGATE endHudProcess];

}
-(void)ShowResetNotification:(CBPeripheral *)peripheral
{
    [alert removeFromSuperview];
    alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    alert.tag = 555;
    alert.selectedPeripheral = peripheral;
    alert.delegate = self;
    [alert addButton:@"Yes" withActionBlock:^{
//        [self StartFactoryResetafterPermission];
    }];
    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Do you want to Reset this device?"
           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
       withDoneButtonTitle:@"No" andButtons:nil];
}
-(void)StartFactoryResetafterPermission:(CBPeripheral *)peripheral
{
    [APP_DELEGATE hudEndProcessMethod];
    [APP_DELEGATE startHudProcess:@"Resetting Device..."];
    [[BLEService sharedInstance] readFactoryResetValue:peripheral];
    isSearchingfromFactory = YES;
    
    [confirmTimer invalidate];
    confirmTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(timeoutMethodClick) userInfo:nil repeats:NO];
    
    [self showPopuptoTellturnofflights];
}
-(void)showPopuptoTellturnofflights
{
    [APP_DELEGATE hudEndProcessMethod];
    [APP_DELEGATE startHudProcess:@"Resetting Device..."];

    [timeOutAlert removeFromSuperview];
    timeOutAlert = [[FCAlertView alloc] init];
    timeOutAlert.colorScheme = [UIColor blackColor];
    [timeOutAlert makeAlertTypeSuccess];
    timeOutAlert.tag = 333;
    [timeOutAlert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Please turn off and turn on smart light within 15 secs to factory reset while the light is blinking blue. After turning on if the device is blinking green it indicates factory reset is successful."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
    timeOutAlert.hideAllButtons = YES;
}
-(void)GlobalBLuetoothCheck
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Vithamas" message:@"Please enable Bluetooth Connection. Tap on enable Bluetooth icon by swiping Up." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:true completion:nil];
}
#pragma mark - CentralManager Ble delegate Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
}
#pragma mark - Ble device Disconnect method
-(void)onDisconnectWithDevice:(CBPeripheral*)peripheral
{
    [[BLEManager sharedManager] disconnectDevice:peripheral];
}
#pragma mark - Ble device Connect method

-(void)onConnectWithDevice:(CBPeripheral*)peripheral
{
    [[BLEManager sharedManager] connectDevice:peripheral];
}

-(void)checkForConnectedDevice
{
    NSArray * lastConnec = [[BLEManager sharedManager] getLastConnected];
    
    if ([lastConnec count]==0)
    {
    }
    for (int i=0; i<[lastConnec count]; i++)
    {
        CBPeripheral * CBPD = [lastConnec objectAtIndex:i];
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"NA" forKey:@"Manufac"];
        [dict setObject:CBPD forKey:@"peripheral"];
        
        if ([[[BLEManager sharedManager] nonConnectArr] count]==0)
        {
            [[[BLEManager sharedManager] nonConnectArr] addObject:dict];
        }
        else
        {
            if (![[[[BLEManager sharedManager] nonConnectArr] valueForKey:@"peripheral"] containsObject:CBPD])
            {
                [[[BLEManager sharedManager] nonConnectArr] addObject:dict];
            }
        }
    }
    if (isFromAddDevice)
    {
        [timerConnectedCheck invalidate];
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
    return hex;
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
#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
    if (alertView.tag == 555)
    {
        [self StartFactoryResetafterPermission:alertView.selectedPeripheral];
    }
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 222)
    {
        isFromFactoryRest = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (alertView.tag == 333)
    {
        [timertoStopIndicator invalidate];
        timertoStopIndicator = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(toStopIndicator) userInfo:nil repeats:NO];
    }
//    NSLog(@"Done Button Clicked");
}

- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
//    NSLog(@"Alert Dismissed");
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
//    NSLog(@"Alert Will Appear");
}

#pragma mark - MEScrollToTopDelegate Methods

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
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
    if ([IS_USER_SKIPPED isEqualToString:@"NO"])
    {
        //[lblAccName setText:[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_NAME"]]];
        
        if ([APP_DELEGATE isNetworkreachable])
        {
           
                [self refreshBtnClick];
                [self performSelector:@selector(stoprefresh) withObject:nil afterDelay:1.5];
        }
    }
    else
    {
        [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
    }
    
}
-(void)stoprefresh
{
    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
}

#pragma mark - Save Install records to Database
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
//                    NSLog(@"USER ID=%@",CURRENT_USER_ID);
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
                                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                            if (error)
                                                            {
//                                                                NSLog(@"Servicer error = %@", error);
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
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

