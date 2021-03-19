//
//  DashboardVC.m
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 5/31/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import "DashboardVC.h"
#import "SetBeaconManager.h"
#import "GetBeaconManager.h"
#import "AddGroupsVC.h"
#import "BridgeVC.h"
#import "CustomGroupCell.h"
#import "ManageAccVC.h"
#import "MNMPullToRefreshManager.h"
#import "SideTableViewCell.h"
#import "AlarmVC.h"
#import "SettingsVC.h"
#import "WelcomeVC.h"
#import "VCFloatingActionButton.h"
#import "HistoryCell.h"
#import "HRHSVColorUtil.h"
#import <CocoaMQTT/CocoaMQTT.h>
#import "AddSocketVC.h"
#import "SocketDetailVC.h"
#import "SocketWiFiSetupVC.h"
#import "DashboardNewCell.h"
#import "NewCustomGroupCell.h"

@import CocoaMQTT;

@interface DashboardVC ()<MNMPullToRefreshManagerClient,CBCentralManagerDelegate,floatMenuDelegate,UIGestureRecognizerDelegate, CocoaMQTTDelegate, SocketDetailPageDelegate>
{
    NSMutableArray * tmpGroupArr, * syncedDeletedListArr;
    NSInteger groupSentCount, groupSyncCount, requestedIndex;
    NSString * strUnsyncedGroupId, * strUpdatedName;
    NSInteger deviceTriedCount, groupTriedCount, renameIndex;
    MNMPullToRefreshManager * topPullToRefreshManager;
    VCFloatingActionButton *addFloatButton,*addFloatBtnForRooms;
//    NSIndexPath *  previousIndexPath;
    NSTimer * colorTimer,* updateConnectedDeviceTimer;
    NSInteger brightnessIndex;
    BOOL isCentralAssigned;
    NSString * isRequestfor;
    
    CocoaMQTT * mqttObj;
    NSArray *imageArray,*labelArray;
    NSMutableArray * arrayAllDevice;
    NSString * strCurrentTopic;
    BOOL isFloatButton;
    BOOL isMqttDisconnected;

}
@property (nonatomic) NSIndexPath *expandingIndexPath;
@property (nonatomic) NSIndexPath *expandedIndexPath;
@property (nonatomic) NSIndexPath *expandingIndexPathGroup;
@property (nonatomic) NSIndexPath *expandedIndexPathGroup;

- (NSIndexPath *)actualIndexPathForTappedIndexPath:(NSIndexPath *)indexPath;
@end

@implementation DashboardVC
@synthesize strMack;
#pragma mark - Life Cycle
- (void)viewDidLoad
{
    dictSocketSwitchStatus = [[NSMutableDictionary alloc] init];
    
    sideBtnIndex = 1;

    [APP_DELEGATE startAdvertisingBeacons];
    
    [topPullToRefreshManager setPullToRefreshViewVisible:NO];

    groupsArr = [[NSMutableArray alloc] init];
    [super viewDidLoad];
    
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.contentMode = UIViewContentModeScaleAspectFit;
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];

    selectedDict = [[NSMutableDictionary alloc] init];
    setDict = [[NSDictionary alloc] init];
    arrayAllDevice = [[NSMutableArray alloc] init];
    
    NSString * str = [NSString stringWithFormat:@"Select * from Device_Table"];
    [[DataBaseManager dataBaseManager] execute:str resultsArray:arrayAllDevice];
    
    [self setNavigationViewFrames];
    
    [self setMainViewContent];
    
//    [self getDatafromDatabase];
    
    [self ConnecttoMQTTSocketServer];
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIView *statusBar;
    if (@available(iOS 13, *))
    {
        statusBar = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame] ;
        statusBar.backgroundColor = global_brown_color;
        [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
     }
    else
    {
        statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    }
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor blackColor];//set whatever color you like
    }
    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
    if ([IS_USER_SKIPPED isEqualToString:@"NO"])
    {
        [lblAccName setText:[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_NAME"]]];
        if ([APP_DELEGATE isNetworkreachable])
        {
            [self getAllDevices];
        }
    }
    sideViewArray = [[NSMutableArray alloc]init];
    [sideViewArray addObject:@"Home"];
    [sideViewArray addObject:@"Scheduler"];
    [sideViewArray addObject:@"Device Settings"];
    [sideViewArray addObject:@"Account"];
    [sideViewArray addObject:@"Help"];
    [sideViewArray addObject:@"Contact Us"];
    
    [updateConnectedDeviceTimer invalidate];
    updateConnectedDeviceTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(CheckSockectConnectionTimer) userInfo:nil repeats:YES];
    
    [[BLEManager sharedManager] rescan];
}

-(void)viewWillAppear:(BOOL)animated
{
    isViewWillAppeared = YES;
    isCheckforDashScann = YES;
    isScanCheckforDashboard = YES;
    
    if (isCentralAssigned == NO)
    {
        centralManager = nil;
        centralManager.delegate = nil;
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        isCentralAssigned = YES;
    }
    
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
    }
    
    [topPullToRefreshManager setPullToRefreshViewVisible:YES];

    currentScreen = @"Dashboard";
    
    
    [[SetBeaconManager sharedManager] stopAdv];
    
    [[BLEManager sharedManager] centralmanagerScanStop];
    
    [super viewWillAppear:YES];
    
    [APP_DELEGATE showTabBar:self.tabBarController];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCheckButtonVisibilityNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DashboardConnectionNotify" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DashBoardConnected) name:@"DashboardConnectionNotify" object:nil];
    
    [self getDatafromDatabase];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:currentScreen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBleStatus) name:currentScreen object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BLEConnectionErrorPopup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BLEConnectionErrorPopup) name:@"BLEConnectionErrorPopup" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GlobalBLuetoothCheck" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GlobalBLuetoothCheck) name:@"GlobalBLuetoothCheck" object:nil];
    
    [APP_DELEGATE sendSignalViaScan:@"TimeSet" withDeviceID:@"0" withValue:@"0"];

    imgNotConnected.hidden = NO;
    
    
    if ([IS_USER_SKIPPED isEqualToString:@"NO"])
    {
        [lblAccName setText:[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_NAME"]]];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetFavoriteColors" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SendCallbackforDashScanning" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SendCallbackforDashScanning:) name:@"SendCallbackforDashScanning" object:nil];

    [imgNotConnected removeFromSuperview];
    imgNotConnected = [[UIImageView alloc]init];
    imgNotConnected.image = [UIImage imageNamed:@"notconnect_iconWhite.png"];
    imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 32, 30, 22);
    imgNotConnected.contentMode = UIViewContentModeScaleAspectFit;
    imgNotConnected.layer.masksToBounds = true;
//    [self.view addSubview:imgNotConnected];
    
    if (IS_IPHONE_X)
    {
        imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 55, 30, 22);
    }
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        imgNotConnected.image = [UIImage imageNamed:@"Connected_icon.png"];
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
    [colorTimer invalidate];
    colorTimer = [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(changeColor) userInfo:nil repeats:YES];

    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}
-(void)viewDidAppear:(BOOL)animated
{
    NSString * strScanNotify = [NSString stringWithFormat:@"ResponsefromScanDashDashboard"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:strScanNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ResponsefromScanDash:) name:strScanNotify object:nil];
    
    NSString * strSwitchNotify = [NSString stringWithFormat:@"updateDataforONOFFDashboard"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:strSwitchNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataforONOFF:) name:strSwitchNotify object:nil];
    
    deviceTriedCount = 0;
    groupTriedCount = 0;
    
    if ([IS_USER_SKIPPED isEqualToString:@"NO"])
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
            if (isUserDetailedCheck == NO)
            {
                isRequestfor = @"FirstCheck";
                [self CheckUserCredentialDetials];
                isUserDetailedCheck = YES;
            }
            [self SendUnsyncRecordsToServer];
        }
    }
    
    [super viewDidAppear:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [colorTimer invalidate];
    imgNotConnected.hidden = YES;
    
    isDashScanning = NO;
    
    isViewWillAppeared = false;
    isCheckforDashScann = false;
    isScanCheckforDashboard = false;

    [super viewWillDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateInternetAvailabilityNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCheckButtonVisibilityNotification object:nil];
    
    NSString * strScanNotify = [NSString stringWithFormat:@"ResponsefromScanDashDashboard"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:strScanNotify object:nil];
}

#pragma mark - Set View Frames of Segment & Table
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    lblBack.backgroundColor = [UIColor clearColor];
    lblBack.alpha = 0.5;
    [viewHeader addSubview:lblBack];

    UIImageView * imgMenu = [[UIImageView alloc]initWithFrame:CGRectMake(10,20+7, 33, 30)];
    imgMenu.image = [UIImage imageNamed:@"menu.png"];
    imgMenu.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgMenu];

    UIButton * btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMenu setFrame:CGRectMake(0, 0, 80, 64)];
    [btnMenu addTarget:self action:@selector(btnMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnMenu];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 12, DEVICE_WIDTH-100, 64)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Vithamas"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGBold size:textSizes+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 44, DEVICE_WIDTH-100, 44);
        [btnMenu setFrame:CGRectMake(0, 0, 88, 88)];
        imgMenu.frame = CGRectMake(10,44+7, 33, 30);
        imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 55, 30, 22);
    }
    if ([IS_USER_SKIPPED isEqualToString:@"YES"])
    {
        lblAccName.hidden = YES;
    }
}
-(void)setMainViewContent
{
    int yy = 64 + 5;
    
    if (IS_IPHONE_X)
    {
        yy = 88 + 10;
    }
    blueSegmentedControl = [[NYSegmentedControl alloc] initWithItems:@[@"Devices", @"Rooms"]];
    blueSegmentedControl.titleTextColor = global_brown_color;
    blueSegmentedControl.selectedTitleTextColor = [UIColor whiteColor];
    blueSegmentedControl.segmentIndicatorBackgroundColor = global_brown_color;
    blueSegmentedControl.backgroundColor = [UIColor whiteColor];
    blueSegmentedControl.borderWidth = 0.0f;
    blueSegmentedControl.segmentIndicatorBorderWidth = 0.0f;
    blueSegmentedControl.segmentIndicatorInset = 2.0f;
    blueSegmentedControl.segmentIndicatorBorderColor = self.view.backgroundColor;
    blueSegmentedControl.cornerRadius = 22;
    blueSegmentedControl.usesSpringAnimations = YES;
    [blueSegmentedControl addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventValueChanged];
    blueSegmentedControl.layer.cornerRadius = 22;
    blueSegmentedControl.layer.masksToBounds = YES;
    [self.view addSubview:blueSegmentedControl];
    [blueSegmentedControl setFrame:CGRectMake(30,yy, DEVICE_WIDTH-60, 44)];
    
    yy = yy + 44 + 5;
    
    noMsgView = [[UIView alloc] init];
    noMsgView.frame = CGRectMake(0, yy+60, DEVICE_WIDTH, DEVICE_HEIGHT-50-yy);
    noMsgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:noMsgView];
    
    blbImg = [[UIImageView alloc] init];
//    blbImg.image = [UIImage imageNamed:@"bulb_icon.png"];
    blbImg.frame = CGRectMake((DEVICE_WIDTH-70)/2, (noMsgView.frame.size.height-103)/2-60-60, 70, 103);
//    [noMsgView addSubview:blbImg];
    
    if (IS_IPHONE_4)
    {
        blbImg.frame = CGRectMake((DEVICE_WIDTH-70)/2, (noMsgView.frame.size.height-103)/2-30-30, 70, 103);
        yy = yy + (noMsgView.frame.size.height-103)/2-50-30 + 0;
    }
    else
    {
        yy = yy + (noMsgView.frame.size.height-103)/2-60-60 + 0;
    }
    
    lblSuccessMsg = [[UILabel alloc] initWithFrame:CGRectMake(10, yy, DEVICE_WIDTH-20, 80)];
    [lblSuccessMsg setTextColor:UIColor.whiteColor];
    [lblSuccessMsg setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lblSuccessMsg setTextAlignment:NSTextAlignmentCenter];
    [lblSuccessMsg setNumberOfLines:5];
    [lblSuccessMsg setText:@"No devices found. Tap on + button to add device."];
    [noMsgView addSubview:lblSuccessMsg];
    
    yy = yy + 30 + 40 ;
    
    noMsgView.hidden=YES;
    sectionArr = [[NSMutableArray alloc] init];
    NSString * str1 = [NSString stringWithFormat:@"Select * from Device_Table where user_id='%@' and status = '1' group by ble_address  ORDER BY is_favourite ASC",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:str1 resultsArray:sectionArr];
    
    if ([sectionArr count]==0)
    {
        noMsgView.hidden = NO;
    }
    else
    {
        noMsgView.hidden = YES;
    }
    [addFloatButton ChangeImage:[UIImage imageNamed:@"cross.png"]];
    int yytbl = 64 + 5;
    
    if (IS_IPHONE_X)
    {
        yytbl = 88 + 10;
    }
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, yytbl+50, DEVICE_WIDTH, DEVICE_HEIGHT-(yytbl+50)) style:UITableViewStyleGrouped];
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblView.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:tblView];
    
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    longPressRecognizer.minimumPressDuration = 2.0;
    longPressRecognizer.delegate = self;
    [tblView addGestureRecognizer:longPressRecognizer];
    
    topPullToRefreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:tblView withClient:self];
    [topPullToRefreshManager setPullToRefreshViewVisible:YES];
    [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];
    
    
    addFloatButton = [[VCFloatingActionButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-70, DEVICE_HEIGHT-100, 60, 60) normalImage:[UIImage imageNamed:@"plus.png"] andPressedImage:[UIImage imageNamed:@"cross.png"] withScrollview:tblView]; // cross
    addFloatButton.backgroundColor = global_brown_color;
    addFloatButton.layer.masksToBounds = true;
    addFloatButton.layer.cornerRadius = 30;
    addFloatButton.delegate = self;
    addFloatButton.isAnimatedRequired = YES;
    addFloatButton.hideWhileScrolling = YES;
    addFloatButton.imageArray = @[@"default_pic.png",@"default_powerstrip_icon.png"];
    addFloatButton.labelArray = @[@"Smart Lights",@"Power socket"];
    [self.view addSubview:addFloatButton];
    
    addFloatBtnForRooms = [[VCFloatingActionButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-70, DEVICE_HEIGHT-100, 60, 60) normalImage:[UIImage imageNamed:@"plus.png"] andPressedImage:[UIImage imageNamed:@"cross.png"] withScrollview:tblView]; // cross
    addFloatBtnForRooms.backgroundColor = global_brown_color;
    addFloatBtnForRooms.layer.masksToBounds = true;
    addFloatBtnForRooms.layer.cornerRadius = 30;
    addFloatBtnForRooms.delegate = self;
    addFloatBtnForRooms.hideWhileScrolling = YES;
    addFloatBtnForRooms.isAnimatedRequired = NO;
    [self.view addSubview:addFloatBtnForRooms];
    addFloatBtnForRooms.hidden = YES;
    
    [tblView reloadData];

    if (IS_IPHONE_X)
    {
        CGRect tblFrame = tblView.frame;
        tblFrame = CGRectMake(tblFrame.origin.x, tblFrame.origin.y, tblFrame.size.width, tblFrame.size.height-44+6);
        tblView.frame = tblFrame;
    }
}
-(void)updateBleStatus
{
    if (globalConnStatus)
    {
        bleConnectStatusImg.image = [UIImage imageNamed:@"Connected_icon.png"];
    }
    else
    {
        bleConnectStatusImg.image = [UIImage imageNamed:@"notconnect_icon.png"];
    }
}
#pragma mark - Button Clicks
-(void)btnMenuClicked:(id)sender
{
    [self.menuContainerViewController setMenuSlideAnimationFactor:0.5f];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}
-(void)segmentClick:(NYSegmentedControl *) sender
{
    if (sender.selectedSegmentIndex==0)
    {
        addFloatBtnForRooms.hidden  = YES;
        addFloatButton.hidden = NO;
        CGRect blbFrame =  blbImg.frame;
        blbFrame.size.width = 70;
        blbFrame.size.height = 103;
        blbFrame.origin.x = (DEVICE_WIDTH-70)/2;
        blbImg.frame = blbFrame;
//        blbImg.image = [UIImage imageNamed:@"plus.png"];
        
        isForGroup = NO;
        lblSuccessMsg.hidden = NO;
        tblView.hidden = YES;
        
        [lblSuccessMsg setText:@"No devices found. Tap on + button to add device."];
        sectionArr = [[NSMutableArray alloc] init];
        
        NSString * strQuery = [NSString stringWithFormat:@"Select * from Device_Table where user_id ='%@' and status = '1' group by ble_address  ORDER BY is_favourite ASC",CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:sectionArr];
        
        if ([sectionArr count]==0)
        {
            noMsgView.hidden = NO;
            btnBigAddDevice.hidden = NO;
            addFloatButton.hidden = NO;
            [UIView transitionWithView:noMsgView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
                [noMsgView setHidden:NO];
            } completion:nil];
        }
        else
        {
            noMsgView.hidden = YES;
            btnBigAddDevice.hidden = YES;
            addFloatButton.hidden = NO;
            [UIView transitionWithView:tblView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
                [tblView setHidden:NO];
            } completion:nil];
        }
        [tblView reloadData];
        [addFloatButton ChangeImage:[UIImage imageNamed:@"plus.png"]];
        imgNetworkStatus.frame = CGRectMake(DEVICE_WIDTH-15, 32+0, 10, 18);
        imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 32, 30, 22);

        if (IS_IPHONE_X)
        {
            imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 55, 30, 22);
        }
    }
    else if (sender.selectedSegmentIndex==1)
    {
        addFloatBtnForRooms.hidden  = NO;
        addFloatButton.hidden = YES;

        CGRect blbFrame =  blbImg.frame;
        blbFrame.size.width = 121;
        blbFrame.size.height = 103;
        blbFrame.origin.x = (DEVICE_WIDTH-121)/2;
        blbImg.frame = blbFrame;
        blbImg.image = [UIImage imageNamed:@"group_icon.png"];
        [addFloatButton ChangeImage:[UIImage imageNamed:@"add_group.png"]];
        imgNetworkStatus.frame = CGRectMake(DEVICE_WIDTH-10, 32+0, 10, 18);
        imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 32, 30, 22);

        if (IS_IPHONE_X)
        {
            imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 55, 30, 22);
        }
        isForGroup = YES;
        lblSuccessMsg.hidden = NO;

        [lblSuccessMsg setText:@"No rooms found. Tap on + button to add rooms. \n ( You can add Smart Lights only )"];
        
        groupsArr = [[NSMutableArray alloc] init];
        NSString * str0 = [NSString stringWithFormat:@"Select * from GroupsTable where user_id ='%@' and status = '1' group by local_group_id ORDER BY is_favourite ASC",CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:str0 resultsArray:groupsArr];
        
        if ([groupsArr count]==0)
        {
            lblSuccessMsg.hidden = NO;
            tblView.hidden=NO;
            noMsgView.hidden = NO;
            btnBigAddDevice.hidden = NO;
            [tblView bringSubviewToFront:btnBigAddDevice];
            [UIView transitionWithView:noMsgView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
                [noMsgView setHidden:NO];
            } completion:nil];
        }
        else
        {
            lblSuccessMsg.hidden = YES;
            tblView.hidden=NO;
            noMsgView.hidden = YES;
            btnBigAddDevice.hidden = YES;
            [UIView transitionWithView:tblView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
                [tblView setHidden:NO];
            } completion:nil];
        }
        [tblView reloadData];
        if (isCalledGroup)
        {
        }
        else
        {
            if ([IS_USER_SKIPPED isEqualToString:@"NO"])
            {
                if ([APP_DELEGATE isNetworkreachable])
                {
                    [self getAllGroups];
                }
            }
            isCalledGroup = YES;
        }
    }
}
-(void)btnFavouriteClick:(id)sender
{
    if (isForGroup)
    {
        if ([groupsArr count]> [sender tag]-1)
        {
            NSString * strIsFav = @"1";
            if ([[[groupsArr objectAtIndex:[sender tag]-1] valueForKey:@"is_favourite"] isEqualToString:@"1"])
            {
                strIsFav = @"2";
            }
            else
            {
                strIsFav = @"1";
            }
            NSString * strUpdate = [NSString stringWithFormat:@"Update GroupsTable set is_favourite = '%@',is_sync = '0' where local_group_id='%@'",strIsFav,[[groupsArr objectAtIndex:[sender tag]-1] valueForKey:@"local_group_id"]];
            [[DataBaseManager dataBaseManager] execute:strUpdate];
            [[groupsArr objectAtIndex:[sender tag]-1]setObject:strIsFav forKey:@"is_favourite"];
            [tblView reloadData];
        }
        if ([IS_USER_SKIPPED isEqualToString:@"NO"])
        {
            if ([APP_DELEGATE isNetworkreachable])
            {
                [self SaveGroupsDetailstoServer:[groupsArr objectAtIndex:[sender tag]-1]];
            }
        }
    }
    else
    {
        NSString * strIsFav = @"1";
        if ([[[sectionArr objectAtIndex:[sender tag]] valueForKey:@"is_favourite"] isEqualToString:@"1"])
        {
             strIsFav = @"2";
        }
        else
        {
             strIsFav = @"1";
        }
        NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set is_favourite = '%@', is_sync ='0' where device_id='%@'",strIsFav,[[sectionArr objectAtIndex:[sender tag]] valueForKey:@"device_id"]];
        [[DataBaseManager dataBaseManager] execute:strUpdate];
        [[sectionArr objectAtIndex:[sender tag]]setObject:strIsFav forKey:@"is_favourite"];
        [tblView reloadData];
        if ([IS_USER_SKIPPED isEqualToString:@"NO"])
        {
            if ([APP_DELEGATE isNetworkreachable])
            {
                [self SaveDeviceDetailstoServer:[sectionArr objectAtIndex:[sender tag]]];
            }
        }
    }
}
-(void)btnRenameClick:(id)sender
{
    if (isForGroup)
    {
        selectedIndexPathl = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
        if ([groupsArr count]> selectedIndexPathl.row-1)
        {
            strRename = [[groupsArr objectAtIndex:selectedIndexPathl.row-1] valueForKey:@"group_name"];
            strDeviceID = [[groupsArr objectAtIndex:selectedIndexPathl.row-1] valueForKey:@"local_group_id"];
            strTableId = [[groupsArr objectAtIndex:selectedIndexPathl.row-1] valueForKey:@"local_group_id"];
        }
        AddGroupsVC * deviceGroup = [[AddGroupsVC alloc] init];
        deviceGroup.detailDict = [groupsArr objectAtIndex:selectedIndexPathl.row-1];
        deviceGroup.isfromEdit = YES;
        [self.navigationController pushViewController:deviceGroup animated:YES];
    }
    else
    {
        selectedIndexPathl = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
        
        strRename = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"device_name"];
        strDeviceID = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"device_id"];
        globalDeviceHexId = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"hex_device_id"];
        strTableId = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"id"];
        renameIndex = [sender tag];
        
        NSString * msgPlaceHolder = [NSString stringWithFormat:@"Enter Device Name"];
        
        [alert removeFromSuperview];
        alert = [[FCAlertView alloc] init];
        alert.delegate = self;
        alert.tag = 123;
        alert.colorScheme = global_brown_color;
        
        UITextField *customField = [[UITextField alloc] init];
        customField.placeholder = msgPlaceHolder;
        customField.text = strRename;
        customField.keyboardAppearance = UIKeyboardAppearanceAlert;
        customField.textColor = [UIColor blackColor];

        [alert addTextFieldWithCustomTextField:customField andPlaceholder:nil andTextReturnBlock:^(NSString *text) {
            strUpdatedName = text;
        }];
        [alert addButton:@"Cancel" withActionBlock:^{
        }];
        
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"Enter name"
               withCustomImage:nil
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
}
-(void)btnMoreClick:(id)sender
{
    NSString * strStste = [[sectionArr objectAtIndex:[sender tag]] valueForKey:@"isExpanded"];
    
    if ([strStste isEqual:@"0"])
    {
        [[sectionArr objectAtIndex:[sender tag]] setValue:@"1" forKey:@"isExpanded"];
    }
    else
    {
        [[sectionArr objectAtIndex:[sender tag]] setValue:@"0" forKey:@"isExpanded"];
    }
    
    [tblView reloadData];
}
-(void)btnHeaderClick
{
    isAll = YES;
    selectedDict = [[NSMutableDictionary alloc] init];
    globalGroupId  = [NSString stringWithFormat:@"0"];
    DeviceDetailVC * detailVC = [[DeviceDetailVC alloc] init];
    detailVC.deviceDict = selectedDict;
    detailVC.isFromAll = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}
-(void)btnSettingsClick:(UIButton *)sender
{
    if ([[[sectionArr objectAtIndex:sender.tag] valueForKey:@"device_type"] isEqual:@"4"])
    {
        NSString * strWifiConfig = [[sectionArr objectAtIndex:[sender tag]] valueForKey:@"wifi_configured"];
        NSString * strMacaddress = [[sectionArr objectAtIndex:[sender tag]] valueForKey:@"ble_address"];
        
        SocketWiFiSetupVC * socketWifi = [[SocketWiFiSetupVC alloc] init];
        socketWifi.dictData = [sectionArr objectAtIndex:[sender tag]];
        
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
                        socketWifi.peripheralPss = p;
                    }
                }
            }
        }
        socketWifi.strBleAddress = strMacaddress;
        socketWifi.isWIFIconfig = strWifiConfig; 
        [self.navigationController pushViewController:socketWifi animated:true];
    }
    else
    {
        selectedIndexPathl = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
        strDeviceID = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"device_id"];
        globalDeviceHexId = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"hex_device_id"];
        strTableId = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"id"];
        
        [backView removeFromSuperview];
        backView = [[UIView alloc]init];
        backView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
        backView.backgroundColor = UIColor.blackColor;
        backView.alpha = 0.7;
        [self.view addSubview:backView];
        
        [viewSetting removeFromSuperview];
        viewSetting = [[UIView alloc]init];
        viewSetting.frame = CGRectMake(10, DEVICE_HEIGHT, DEVICE_WIDTH-20, 320);
        viewSetting.backgroundColor = UIColor.whiteColor;
        [self.view addSubview:viewSetting];
        
        [viewSetting.layer setBorderWidth:3.0];
        [viewSetting.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        viewSetting.layer.cornerRadius = 5;
        [viewSetting.layer setShadowOffset:CGSizeMake(5, 5)];
        [viewSetting.layer setShadowColor:[[UIColor whiteColor] CGColor]];
        [viewSetting.layer setShadowOpacity:0.2];
        
        UILabel * lblTitle = [[UILabel alloc]init];
        lblTitle.frame = CGRectMake(0, 0, viewSetting.frame.size.width, 50);
        lblTitle.text = @"Main Power On Setting!!!";
        lblTitle.textAlignment = NSTextAlignmentCenter;
        lblTitle.textColor = UIColor.blackColor;
        lblTitle.font = [UIFont fontWithName:CGBold size:textSizes+6];
        lblTitle.backgroundColor = [UIColor clearColor];
        [viewSetting addSubview:lblTitle];
        
        UIButton *btnCancel = [[UIButton alloc]init];
        btnCancel.frame = CGRectMake(0, viewSetting.frame.size.height-44, (viewSetting.frame.size.width/2)-1, 44);
        btnCancel.backgroundColor = global_brown_color;
        [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
        btnCancel.titleLabel.textColor = UIColor.whiteColor;
        btnCancel.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+2];
        [btnCancel addTarget:self action:@selector(btnCancelAction) forControlEvents:UIControlEventTouchUpInside];
        [viewSetting addSubview:btnCancel];
        
        UIButton *btnSave = [[UIButton alloc]init];
        btnSave.frame = CGRectMake((viewSetting.frame.size.width/2)+1, viewSetting.frame.size.height-44, (viewSetting.frame.size.width/2)-1, 44);
        btnSave.backgroundColor = global_brown_color;
        [btnSave setTitle:@"Save" forState:UIControlStateNormal];
        btnSave.titleLabel.textColor = UIColor.whiteColor;
        [btnSave addTarget:self action:@selector(btnSaveAction) forControlEvents:UIControlEventTouchUpInside];
        btnSave.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+2];
        [viewSetting addSubview:btnSave];
        
        int yy = 44+10;
        btn1 = [[UIButton alloc]init];
        [self setSesstingButtons:btn1 withy:yy withTag:500 withTitle:@"  Cool White"];
            
        yy = yy+50;
        btn2 = [[UIButton alloc]init];
        [self setSesstingButtons:btn2 withy:yy withTag:501 withTitle:@"  Last Set Color"];

        
        yy = yy+50;
        btn3 = [[UIButton alloc]init];
        [self setSesstingButtons:btn3 withy:yy withTag:502 withTitle:@"  Warm White"];
        
        yy = yy+50;
        btn4 = [[UIButton alloc]init];
        [self setSesstingButtons:btn4 withy:yy withTag:503 withTitle:@"  Mood Lightning"];

        intSelectedSettingsValue = [[[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"remember_last_color"] intValue];
        if (intSelectedSettingsValue == 0)
        {
            [btn1 setImage:[UIImage imageNamed:@"radioSelectedBlack.png"] forState:UIControlStateNormal];
        }
        else if (intSelectedSettingsValue == 1)
        {
            [btn2 setImage:[UIImage imageNamed:@"radioSelectedBlack.png"] forState:UIControlStateNormal];
        }
        else if (intSelectedSettingsValue == 2)
        {
            [btn3 setImage:[UIImage imageNamed:@"radioSelectedBlack.png"] forState:UIControlStateNormal];
        }
        else if (intSelectedSettingsValue == 3)
        {
            [btn4 setImage:[UIImage imageNamed:@"radioSelectedBlack.png"] forState:UIControlStateNormal];
        }
        else
        {
            [btn1 setImage:[UIImage imageNamed:@"radioSelectedBlack.png"] forState:UIControlStateNormal];
        }
        [self ShowPicker:YES andView:viewSetting];
    }
}
-(void)setSesstingButtons:(UIButton *)btn withy:(int )yAxis withTag:(int)tagValue withTitle:(NSString *)strTitle
{
    btn.frame = CGRectMake(10,yAxis,viewSetting.frame.size.width-20,44);
    btn.tag = tagValue;
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitle:strTitle forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes];
    [btn setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn addTarget:self action:@selector(btnPowerOnSettingClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewSetting addSubview:btn];

}
-(void)btnPowerOnSettingClick:(id)sender
{
    [btn1 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    [btn2 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    [btn3 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    [btn4 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];

    intSelectedSettingsValue =  [sender tag] - 500;
    UIButton * btnSelected = (UIButton *)[self.view viewWithTag:[sender tag]];
    [btnSelected setImage:[UIImage imageNamed:@"radioSelectedBlack.png"] forState:UIControlStateNormal];
}

-(void)btnCancelAction
{
    [self ShowPicker:NO andView:viewSetting];
}
-(void)btnSaveAction
{
    [self ShowPicker:NO andView:viewSetting];
    
    [self AlertPopForSetting:@"Main Power Setting Saved."];

    NSString * strON = [NSString stringWithFormat:@"%d",intSelectedSettingsValue];
    
    [APP_DELEGATE sendSignalViaScan:@"RememberUDID" withDeviceID:strDeviceID withValue:strON]; //KalpeshScanCode
    NSString * strQuery = [NSString stringWithFormat:@"update Device_Table set remember_last_color =%@ where device_id ='%@'",strON,strDeviceID];
    [[DataBaseManager dataBaseManager] execute:strQuery];
    [[sectionArr objectAtIndex:selectedIndexPathl.row] setValue:strON forKey:@"remember_last_color"];
    [tblView reloadData];
}
-(void)btnDeleteClick:(id)sender
{
    selectedIndexPathl = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    strRename = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"device_name"];
    strDeviceID = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"device_id"];
    globalDeviceHexId = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"hex_device_id"];
    strTableId = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"id"];
    
    NSString * msgStr = [NSString stringWithFormat:@"Are you sure. You want to delete this device ?"];
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    [alert addButton:@"Yes" withActionBlock:^{
        {
            [APP_DELEGATE startHudProcess:@"Removing Device..."];
            
            if ([IS_USER_SKIPPED isEqualToString:@"NO"] && ![[[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"device_type"] isEqual:@"4"])
            {
                if ([APP_DELEGATE isNetworkreachable])
                {
                    isRequestfor = @"DeleteDeviceCheck";
                    [self CheckUserCredentialDetials];
                }
            }
            else
            {
                if ([IS_USER_SKIPPED isEqualToString:@"NO"])
                {
                    if ([APP_DELEGATE isNetworkreachable])
                    {
                        isRequestfor = @"DeleteDeviceCheck";
                        [self CheckUserCredentialDetials];
                    }
                }

                [self performSelector:@selector(timeOutForDeleteDevice) withObject:nil afterDelay:5];
                // Put your action here
                if ([sectionArr count]> selectedIndexPathl.row)
                {
                    syncedDeletedListArr = [[NSMutableArray alloc] init];
                    
                    if ([[[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"device_type"] isEqual:@"4"])
                    {
                        if ([sectionArr count]> selectedIndexPathl.row)
                        {
                            [self deleteSocketDevice:selectedIndexPathl];
                        }
                    }
                    else
                    {
                        [self removeDevice];
                        if ([sectionArr count]> selectedIndexPathl.row)
                        {
                            syncedDeletedListArr = [[NSMutableArray alloc] init];
                            NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set status ='2',is_sync = '0' where device_id = '%@'",strDeviceID];
                            [[DataBaseManager dataBaseManager] execute:strUpdate];
                            [syncedDeletedListArr addObject:strDeviceID];
                            
                            if ([sectionArr count] > selectedIndexPathl.row)
                            {
                                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                                dict = [sectionArr objectAtIndex:selectedIndexPathl.row];
                                [dict setObject:@"0" forKey:@"status"];
                                [self SaveDeviceDetailstoServer:dict];
                                
                                [sectionArr removeObjectAtIndex:selectedIndexPathl.row];
                                [tblView reloadData];
                            }
                            self.expandingIndexPathGroup = nil;
                            self.expandedIndexPathGroup = nil;
                            self.expandingIndexPath = nil;
                            self.expandedIndexPath = nil;
                            
                            if ([sectionArr count]>0)
                            {
                                noMsgView.hidden = YES;
                            }
                            else
                            {
                                noMsgView.hidden = NO;
                            }
                            [APP_DELEGATE hudEndProcessMethod];

                            FCAlertView *alert = [[FCAlertView alloc] init];
                            alert.colorScheme = [UIColor blackColor];
                            [alert makeAlertTypeSuccess];
                            [alert showAlertInView:self
                                         withTitle:@"Smart Light"
                                      withSubtitle:@"Device has been removed successfully."
                                   withCustomImage:[UIImage imageNamed:@"logo.png"]
                               withDoneButtonTitle:nil
                                        andButtons:nil];
                        }
                    }
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
-(void)deleteSocketDevice:(NSIndexPath*)selectedIndex
{
    NSString * strBleAddress = [[[sectionArr objectAtIndex:selectedIndex.row] valueForKey:@"ble_address"] uppercaseString];
    NSString * strUpdate = [NSString stringWithFormat:@"update Device_Table set status ='2',is_sync = '0', wifi_configured = '0' where ble_address = '%@'",strBleAddress];
    [[DataBaseManager dataBaseManager] execute:strUpdate];
    
    NSString * strDeleteAlarm = [NSString stringWithFormat:@"delete from Socket_Alarm_Table where ble_address ='%@'",strBleAddress];
    [[DataBaseManager dataBaseManager] execute:strDeleteAlarm];

    if ([sectionArr count] > selectedIndexPathl.row)
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        dict = [sectionArr objectAtIndex:selectedIndexPathl.row];
        [dict setObject:@"0" forKey:@"status"];
        [self SaveDeviceDetailstoServer:dict];
        [APP_DELEGATE hudEndProcessMethod];
        
        [sectionArr removeObjectAtIndex:selectedIndexPathl.row];
        [tblView reloadData];
    }
    self.expandingIndexPathGroup = nil;
    self.expandedIndexPathGroup = nil;
    self.expandingIndexPath = nil;
    self.expandedIndexPath = nil;
    
    if ([sectionArr count]>0)
    {
        noMsgView.hidden = YES;
    }
    else
    {
        noMsgView.hidden = NO;
    }
    
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

    [APP_DELEGATE hudEndProcessMethod];
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    [alert showAlertInView:self
                 withTitle:@"Power socket"
              withSubtitle:@"Device has been deleted successfully."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];


}

-(void)btnGroupDeleteClick:(id)sender
{
    groupSentCount = 0;
    groupSyncCount = 0;
    selectedIndexPathl = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    if ([groupsArr count]> selectedIndexPathl.row-1)
    {
        strRename = [[groupsArr objectAtIndex:selectedIndexPathl.row-1] valueForKey:@"group_name"];
        strDeviceID = [[groupsArr objectAtIndex:selectedIndexPathl.row-1] valueForKey:@"local_group_id"];
        strTableId = [[groupsArr objectAtIndex:selectedIndexPathl.row-1] valueForKey:@"local_group_id"];
    }
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    [alert addButton:@"Yes" withActionBlock:^{
        [APP_DELEGATE startHudProcess:@"Removing Room..."];
        if ([IS_USER_SKIPPED isEqualToString:@"NO"])
        {
            if ([APP_DELEGATE isNetworkreachable])
            {
                isRequestfor = @"DeleteGroupCheck";
                [self CheckUserCredentialDetials];
            }
        }
        else
        {
            if ([groupsArr count]> selectedIndexPathl.row)
            {
                isDashScanning = YES;
                isAction = @"RemoveGroup";
                strGlogalNotify = @"Dashboard";
                NSString * strQuery = [NSString stringWithFormat:@"Select * from Group_Details_Table where group_id ='%@' and status = '1'",strDeviceID];
                tmpGroupArr = [[NSMutableArray alloc] init];
                syncedDeletedListArr = [[NSMutableArray alloc] init];
                [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:tmpGroupArr];
                [self sendDeviceonebyone];
            }
        }
    }];
    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Are you sure. You want to delete this Room ?"
           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
       withDoneButtonTitle:@"No" andButtons:nil];
}

#pragma mark- UITableView Methods
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 60;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * foot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 60)];
    foot.backgroundColor = [UIColor clearColor];
    return foot;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * foot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 1)];
    foot.backgroundColor = [UIColor clearColor];
    return foot;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblView)
    {
        if (isForGroup)
        {
            return [groupsArr count]+1;
        }
        else
        {
            return [sectionArr count];
        }
        return 0;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView  == tblView)
    {
        if (isForGroup)
        {
            if (indexPath.row == 0)
            {
                return 65;
            }
            else
            {
                if ([[[groupsArr objectAtIndex:indexPath.row] valueForKey:@"isExpanded"] isEqual:@"0"])
                {
                    return 65;
                }
                else
                {
                    return 110;
                }
            }
        }
        else
        {
            if ([[[sectionArr objectAtIndex:indexPath.row] valueForKey:@"device_type"] isEqual:@"4"])
            {
                if ([[[sectionArr objectAtIndex:indexPath.row] valueForKey:@"isExpanded"] isEqual:@"1"])
                {
                    return 110;
                }
                else
                {
                    return 65;
                }
            }
            else
            {
                if ([[[sectionArr objectAtIndex:indexPath.row] valueForKey:@"switch_status"] isEqualToString:@"Yes"])
                {
                    if ([[[sectionArr objectAtIndex:indexPath.row] valueForKey:@"isExpanded"] isEqual:@"1"])
                    {
                        return 140;
                    }
                    else
                    {
                        return 100;
                    }
                }
                else
                {
                    if ([[[sectionArr objectAtIndex:indexPath.row] valueForKey:@"isExpanded"] isEqual:@"1"])
                    {
                        return 100;
                    }
                    else
                    {
                        return 70;
                    }
                }
            }
        }
    }
    return 65;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView  == tblView)
    {
        static NSString *cellIdentifier = nil;
        if (isForGroup) //  New custemGrouop cell
        {
            NewCustomGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell==nil)
            {
                cell = [[NewCustomGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor blackColor];
            cell._switchLight.delegate = self;
            cell._switchLight.tag = indexPath.row;
            cell.btnEdit.tag = indexPath.row;
            cell.btnDelete.tag = indexPath.row;
            cell.btnFav.tag = indexPath.row;
            cell.btnMore.tag = indexPath.row;
            
            cell.lblName.textColor = UIColor.whiteColor;
            
            [cell.btnEdit addTarget:self action:@selector(btnRenameClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnFav addTarget:self action:@selector(btnFavouriteClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnMore addTarget:self action:@selector(btnMoreClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnDelete addTarget:self action:@selector(btnGroupDeleteClick:) forControlEvents:UIControlEventTouchUpInside];
            cell.lblName.textColor = UIColor.whiteColor;
            [cell.imgBulb setImage:[UIImage imageNamed:@"default_group_icon.png"]];
            
            if (indexPath.row==0)
            {
                [self CellforAllDevices:cell WithIndexPath:indexPath];
            }
            else
            {
                [self CellforGroups:cell WithIndexPath:indexPath];
            }
            
            if (indexPath.row == 0)
            {
                cell.gradient.colors = @[(id)[UIColor colorWithRed:138.0/255.0 green:35.0/255.0 blue:135.0/255.0 alpha:1].CGColor, (id)[UIColor colorWithRed:233.0/255.0 green:64.0/255.0 blue:87.0/255.0 alpha:1].CGColor,(id)[UIColor colorWithRed:242.0/255.0 green:113.0/255.0 blue:33.0/255.0 alpha:1].CGColor];
            }
            else if (indexPath.row % 2 == 0)
            {
                cell.gradient.colors = @[(id)[UIColor colorWithRed:138.0/255.0 green:35.0/255.0 blue:135.0/255.0 alpha:1].CGColor, (id)[UIColor colorWithRed:66.0/255.0 green:134.0/255.0 blue:244.0/255.0 alpha:1].CGColor];
            }
            else
            {
                cell.gradient.colors = @[(id)[UIColor colorWithRed:66.0/255.0 green:134.0/255.0 blue:244.0/255.0 alpha:1].CGColor, (id)[UIColor colorWithRed:138.0/255.0 green:35.0/255.0 blue:135.0/255.0 alpha:1].CGColor];
            }
            cell.gradient.frame = cell.lblBack.bounds;
            cell.imgBulb.image = [UIImage imageNamed:@"default_group_icon.png"];
            return cell;
        }
        else //  dashboard New cell use
        {
            DashboardNewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell==nil)
            {
                cell = [[DashboardNewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
            cell._switchLight.delegate = self;
            cell._switchLight.tag = indexPath.row;
            cell.btnEdit.tag = indexPath.row;
            cell.btnDelete.tag = indexPath.row;
            cell.btnFav.tag = indexPath.row;
            cell.lblName.textColor = UIColor.whiteColor;
            cell.btnMore.tag = indexPath.row;
            cell.brightnessSlider.tag = indexPath.row;
            
            cell.lblName.text = [[sectionArr objectAtIndex:indexPath.row] valueForKey:@"device_name"];

            [cell.btnEdit addTarget:self action:@selector(btnRenameClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnFav addTarget:self action:@selector(btnFavouriteClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnMore addTarget:self action:@selector(btnMoreClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnDelete addTarget:self action:@selector(btnDeleteClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnSettings addTarget:self action:@selector(btnSettingsClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.brightnessSlider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
            
            if ([[[sectionArr objectAtIndex:indexPath.row] valueForKey:@"device_type"] isEqual:@"4"])
            {
                [self CellforSocket:cell WithIndexPath:indexPath];
            }
            else
            {
                [self CellforSmartLights:cell WithIndexPath:indexPath];
            }
            

            if ([[[sectionArr objectAtIndex:indexPath.row] valueForKey:@"is_favourite"] isEqualToString:@"1"])
            {
                [cell.btnFav setImage:[UIImage imageNamed:@"active_favorite_icon.png"] forState:UIControlStateNormal];
            }
            else
            {
                [cell.btnFav setImage:[UIImage imageNamed:@"favorite_icon-1.png"] forState:UIControlStateNormal];
            }

            if (![[self checkforValidString:[[sectionArr objectAtIndex:indexPath.row] valueForKey:@"brightnessValue"]] isEqualToString:@"NA"])
            {
                double brightLabel = [[[sectionArr objectAtIndex:indexPath.row] valueForKey:@"brightnessValue"] floatValue];
                cell.brightnessSlider.value = brightLabel;
            }
            
            NSString * strType = [[sectionArr objectAtIndex:indexPath.row] valueForKey:@"device_type"];
            cell.imgBulb.image = [UIImage imageNamed:[self getImageName:strType]];
            
            if (indexPath.row == 0  || indexPath.row % 2 == 0)
            {
                cell.gradient.colors = @[(id)[UIColor colorWithRed:50.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.6].CGColor, (id)global_brown_color.CGColor];
            }
            else
            {
                cell.gradient.colors = @[(id)global_brown_color.CGColor, (id)[UIColor colorWithRed:50.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.6].CGColor];
            }
            cell.gradient.frame = cell.lblBack.bounds;
            return cell;
        }
    }
    return 0;
}
-(void)CellforAllDevices:(NewCustomGroupCell *)cell WithIndexPath:(NSIndexPath *)indexx
{
    cell.lblName.text = @"All Samrt light's";//@"All Devices"
    cell._switchLight.tag = 123;
    cell._switchLight.frame = CGRectMake(DEVICE_WIDTH-110+30+15, 0+10, 60, 40);
    cell.lblBack.frame = CGRectMake(4, 0,DEVICE_WIDTH-8,60);

    cell.btnMore.hidden = YES;
    cell.imgMore.hidden = YES;
    cell.lblLine.hidden = YES;
    cell.optionView.hidden = YES; // css commnected
    
    if (isAlldevicePowerOn)
    {
        [cell._switchLight setIsOn:YES];
        [cell._switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
    }
    else
    {
        [cell._switchLight setIsOn:NO];
        [cell._switchLight setCustomKnobImage:[UIImage imageNamed:@"off_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
    }
}
-(void)CellforGroups:(NewCustomGroupCell *)cell WithIndexPath:(NSIndexPath *)indexx
{
    cell.btnMore.hidden = NO;
    cell.imgMore.hidden = NO;
    cell._switchLight.frame = CGRectMake(DEVICE_WIDTH-110+15, 0+10, 60, 40);
    
    if ([groupsArr count]==0)
    {
    }
    else
    {
        cell.optionView.hidden = YES;
        cell.lblBack.frame = CGRectMake(4, 0,DEVICE_WIDTH-8,60);
        cell.lblLine.hidden = YES;
        cell.lblName.text = [[groupsArr objectAtIndex:indexx.row-1] valueForKey:@"group_name"];
        if ([[[groupsArr objectAtIndex:indexx.row-1] valueForKey:@"switch_status"] isEqualToString:@"Yes"])
        {
            [cell._switchLight setIsOn:YES];
            [cell._switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
        }
        else
        {
            [cell._switchLight setIsOn:NO];
            [cell._switchLight setCustomKnobImage:[UIImage imageNamed:@"off_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
        }
        
        if ([[[groupsArr objectAtIndex:indexx.row-1] valueForKey:@"is_favourite"] isEqualToString:@"1"])
        {
            [cell.btnFav setImage:[UIImage imageNamed:@"active_favorite_icon.png"] forState:UIControlStateNormal];
        }
        else
        {
            [cell.btnFav setImage:[UIImage imageNamed:@"favorite_icon-1.png"] forState:UIControlStateNormal];
        }
    }
}

-(void)CellforSocket:(DashboardNewCell *)cell WithIndexPath:(NSIndexPath *)indexx
{
    cell.brightnessSlider.hidden = true;
    cell.imgLowBrightness.hidden = true;
    cell.imgFullBrightness.hidden = true;

    if ([[[sectionArr objectAtIndex:indexx.row] valueForKey:@"isExpanded"] isEqualToString:@"1"])
    {
        cell.optionView.hidden = NO;
        cell.lblLine.hidden = NO;
        cell.lblBack.frame = CGRectMake(4, 0,DEVICE_WIDTH-8,100);
        cell.lblLine.frame = CGRectMake(4, 59.5, DEVICE_WIDTH-8, 0.5);
        cell.optionView.frame = CGRectMake(4, 60, DEVICE_WIDTH-8, 40);
        cell.btnSettings.tag = indexx.row;
    }
    else
    {
        cell.lblBack.frame = CGRectMake(4, 0,DEVICE_WIDTH-8,60);
        cell.optionView.hidden = YES;
        cell.lblLine.hidden = YES;
        cell.btnSettings.tag = indexx.row;
    }
    
    if ([[[sectionArr objectAtIndex:indexx.row] allKeys] containsObject:@"switch_status"])
    {
        if ([[[sectionArr objectAtIndex:indexx.row] valueForKey:@"switch_status"] isEqualToString:@"Yes"])
        {
            [cell._switchLight setIsOn:YES];
            [cell._switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
        }
        else
        {
            [cell._switchLight setIsOn:NO];
            [cell._switchLight setCustomKnobImage:[UIImage imageNamed:@"off_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
        }
    }

}
-(void)CellforSmartLights:(DashboardNewCell *)cell WithIndexPath:(NSIndexPath *)indexx
{
    cell.optionView.hidden = NO;
    cell.lblLine.hidden = NO;
    cell.lblBack.frame = CGRectMake(4, 0,DEVICE_WIDTH-8,140);
    cell.lblLine.frame = CGRectMake(4, 90.5, DEVICE_WIDTH-18, 0.5);
    cell.optionView.frame = CGRectMake(4, 90, DEVICE_WIDTH-14, 40);
    cell.brightnessSlider.hidden = NO;
    cell.imgLowBrightness.hidden = NO;
    cell.imgFullBrightness.hidden = NO;

    if ([[[sectionArr objectAtIndex:indexx.row] valueForKey:@"switch_status"] isEqualToString:@"Yes"])
    {
        if ([[[sectionArr objectAtIndex:indexx.row] valueForKey:@"isExpanded"] isEqualToString:@"1"])
        {
            cell.lblBack.frame = CGRectMake(4, 0,DEVICE_WIDTH-8,130);
            cell.optionView.hidden = NO;
            cell.lblLine.hidden = NO;
        }
        else
        {
            cell.optionView.hidden = YES;
            cell.lblBack.frame = CGRectMake(4, 0,DEVICE_WIDTH-8,90);
            cell.lblLine.hidden = YES;
        }
    }
    else
    {
        if ([[[sectionArr objectAtIndex:indexx.row] valueForKey:@"isExpanded"] isEqualToString:@"1"])
        {
            cell.lblBack.frame = CGRectMake(4, 0,DEVICE_WIDTH-8,90);
            cell.optionView.hidden = NO;
            cell.lblLine.hidden = NO;
        }
        else
        {
            cell.optionView.hidden = YES;
            cell.lblBack.frame = CGRectMake(4, 0,DEVICE_WIDTH-8,60);
            cell.lblLine.hidden = YES;
        }
    }
    cell.lblName.text = [[sectionArr objectAtIndex:indexx.row] valueForKey:@"device_name"];

    if ([[[sectionArr objectAtIndex:indexx.row] valueForKey:@"switch_status"] isEqualToString:@"Yes"])
    {
        [cell._switchLight setIsOn:YES];
        [cell._switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
        
        cell.brightnessSlider.hidden = false;
        cell.imgFullBrightness.hidden = false;
        cell.imgLowBrightness.hidden = false;
        
        cell.lblLine.frame = CGRectMake(7, 59.5+30, DEVICE_WIDTH-14, 0.5);
        cell.optionView.frame = CGRectMake(7, 60+30, DEVICE_WIDTH-14, 40);
    }
    else
    {
        [cell._switchLight setIsOn:NO];
        [cell._switchLight setCustomKnobImage:[UIImage imageNamed:@"off_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
        
        cell.brightnessSlider.hidden = true;
        cell.imgFullBrightness.hidden = true;
        cell.imgLowBrightness.hidden = true;
        
        cell.lblLine.frame = CGRectMake(7, cell.brightnessSlider.frame.size.height-0.5, DEVICE_WIDTH-14, 0.5);
        cell.optionView.frame = CGRectMake(7, cell.brightnessSlider.frame.size.height, DEVICE_WIDTH-14, 40);
    }

}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (tableView  == tblView)
    {
        cell.backgroundColor = [UIColor clearColor];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (tableView  == tblView)
    {
        strGlogalNotify = @"Dashboard";
        isAll = NO;
        
        if (previouIndex)
        {
            SWTableViewCell *cell = (SWTableViewCell *)[(UITableView *)tblView cellForRowAtIndexPath:previouIndex];
            [cell centerView:previouIndex.row];
        }
        
        selectedIndexPathl = indexPath;
        if (isForGroup)
        {
            if (selectedIndexPathl.row == 0)
            {
                [self btnHeaderClick];
            }
            else
            {
                selectedDict = [[NSMutableDictionary alloc] init];
                selectedDict = [groupsArr objectAtIndex:indexPath.row-1];
                globalGroupId  = [NSString stringWithFormat:@"%@",[selectedDict valueForKey:@"local_group_id"]];
                
                DeviceDetailVC * detailVC = [[DeviceDetailVC alloc] init];
                detailVC.deviceDict = selectedDict;
                detailVC.isfromGroup = isForGroup;
                
                if ([[selectedDict valueForKey:@"device_type"] isEqualToString:@"2"])
                {
                    detailVC.isDeviceWhite = YES;
                }
                [self.navigationController pushViewController:detailVC animated:YES];
            }
        }
        else
        {
            selectedDict = [[NSMutableDictionary alloc] init];
            selectedDict = [sectionArr objectAtIndex:indexPath.row];
            globalGroupId  = [NSString stringWithFormat:@"%@",[selectedDict valueForKey:@"device_id"]];
            
            if ([[[sectionArr objectAtIndex:indexPath.row] valueForKey:@"device_type"] isEqual:@"4"])
            {
                globalSocketDetailVC  = [[SocketDetailVC alloc] init];
                globalSocketDetailVC.deviceDetail = selectedDict;
                globalSocketDetailVC.delegate = self;
                
                if ([[arrSocketDevices valueForKey:@"ble_address"] containsObject:[selectedDict objectForKey:@"ble_address"]])
                {
                    NSInteger foundindex = [[arrSocketDevices valueForKey:@"ble_address"] indexOfObject:[selectedDict objectForKey:@"ble_address"]];
                    if (foundindex != NSNotFound)
                    {
                        if ([arrSocketDevices count] > foundindex)
                        {
                            if ([[arrSocketDevices objectAtIndex:foundindex] objectForKey:@"peripheral"])
                            {
                                CBPeripheral * p = [[arrSocketDevices objectAtIndex:foundindex] objectForKey:@"peripheral"];
                                globalSocketDetailVC.classPeripheral = p;
                            }
                        }
                    }
                }
                
//                if ([[selectedDict valueForKey:@"wifi_configured"] isEqualToString:@"1"])
//                {
                    if (mqttObj)
                    {
                        globalSocketDetailVC.classMqttObj = mqttObj;
                    }
//                }
                [self.navigationController pushViewController:globalSocketDetailVC animated:true];
            }
            else
            {
                DeviceDetailVC *detailVC  = [[DeviceDetailVC alloc] init];
                [self.navigationController pushViewController:detailVC animated:YES];
            }
        }
    }
}
#pragma mark- ORB SWITCH ON OFF METHOD
- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue
{
    if (switchObj.tag==123)
    {
        tmpSwtch = switchObj;
        [self switchOffDevice:@"0" withType:newValue];
        isAlldevicePowerOn = newValue;
        NSIndexPath * tmpIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        CustomGroupCell * cell = (CustomGroupCell *)[tblView cellForRowAtIndexPath:tmpIndex];
        
        if (newValue)
        {
            cell.imgBulb.layer.shadowColor = [[UIColor grayColor] CGColor];
            cell.imgBulb.layer.shadowRadius = 4.0f;
            cell.imgBulb.layer.shadowOpacity = .9;
            cell.imgBulb.layer.shadowOffset = CGSizeZero;
            cell.imgBulb.layer.masksToBounds = NO;
        }
        else
        {
            cell.imgBulb.layer.shadowColor = [[UIColor clearColor] CGColor];
            cell.imgBulb.layer.shadowRadius = 1.0f;
            cell.imgBulb.layer.shadowOpacity = 1.0;
            cell.imgBulb.layer.shadowOffset = CGSizeZero;
            cell.imgBulb.layer.masksToBounds = YES;
        }
    }
    else
    {
        NSIndexPath * tmpIndex = [NSIndexPath indexPathForRow:switchObj.tag inSection:0];
        
        switchIndex = tmpIndex;
        NSString * deviceID = @"NA";
       
        if (isForGroup)
        {
            NewCustomGroupCell * cell = (NewCustomGroupCell *)[tblView cellForRowAtIndexPath:tmpIndex];

            if (newValue)
            {
                cell.imgBulb.layer.shadowColor = [[UIColor grayColor] CGColor];
                cell.imgBulb.layer.shadowRadius = 4.0f;
                cell.imgBulb.layer.shadowOpacity = .9;
                cell.imgBulb.layer.shadowOffset = CGSizeZero;
                cell.imgBulb.layer.masksToBounds = NO;
            }
            else
            {
                cell.imgBulb.layer.shadowColor = [[UIColor clearColor] CGColor];
                cell.imgBulb.layer.shadowRadius = 1.0f;
                cell.imgBulb.layer.shadowOpacity = 1.0;
                cell.imgBulb.layer.shadowOffset = CGSizeZero;
                cell.imgBulb.layer.masksToBounds = YES;
            }
            deviceID = [[groupsArr objectAtIndex:tmpIndex.row-1] valueForKey:@"local_group_id"];
        }
        else
        {
            DashboardNewCell *cell = (DashboardNewCell *)[tblView cellForRowAtIndexPath:tmpIndex];//            CustomTableViewCell *cell = (CustomTableViewCell *)[tblView cellForRowAtIndexPath:tmpIndex];

            if ([sectionArr count] > tmpIndex.row)
            {
                if ([[[sectionArr objectAtIndex:tmpIndex.row] valueForKey:@"device_type"] isEqualToString:@"4"])
                {
                    [self SocketMainSwitchTurnOnOff:[sectionArr objectAtIndex:tmpIndex.row] withSwitchStatus:newValue];

                }
            }
            if (newValue)
            {
                cell.imgBulb.layer.shadowColor = [[UIColor grayColor] CGColor];
                cell.imgBulb.layer.shadowRadius = 4.0f;
                cell.imgBulb.layer.shadowOpacity = .9;
                cell.imgBulb.layer.shadowOffset = CGSizeZero;
                cell.imgBulb.layer.masksToBounds = NO;
            }
            else
            {
                cell.imgBulb.layer.shadowColor = [[UIColor clearColor] CGColor];
                cell.imgBulb.layer.shadowRadius = 1.0f;
                cell.imgBulb.layer.shadowOpacity = 1.0;
                cell.imgBulb.layer.shadowOffset = CGSizeZero;
                cell.imgBulb.layer.masksToBounds = YES;
            }
            deviceID = [[sectionArr objectAtIndex:tmpIndex.row] valueForKey:@"device_id"];
        }
        tmpSwtch = switchObj;
        if (![deviceID isEqualToString:@"NA"])
        {
            [self switchOffDevice:deviceID withType:newValue];
        }
    }
}
- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj
{
    [switchObj setCustomKnobImage:[UIImage imageNamed:(switchObj.isOn) ? @"on_icon" : @"off_icon"]
          inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]
            activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
}
-(void)stopIndicator
{
    [APP_DELEGATE hideScannerView];
    [APP_DELEGATE endHudProcess];
}
-(BOOL)isConnectionAvail
{
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        return YES;
    }
    else
    {
        if ([[[BLEManager sharedManager] getLastConnected] count]>0)
        {
            if (globalPeripheral.state == CBPeripheralStateConnected)
            {
                return YES;
            }
            else
            {
                [APP_DELEGATE showScannerView:@"Connecting..."];
                if (globalPeripheral)
                {
                }
                else
                {
                    isNonConnectScanning = NO;
                    [[BLEManager sharedManager] updateBluetoothState];
                }
                [tmpSwtch setCustomKnobImage:[UIImage imageNamed:(tmpSwtch.isOn) ? @"off_icon" : @"on_icon"]
                     inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]
                       activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
                [tmpSwtch setIsOn:NO];
                return NO;
            }
        }
        else
        {
            [APP_DELEGATE showScannerView:@"Connecting..."];
            if (globalPeripheral)
            {
            }
            else
            {
                isNonConnectScanning = NO;
                [[BLEManager sharedManager] updateBluetoothState];
            }
            [tmpSwtch setCustomKnobImage:[UIImage imageNamed:(tmpSwtch.isOn) ? @"off_icon" : @"on_icon"]
                 inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]
                   activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
            [tmpSwtch setIsOn:NO];
            return NO;
        }
    }
    return NO;
}
#pragma mark - CleanUp
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Webservice Methods
-(void)getAllDevices
{
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"is_first_time_called"] isEqualToString:@"Yes"])
    {
    }
    else
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Getting information...."];
    }
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"GetallDevices";
    manager.delegate = self;
    NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/get_all_device";
    [manager urlCall:strServerUrl withParameters:dict];
}

-(void)getAllGroups
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"GetallGroupss";
    manager.delegate = self;
    NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/get_all_group";
    [manager urlCall:strServerUrl withParameters:dict];
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
/*Save Install records to Server*/
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
                    [args setObject:[self checkforValidString:[inforDict valueForKey:@"wifi_configured"]] forKey:@"wifi_configured"];

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
-(void)SaveGroupsDetailstoServer:(NSMutableDictionary *)inforDict
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        if ([IS_USER_SKIPPED isEqualToString:@"NO"])
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                {
                    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
                    [args setValue:CURRENT_USER_ID forKey:@"user_id"];
                    [args setValue:[inforDict valueForKey:@"local_group_id"] forKey:@"local_group_id"];
                    [args setValue:[inforDict valueForKey:@"local_group_hex_id"] forKey:@"local_group_hex_id"];
                    [args setValue:[inforDict valueForKey:@"group_name"] forKey:@"group_name"];
                    [args setValue:[inforDict valueForKey:@"status"] forKey:@"status"];
                    [args setValue:[inforDict valueForKey:@"is_favourite"] forKey:@"is_favourite"];
                    [args setValue:@"1" forKey:@"is_update"];
                    NSString *deviceToken =deviceTokenStr;
                    if (deviceToken == nil || deviceToken == NULL)
                    {
                        [args setValue:@"123456789" forKey:@"device_token"];
                    }
                    else
                    {
                        [args setValue:deviceToken forKey:@"device_token"];
                    }
                    if ([[inforDict valueForKey:@"is_added_firsttime"] isEqualToString:@"1"])
                    {
                        [args setValue:@"0" forKey:@"is_update"];
                    }
                    //            devices
                    NSString * str =[NSString stringWithFormat:@"Select server_device_id from Group_Details_Table where group_id ='%@'",[inforDict valueForKey:@"local_group_id"]];
                    NSMutableArray * tmparr =[[NSMutableArray alloc] init];
                    [[DataBaseManager dataBaseManager] execute:str resultsArray:tmparr];
                    
                    NSString * deviceStr = [tmparr componentsJoinedByString:@","];
                    [args setValue:deviceStr forKey:@"devices"];
                    
                    AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
                    //[manager1.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
                    NSString *token=[[NSUserDefaults standardUserDefaults]valueForKey:@"globalCode"];
                    NSString *authorization = [NSString stringWithFormat: @"Basic %@",token];
                    [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
                    [manager1.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                    //manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
                    
                    AFHTTPRequestOperation *op = [manager1 POST:@"http://vithamastech.com/smartlight/api/save_group" parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject)
                                                  {
                        NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                        dictID = [responseObject mutableCopy];
                        if ([[dictID valueForKey:@"message"] isEqualToString:@"Group already deleted"])
                        {
                            NSString * strDeleteGroup = [NSString stringWithFormat:@"delete from GroupsTable where local_group_id = '%@'",[[dictID valueForKey:@"data"]valueForKey:@"local_group_id"]];
                            [[DataBaseManager dataBaseManager] execute:strDeleteGroup];
                        }
                        else
                        {
                            if ([dictID valueForKey:@"data"] == [NSNull null] || [dictID valueForKey:@"data"] == nil)
                            {
                            }
                            else
                            {
                                if ([[dictID valueForKey:@"data"] count]>0)
                                {
                                    NSString * strIDD = [[[dictID valueForKey:@"data"] objectAtIndex:0] valueForKey:@"local_group_id"];
                                    NSString * strUpdate = [NSString stringWithFormat:@"Update GroupsTable set is_sync ='1', is_added_firsttime = '2' where local_group_id='%@'",strIDD];
                                    [[DataBaseManager dataBaseManager] execute:strUpdate];
                                                                  
                                    NSString * strUpdateDetail = [NSString stringWithFormat:@"Update Group_Details_Table set is_sync ='1' where group_id='%@'",strIDD];
                                    [[DataBaseManager dataBaseManager] execute:strUpdateDetail];
                                                                  
                                }
                            }
                        }
                    }
                                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        if (error)
                        {
                            //      NSLog(@"Servicer error = %@", error);
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
-(void)SendUnsyncRecordsToServer
{
    NSString * str = [NSString stringWithFormat:@"Select * from Device_Table where user_id='%@' and is_sync='0' group by ble_address",CURRENT_USER_ID];
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:str resultsArray:tmpArr];
    
    if ([tmpArr count]>0)
    {
        if (deviceTriedCount < 10)
        {
            [self SaveDeviceDetailstoServer:[tmpArr objectAtIndex:0]];
            [self performSelector:@selector(SendUnsyncRecordsToServer) withObject:nil afterDelay:3];
            deviceTriedCount = deviceTriedCount + 1;
        }
    }
    else
    {
        [self SendUnsyncedGroupstoServer];
    }
}
-(void)SendUnsyncedGroupstoServer
{
    NSString * str = [NSString stringWithFormat:@"Select * from GroupsTable where user_id='%@' and is_sync='0'",CURRENT_USER_ID];
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:str resultsArray:tmpArr];
    
    bool isAllowed = YES;
    if ([tmpArr count]>0)
    {
        if (isAllowed)
        {
            strUnsyncedGroupId = [[tmpArr objectAtIndex:0] valueForKey:@"local_group_id"];
            [self SaveGroupsDetailstoServer:[tmpArr objectAtIndex:0]];
        }
        if ([currentScreen isEqualToString:@"Dashboard"])
        {
            if (groupTriedCount < 10)
            {
                [self performSelector:@selector(SendUnsyncedGroupstoServer) withObject:nil afterDelay:3];
                groupTriedCount = groupTriedCount + 1;
            }
        }
    }
    else
    {
        
    }
}

#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    NSLog(@"=======Result=======%@",result);
    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
    [APP_DELEGATE endHudProcess];
    if ([[result valueForKey:@"commandName"] isEqualToString:@"GetallDevices"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"flag"] isEqualToString:@"true"])
            {
                if([[result valueForKey:@"result"] valueForKey:@"data"]!=[NSNull null] || [[result valueForKey:@"result"] valueForKey:@"data"] != nil)
                {
                    NSMutableArray * arrTemp = [[NSMutableArray alloc] init];
                    arrTemp = [[result valueForKey:@"result"] valueForKey:@"data"];
                    if ([arrTemp count]>0)
                    {
                        for (int i = 0; i<[arrTemp count]; i++)
                        {
                            [self saveDeviceintoDatabase:[arrTemp objectAtIndex:i]];
                        }
                        [self getDatafromDatabase];
                    }
                }
                else
                {
                    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"is_first_time_called"] isEqualToString:@"Yes"])
                    {
                        
                    }
                    else
                    {
                        FCAlertView *alert = [[FCAlertView alloc] init];
                        alert.colorScheme = [UIColor blackColor];
                        [alert makeAlertTypeCaution];
                        [alert showAlertInView:self
                                     withTitle:@"Smart Light"
                                  withSubtitle:@"Something went wrong. Please try again later."
                               withCustomImage:[UIImage imageNamed:@"logo.png"]
                           withDoneButtonTitle:nil
                                    andButtons:nil];
                    }
                }
                if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"is_first_time_called"] isEqualToString:@"Yes"])
                {
                }
                else
                {
                    [[NSUserDefaults standardUserDefaults] setValue:@"Yes" forKey:@"is_first_time_called"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }
        else
        {
            NSString * strMsg = [[result valueForKey:@"result"] valueForKey:@"message"];
            if ([strMsg isEqualToString:@"No device found"])
            {
                NSString * strDelete = [NSString stringWithFormat:@"Delete from Device_Table where user_id = '%@'",CURRENT_USER_ID];
                [[DataBaseManager dataBaseManager] execute:strDelete];
                [sectionArr removeAllObjects];
                [tblView reloadData];
            }
            else
            {
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
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"GetallGroupss"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if([[result valueForKey:@"result"] valueForKey:@"group"]!=[NSNull null] || [[result valueForKey:@"result"] valueForKey:@"group"] != nil)
            {
                NSString * strDelete = [NSString stringWithFormat:@"Delete from GroupsTable where user_id = '%@' and is_sync = '1'",CURRENT_USER_ID];
                [[DataBaseManager dataBaseManager] execute:strDelete];
                
                NSString * strDeleteDetails = [NSString stringWithFormat:@"Delete from Group_Details_Table where user_id = '%@' and is_sync = '1' ",CURRENT_USER_ID];
                [[DataBaseManager dataBaseManager] execute:strDeleteDetails];
                
                NSMutableArray * arrTemp = [[NSMutableArray alloc] init];
                arrTemp = [[result valueForKey:@"result"] valueForKey:@"group"];
                if ([arrTemp count]>0)
                {
                    for (int i = 0; i<[arrTemp count]; i++)
                    {
                        [self saveGroupsinDatabase:[arrTemp objectAtIndex:i]];
                    }
                    [self getDatafromDatabase];
                }
            }
        }
        else
        {
            NSString * strMsg = [[result valueForKey:@"result"] valueForKey:@"message"];
            if ([strMsg isEqualToString:@"device group not found"])
            {
                NSString * strDelete = [NSString stringWithFormat:@"Delete from GroupsTable where user_id = '%@' and is_sync = '1'",CURRENT_USER_ID];
                [[DataBaseManager dataBaseManager] execute:strDelete];
                
                NSString * strDeleteDetails = [NSString stringWithFormat:@"Delete from Group_Details_Table where user_id = '%@' and is_sync = '1' ",CURRENT_USER_ID];
                [[DataBaseManager dataBaseManager] execute:strDeleteDetails];
                [groupsArr removeAllObjects];
                [tblView reloadData];
            }
            else
            {
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
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"CheckUserDetails"])
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
                /*[alert addButton:@"OK" withActionBlock:^{
                    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IS_USER_LOGGED"];
                    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IS_USER_SKIPPED"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self clearUserDefaults];
                    [APP_DELEGATE movetoLogin];
                    
                    NSString *strDelete;
                    strDelete = [NSString stringWithFormat:@"Delete from UserAccount_Table"];
                    [[DataBaseManager dataBaseManager] execute:strDelete];
                }];*/
            }
        }
        else
        {
            if ([isRequestfor isEqualToString:@"FirstCheck"])
            {
                
            }
            else if ([isRequestfor isEqualToString:@"DeleteDeviceCheck"])
            {
                NSLog(@"<-------onResult------>%@",result);


                if ([sectionArr count]> selectedIndexPathl.row)
                {
                    if ([[[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"device_type"] isEqual:@"4"])
                    {
                        return;
                    }
                    else
                    {
                        [APP_DELEGATE startHudProcess:@"Removing Device..."];
                        [self performSelector:@selector(timeOutForDeleteDevice) withObject:nil afterDelay:5];
                        // Put your action here

                        syncedDeletedListArr = [[NSMutableArray alloc] init];
                        [self removeDevice];
                        NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set status ='2',is_sync = '0' where device_id = '%@'",strDeviceID];
                        
                        [[DataBaseManager dataBaseManager] execute:strUpdate];

                        [syncedDeletedListArr addObject:strDeviceID];
                        
                        if ([sectionArr count] > selectedIndexPathl.row)
                        {
                            
                            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                            dict = [sectionArr objectAtIndex:selectedIndexPathl.row];
                            [dict setObject:@"0" forKey:@"status"];
                            [self SaveDeviceDetailstoServer:dict];
                            [APP_DELEGATE hudEndProcessMethod];
                            
                            [sectionArr removeObjectAtIndex:selectedIndexPathl.row];
                            [tblView reloadData];
                        }
                        self.expandingIndexPathGroup = nil;
                        self.expandedIndexPathGroup = nil;
                        self.expandingIndexPath = nil;
                        self.expandedIndexPath = nil;
                        
                        if ([sectionArr count]>0)
                        {
                            noMsgView.hidden = YES;
                        }
                        else
                        {
                            noMsgView.hidden = NO;
                        }
                        
                        FCAlertView *alert = [[FCAlertView alloc] init];
                        alert.colorScheme = [UIColor blackColor];
                        [alert makeAlertTypeSuccess];
                        [alert showAlertInView:self
                                     withTitle:@"Smart Light"
                                  withSubtitle:@"Device has been removed successfully."
                               withCustomImage:[UIImage imageNamed:@"logo.png"]
                           withDoneButtonTitle:nil
                                    andButtons:nil];

                    }
                }
            }
            else if ([isRequestfor isEqualToString:@"DeleteGroupCheck"])
            {
                [APP_DELEGATE startHudProcess:@"Removing Room..."];
                // Put your action here
                if ([groupsArr count] > selectedIndexPathl.row)
                {
                    isDashScanning = YES;
                    isAction = @"RemoveGroup";
                    strGlogalNotify = @"Dashboard";
                    
                    NSString * strQuery = [NSString stringWithFormat:@"Select * from Group_Details_Table where group_id ='%@' and status = '1'",strDeviceID];
                    tmpGroupArr = [[NSMutableArray alloc] init];
                    syncedDeletedListArr = [[NSMutableArray alloc] init];
                    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:tmpGroupArr];
                    [self sendDeviceonebyone];
                    
                }
            }
        }
    }
}
- (void)onError:(NSError *)error
{
    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];

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
#pragma mark - DATABASE Methods
-(void)getDatafromDatabase
{
    if (isForGroup)
    {
        groupsArr = [[NSMutableArray alloc] init];
        NSString * strQuery = [NSString stringWithFormat:@"Select * from GroupsTable where user_id ='%@' and status = '1' ORDER BY is_favourite ASC",CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:groupsArr];
        
        if ([groupsArr count]>0)
        {
            noMsgView.hidden = YES;
        }
        else
        {
            noMsgView.hidden = NO;
        }
    }
    else
    {
        sectionArr = [[NSMutableArray alloc] init];
        
        NSString * strQuery = [NSString stringWithFormat:@"Select * from Device_Table  where user_id ='%@' and status = '1' group by ble_address ORDER BY is_favourite ASC",CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:sectionArr];
        
        [sectionArr setValue:@"0" forKey:@"isExpanded"]; //css added

        for (int i = 0; i < [sectionArr count]; i ++)
        {

            if ([[[sectionArr objectAtIndex:i] valueForKey:@"device_type"] isEqualToString:@"4"])
            {
                NSString * strIdentifier = [self checkforValidString:[[sectionArr objectAtIndex:i] valueForKey:@"identifier"]];
                NSString * strBleAddress = [self checkforValidString:[[sectionArr objectAtIndex:i] valueForKey:@"ble_address"]];
                if ([[dictSocketSwitchStatus allKeys] containsObject:[strBleAddress uppercaseString]])
                {
                    NSString * strStatus = [self checkforValidString:[dictSocketSwitchStatus valueForKey:[strBleAddress uppercaseString]]];
                    if ([strStatus isEqualToString:@"56111111"])
                    {
                        [[sectionArr objectAtIndex:i] setValue:@"Yes" forKey:@"switch_status"];
                    }
                    else
                    {
                        [[sectionArr objectAtIndex:i] setValue:@"No" forKey:@"switch_status"];
                    }
                    
                }
//                [dictSocketSwitchStatus setValue:strStatus forKey:strAddress];

                CBPeripheral * p;

                if(![strIdentifier isEqualToString:@"NA"])
                {
                    NSArray * arrDevie = [[BLEManager sharedManager] getLastDiscoveredSocketDevices:strIdentifier];
                    if ([arrDevie count] > 0)
                    {
                         p = [arrDevie objectAtIndex:0];
                    }
                }
                if (p != nil)
                {
                    NSString * strPeripheralIdentifier = [NSString stringWithFormat:@"%@",p.identifier];
                    if (![[arrSocketDevices valueForKey:@"identifier"] containsObject:strPeripheralIdentifier])
                    {
                        [[sectionArr objectAtIndex:i] setObject:p forKey:@"peripheral"];
                        [arrSocketDevices addObject:[sectionArr objectAtIndex:i]];
                    }
                    else
                    {
                        NSInteger  foudIndex = [[arrSocketDevices valueForKey:@"ble_address"] indexOfObject:strBleAddress];
                        if (foudIndex != NSNotFound)
                        {
                            if ([arrSocketDevices count] > foudIndex)
                            {
                                NSMutableDictionary * dataDict = [arrSocketDevices objectAtIndex:foudIndex];
                                [dataDict setValue:p forKey:@"peripheral"];
                                [dataDict setValue:strBleAddress forKey:@"ble_address"];
                                [dataDict setValue:[NSString stringWithFormat:@"%@",p.identifier] forKey:@"identifier"];
                                [arrSocketDevices replaceObjectAtIndex:foudIndex withObject:dataDict];
                            }
                        }
                    }
                }
                else
                {
                    if (![[arrSocketDevices valueForKey:@"ble_address"] containsObject:strBleAddress])
                    {
                        [arrSocketDevices addObject:[sectionArr objectAtIndex:i]];
                    }
                }
            }
        }
        
        [self CheckSockectConnectionTimer];
        
        if ([sectionArr count]>0)
        {
            noMsgView.hidden = YES;
            tblView.hidden = NO;
        }
        else
        {
            noMsgView.hidden = NO;
            tblView.hidden = YES;
        }
    }
    NSLog(@"Database of Socket=%@",arrSocketDevices);
    [tblView reloadData];
}

-(void)saveDeviceintoDatabase:(NSMutableDictionary *)dictHistory
{
    NSString * strServerDeviceId = [self checkforValidString:[dictHistory valueForKey:@"server_device_id"]];
    NSString * strUserId = [self checkforValidString:[dictHistory valueForKey:@"user_id"]];
    NSString * strDeviceId = [self checkforValidString:[dictHistory valueForKey:@"device_id"]];
    NSString * strHexDeviceId = [self checkforValidString:[dictHistory valueForKey:@"hex_device_id"]];
    NSString * strDeviceName = [self checkforValidString:[dictHistory valueForKey:@"device_name"]];
    NSString * strBleAddress = [[self checkforValidString:[dictHistory valueForKey:@"ble_address"]] uppercaseString];
    NSString * strDeviceType = [self checkforValidString:[dictHistory valueForKey:@"device_type"]];
    NSString * strDeviceTypeName = [self checkforValidString:[dictHistory valueForKey:@"device_type_name"]];
    NSString * strIsFavorite = [self checkforValidString:[dictHistory valueForKey:@"is_favourite"]];
    NSString * strCreatedDate = [self checkforValidString:[dictHistory valueForKey:@"created_date"]];
    NSString * strUpdatedDate = [self checkforValidString:[dictHistory valueForKey:@"updated_date"]];
    NSString * strTimeStamp = [self checkforValidString:[dictHistory valueForKey:@"timestamp"]];
    NSString * strStatus = [self checkforValidString:[dictHistory valueForKey:@"status"]];
    
    NSString * selectStr  =[NSString stringWithFormat:@"Select * from Device_Table where user_id ='%@' and ble_address = '%@'",CURRENT_USER_ID,strBleAddress];
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:selectStr resultsArray:tmpArr];
    if ([tmpArr count]>0)
    {
        NSString *  strQuery =[NSString stringWithFormat:@"update 'Device_Table' set 'device_name' = \"%@\",'is_favourite' = \"%@\",'updated_at' = \"%@\", is_sync = '1', timestamp='%@','device_id'='%@','hex_device_id'='%@','status'='%@' where ble_address ='%@'",strDeviceName,strIsFavorite,strUpdatedDate,strTimeStamp,strDeviceId,strHexDeviceId,strStatus,strBleAddress];
        [[DataBaseManager dataBaseManager] execute:strQuery];
    }
    else
    {
        NSString * requestStr =[NSString stringWithFormat:@"insert into 'Device_Table'('server_device_id','device_id','hex_device_id','real_name','device_name','ble_address','device_type','device_type_name','user_id','is_favourite','created_at','updated_at','is_sync','timestamp','status','brightnessValue') values(\"%@\",\"%@\",'%@',\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",'1',\"%@\",\"%@\",\"%f\")",strServerDeviceId,strDeviceId,strHexDeviceId,strDeviceName,strDeviceName, strBleAddress,strDeviceType,strDeviceTypeName,strUserId,strIsFavorite,strCreatedDate,strUpdatedDate,strTimeStamp,strStatus,intBrightnessValue];
        [[DataBaseManager dataBaseManager] execute:requestStr];
    }
}

-(void)saveGroupsinDatabase:(NSMutableDictionary *)dictHistory
{
    NSString * strServerGroupId = [self checkforValidString:[dictHistory valueForKey:@"device_group_id"]];
    //    NSString * strUserId = [self checkforValidString:[dictHistory valueForKey:@"user_id"]];
    NSString * strLocalGroupId = [self checkforValidString:[dictHistory valueForKey:@"local_group_id"]];
    NSString * strLocalGroupHexId = [self checkforValidString:[dictHistory valueForKey:@"local_group_hex_id"]];
    NSString * strGroupName = [self checkforValidString:[dictHistory valueForKey:@"group_name"]];
    NSString * strIsFavorite = [self checkforValidString:[dictHistory valueForKey:@"is_favourite"]];
    NSString * strCreatedDate = [self checkforValidString:[dictHistory valueForKey:@"created_date"]];
    NSString * strStatus = [self checkforValidString:[dictHistory valueForKey:@"status"]];
    NSString * strTimeStamp = [self checkforValidString:[dictHistory valueForKey:@"timestamp"]];
    
    NSString * strGroup = [NSString stringWithFormat:@"insert into 'GroupsTable'('group_name','user_id','local_group_id','local_group_hex_id','server_group_id','status','switch_status','is_sync','is_favourite','created_date','timestamp') values('%@','%@','%@','%@','%@',\"%@\",\"%@\",'%@','%@','%@','%@')",strGroupName,CURRENT_USER_ID,strLocalGroupId,strLocalGroupHexId,strServerGroupId,strStatus,@"1",@"1",strIsFavorite,strCreatedDate,strTimeStamp];
    int groupTblID =  [[DataBaseManager dataBaseManager] executeSw:strGroup];
    NSString * strGrpTblID = [NSString stringWithFormat:@"%d",groupTblID];
    
    
    NSMutableArray * deviceArr = [[NSMutableArray alloc] init];
    deviceArr = [[dictHistory valueForKey:@"device_details"] mutableCopy];
    for (int i =0; i<[deviceArr count]; i++)
    {
        NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
        tmpDict = [deviceArr objectAtIndex:i];
        NSString * strServerDeviceId = [self checkforValidString:[tmpDict valueForKey:@"server_device_id"]];
        NSString * strDeviceId = [self checkforValidString:[tmpDict valueForKey:@"device_id"]];
        NSString * strHexDeviceId = [self checkforValidString:[tmpDict valueForKey:@"hex_device_id"]];
        NSString * strDeviceName = [self checkforValidString:[tmpDict valueForKey:@"device_name"]];
        NSString * strBleAddress = [[self checkforValidString:[tmpDict valueForKey:@"ble_address"]] uppercaseString];
        NSString * strDeviceType = [self checkforValidString:[tmpDict valueForKey:@"device_type"]];
        NSString * strDeviceTypeName = [self checkforValidString:[tmpDict valueForKey:@"device_type_name"]];
        NSString * strDeviceStatus = [self checkforValidString:[tmpDict valueForKey:@"status"]];
        
        NSString * insrtStr = [NSString stringWithFormat:@"insert into 'Group_Details_Table'('group_table_id','group_id','device_id','hex_device_id','ble_address','device_type','device_type_name','user_id','status','device_name','server_device_id') values('%@','%@','%@','%@',\"%@\",\"%@\",'%@','%@','%@','%@','%@')",strGrpTblID,strLocalGroupId,strDeviceId,strHexDeviceId,strBleAddress,strDeviceType, strDeviceTypeName,CURRENT_USER_ID,strDeviceStatus,strDeviceName,strServerDeviceId];
        [[DataBaseManager dataBaseManager] execute:insrtStr];
        
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
-(NSString *)getImageName:(NSString *)strType
{
    NSString * strImgName = @"default_pic.png";
    
    if ([strType isEqualToString:@"1"])
    {
        strImgName= @"default_pic.png";
    }
    else if ([strType isEqualToString:@"2"])
    {
        strImgName= @"default_pic.png";
    }
    else if ([strType isEqualToString:@"3"])
    {
        strImgName= @"default_switch_icon.png";
    }
    else if ([strType isEqualToString:@"4"])
    {
        strImgName= @"default_powerstrip_icon.png";
    }
    else if ([strType isEqualToString:@"5"])
    {
        strImgName= @"default_fan_icon.png";
    }
    else if ([strType isEqualToString:@"6"])
    {
        strImgName= @"default_striplight_icon.png";
    }
    else if ([strType isEqualToString:@"7"])
    {
        strImgName= @"default_lamp.png";
    }
    else if ([strType isEqualToString:@"8"])
    {
        strImgName= @"default_powerstrip_icon.png";
    }
    return strImgName;
}



#pragma mark - All Popup Methods & Delegate
-(void)timeOutForDeleteDevice
{
    [APP_DELEGATE endHudProcess];
    if ([isAction isEqualToString:@"DeviceDeleted"])
    {
        
    }
    else
    {
        /*NSString * strMsg = [NSString stringWithFormat:@"Something went wrong. Please try again."];
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:strMsg
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];*/
    }
}
-(void)BLEConnectionErrorPopup
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

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
    if (alertView.tag == 123)
    {
    }
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 123)
    {
        [self ValidationforAddedMessage:strUpdatedName];
    }
    else if (alertView.tag == 345)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IS_USER_LOGGED"];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IS_USER_SKIPPED"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self clearUserDefaults];
        [APP_DELEGATE movetoLogin];
        
        NSString *strDelete;
        strDelete = [NSString stringWithFormat:@"Delete from UserAccount_Table"];
        [[DataBaseManager dataBaseManager] execute:strDelete];

    }
}

- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
}
-(void)ValidationforAddedMessage:(NSString *)text
{
    if ([[self checkforValidString:text] isEqualToString:@"NA"])
    {
        [self showErrorMessage:@"Please enter valid name."];
    }
    else
    {
        NSString * strDelete = [NSString stringWithFormat:@"Update Device_Table set device_name='%@',is_sync='0' where id = '%@'",strUpdatedName,strTableId];
        [[DataBaseManager dataBaseManager] execute:strDelete];
        
        [[sectionArr objectAtIndex:selectedIndexPathl.row] setObject:text forKey:@"device_name"];
        [tblView reloadData];
        
        if ([IS_USER_SKIPPED isEqualToString:@"NO"])
        {
            if ([APP_DELEGATE isNetworkreachable])
            {
                [self SaveDeviceDetailstoServer:[sectionArr objectAtIndex:renameIndex]];
            }
        }
    }
}
-(void)showErrorMessage:(NSString *)strMessage
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    [alert showAlertInView:self
                 withTitle:@"Smart Home"//Light
              withSubtitle:strMessage
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)AlertPopForSetting:(NSString *)strMsg
{
FCAlertView *alert = [[FCAlertView alloc] init];
alert.colorScheme = [UIColor blackColor];
[alert makeAlertTypeSuccess];
[alert showAlertInView:self
             withTitle:@"Smart Home" //Light
          withSubtitle:strMsg
       withCustomImage:[UIImage imageNamed:@"logo.png"]
   withDoneButtonTitle:nil
            andButtons:nil];
    alert.dismissOnOutsideTouch = true;
}
-(void)GlobalBLuetoothCheck
{

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Vithamas" message:@"Please enable Bluetooth Connection. Tap on enable Bluetooth icon by swiping Up." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:true completion:nil];
}

//#pragma mark - ME Floating Button Methods
//
//- (void)floatingButton:(UIScrollView *)scrollView didTapButton:(UIButton *)button;
//{
//
//}
//- (void)floatingButtonWillAppear:(UIScrollView *)scrollView;
//{
//
//}
//- (void)floatingButtonDidAppear:(UIScrollView *)scrollView;
//{
//
//}
//- (void)floatingButtonWillDisappear:(UIScrollView *)scrollView;
//{
//
//}
//- (void)floatingButtonDidDisappear:(UIScrollView *)scrollView;
//{
//
//}
#pragma mark - float Button Delegate
-(void)didSelectMenuOptionAtIndex:(NSInteger)row
{
    if (row == 0)
    {
        if (isForGroup)
        {
                AddGroupsVC * addDeviceVC = [[AddGroupsVC alloc] init];
                addDeviceVC.isForGroup = isForGroup;
                [self.navigationController pushViewController:addDeviceVC animated:YES];
        }
        else
        {
                AddDeviceVC * addDeviceVC = [[AddDeviceVC alloc] init];
                addDeviceVC.isForGroup = isForGroup;
                [self.navigationController pushViewController:addDeviceVC animated:YES];
        }
    }
    else if (row == 1)
    {
             AddSocketVC * addVC = [[AddSocketVC alloc] init];
             [self.navigationController pushViewController:addVC animated:YES];
    }
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
        [lblAccName setText:[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_NAME"]]];
        
        if ([APP_DELEGATE isNetworkreachable])
        {
            if (isForGroup)
            {
                [self getAllGroups];
            }
            else
            {
                [self getAllDevices];
            }
        }
        else
        {
            [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
        }
    }
    else
    {
        [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
    }

}
#pragma mark - Animations
-(void)ShowPicker:(BOOL)isShow andView:(UIView *)myView
{
    if (isShow == YES)
    {
        [UIView transitionWithView:myView duration:0.2
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            [myView setFrame:CGRectMake(10,(DEVICE_HEIGHT-320)/2,DEVICE_WIDTH-20, 320)];
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
    else
    {
        [UIView transitionWithView:myView duration:0.2
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            [myView setFrame:CGRectMake(10,DEVICE_HEIGHT,DEVICE_WIDTH-20, 320)];
                        }
                        completion:^(BOOL finished)
         {
             [backView removeFromSuperview];
             [viewSetting removeFromSuperview];
         }];
    }
}
#pragma long Press Events
-(void)onLongPress:(UILongPressGestureRecognizer *)pGesture
{
    if (isForGroup)
    {
        
    }
    else
    {
        if (pGesture.state == UIGestureRecognizerStateRecognized)
        {
            //Do something to tell the user!
        }
        if (pGesture.state == UIGestureRecognizerStateBegan)
        {
            CGPoint touchPoint = [pGesture locationInView:tblView];
            NSIndexPath* indexPath = [tblView indexPathForRowAtPoint:touchPoint];
            if (indexPath != nil)
            {
                if ([sectionArr count]>indexPath.row)
                {
                    strDeviceID = [[sectionArr objectAtIndex:indexPath.row] valueForKey:@"device_id"];
                    [APP_DELEGATE sendSignalViaScan:@"IdentifyUUID" withDeviceID:strDeviceID withValue:@"0"];
                    
                }
            }
        }
    }
    
}
- (UIColor *)adjustedColorForColor:(UIColor *)c : (double)percent
{
    if (percent < 0) percent = 0;
    
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r * percent, 0.0)
                               green:MAX(g * percent, 0.0)
                                blue:MAX(b * percent, 0.0)
                               alpha:a];
    return nil;
}
-(void)changeColor
{
    if (isChanged)
    {
        if (fullRed ==0 && fullBlue ==0 && fullGreen == 0)
        {
        }
        else
        {
            [APP_DELEGATE sendSignalViaScan:@"ColorChange" withDeviceID:globalGroupId withValue:@"0"]; //KalpeshScanCode
        }
        
        isChanged = NO;
        
        [[BLEService sharedInstance] writeColortoDevice:completeData with:globalPeripheral withDestID:globalGroupId];
        [[NSUserDefaults standardUserDefaults] setInteger:globalCount forKey:@"GlobalCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString * strUpdate = [NSString stringWithFormat:@"update Device_Table set manualBrightness = '%f' where device_id = '%@'",realBrightnessValue,globalGroupId];
        [[DataBaseManager dataBaseManager] execute:strUpdate];
        
        if ([sectionArr count]>brightnessIndex)
        {
            [[sectionArr objectAtIndex:brightnessIndex] setObject:[NSString stringWithFormat:@"%f",realBrightnessValue] forKey:@"manualBrightness"];
        }
    }
    else
    {
        isChanged = NO;
    }
}



#pragma mark - Clear User Defaults
-(void)clearUserDefaults
{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_ID"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_ACCESS_TOKEN"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_EMAIL"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_FIRST_NAME"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_LAST_NAME"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_IMAGE"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_PHONE_NUMBER"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_ACCESS_PERMISSION"];
    //    [userDefault setValue:@"" forKey:@"CURRENT_USER_MOBILE"];
    
    [userDefault synchronize];
}
#pragma mark -  ALL BLE Methods
/* Send signal to remove device to BLE device*/
-(void)removeDevice
{
    isDashScanning = YES;
    isAction = @"RemoveDevice";
    strGlogalNotify = @"Dashboard";
    
    [APP_DELEGATE sendSignalViaScan:@"DeleteUUID" withDeviceID:strDeviceID withValue:@"0"]; //KalpeshScanCode
    
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        NSMutableData * collectChekData = [[NSMutableData alloc] init];
        
        NSInteger int1 = [@"100" integerValue];
        NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];
        
        globalCount = globalCount + 1;
        NSInteger int2 = globalCount;
        NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2];
        collectChekData = [data2 mutableCopy];
        
        NSInteger int3 = [@"9000" integerValue];
        NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2];
        [collectChekData appendData:data3];
        
        NSInteger int4 = [strDeviceID integerValue];
        NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2];
        [collectChekData appendData:data4];
        
        NSInteger int5 = [@"0" integerValue];
        NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2];
        [collectChekData appendData:data5];
        
        NSInteger int6 = [@"55" integerValue];
        NSData * data6 = [[NSData alloc] initWithBytes:&int6 length:2];
        [collectChekData appendData:data6];
        
        NSData * finalCheckSumData = [APP_DELEGATE GetCountedCheckSumData:collectChekData];
        
        NSMutableData * completeData = [[NSMutableData alloc] init];
        completeData = [data1 mutableCopy];
        [completeData appendData:data2];
        [completeData appendData:data3];
        [completeData appendData:data4];
        [completeData appendData:finalCheckSumData];
        [completeData appendData:data6];
        
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
}
-(void)sendDeviceonebyone
{
    if ([tmpGroupArr count]> groupSentCount)
    {
        NSString * strId = [[tmpGroupArr objectAtIndex:groupSentCount] valueForKey:@"device_id"];
        [self removeGroupwithGroupID:strDeviceID withDevieID:strId];
        [self removeGroupwithGroupID:strDeviceID withDevieID:strId];
        [self removeGroupwithGroupID:strDeviceID withDevieID:strId];
        groupSentCount = groupSentCount + 1;
        [self performSelector:@selector(sendDeviceonebyone) withObject:nil afterDelay:1];
    }
    else
    {
        [self performSelector:@selector(CheckforDeleteGroup) withObject:nil afterDelay:2];
    }
}
-(void)CheckforDeleteGroup
{
    isDashScanning = NO;
    [APP_DELEGATE hudEndProcessMethod];
    
    if (groupSyncCount == groupSentCount)
    {
        NSString * strDelete = [NSString stringWithFormat:@"update GroupsTable set status = '2', is_sync ='0' where local_group_id = '%@' and user_id ='%@' ",strDeviceID,CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:strDelete];
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        
        if ([groupsArr count]> selectedIndexPathl.row-1)
        {
            dict = [groupsArr objectAtIndex:selectedIndexPathl.row-1];
            [groupsArr removeObjectAtIndex:selectedIndexPathl.row-1];
        }
        [dict setObject:@"2" forKey:@"status"];
        [self SaveGroupsDetailstoServer:dict];
        [tblView reloadData];
        
        if ([groupsArr count]>0)
        {
            noMsgView.hidden = YES;
        }
        else
        {
            noMsgView.hidden = NO;
        }
        
        isAction = @"";
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeSuccess];
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"Room has been removed successfully."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
        self.expandingIndexPathGroup = nil;
        self.expandedIndexPathGroup = nil;
        self.expandingIndexPath = nil;
        self.expandedIndexPath = nil;
        
    }
    else
    {
        NSString * strMsg = [NSString stringWithFormat:@"There are few devices which are not in range. So we can't delete this Room now."];
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
-(void)removeGroupwithGroupID:(NSString *)strGroupID withDevieID:(NSString *)strDeviceID
{
    isDashScanning = YES;
    [APP_DELEGATE sendSignalViaScan:@"DeleteGroupUUID" withDeviceID:strDeviceID withValue:strGroupID];
    
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        NSMutableData * collectChekData = [[NSMutableData alloc] init];
        
        NSInteger int1 = [@"50" integerValue];
        NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];
        
        globalCount = globalCount + 1;
        NSInteger int2 = globalCount;
        NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2];
        collectChekData = [data2 mutableCopy];
        
        NSInteger int3 = [@"9000" integerValue];
        NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2];
        [collectChekData appendData:data3];
        
        NSInteger int4 = [strDeviceID integerValue];
        NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2];
        [collectChekData appendData:data4];
        
        NSInteger int5 = [@"0" integerValue];
        NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2];
        [collectChekData appendData:data5];
        
        NSInteger int6 = [@"10" integerValue];
        NSData * data6 = [[NSData alloc] initWithBytes:&int6 length:2];
        [collectChekData appendData:data6];
        
        NSInteger int7 = [@"1" integerValue];
        NSData * data7 = [[NSData alloc] initWithBytes:&int7 length:1];
        [collectChekData appendData:data7];
        
        NSInteger int8 = [strGroupID integerValue];
        NSData * data8 = [[NSData alloc] initWithBytes:&int8 length:2];
        [collectChekData appendData:data8];
        
        NSData * finalCheckData = [APP_DELEGATE GetCountedCheckSumData:collectChekData];
        
        NSMutableData * completeData = [[NSMutableData alloc] init];
        completeData = [data1 mutableCopy];
        [completeData appendData:data2];
        [completeData appendData:data3];
        [completeData appendData:data4];
        [completeData appendData:finalCheckData];
        [completeData appendData:data6];
        [completeData appendData:data7];
        [completeData appendData:data8];
        
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
}
-(void)ResponsefromScanDash:(NSNotification *)notification
{
    isDashScanning = NO;
    if ([isAction isEqualToString:@"DeviceNameChange"])
    {
        NSString * strDelete = [NSString stringWithFormat:@"Update Device_Table set device_name='%@' where id = '%@'",strChangedDeviceNames,strTableId];
        [[DataBaseManager dataBaseManager] execute:strDelete];
        [[sectionArr objectAtIndex:selectedIndexPathl.row] setObject:strChangedDeviceNames forKey:@"device_name"];
        [tblView reloadData];
    }
    else if ([isAction isEqualToString:@"RemoveDevice"])
    {
        NSString * kpstr = (NSString*) notification.object;
        if ([kpstr rangeOfString:globalDeviceHexId].location == NSNotFound)
        {
        }
        else
        {
            isDashScanning = NO;
            isAction = @"DeviceDeleted";
            if (![syncedDeletedListArr containsObject:strDeviceID])
            {
            }
        }
    }
    else if ([isAction isEqualToString:@"RemoveGroup"])
    {
        NSString * kpstr = (NSString*) notification.object;
        
        for (int i =0; i<[tmpGroupArr count]; i++)
        {
            NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
            [tmpDict setObject:[[tmpGroupArr objectAtIndex:i] valueForKey:@"device_id"] forKey:@"device_id"];
            NSString * strCompare = [[tmpGroupArr objectAtIndex:i] valueForKey:@"hex_device_id"];
            if ([kpstr rangeOfString:strCompare].location == NSNotFound)
            {
            }
            else
            {
                if (![[syncedDeletedListArr valueForKey:@"device_id"] containsObject:[[tmpGroupArr objectAtIndex:i] valueForKey:@"device_id"]])
                {
                    [syncedDeletedListArr addObject:tmpDict];
                    groupSyncCount = groupSyncCount + 1;
                    
                    NSString * strUpdate = [NSString stringWithFormat:@"delete from Group_Details_Table where group_id = '%@' and device_id ='%@' ",[[tmpGroupArr objectAtIndex:i] valueForKey:@"group_id"],[[tmpGroupArr objectAtIndex:i] valueForKey:@"device_id"]];
                    [[DataBaseManager dataBaseManager] execute:strUpdate];
                }
                [[tmpGroupArr objectAtIndex:i] setObject:@"1" forKey:@"isDeleted"];
            }
        }
    }
    else if([isAction isEqualToString:@"Move"])
    {
        if ([currentScreen isEqualToString:@"Dashboard"])
        {
            DeviceDetailVC * detailVC = [[DeviceDetailVC alloc] init];
            detailVC.deviceDict = selectedDict;
            detailVC.isfromGroup = isForGroup;
            if ([[selectedDict valueForKey:@"device_type"] isEqualToString:@"2"])
            {
                detailVC.isDeviceWhite = YES;
            }
            globalGroupId  = [NSString stringWithFormat:@"%@",[selectedDict valueForKey:@"device_id"]];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }
}
-(void)switchOffDevice:(NSString *)sentID withType:(BOOL)isOn
{
    NSString * strON, * strStatus;
    if (isOn)
    {
        strON = @"1";
        strStatus = @"Yes";
    }
    else
    {
        strON = @"0";
        strStatus = @"No";
    }
    [tblView reloadData];
    
    [APP_DELEGATE sendSignalViaScan:@"OnOff" withDeviceID:sentID withValue:strON]; //KalpeshScanCode
    
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        NSMutableData * collectChekData = [[NSMutableData alloc] init];
        
        NSInteger int1 = [@"50" integerValue];
        NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];
        
        globalCount = globalCount + 1;
        NSInteger int2 = globalCount;
        NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2];
        collectChekData = [data2 mutableCopy];
        
        NSInteger int3 = [@"9000" integerValue];
        NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2];
        [collectChekData appendData:data3];
        
        NSInteger int4 = [sentID integerValue];
        NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2];
        [collectChekData appendData:data4];
        
        NSInteger int5 = [@"0" integerValue];
        NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2];
        [collectChekData appendData:data5];
        
        NSInteger int6 = [@"85" integerValue];
        NSData * data6 = [[NSData alloc] initWithBytes:&int6 length:2];
        [collectChekData appendData:data6];
        
        NSInteger int7 = [strON integerValue];
        NSData * data7 = [[NSData alloc] initWithBytes:&int7 length:1];
        [collectChekData appendData:data7];
        
        NSData * finalCheckData = [APP_DELEGATE GetCountedCheckSumData:collectChekData];
        NSMutableData *completeData = [[NSMutableData alloc] init];
        completeData = [data1 mutableCopy];
        [completeData appendData:data2];
        [completeData appendData:data3];
        [completeData appendData:data4];
        [completeData appendData:finalCheckData];
        [completeData appendData:data6];
        [completeData appendData:data7];
        
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
    if (tmpSwtch.tag ==123)
    {
        [sectionArr setValue:strStatus forKey:@"switch_status"];
        NSString * updateStr = [NSString stringWithFormat:@"Update Device_Table set switch_status = '%@'",strStatus];
        [[DataBaseManager dataBaseManager] execute:updateStr];
    }
    else
    {
        [self updateSwitchStatus:isOn withDeviceID:sentID];
    }
}
-(void)updateSwitchStatus:(BOOL)newValue withDeviceID:(NSString*)deviceID
{
    NSString  * strStatus;
    if (newValue)
    {
        strStatus = @"Yes";
    }
    else
    {
        strStatus = @"No";
    }
    
    if (isForGroup)
    {
        deviceID = [[groupsArr objectAtIndex:switchIndex.row-1] valueForKey:@"local_group_id"];
        [[groupsArr objectAtIndex:switchIndex.row-1] setObject:strStatus forKey:@"switch_status"];
        NSString * strUpdate = [NSString stringWithFormat:@"Update GroupsTable set switch_status='%@' where local_group_id = '%@'",strStatus,deviceID];
        [[DataBaseManager dataBaseManager] execute:strUpdate];
    }
    else
    {
        deviceID = [[sectionArr objectAtIndex:switchIndex.row] valueForKey:@"device_id"];
        [[sectionArr objectAtIndex:switchIndex.row] setObject:strStatus forKey:@"switch_status"];
        NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set switch_status='%@' where device_id = '%@'",strStatus,deviceID];
        [[DataBaseManager dataBaseManager] execute:strUpdate];
    }
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
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state;
{
}
-(void)updateDataforONOFF:(NSNotification *)notification
{
    NSDictionary *dict = [notification object];
    setDict = dict;
    NSString * strSet = @"No";
    NSString * deviceID = @"0";
    if ([[dict valueForKey:@"isSwitch"] isEqualToString:@"1"])
    {
        strSet = @"Yes";
    }
    else
    {
        strSet = @"No";
    }
    
    if (isAll)
    {
    }
    else
    {
        if ([dict count]>0)
        {
            if (isForGroup)
            {
                if ([groupsArr count]>selectedIndexPathl.row-1)
                {
                    deviceID = [[groupsArr objectAtIndex:selectedIndexPathl.row-1] valueForKey:@"local_group_id"];
                    [[groupsArr objectAtIndex:selectedIndexPathl.row-1] setValue:strSet forKey:@"switch_status"];
                    
                    NSString * strUpdate = [NSString stringWithFormat:@"Update GroupsTable set switch_status='%@' where local_group_id = '%@'",strSet,deviceID];
                    [[DataBaseManager dataBaseManager] execute:strUpdate];
                }
            }
            else
            {
                if (sectionArr.count > selectedIndexPathl.row)
                {
                    deviceID = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"device_id"];
                    [[sectionArr objectAtIndex:selectedIndexPathl.row] setValue:strSet forKey:@"switch_status"];
                    
                    NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set switch_status='%@' where device_id = '%@'",strSet,deviceID];
                    [[DataBaseManager dataBaseManager] execute:strUpdate];
                    
                    [tblView reloadData];
                }
                
            }
        }
    }
}
- (NSIndexPath *)actualIndexPathForTappedIndexPath:(NSIndexPath *)indexPath
{
    
    if (isForGroup)
    {
        if (self.expandedIndexPathGroup && [indexPath row] > [self.expandedIndexPathGroup row])
        {
            return [NSIndexPath indexPathForRow:[indexPath row] inSection:[indexPath section]];
        }
    }
    else
    {
        if (self.expandedIndexPath && [indexPath row] > [self.expandedIndexPath row])
        {
            return [NSIndexPath indexPathForRow:[indexPath row] inSection:[indexPath section]];
        }
    }
    return indexPath;
}

-(void)checkTimeOut
{
    [APP_DELEGATE hideScannerView];
    [APP_DELEGATE endHudProcess];
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
    }
    else
    {
        
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"There is something went wrong. Please check device connection."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
        
    }
}
-(void)DashBoardConnected
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    alert.tag = 222;
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Device has been connected successfully."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)SendCallbackforDashScanning:(NSNotification *)notify
{
    if (isChanged)
    {
        return;
    }
    NSString  * strInfo = [notify object];
//    NSLog(@"Update=======>>>>>>Brigthness=====>>>>>%@",strInfo);
    if (![[self checkforValidString:strInfo] isEqualToString:@"NA"])
    {
        if ([strInfo length]>=16)
        {
            NSRange rangeCheck = NSMakeRange(6, 4);
            NSString * strDeviceIdCheck = [strInfo substringWithRange:rangeCheck];
            
            if ([[strInfo substringWithRange:NSMakeRange([strInfo length]-8, 2)] isEqualToString:@"00"])
            {
                NSInteger indexx = [[sectionArr valueForKey:@"hex_device_id"] indexOfObject:strDeviceIdCheck];
                if (indexx != NSNotFound)
                {
                    NSString * strQry = [NSString stringWithFormat:@"Update Device_Table set switch_status = 'No' where hex_device_id = '%@'", strDeviceIdCheck];
                    [[DataBaseManager dataBaseManager] execute:strQry];
                    if ([sectionArr count]> indexx)
                    {
                        [[sectionArr objectAtIndex:indexx] setObject:@"No" forKey:@"switch_status"];
                        [tblView reloadData];
                    }
                }
            }
            else
            {
                NSInteger indexx = [[sectionArr valueForKey:@"hex_device_id"] indexOfObject:strDeviceIdCheck];
                if (indexx != NSNotFound)
                {
                    int red = [[APP_DELEGATE stringFroHex:[strInfo substringWithRange:NSMakeRange([strInfo length]-6, 2)]] intValue];
                    int green = [[APP_DELEGATE stringFroHex:[strInfo substringWithRange:NSMakeRange([strInfo length]-4, 2)]] intValue];
                    int blue = [[APP_DELEGATE stringFroHex:[strInfo substringWithRange:NSMakeRange([strInfo length]-2, 2)]] intValue];
                    //                    double brightness = (red / 255.0) * 0.3 + (green / 255.0) * 0.59 + (blue / 255.0) * 0.11;
                    
                    CGFloat brightness;
                    [[UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1] getHue:NULL saturation:NULL brightness:&brightness alpha:NULL];
                    
                    NSString * strQry = [NSString stringWithFormat:@"Update Device_Table set switch_status = 'Yes', brightnessValue = '%f', red = '%d', green = '%d', blue = '%d' where hex_device_id = '%@'",brightness,red,green,blue, strDeviceIdCheck];
                    [[DataBaseManager dataBaseManager] execute:strQry];
                    if ([sectionArr count]> indexx)
                    {
                        [[sectionArr objectAtIndex:indexx] setObject:@"Yes" forKey:@"switch_status"];
                        [[sectionArr objectAtIndex:indexx] setObject:[NSString stringWithFormat:@"%f",brightness] forKey:@"brightnessValue"];
                        [[sectionArr objectAtIndex:indexx] setObject:[NSString stringWithFormat:@"%d",red] forKey:@"red"];
                        [[sectionArr objectAtIndex:indexx] setObject:[NSString stringWithFormat:@"%d",green] forKey:@"green"];
                        [[sectionArr objectAtIndex:indexx] setObject:[NSString stringWithFormat:@"%d",blue] forKey:@"blue"];
                        
                                                [tblView reloadData];
                    }
                }
            }
        }
    }
}
-(void)brightnessChanged:(id)sender
{
    isChanged = YES;
    
    UISlider *slider = (UISlider*)sender;
    
    imageBrighValue = slider.value;
    realBrightnessValue = slider.value;
    
    if ([sectionArr count]> [sender tag])
    {
        
    }
    else
    {
        return;
    }
    float redf = [[[sectionArr objectAtIndex:[sender tag]] valueForKey:@"red"] floatValue];
    float greenf = [[[sectionArr objectAtIndex:[sender tag]] valueForKey:@"green"] floatValue];
    float bluef = [[[sectionArr objectAtIndex:[sender tag]] valueForKey:@"blue"] floatValue];
    globalGroupId = [[sectionArr objectAtIndex:[sender tag]] valueForKey:@"device_id"];
    brightnessIndex = [sender tag];
    UIColor * imgColor = [UIColor colorWithRed:redf/255.0f green:greenf/255.0f blue:bluef/255.0f alpha:1];
    
    HRHSVColor hsvColor;
    HSVColorFromUIColor(imgColor, &hsvColor);
    hsvColor.v  = (0.7 * (slider.value * 100) + 30 )/100;
    UIColor *newColor = [[UIColor alloc] initWithHue:hsvColor.h
                                          saturation:hsvColor.s
                                          brightness:hsvColor.v
                                               alpha:1];
    
    
    if (newColor != nil)
    {
        const  CGFloat *_components = CGColorGetComponents(newColor.CGColor);
        CGFloat red     = _components[0];
        CGFloat green = _components[1];
        CGFloat blue   = _components[2];
        
        NSInteger sixth = [@"66" integerValue];
        NSData * dSix = [[NSData alloc] initWithBytes:&sixth length:1];
        
        NSInteger seven = [@"00" integerValue];
        NSData * dSeven = [[NSData alloc] initWithBytes:&seven length:1];
        
        fullRed = red * 255;
        NSData * dR = [[NSData alloc] initWithBytes:&fullRed length:1];
        
        fullGreen = green * 255;
        NSData * dG = [[NSData alloc] initWithBytes:&fullGreen length:1];
        
        fullBlue = blue * 255;
        NSData * dB = [[NSData alloc] initWithBytes:&fullBlue length:1];
        
        completeData = [[NSMutableData alloc] init];
        completeData = [dSix mutableCopy];
        [completeData appendData:dSeven];
        [completeData appendData:dR];
        [completeData appendData:dG];
        [completeData appendData:dB];
        
        int currentvalue = slider.value;
        
        CGRect trackRect = [slider trackRectForBounds:slider.bounds];
        CGRect thumbRect = [slider thumbRectForBounds:slider.bounds
                                            trackRect:trackRect
                                                value:slider.value];
        lblThumbTint.center = CGPointMake(thumbRect.origin.x +slider.frame.origin.x+20,slider.frame.origin.y-5);
        
        NSString *strlbl = [[NSString alloc]initWithFormat:@"%d %@",currentvalue,@"%"];
        
        lblThumbTint.text = strlbl;
        
    }
    
}
#pragma mark - CentralManager Ble delegate Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (@available(iOS 10.0, *))
    {
        if (central.state == CBCentralManagerStatePoweredOff || central.state == CBManagerStateUnknown)
        {
            [self GlobalBLuetoothCheck];
        }
    }
    else
    {
        if (central.state == CBCentralManagerStatePoweredOff)
        {
            [self GlobalBLuetoothCheck];
        }
    }
}

#pragma mark - ALL SOCKET Methods
-(void)CheckSockectConnectionTimer
{
//    NSMutableArray * arrCnt = [[NSMutableArray alloc] init];
//    arrCnt = [[BLEManager sharedManager] arrBLESocketDevices];
    
//    if([arrCnt count] == 0)
    
    if (![currentScreen isEqualToString: @"AddSocket"])
    {
        for (int i=0; i<arrSocketDevices.count; i++)
        {
            if ([[[arrSocketDevices objectAtIndex:i] allKeys] containsObject:@"peripheral"])
            {
                CBPeripheral * p = [[arrSocketDevices objectAtIndex:i] objectForKey:@"peripheral"];
                if (p.state == CBPeripheralStateConnected)
                {
                    bool isNotified = NO;
                    if ([[[arrSocketDevices objectAtIndex:i] allKeys] containsObject:@"IsNotified"])
                    {
                        if ([[[arrSocketDevices objectAtIndex:i] valueForKey:@"IsNotified"] isEqualToString:@"1"])
                        {
                            isNotified = YES;
                        }
                        else
                        {
                            isNotified = NO;
                        }
                    }
                    if (isNotified == NO)
                    {
                        [[BLEService sharedInstance] sendNotificationsSKT:p withType:NO withUUID:@"0000AB00-2687-4433-2208-ABF9B34FB000"];
                        [[BLEService sharedInstance] EnableNotificationsForCommandSKT:p withType:YES];
                        [[BLEService sharedInstance] EnableNotificationsForDATASKT:p withType:YES];
                        [[BLEService sharedInstance] GetAuthcodeforSocket:p withValue:@"1"];//Ask for Authentication Value
                        [[arrSocketDevices objectAtIndex:i] setValue:@"1" forKey:@"IsNotified"];
                    }

                }
                else
                {
                    [self setPeripheraltoCheckKeyUsage:p];
                    if (p.state == CBPeripheralStateDisconnected)
                    {
                       if (![currentScreen isEqualToString: @"AddSocket"])
                        {
//                            NSLog(@"Auto Connection Dashboard =%@",[arrSocketDevices objectAtIndex:i]);
                            [[BLEManager sharedManager] connectDevice:p];
//                            [[arrSocketDevices objectAtIndex:i] setValue:@"1" forKey:@"IsNotified"];
                        }
                    }
                }
            }
            else
            {
                for (int i = 0; i < [sectionArr count]; i ++)
                {
                    if ([[[sectionArr objectAtIndex:i] valueForKey:@"device_type"] isEqualToString:@"4"])
                    {
                        NSString * strIdentifier = [self checkforValidString:[[sectionArr objectAtIndex:i] valueForKey:@"identifier"]];
                        NSString * strBleAddress = [self checkforValidString:[[sectionArr objectAtIndex:i] valueForKey:@"ble_address"]];

                        CBPeripheral * p;

                        if(![strIdentifier isEqualToString:@"NA"])
                        {
                            NSArray * arrDevie = [[BLEManager sharedManager] getLastDiscoveredSocketDevices:strIdentifier];
                            if ([arrDevie count] > 0)
                            {
                                 p = [arrDevie objectAtIndex:0];
                            }
                        }

                        if (p != nil)
                        {
                            if (![[arrSocketDevices valueForKey:@"ble_address"] containsObject:strBleAddress])
                            {
                                [[sectionArr objectAtIndex:i] setObject:p forKey:@"peripheral"];
                                [arrSocketDevices addObject:[sectionArr objectAtIndex:i]];
                            }
                            else
                            {
                                NSInteger  foudIndex = [[arrSocketDevices valueForKey:@"ble_address"] indexOfObject:strBleAddress];
                                if (foudIndex != NSNotFound)
                                {
                                    if ([arrSocketDevices count] > foudIndex)
                                    {
                                        NSMutableDictionary * dataDict = [arrSocketDevices objectAtIndex:foudIndex];
                                        [dataDict setValue:p forKey:@"peripheral"];
                                        [dataDict setValue:[NSString stringWithFormat:@"%@",p.identifier] forKey:@"identifier"];
                                        [arrSocketDevices replaceObjectAtIndex:foudIndex withObject:dataDict];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
//    else
//    {
//        for (int i=0; i<[arrCnt count]; i++)
//        {
//            CBPeripheral * tmpPerphrl = [[arrCnt objectAtIndex:i] objectForKey:@"peripheral"];
//
//            if ([[arrSocketDevices valueForKey:@"ble_address"] containsObject:[[arrCnt objectAtIndex:i] valueForKey:@"ble_address"]])
//            {
//                NSInteger idxAddress = [[arrSocketDevices valueForKey:@"ble_address"] indexOfObject:[[arrCnt objectAtIndex:i] valueForKey:@"ble_address"]];
//                if (idxAddress != NSNotFound)
//                {
//                    if (idxAddress < [arrSocketDevices count])
//                    {
//                        [[arrSocketDevices objectAtIndex:idxAddress]setObject:tmpPerphrl forKey:@"peripheral"];
//                        [[arrSocketDevices objectAtIndex:idxAddress]setValue:[NSString stringWithFormat:@"%@",tmpPerphrl.identifier] forKey:@"identifier"];
//                        if (tmpPerphrl.state == CBPeripheralStateConnected)
//                        {
//                        }
//                        else
//                        {
//                            [self setPeripheraltoCheckKeyUsage:tmpPerphrl];
//                            if (tmpPerphrl.state == CBPeripheralStateDisconnected)
//                            {
////                                [[BLEManager sharedManager] connectDevice:tmpPerphrl];
//                                if (![currentScreen isEqualToString: @"AddSocket"])
//                                {
//                                    [[BLEManager sharedManager] ConnectDevicePeripheralforSocket:tmpPerphrl];
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
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
-(void)SocketMainSwitchTurnOnOff:(NSDictionary *)dictDetail withSwitchStatus:(BOOL)swithStatus
{
    NSInteger switchStatus = [@"00" integerValue];

    if (swithStatus == YES)
    {
        switchStatus = [@"01" integerValue];
    }

    NSString * strAddress = [dictDetail valueForKey:@"ble_address"];
    
    BOOL isBleConnected = NO;
    NSString * strBleAddress = [[dictDetail valueForKey:@"ble_address"] uppercaseString];
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
                    if (p.state == CBPeripheralStateConnected)
                    {
                        isBleConnected = YES;
                        NSInteger intPacket = [@"0" integerValue];
                        NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
                        NSData * dataSwitchStatus = [[NSData alloc] initWithBytes:&switchStatus length:1];

                        [[BLEService sharedInstance] WriteSocketData:dataSwitchStatus withOpcode:@"10" withLength:@"1" withPeripheral:p];
                        [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"05" withLength:@"00" withPeripheral:p];
                    }
                }
            }
        }
    }
    if (isBleConnected == NO)
    {
        NSString * strTopic = [NSString stringWithFormat:@"/vps/device/%@",[strAddress uppercaseString]];
        NSArray * arrPackets =[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:10],[NSNumber numberWithInt:1],[NSNumber numberWithInteger:switchStatus], nil];
        [self PublishMessageonMQTTwithTopic:strTopic withDataArray:arrPackets];
    }
}
#pragma mark - Common Method to Publish on MQTT
-(void)PublishMessageonMQTTwithTopic:(NSString *)strTopic withDataArray:(NSArray *)arrData
{
    NSLog(@"===========================================================================================%hhu",[mqttObj connState]);
    CocoaMQTTMessage * msg = [[CocoaMQTTMessage alloc] initWithTopic:strTopic payload:arrData qos:2 retained:NO dup:NO];
    UInt16 subTop = [mqttObj publish:msg];
    NSLog(@"MQTT MSG Sent==%hu",subTop);
}

#pragma  mark- MQtt connection

-(void)ConnecttoMQTTSocketServer
{
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    NSString * str = [NSString stringWithFormat:@"Select * from Device_Table where device_type = '4'"];
    [[DataBaseManager dataBaseManager] execute:str resultsArray:tmpArr];
    
//    if ([tmpArr count] > 0)
    {
        NSString * strClientId = [self checkforValidString:deviceTokenStr];
        if ([strClientId isEqualToString:@"NA"])
        {
            strClientId = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        }

        [mqttObj didDisconnect];
        self->mqttObj = [[CocoaMQTT alloc] initWithClientID:strClientId host:@"iot.vithamastech.com" port:8883];
        self->mqttObj.delegate = self;
        mqttObj.autoReconnect = YES;
    
        [self->mqttObj selfSignedSSLSetting];
        BOOL isConnected =  [self->mqttObj connect];
        if (isConnected)
        {
            NSLog(@"MQTT is CONNECTING....");
        }
    }
}
-(void)DisconnectMQTTSocketServer
{
    if (mqttObj)
    {
        [mqttObj disconnect];
        isMqttDisconnected = YES;
    }
}
-(void)NewSocketAddedWithWIFIConfigured:(NSString *)strBleAddress withPeripheral:(CBPeripheral *)peripheral
{
    if (peripheral)
    {
        if ([[arrSocketDevices valueForKey:@"ble_address"] containsObject:strBleAddress])
        {
            NSInteger idxAddress = [[arrSocketDevices valueForKey:@"ble_address"] indexOfObject:strBleAddress];
            if (idxAddress != NSNotFound)
            {
                if (idxAddress < [arrSocketDevices count])
                {
                    [[arrSocketDevices objectAtIndex:idxAddress]setObject:peripheral forKey:@"peripheral"];
                    [[arrSocketDevices objectAtIndex:idxAddress]setValue:[NSString stringWithFormat:@"%@",peripheral.identifier] forKey:@"identifier"];
                }
            }
        }
    }
    if (self->mqttObj == nil)
    {
        NSString * strClientId = [self checkforValidString:deviceTokenStr];
        if ([strClientId isEqualToString:@"NA"])
        {
            strClientId = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        }

        self->mqttObj = [[CocoaMQTT alloc] initWithClientID:strClientId host:@"iot.vithamastech.com" port:8883];
        self->mqttObj.delegate = self;
        [self->mqttObj selfSignedSSLSetting];
        BOOL isConnected =  [self->mqttObj connect];
        if (isConnected)
        {
            NSLog(@"MQTT is CONNECTING....");
        }
    }
    else
    {
        NSString * strCurrentTopic = [NSString stringWithFormat:@"/vps/app/%@",[strBleAddress uppercaseString]];
        UInt16 subTop =  [self->mqttObj subscribe:strCurrentTopic qos:2];
        NSLog(@"%d",subTop);
    }
}
-(void)ConnectedSocketfromSocketDetailPage:(CocoaMQTT *)mqtt
{
    mqttObj = mqtt;
}
#pragma mark - MQTT Delegate Methods
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
    
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    NSString * str = [NSString stringWithFormat:@"Select * from Device_Table where device_type = '4' and status = '1' group by ble_address"];
    [[DataBaseManager dataBaseManager] execute:str resultsArray:tmpArr];

    //Here we will subscribe for all the sockets
    for (int i = 0 ; i< [tmpArr count]; i++)
    {
        NSString * strCurrentTopic = [NSString stringWithFormat:@"/vps/app/%@",[[[tmpArr objectAtIndex:i] valueForKey:@"ble_address"] uppercaseString]];
        UInt16 subTop = [mqtt subscribe:strCurrentTopic qos:2];
        NSLog(@"%d",subTop);
    }

    NSLog(@"MQTT Connected --->");
}
-(void)mqtt:(CocoaMQTT *)mqtt didPublishMessage:(CocoaMQTTMessage *)message id:(uint16_t)id
{
    NSArray * arrAck = [message payload];
    if([arrAck count]>0)
    {
        NSString * strAck = [arrAck componentsJoinedByString:@","];
        NSLog(@"mqtt didPublishMessage =%@",strAck);
    }
}
-(void)mqtt:(CocoaMQTT *)mqtt didPublishAck:(uint16_t)id
{
}
-(void)mqtt:(CocoaMQTT *)mqtt didReceiveMessage:(CocoaMQTTMessage *)message id:(uint16_t)id
{
    //Whenever message received we will send it to socketdtailvc.
    NSLog(@"Dashboard mqtt didReceiveMessage =%@",[message payload]);
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
        if([[sectionArr valueForKey:@"ble_address"] containsObject:strAddress])
        {
            NSInteger foundIndex  = [[sectionArr valueForKey:@"ble_address"] indexOfObject:strAddress];
            if(foundIndex != NSNotFound)
            {
                if([sectionArr count] > foundIndex)
                {
                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                    [dict setValue:arrReceive forKey:@"data"];
                    [dict setValue:strAddress forKey:@"ble_address"];
                    [tblView reloadData];
                    if(globalSocketDetailVC != nil)
                    {
                        [globalSocketDetailVC ReceivedMQTTResponsefromserver:dict];
                    }
                }
            }
        }
    }
}
-(void)mqtt:(CocoaMQTT *)mqtt didSubscribeTopic:(NSArray<NSString *> *)topics
{
    NSLog(@"Topic Subscried successfully =%@",topics);
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
        if(isMqttDisconnected == NO)
        {
            NSString * strClientId = [self checkforValidString:deviceTokenStr];
            if ([strClientId isEqualToString:@"NA"])
            {
                strClientId = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
            }

//            mqttObj = [[CocoaMQTT alloc] initWithClientID:strClientId host:@"iot.vithamastech.com" port:8883];
//            mqttObj.delegate = self;
//            [mqttObj selfSignedSSLSetting];
//            BOOL isConnected =  [mqttObj connect];
//            if (isConnected)
//            {
//                NSLog(@"MQTT is CONNECTING....");
//            }
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
-(void)UpdateSocketSwithchStatus:(NSArray *)arrData withMacAddress:(NSString *)strAddress
{
    if([[sectionArr valueForKey:@"ble_address"] containsObject:strAddress])
    {
        NSInteger foundIndex  = [[sectionArr valueForKey:@"ble_address"] indexOfObject:strAddress];
        if(foundIndex != NSNotFound)
        {
            if([sectionArr count] > foundIndex)
            {
                if([arrData count] >= 1)
                {
                    NSString * strOpcode = [self checkforValidString:[NSString stringWithFormat:@"%@",[arrData objectAtIndex:0]]];
                    if([strOpcode isEqualToString:@"5"])
                    {
                        if([arrData count] >= 8)
                        {
                            NSString * strStatus = [NSString stringWithFormat:@"%@",[arrData componentsJoinedByString:@""]];
                            [dictSocketSwitchStatus setValue:strStatus forKey:strAddress];
                            if ([strStatus isEqualToString:@"56111111"])
                            {
                                [[sectionArr objectAtIndex:foundIndex] setValue:@"Yes" forKey:@"switch_status"];
                            }
                            else
                            {
                                [[sectionArr objectAtIndex:foundIndex] setValue:@"No" forKey:@"switch_status"];
                            }
//                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                [tblView reloadData];
//                            });
                        }
                    }
                
                }
//                [[sectionArr objectAtIndex:foundIndex] setValue:@"" forKey:<#(nonnull NSString *)#>];
//                switch_status
            }
        }
    }
}
//
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sendier:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 320c 0028 23 d209 d204 0a00 01 3724
 6314 0028 23 d209 6500 0a00  3724
 6314 0028 23 d209 65000 a00 3724 00>
 
 2018-06-07 11:23:01.897669+0530 SmartLightApp[2616:1111511] DEVICE ID=1129  & SENT HEX ID=6904 & RECIEVED HEX ID=3270006904282332000b00
 2018-06-07 11:23:01.898147+0530 SmartLightApp[2616:1111511] DEVICE ID=6226  & SENT HEX ID=5218 & RECIEVED HEX ID=3270006904282332000b00
 2018-06-07 11:23:01.898416+0530 SmartLightApp[2616:1111511] DEVICE ID=7779  & SENT HEX ID=631e & RECIEVED HEX ID=3270006904282332000b00
 
 3170006904282332000b00
 3272006904282332000b00
 3162005218282332000b00
 3166005218282332000b00
 
 */

@end

