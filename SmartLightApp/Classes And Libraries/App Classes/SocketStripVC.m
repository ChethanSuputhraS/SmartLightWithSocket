//
//  SocketStripVC.m
//  SmartLightApp
//
//  Created by stuart watts on 06/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "SocketStripVC.h"
#import "ORBSwitch.h"

@interface SocketStripVC ()<ORBSwitchDelegate,FCAlertViewDelegate>
{
    UIImageView * statusImg;
    UIScrollView * scrlView;
    BOOL isSentNoticication,isShowPopup;
}
@end

@implementation SocketStripVC
@synthesize _switchLight,deviceName,deviceDict,isFromScan,isFromAll,isfromGroup;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:19/255.0 green:24/255.0 blue:27/255.0 alpha:1.0];
    
    isShowPopup = YES;
    
    [self setNavigationViewFrames];
    [self setMainView];
    
    
    UILabel * lblDevice = [[UILabel alloc] initWithFrame:CGRectMake(0, 74, DEVICE_WIDTH, 24)];
    [lblDevice setBackgroundColor:[UIColor grayColor]];
    [lblDevice setText:[NSString stringWithFormat:@" Turn on/off individual socket from strip"]];
    [lblDevice setTextAlignment:NSTextAlignmentLeft];
    [lblDevice setFont:[UIFont systemFontOfSize:14 weight:UIFontWeightLight]];
    [lblDevice setFont:[UIFont italicSystemFontOfSize:14]];
    [lblDevice setTextColor:[UIColor whiteColor]];
    [self.view addSubview:lblDevice];
    
    statusImg = [[UIImageView alloc] init];
    statusImg.image = [UIImage imageNamed:@"Connected_icon.png"];
    statusImg.frame = CGRectMake(DEVICE_WIDTH-36, 75, 12, 22);
    [self.view addSubview:statusImg];
    
    if (globalConnStatus)
    {
        statusImg.image = [UIImage imageNamed:@"Connected_icon.png"];
    }
    else
    {
        statusImg.image = [UIImage imageNamed:@"notconnect_icon.png"];
    }
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    currentScreen = @"Detail";
    
    [APP_DELEGATE hideTabBar:self.tabBarController];
    
    [[BLEManager sharedManager] centralmanagerScanStop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:currentScreen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBleStatus) name:currentScreen object:nil];
    
    [super viewWillAppear:YES];
}
-(void)viewDidDisappear:(BOOL)animated
{
    isNonConnectScanning = NO;
    [[BLEManager sharedManager] updateBluetoothState];
    [super viewDidDisappear:YES];
}

#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor colorWithRed:19/255.0 green:24/255.0 blue:27/255.0 alpha:1.0]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.4;
    [viewHeader addSubview:lblBack];

    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:[NSString stringWithFormat:@"   %@",[deviceDict valueForKey:@"device_name"]]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    lblTitle.numberOfLines = 0;
    [viewHeader addSubview:lblTitle];
    
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 70, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];
    
    _switchLight = [[ORBSwitch alloc] initWithCustomKnobImage:[UIImage imageNamed:@"off_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] frame:CGRectMake(0, 0, 100, 60)];
    _switchLight.isOn = NO;
    _switchLight.knobRelativeHeight = 0.8f;
    _switchLight.frame = CGRectMake(DEVICE_WIDTH-50, 22, 60, 40);
    _switchLight.delegate =self;
    _switchLight.tag = 222;
    [viewHeader addSubview:_switchLight];
    
    if ([[deviceDict valueForKey:@"switch_status"] isEqualToString:@"Yes"])
    {
        _switchLight.isOn = YES;
        [_switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
    }
    
    deviceName = @"Vithamas Light";
    if ([deviceDict valueForKey:@"device_name"])
    {
        deviceName = [deviceDict valueForKey:@"device_name"];
    }
    
    if (isfromGroup)
    {
        deviceName = [deviceDict valueForKey:@"group_name"];
    }
    
    if (isFromAll)
    {
        deviceName = @"All devices";
    }
    
    [lblTitle setText:[NSString stringWithFormat:@"   %@",deviceName]];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
        _switchLight.frame = CGRectMake(DEVICE_WIDTH-50, 46, 60, 40);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
    }
}
-(void)setMainView
{
    scrlView = [[UIScrollView alloc] init];
    scrlView.frame = CGRectMake(0, 115, DEVICE_WIDTH, DEVICE_HEIGHT-115);
    scrlView.backgroundColor = [UIColor colorWithRed:13/255.0 green:17/255.0 blue:20/255.0 alpha:1.0];
    //    scrlView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:scrlView];
    
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    NSString * strQury = [NSString stringWithFormat:@"Select * from SocketStrip where device_id = '%@'",[self.deviceDict valueForKey:@"device_id"]];
    [[DataBaseManager dataBaseManager] execute:strQury resultsArray:arr];
    
    
    int xx = 0;
    int yy = 0;
    int cnt = 0;
    int vWidth = (DEVICE_WIDTH/2);
    
    for (int i=0; i<2; i++)
    {
        xx=0;
        for (int j=0; j<2; j++)
        {
            UILabel * lblTmp = [[UILabel alloc] init];
            lblTmp.frame = CGRectMake(xx, yy, vWidth, vWidth);
            lblTmp.backgroundColor = [UIColor colorWithRed:19/255.0 green:24/255.0 blue:27/255.0 alpha:1.0];
            //            lblTmp.backgroundColor = [UIColor redColor];
            lblTmp.userInteractionEnabled = YES;
            lblTmp.text = @" ";
            lblTmp.layer.borderWidth=0.5;
            lblTmp.layer.borderColor = [[UIColor grayColor] CGColor];
            [scrlView addSubview:lblTmp];
            
            UIImageView * img = [[UIImageView alloc] init];
            img.frame = CGRectMake((vWidth-60)/2,40, 60, 60);
            img.image = [UIImage imageNamed:@"default_socket_icon.png"];
            [lblTmp addSubview:img];
            
            UILabel * lblName = [[UILabel alloc] init];
            lblName.frame = CGRectMake(10, vWidth-40, vWidth-20, 40);
            lblName.text = [NSString stringWithFormat:@"Socket %d",cnt+1];
            [lblName setFont:[UIFont fontWithName:CGRegular size:textSizes]];
            lblName.textColor = [UIColor whiteColor];
            [lblTmp addSubview:lblName];
            
            ORBSwitch * scktSwitch = [[ORBSwitch alloc] initWithCustomKnobImage:[UIImage imageNamed:@"off_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] frame:CGRectMake(0, 0, 100, 60)];
            scktSwitch.isOn = NO;
            scktSwitch.knobRelativeHeight = 0.8f;
            scktSwitch.frame = CGRectMake(vWidth-70, vWidth-40, 60, 40);
            scktSwitch.delegate =self;
            scktSwitch.tag = [[[arr objectAtIndex:i] valueForKey:@"id"] integerValue];
            [lblTmp addSubview:scktSwitch];
            
            if ([[[arr objectAtIndex:i] valueForKey:@"switch_status"] isEqualToString:@"Yes"])
            {
                [_switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
            }
            else
            {
                [_switchLight setCustomKnobImage:[UIImage imageNamed:@"off_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
            }
            
            if (j==0)
            {
                lblTmp.frame = CGRectMake(xx, yy, (vWidth)+5, vWidth);
            }
            if (i==1)
            {
                CGRect frme = lblTmp.frame;
                frme.origin.y = frme.origin.y-5;
                frme.size.height = frme.size.height-5;
                lblTmp.frame = frme;
                lblName.frame = CGRectMake(10, vWidth-40, vWidth-20, 40);
            }
            
            xx = vWidth + xx;
            cnt = cnt +1;
        }
        yy = yy + DEVICE_WIDTH/2 ;
    }
    
}
#pragma mark - Button Click
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - ORBSwitchDelegate

- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue
{
    NSString * deviceID = @"NA";
    deviceID = globalGroupId;
    NSString * updateStr, * strsSts ;

    if (newValue == YES)
    {
        strsSts = @"Yes";
        [deviceDict setObject:@"Yes" forKey:@"switch_status"];
    }
    else
    {
        strsSts = @"No";
        [deviceDict setObject:@"No" forKey:@"switch_status"];
    }
    
    if (switchObj.tag == 222)
    {
        updateStr = [NSString stringWithFormat:@"update SocketStrip set switch_status = '%@'",strsSts];
    }
    else
    {
        updateStr = [NSString stringWithFormat:@"update SocketStrip set switch_status = '%@' where id='%ld'",strsSts,(long)switchObj.tag];
    }
    
    [[DataBaseManager dataBaseManager] execute:updateStr];
    
    if (![deviceID isEqualToString:@"NA"])
    {
        [self switchOffDevice:deviceID withType:newValue];
    }
}

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj
{
    [switchObj setCustomKnobImage:[UIImage imageNamed:(switchObj.isOn) ? @"on_icon" : @"off_icon"]
          inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]
            activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
}

-(void)switchOffDevice:(NSString *)sentID withType:(BOOL)isOn
{
    NSString * strON;
    if (isOn)
    {
        strON = @"1";
        isSentNoticication = YES;
    }
    else
    {
        isSentNoticication = NO;
        strON = @"0";
    }
    NSInteger int1 = [@"50" integerValue];
    NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];
    
    globalCount = globalCount + 1;
    NSInteger int2 = globalCount;
    NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2];
    
    NSInteger int3 = [@"9000" integerValue];
    NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2];
    
    NSInteger int4 = [sentID integerValue];
    NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2];
    
    NSInteger int5 = [@"1234" integerValue];
    NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2];
    
    NSInteger int6 = [@"85" integerValue];
    NSData * data6 = [[NSData alloc] initWithBytes:&int6 length:2];
    
    NSInteger int7 = [strON integerValue];
    NSData * data7 = [[NSData alloc] initWithBytes:&int7 length:1];
    
    NSMutableData * completeData = [[NSMutableData alloc] init];
    completeData = [data1 mutableCopy];
    [completeData appendData:data2];
    [completeData appendData:data3];
    [completeData appendData:data4];
    [completeData appendData:data5];
    [completeData appendData:data6];
    [completeData appendData:data7];
    [[BLEService sharedInstance] writeValuetoDeviceMsg:completeData with:globalPeripheral];
    [[NSUserDefaults standardUserDefaults] setInteger:globalCount forKey:@"GlobalCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [APP_DELEGATE sendSignalViaScan:@"OnOff" withDeviceID:sentID withValue:strON]; //KalpeshScanCode
    
    if (isFromAll)
    {
        
    }
    else
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setValue:strON forKey:@"isSwitch"];
        
        NSString * strSwitchNotify = [NSString stringWithFormat:@"updateDataforONOFF%@",strGlogalNotify];

        [[NSNotificationCenter defaultCenter] postNotificationName:strSwitchNotify object:dict];
    }
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
                [self performSelector:@selector(checkTimeOut) withObject:nil afterDelay:5];
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
            [self performSelector:@selector(checkTimeOut) withObject:nil afterDelay:5];
            return NO;
        }
    }
    return NO;
}

-(void)checkTimeOut
{
    [APP_DELEGATE hideScannerView];
    [APP_DELEGATE endHudProcess];
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        isShowPopup = YES;
    }
    else
    {
        if (isShowPopup)
        {
            
        }
        else
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            alert.tag = 222;
            alert.delegate =self;
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"There is something went wrong. Please try again later."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
            
        }
    }
}

#pragma mark - BLE Methods

-(void)InitialBLE
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallNotificationforDiscover" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"deviceDidDisConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"deviceDidConnectNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDiscoverPeripheralNotification:) name:@"CallNotificationforDiscover" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidConnectNotification:) name:@"deviceDidConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidDisConnectNotification:) name:@"deviceDidDisConnectNotification" object:nil];
}

-(void)didDiscoverPeripheralNotification:(NSNotification*)notification//Update peripheral
{
}
-(void)DeviceDidConnectNotification:(NSNotification*)notification//Connect periperal
{
    isShowPopup = YES;
    
    [APP_DELEGATE hideScannerView];
    [APP_DELEGATE endHudProcess];
//    [[BLEService sharedInstance] sendNotifications:globalPeripheral withType:NO];
    [[BLEManager sharedManager] centralmanagerScanStop];
}

-(void)DeviceDidDisConnectNotification:(NSNotification*)notification//Disconnect periperal
{
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 222)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
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
