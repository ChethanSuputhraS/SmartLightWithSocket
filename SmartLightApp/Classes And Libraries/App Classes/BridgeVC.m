//
//  BridgeVC.m
//  SmartLightApp
//
//  Created by stuart watts on 28/11/2017.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import "BridgeVC.h"
#import "HistoryCell.h"
#import "AuthenticationVC.h"
#import "MNMPullToRefreshManager.h"


@interface BridgeVC ()<UITableViewDelegate,UITableViewDataSource,FCAlertViewDelegate,MNMPullToRefreshManagerClient,CBCentralManagerDelegate>
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
    NSMutableDictionary * bleRememberDict;
    NSInteger selectedIndex;
    NSString * strSelectedBLEAddress;
}
@end

@implementation BridgeVC
@synthesize isFromAddDevice,arrFromAddDevice; 
- (void)viewDidLoad
{
    
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
    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
    
//    timerConnectedCheck = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkForConnectedDevice) userInfo:nil repeats:YES];
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
    }
    else
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
    isFromFactoryRest = NO;
    
    [super viewWillAppear:YES];
    
    [self InitialBLE];
    [[[BLEManager sharedManager] nonConnectArr] removeAllObjects];
    [[BLEManager sharedManager] startScan];//Scan Ble devices
    [self refreshBtnClick];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:currentScreen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBleStatus) name:currentScreen object:nil];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
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
    [lblTitle setText:@"Device Connection"];
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
    NSArray * tmpArr = [[BLEManager sharedManager]getLastConnected];
    [[BLEManager sharedManager] stopScan];
    [[[BLEManager sharedManager] foundDevices] removeAllObjects];
    for (int i=0; i<tmpArr.count; i++)
    {
        CBPeripheral * p = [tmpArr objectAtIndex:i];
        [[BLEManager sharedManager]disconnectDevice:p];
    }
    isfromBridge = NO;
    [timerConnectedCheck invalidate];
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

}
#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-146, 45)];
    headerView.backgroundColor = [UIColor blackColor];
    
    UILabel *lblmenu=[[UILabel alloc]init];
    lblmenu.text = @" Tap on device for Connect/Disconnect.";
    [lblmenu setTextColor:[UIColor whiteColor]];
    [lblmenu setFont:[UIFont fontWithName:CGRegular size:textSizes-1]];
    lblmenu.frame = CGRectMake(5, 0, DEVICE_WIDTH-10, 45);
    [headerView addSubview:lblmenu];
    
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        [lblmenu setFont:[UIFont fontWithName:CGRegular size:textSizes-2]];
    }

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
    return [[[BLEManager sharedManager] foundDevices] count];
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
    
    //    cell.imgIcon.image = [UIImage imageNamed:@"default_pic.png"];
    cell.imgIcon.hidden = NO;
    cell.lblConnect.text = @"Connect";
    cell.lblAddress.hidden = NO;
    
    cell.lblDeviceName.font = [UIFont fontWithName:CGRegular size:textSizes+2];
    cell.lblAddress.font = [UIFont fontWithName:CGRegular size:textSizes-1];
    cell.lblConnect.font = [UIFont fontWithName:CGRegular size:textSizes-1];
    
    cell.lblDeviceName.frame = CGRectMake(10, 0, DEVICE_WIDTH-20, 30); // css add this
    cell.lblAddress.frame = CGRectMake(10,  25+7, DEVICE_WIDTH-20, 20); // css add this

    
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] foundDevices];
    
    if ([arrayDevices count]>0)
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"peripheral"];
        cell.lblDeviceName.text = p.name;
        
        cell.lblAddress.text = [[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"address"];
        if (p.state == CBPeripheralStateConnected)
        {
            cell.lblConnect.text = @"Disconnect";
        }
        else
        {
            cell.lblConnect.text = @"Connect";
        }
 
        NSString * manuStr = [[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"Manufac"];
        //        NSRange rangeFirst = NSMakeRange(1, 4);
        //        NSString * strOpCodeCheck = [manuStr substringWithRange:rangeFirst];
                {
                    NSString * kpstr = manuStr;
                    kpstr = [kpstr stringByReplacingOccurrencesOfString:@" " withString:@""];
                    kpstr = [kpstr stringByReplacingOccurrencesOfString:@">" withString:@""];
                    kpstr = [kpstr stringByReplacingOccurrencesOfString:@"<" withString:@""];

                    if ([kpstr length]>=38)
                    {
                        NSRange range71 = NSMakeRange(22, 12);
                        NSString * str1 = [kpstr substringWithRange:range71];
                        cell.lblAddress.text = [str1 uppercaseString];
                        
                        range71 = NSMakeRange([kpstr length]-4, 4);
                        NSString * strType = [kpstr substringWithRange:range71];
                        
                        if ([strType isEqualToString:@"0100"])
                        {
                            cell.lblDeviceName.text = @"Vithamas Light";
                            cell.imgIcon.image = [UIImage imageNamed:@"default_pic.png"];
                        }
                        else if ([strType isEqualToString:@"0200"])
                        {
                            cell.lblDeviceName.text = @"Vithamas White Light";
                            cell.imgIcon.image = [UIImage imageNamed:@"default_pic.png"];
                        }
                        else if ([strType isEqualToString:@"0300"])
                        {
                            cell.lblDeviceName.text = @"Vithamas Switch";
                            cell.imgIcon.image = [UIImage imageNamed:@"default_switch_icon.png"];
                        }
                        else if ([strType isEqualToString:@"0400"])
                        {
                            cell.lblDeviceName.text = @"Vithamas Socket";
                            cell.imgIcon.image = [UIImage imageNamed:@"default_socket_icon.png"];
                        }
                        else if ([strType isEqualToString:@"0500"])
                        {
                            cell.lblDeviceName.text = @"Vithamas Fan";
                            cell.imgIcon.image = [UIImage imageNamed:@"default_fan_icon.png"];
                        }
                        else if ([strType isEqualToString:@"0600"])
                        {
                            cell.lblDeviceName.text = @"Vithamas Strip Light";
                            cell.imgIcon.image = [UIImage imageNamed:@"stripwhite.png"];
                        }
                        else if ([strType isEqualToString:@"0700"])
                        {
                            cell.lblDeviceName.text = @"Vithamas Night lamp";
                            cell.imgIcon.image = [UIImage imageNamed:@"default_lamp.png"];
                        }
                        else if ([strType isEqualToString:@"0800"])
                        {
                            cell.lblDeviceName.text = @"Vithamas Power socket strip";
                            cell.imgIcon.image = [UIImage imageNamed:@"default_powerstrip_icon.png"];
                        }
                    }
                }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (void)configureCell:(HistoryCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.lblConnect.hidden = YES;
    
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] foundDevices];
    
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
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] foundDevices];
    
    if ([arrayDevices count]>0)
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"peripheral"];
        bleRememberDict = [[NSMutableDictionary alloc] init];
        bleRememberDict = [arrayDevices objectAtIndex:indexPath.row];
        strSelectedBLEAddress = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"address"];

        myPeripheral = p;
        if (p.state == CBPeripheralStateConnected)
        {
            [APP_DELEGATE startHudProcess:@"Disconnecting..."];
            
            if ([[arrGlobalDevices valueForKey:@"peripheral"] containsObject:p])
            {
                NSInteger foundIndex = [[arrGlobalDevices valueForKey:@"peripheral"] indexOfObject:p];
                if (foundIndex != NSNotFound)
                {
                    if (arrGlobalDevices.count > foundIndex)
                    {
                        [arrGlobalDevices removeObjectAtIndex:foundIndex];
                    }
                }
            }

            [self onDisconnectWithDevice:p];
        }
        else
        {
            connectionCount = 0;
            [APP_DELEGATE startHudProcess:@"Connecting..."];
            [self sentConnectRequest];
        }
    }
}
-(void)sentConnectRequest
{
    if (myPeripheral.state == CBPeripheralStateConnected)
    {
        [APP_DELEGATE endHudProcess];
    }
    else
    {
        if (connectionCount <10)
        {
            [self onConnectWithDevice:myPeripheral];
            connectionCount = connectionCount +1;
            [self performSelector:@selector(sentConnectRequest) withObject:nil afterDelay:1];
        }
        else
        {
            [APP_DELEGATE endHudProcess];
        }
    }
}
#pragma mark - BLE Methods
-(void)InitialBLE
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallNotificationforNonConnectforAdd" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"deviceDidDisConnectNotificationBridge" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"deviceDidConnectNotificationBridge" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotifyforBridge:) name:@"CallNotificationforNonConnectforAdd" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidConnectNotification:) name:@"deviceDidConnectNotificationBridge" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidDisConnectNotification:) name:@"deviceDidDisConnectNotificationBridge" object:nil];
}
-(void)NotifyforBridge:(NSNotification*)notification  //Update peripheral
{
    [tblView reloadData];
}
-(void)DeviceDidConnectNotification:(NSNotification*)notification  //Connect periperal
{

    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE hideScannerView];
    isCnnectedSucess = YES;
    [tblView reloadData];
    

    
    [APP_DELEGATE hudEndProcessMethod];
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    alert.delegate = self;
    alert.tag = 222;
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Device has been connected successfully."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
    
    if (isFromAddDevice)
    {
        isfromBridge = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTableAddDevice" object:nil];
        [self.navigationController popViewControllerAnimated:YES];
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
    [self performSelector:@selector(timeOutConnection) withObject:nil afterDelay:6];
    
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
            [APP_DELEGATE startHudProcess:@"Connecting..."];
            [self onConnectWithDevice:p];
        }
    }
}
-(void)timeOutConnection
{
    [APP_DELEGATE endHudProcess];
    
    if ([currentScreen isEqualToString:@""])
    {
        if (isCnnectedSucess == NO)
        {
            NSString * strMsg = [NSString stringWithFormat:@"Something went wrong. Please try again."];
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
    BOOL isNewDeviceFound = NO;
    
    for (int i =0; i<[arrConnectedDevices count]; i++)
    {
        CBPeripheral * tmpPeri = [[arrConnectedDevices objectAtIndex:i] objectForKey:@"peripheral"];
        if (tmpPeri.state == CBPeripheralStateConnected)
        {
            if ([[[[BLEManager sharedManager] foundDevices] valueForKey:@"address"] containsObject:[[arrConnectedDevices objectAtIndex:i] objectForKey:@"address"]])
            {
            }
            else
            {
                isNewDeviceFound = YES;
                [[[BLEManager sharedManager] foundDevices] addObject:[arrConnectedDevices objectAtIndex:i]];
            }
        }
    }
    [tblView reloadData];
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
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 222)
    {
        isfromBridge = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
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

@end

