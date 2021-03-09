//
//  DeviceDetailVC.m
//  SmartLightApp
//
//  Created by stuart watts on 29/11/2017.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import "DeviceDetailVC.h"
#import "UIColor+extensions.h"
#import "UIColor+BrandColors.h"
#import <AVFoundation/AVFoundation.h>
#import "MMParallaxCell.h"
#import "Rec_customview.h"
#import "UIView+colorOfPoint.h"
#import "KPWhiteColorImgView.h"
#import "tagsTableVC.h"
#import "AHTagTableViewCell.h"
#import <SAMultisectorControl/SAMultisectorControl.h>
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import "JMMarkSlider.h"
#import <Lottie/Lottie.h>
#import "UIImage+animatedGIF.h"
#import "AlarmColorSelectVC.h"
#import "PatternCell.h"
#import "HRHSVColorUtil.h"

#define kColorCellIdentifier @"KPSolidColorViewCellReuseIdentifier"

@interface DeviceDetailVC ()<FCAlertViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,CBCentralManagerDelegate>
{
    BOOL isVoiceCreated;
    UILabel * lblTitle, * lblVoiceStatus;
    UIImageView * imgVoice, * imgBack;
    Rec_customview *cust_view;
    NSTimer * voiceTimer;
    BOOL isListening;
    CGFloat imageBrighValue;
    SAMultisectorControl *multisectorControl;
    UIImageView * imgRGBBulb ;
    BOOL isMusicModeOn;
    int selectedWheel, lastSendMusicBeats;
    UIImageView * btnCheckMark;
    CGFloat slideRed, slideGreen, slideBlue;
    LOTAnimationView *animation;
    UIImageView* animatedImageView;
    CBCentralManager *centralManager;
    UISlider *brightnessSliderColorView;
    UIButton * btnOptions;
    BOOL isfromSolid;
    UIView * settingView;
    UITableView * tblSettings;
}
@property (strong, nonatomic) JMMarkSlider * redSlider;
@property (strong, nonatomic) JMMarkSlider * greenSlider;
@property (strong, nonatomic) JMMarkSlider * blueSlider;

@end
@implementation NSArray (Extensions)

- (NSArray *)map:(id (^)(id obj))block {
    NSMutableArray *mutableArray = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        [mutableArray addObject:block(obj)];
    }];
    return mutableArray;
}
@end

@implementation DeviceDetailVC
{
    NSArray<NSArray<AHTag *> *> *_dataSource;
}
@synthesize  brightnessSliderVal;

@synthesize _switchLight, deviceName,deviceDict,isFromScan,isFromAll,isfromGroup,isDeviceWhite,colorPicker;
- (void)viewDidLoad
{

    self.view.backgroundColor = UIColor.blackColor;
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

    patternSelected = -1;
    imageBrighValue = 1.0;
    
    [APP_DELEGATE startAdvertisingBeacons];
    [super viewDidLoad];
    
    imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    imgBack.userInteractionEnabled = YES;
    imgBack.hidden = true;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];
    
    yAbove = 0;

    if (isDeviceWhite)
    {
        [self setWhiteView];
    }
    else
    {
        [self setVoiceArrays];
        [self setSegmentView];
        [self SetViewforColorWheel];
    }
    brighcount = 100;
    isChanged = NO;
    isShowPopup = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetFavoriteColors" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetFavoriteColors:) name:@"GetFavoriteColors" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (isDeviceWhite == NO)
    {
    }
}
-(void)viewWillAppear:(BOOL)animated
{
 self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    
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
    currentScreen = @"Detail";
    [APP_DELEGATE hideTabBar:self.tabBarController];
    if (isDeviceWhite)
    {
    }
    else
    {
        [colorTimer invalidate];
        colorTimer = [NSTimer scheduledTimerWithTimeInterval:.52 target:self selector:@selector(MethodtoSendColor) userInfo:nil repeats:YES];
        
        [brightTimer invalidate];
        brightTimer = [NSTimer scheduledTimerWithTimeInterval:.4 target:self selector:@selector(brightcol) userInfo:nil repeats:YES];
    }
    [[BLEManager sharedManager] centralmanagerScanStop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:currentScreen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBleStatus) name:currentScreen object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowColorSelectScreen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowAddFavColorScreen) name:@"ShowColorSelectScreen" object:nil];


    
    if (isMusicModeOn)
    {
        [self startRecording];
    }
    [super viewWillAppear:YES];
}
-(void)viewDidDisappear:(BOOL)animated
{
    isNonConnectScanning = NO;
    [[BLEManager sharedManager] updateBluetoothState];
    
    [colorTimer invalidate];
    [brightTimer invalidate];
    [timeoutTimer invalidate];
    
    if (self.delegate)
    {
        [self.delegate setSelectedColor:selectedColors];
    }
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.4;
    [viewHeader addSubview:lblBack];
    
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 13, DEVICE_WIDTH-110, 54)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:[NSString stringWithFormat:@"%@",deviceName]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    lblTitle.numberOfLines = 0;
    [viewHeader addSubview:lblTitle];
    
    if (isFromAll)
    {
        lblTitle.frame = CGRectMake(0, 20, DEVICE_WIDTH-00, 44);
    }
    if (isDeviceWhite)
    {
        [lblTitle setText:@"Set brightness"];
    }
    
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 80, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];
    
    _switchLight = [[ORBSwitch alloc] initWithCustomKnobImage:[UIImage imageNamed:@"off_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] frame:CGRectMake(0, 0, 100, 60)];
    _switchLight.isOn = NO;
    _switchLight.knobRelativeHeight = 0.8f;
    _switchLight.frame = CGRectMake(DEVICE_WIDTH-50, 22, 60, 40);
    _switchLight.delegate =self;
    [viewHeader addSubview:_switchLight];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-110, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 88, 88);
        _switchLight.frame = CGRectMake(DEVICE_WIDTH-50, 46, 60, 40);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
    }
    
    if ([[deviceDict valueForKey:@"switch_status"] isEqualToString:@"Yes"])
    {
        _switchLight.isOn = YES;
        [_switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
    }
    
    if (isFromAll)
    {
        if (isAlldevicePowerOn)
        {
            _switchLight.isOn = YES;
            [_switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
        }
        else
        {
            _switchLight.isOn = NO;
            [_switchLight setCustomKnobImage:[UIImage imageNamed:@"off_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
        }
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
    [lblTitle setText:[NSString stringWithFormat:@"%@",deviceName]];
}
-(void)setSegmentView
{
    long yy = 0;

    [blueSegmentedControl removeFromSuperview];
    blueSegmentedControl =[[NYSegmentedControl alloc] initWithItems:@[@"Color",@"Scenes",@"Music"]];
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
    [blueSegmentedControl setFrame:CGRectMake(20,64+10, DEVICE_WIDTH-40, 40)];
    blueSegmentedControl.layer.cornerRadius = 20;
    blueSegmentedControl.layer.masksToBounds = YES;
    [self.view addSubview:blueSegmentedControl];
    
    yy = 104;

    if (IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        blueSegmentedControl.cornerRadius = 20 * approaxSize;
        [blueSegmentedControl setFrame:CGRectMake(20,84*approaxSize, DEVICE_WIDTH-40, 40 * approaxSize)];
        blueSegmentedControl.layer.cornerRadius = 20 * approaxSize;
        yy = 84*approaxSize + 40 * approaxSize;
    }

    optionView = [[UIView alloc] init];
    optionView.frame = CGRectMake(0,(yy+20)*approaxSize, DEVICE_WIDTH, 40*approaxSize);
    optionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:optionView];
    
    NSArray * optArr = [NSArray arrayWithObjects:@"Color",@"Custom",@"White",@"Voice",@"RGB", nil];
    for (int i = 0; i<[optArr count]; i++)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i*(DEVICE_WIDTH/5), 0, DEVICE_WIDTH/5, (40*approaxSize)-5);
        btn.tag = i+50;
        [btn addTarget:self action:@selector(SubMenuEventClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:[optArr objectAtIndex:i] forState:UIControlStateNormal];
        [optionView addSubview:btn];
        [btn.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSizes]];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        if (i==0)
        {
            [btn.titleLabel setFont:[UIFont fontWithName:CGBold size:textSizes+2]];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
    
    stsImgY = ((yy+20)+60)*approaxSize;
    yAbove =  (yy+20)*approaxSize + 40*approaxSize;

    if (IS_IPHONE_X)
    {
        blueSegmentedControl.cornerRadius = 20 * approaxSize;
        [blueSegmentedControl setFrame:CGRectMake(20,108*approaxSize, DEVICE_WIDTH-40, 40 * approaxSize)];
        blueSegmentedControl.layer.cornerRadius = 20 * approaxSize;
        
        yy = blueSegmentedControl.frame.size.height + blueSegmentedControl.frame.origin.y;
        optionView.frame = CGRectMake(0,(yy+22)*approaxSize, DEVICE_WIDTH, 40*approaxSize);
        
        stsImgY = ((yy+22)+60)*approaxSize;
        yAbove =  (yy+22)*approaxSize + 40*approaxSize;
    }
}
-(void)SetupForSetting
{
    int yHeight = (blueSegmentedControl.frame.size.height + blueSegmentedControl.frame.origin.y)*approaxSize + 0;

    settingView = [[UIView alloc] initWithFrame:CGRectMake(0, yHeight, DEVICE_WIDTH, DEVICE_HEIGHT-yHeight)];
    settingView.backgroundColor = UIColor.clearColor;
    settingView.hidden = true;
    [self.view addSubview:settingView];
    
    
    tblSettings = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, settingView.frame.size.width, settingView.frame.size.height)];
    tblSettings.backgroundColor = UIColor.clearColor;
    tblSettings.delegate = self;
    tblSettings.dataSource = self;
    [settingView addSubview:tblSettings];
    
    
}
#pragma mark - ===========Here Send COLORS to Device===========
-(void)MethodtoSendColor
{
    if (isChanged)
    {
        if(isMusicModeOn)
        {
            isMusicModeOn = NO;
            [btnMusic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnMusic setTitle:@"Start Music Mode" forState:UIControlStateNormal];
            animatedImageView.image = [UIImage imageNamed:@"stoppedMusic.png"];
            [timerForPitch invalidate];
            [timerforMusicCount invalidate];
            [self stopRecording];
        }
        
        CGFloat brightness; [imgColor getHue:NULL saturation:NULL brightness:&brightness alpha:NULL];
        if (brightness >= 0.1)
        {
            HRHSVColor hsvColor;
            HSVColorFromUIColor(imgColor, &hsvColor);
            if (imageBrighValue == 0)
            {
                imageBrighValue = 1;
            }
            hsvColor.v = imageBrighValue;
            UIColor *newColor = [[UIColor alloc] initWithHue:hsvColor.h
                                                  saturation:hsvColor.s
                                                  brightness:hsvColor.v
                                                       alpha:1];
            if (isfromSolid)
            {
                newColor = imgColor;
            }
            const  CGFloat *_components = CGColorGetComponents(newColor.CGColor);
            CGFloat red     = _components[0]; CGFloat green = _components[1]; CGFloat blue   = _components[2];
            
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
            isChanged = YES;
            if (isSentNoticication)
            {
            }
            else
            {
                isSentNoticication = YES;
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                [dict setValue:@"1" forKey:@"isSwitch"];
                NSString * strSwitchNotify = [NSString stringWithFormat:@"updateDataforONOFF%@",strGlogalNotify];
                [[NSNotificationCenter defaultCenter] postNotificationName:strSwitchNotify object:dict];
                _switchLight.isOn = YES;
                [_switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
            }
        }
        if (isWarmWhite)
        {
            if (fullRed ==0 && fullBlue ==0 && fullGreen == 0)
            {
            }
            else
            {
                [APP_DELEGATE sendSignalViaScan:@"ColorWhiteChange" withDeviceID:globalGroupId withValue:@"0"]; //KalpeshScanCode
            }
        }
        else
        {
            if (fullRed ==0 && fullBlue ==0 && fullGreen == 0)
            {
            }
            else
            {
                [APP_DELEGATE sendSignalViaScan:@"ColorChange" withDeviceID:globalGroupId withValue:@"0"]; //KalpeshScanCode
            }
        }
        
        isChanged = NO;
        
        if (isFromAll)
        {
            _switchLight.isOn = YES;
            isAlldevicePowerOn = YES;
            [_switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
        }
        else
        {
            _switchLight.isOn = YES;
            [_switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
        }
        if (globalPeripheral.state == CBPeripheralStateConnected)
        {
//            [[BLEService sharedInstance] writeColortoDevice:completeData with:globalPeripheral withDestID:globalGroupId];
        }
        [[NSUserDefaults standardUserDefaults] setInteger:globalCount forKey:@"GlobalCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        isChanged = NO;
    }
}
#pragma mark - ===========FOR COLORS===========
-(void)SetViewforColorWheel
{
    colorSquareView = [[UIView alloc] init];
    colorSquareView.frame = CGRectMake(0, yAbove, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove);
    colorSquareView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:colorSquareView];

    imgColorOptionView = [[KPWhiteColorImgView alloc] initWithFrame:CGRectMake(0, (colorSquareView.frame.size.height-DEVICE_WIDTH)/2-20, DEVICE_WIDTH, DEVICE_WIDTH)];
    imgColorOptionView.image = [UIImage imageNamed:@"ic_wheel_two.png"];
    imgColorOptionView.pickedColorDelegate = self;
    imgColorOptionView.backgroundColor = [UIColor clearColor];
    imgColorOptionView.layer.masksToBounds=YES;
    imgColorOptionView.userInteractionEnabled = YES;
    imgColorOptionView.layer.masksToBounds = YES;
    [colorSquareView addSubview:imgColorOptionView];
    
    if (IS_IPHONE_X)
    {
        colorSquareView.frame = CGRectMake(0, yAbove, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove-45);
        imgColorOptionView.frame = CGRectMake(0,80, DEVICE_WIDTH,DEVICE_WIDTH);
    }
    else if (IS_IPHONE_4)
    {
        imgColorOptionView.frame = CGRectMake(0, (colorSquareView.frame.size.height-DEVICE_WIDTH)/2+10, DEVICE_WIDTH-0, DEVICE_WIDTH-60);
//        imgColorOptionView.layer.cornerRadius = (DEVICE_WIDTH-60)/2;
    }
    btnOptions = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOptions.frame = CGRectMake(DEVICE_WIDTH-50,(DEVICE_HEIGHT-35)-yAbove-5 , 50, 35);
    btnOptions.backgroundColor = [UIColor clearColor];
    [btnOptions addTarget:self action:@selector(btnMoreColorOptionClick) forControlEvents:UIControlEventTouchUpInside];
    [btnOptions setImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
    [colorSquareView addSubview:btnOptions];
    
    isColorOptionON = YES;
    colorSquareView.hidden = NO;
    
    imgColorOptionView.layer.masksToBounds = YES;
    
    brightnessSliderColorView = [[UISlider alloc]init];
    brightnessSliderColorView.frame = CGRectMake(20,colorSquareView.frame.size.height-40,DEVICE_WIDTH-100, 40);
    brightnessSliderColorView.backgroundColor = UIColor.clearColor;
    brightnessSliderColorView.value = 100;
    brightnessSliderColorView.minimumValue = 20;
    brightnessSliderColorView.maximumValue = 100;
    brightnessSliderColorView.continuous = YES;
    brightnessSliderColorView.minimumTrackTintColor = UIColor.whiteColor;
    brightnessSliderColorView.maximumTrackTintColor = UIColor.lightGrayColor;
    brightnessSliderColorView.thumbTintColor = global_brown_color;
    [brightnessSliderColorView addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
    [colorSquareView addSubview:brightnessSliderColorView];
    
    imgColor = UIColor.whiteColor;
    
    float updateBrightnessValue = brightnessSliderVal;
    updateBrightnessValue = updateBrightnessValue*100;
    imageBrighValue = updateBrightnessValue/100;
    brightnessSliderColorView.value = updateBrightnessValue;
    float tempRed = [[deviceDict valueForKey:@"red"] floatValue];
    float  tempGreen = [[deviceDict valueForKey:@"green"] floatValue];
    float tempBLue = [[deviceDict valueForKey:@"blue"]floatValue ];
    UIColor * currColor = [UIColor colorWithRed:tempRed/255.0 green:tempGreen/255.0 blue:tempBLue/255.0 alpha:1];
    if (isFromAll == NO && isfromGroup == NO)
    {
        if (currColor != nil)
        {
            imgColor = currColor;
        }
    }

    /*if (![[self checkforValidString:[deviceDict valueForKey:@"brightnessValue"]] isEqualToString:@"NA"])
    {
        float updateBrightnessValue = [[deviceDict valueForKey:@"brightnessValue"] floatValue];
        updateBrightnessValue = updateBrightnessValue*100;
        imageBrighValue = updateBrightnessValue/100;
        brightnessSliderColorView.value = updateBrightnessValue;
        float tempRed = [[deviceDict valueForKey:@"red"] floatValue];
        float  tempGreen = [[deviceDict valueForKey:@"green"] floatValue];
        float tempBLue = [[deviceDict valueForKey:@"blue"]floatValue ];
        UIColor * currColor = [UIColor colorWithRed:tempRed/255.0 green:tempGreen/255.0 blue:tempBLue/255.0 alpha:1];
        if (isFromAll == NO && isfromGroup == NO)
        {
            if (currColor != nil)
            {
                imgColor = currColor;
            }
        }
    }
    else
    {
        imageBrighValue = 1;
    }*/
    
    /*lblThumbTint = [[UILabel alloc]init];
    lblThumbTint.frame = CGRectMake(20, colorSquareView.frame.size.height-40-20, 35, 30);
    lblThumbTint.backgroundColor = UIColor.clearColor;
    lblThumbTint.textAlignment = NSTextAlignmentCenter;
    lblThumbTint.font = [UIFont fontWithName:CGRegular size:textSizes-4];
    lblThumbTint.textColor = UIColor.whiteColor;
    [[brightnessSliderColorView superview]addSubview:lblThumbTint];*/

    if (IS_IPHONE_X)
    {
        btnOptions.frame = CGRectMake(DEVICE_WIDTH-50,(DEVICE_HEIGHT-35-44)-yAbove-5 , 50, 35);
    }
    
    UIImageView * imgFullBrightness = [[UIImageView alloc]init];
    imgFullBrightness.frame = CGRectMake(DEVICE_WIDTH-50-25,colorSquareView.frame.size.height-30 ,20 ,20 );
    imgFullBrightness.image = [UIImage imageNamed:@"fullBright.png"];
    [colorSquareView addSubview:imgFullBrightness];

    UIImageView * imgLowBrightness = [[UIImageView alloc]init];
    imgLowBrightness.frame = CGRectMake(5,colorSquareView.frame.size.height-25 ,10 ,10 );
    imgLowBrightness.image = [UIImage imageNamed:@"lowBright.png"];
    [colorSquareView addSubview:imgLowBrightness];
    
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        [colorSquareView setHidden:NO];
    } completion:nil];
    imgColorOptionView.currentColorBlock = ^(UIColor *color){
        isfromSolid = NO;
        imgColor = color;
        isChanged = YES;
    };
}
-(void)btnMoreColorOptionClick
{
    [backView removeFromSuperview];
    if (isWarmWhite)
    {
        [self btnWarmOptionClick];
    }
    else
    {
        [self OpenAllcoloroptionView];
    }
}
-(void)OpenAllcoloroptionView
{
    [backView removeFromSuperview];
    backView = [[UIView alloc]init];
    backView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    backView.backgroundColor = UIColor.blackColor;
    backView.alpha = 0.5;
    [self.view addSubview:backView];
    
    [scrlView removeFromSuperview];
    scrlView = [[UIScrollView alloc] init];
    scrlView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, DEVICE_HEIGHT);
    scrlView.backgroundColor = [UIColor blackColor];
//    scrlView.contentSize = CGSizeMake(DEVICE_WIDTH, 100);
    [self.view addSubview:scrlView];
    
    
    UILabel * lblTitle = [[UILabel alloc] init];
    lblTitle.frame = CGRectMake(0, 0, scrlView.frame.size.width, 50);
    lblTitle.font = [UIFont fontWithName:CGRegular size:textSizes];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.text = @"Select Wheel to change";
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.backgroundColor = [UIColor blackColor];
    [scrlView addSubview:lblTitle];
    
    UILabel * lblline = [[UILabel alloc] init];
    lblline.frame = CGRectMake(0, 49, scrlView.frame.size.width, 0.5);
    lblline.backgroundColor = [UIColor lightGrayColor];
    [scrlView addSubview:lblline];
    
    UIButton * btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = CGRectMake(0, 0, 60, 50);
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes-1];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(btnCloseOptionView) forControlEvents:UIControlEventTouchUpInside];
    [scrlView addSubview:btnCancel];
    
    int xx = 0;
    int yy = 50;
    int cnt = 0;
    int vWidth = (DEVICE_WIDTH/2);
    int vHeighth = (DEVICE_WIDTH/2);
    
    NSArray * imgArr = [NSArray arrayWithObjects:@"ic_wheel_two.png",@"ic_wheel_five.png", nil];
    
    for (int i=0; i<[imgArr count]; i++)
    {
            UILabel * lblTmp = [[UILabel alloc] init];
            lblTmp.frame = CGRectMake(xx, yy, vWidth, vHeighth-20);
            lblTmp.backgroundColor = [UIColor clearColor];
            lblTmp.userInteractionEnabled = YES;
            lblTmp.text = @" ";
            [scrlView addSubview:lblTmp];
            
            UIImageView * img = [[UIImageView alloc] init];
            img.frame = CGRectMake(10,10, vWidth-20, vWidth-20);
            img.image = [UIImage imageNamed:[imgArr objectAtIndex:cnt]];
            img.backgroundColor = [UIColor clearColor];
            [lblTmp addSubview:img];
            
            UIButton * btnTap = [UIButton buttonWithType:UIButtonTypeCustom];
            btnTap.frame = lblTmp.frame;
            [btnTap addTarget:self action:@selector(chooseColorWheelClick:) forControlEvents:UIControlEventTouchUpInside];
            btnTap.tag = cnt;
            [scrlView addSubview:btnTap];
            xx = vWidth + xx;
            cnt = cnt +1;
    }
    [self hideMorePopUpView:NO];
}
-(void)btnCloseOptionView
{
    [backView removeFromSuperview];
    [self hideMorePopUpView:YES];
}
-(void)chooseColorWheelClick:(id)sender
{
    [backView removeFromSuperview];
    isColorOptionON = YES;
    colorSquareView.hidden = NO;
    imgColorOptionView.layer.masksToBounds = YES;
    imgColorOptionView.frame = CGRectMake(0, ((colorSquareView.frame.size.height-DEVICE_WIDTH)/2)-17, DEVICE_WIDTH, DEVICE_WIDTH);
    imgColorOptionView.hidden = NO;
    
    if (IS_IPHONE_4)
    {
        imgColorOptionView.frame = CGRectMake(25, (colorSquareView.frame.size.height-(DEVICE_WIDTH-25))/2, DEVICE_WIDTH-50, DEVICE_WIDTH-50);
    }
    imgColorOptionView.isSquareImage = NO;
    
    selectedWheel = [sender tag];
    if ([sender tag]==0)
    {
        imgColorOptionView.image = [UIImage imageNamed:@"ic_wheel_two.png"];
    }
    else if ([sender tag]==1)
    {
        imgColorOptionView.frame = CGRectMake(0, 0, DEVICE_WIDTH, colorSquareView.frame.size.height-40);
        imgColorOptionView.isSquareImage = YES;
        imgColorOptionView.image = [UIImage imageNamed:@"ic_wheel_five.png"];
        imgColorOptionView.layer.cornerRadius = 0;
        imgColorOptionView.layer.masksToBounds = YES;
    }
    [self hideMorePopUpView:YES];
}
-(void)hideMorePopUpView:(BOOL)isHide
{
    if (isHide == YES)
    {
        [scrlView drop:^{
            [scrlView removeFromSuperview];
            [backView removeFromSuperview];
        }];
    }
    else
    {
        if (isVoicView)
        {
            [UIView transitionWithView:scrlView duration:0.2
                               options:UIViewAnimationOptionCurveLinear
                            animations:^{
                                scrlView.frame = CGRectMake(0, 20, DEVICE_WIDTH, DEVICE_HEIGHT-20);
                            }
                            completion:^(BOOL finished)
             {
             }];
        }
        else
        {
            [UIView transitionWithView:scrlView duration:0.2
                               options:UIViewAnimationOptionCurveLinear
                            animations:^{
                                if (IS_IPHONE_X)
                                {
                                    scrlView.frame = CGRectMake(0, DEVICE_HEIGHT-250, DEVICE_WIDTH, DEVICE_HEIGHT-250);
                                }
                                else
                                {
                                    scrlView.frame = CGRectMake(0, DEVICE_HEIGHT-210, DEVICE_WIDTH, DEVICE_HEIGHT-210);
                                }
                            }
                            completion:^(BOOL finished)
             {
             }];
        }
    }
}

-(UIColor *)getColorfromBrightness:(CGFloat)adjusrBright withColor:(UIColor *)newColor
{
    CGFloat hue, saturation, brightness, alpha;
    if ([newColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha])
    {
        brightness += (adjusrBright - 1.0);
        brightness = fmax(MIN(brightness, 1.0), 0.0);
    }
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
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
-(void)brightnessChanged:(id)sender
{
    if(isMusicModeOn)
    {
        [self stopRecording];
    }
    UISlider *slider = (UISlider*)sender;
    imageBrighValue = slider.value/100;
    isChanged = YES;
    int currentvalue = slider.value;
    
    CGRect trackRect = [slider trackRectForBounds:slider.bounds];
    CGRect thumbRect = [slider thumbRectForBounds:slider.bounds trackRect:trackRect value:slider.value];
    
    
//    lblThumbTint.center = CGPointMake(thumbRect.origin.x +slider.frame.origin.x+20,slider.frame.origin.y-5); // baiyya commented
//    lblThumbTint.text = [[NSString alloc]initWithFormat:@"%d %@",currentvalue,@"%"]; // baiyya commented
}
#pragma mark - SOLID VIEW SETUP
-(void)setSolidView
{
    brandedColors = [[NSArray alloc] init];
    brandedColors = [UIColor bc_brands];
    
    solidView  = [[UIView alloc] init];
    solidView.frame = CGRectMake(0, yAbove, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove);
    solidView.backgroundColor = [UIColor blackColor];
    solidView.hidden = YES;
    [self.view addSubview:solidView];

    solidColorView = [[KPSolidColorView alloc] init];
    solidColorView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove);
    solidColorView.delegate = self;
    solidColorView.rowCount = 4;
    solidColorView.cellPaddings = 2.0;
    solidColorView.highlightSelection = YES;
    solidColorView.selectionBorderColor = [UIColor blackColor];
    [solidColorView setColors:[self CreateNewColors]];
    solidColorView.backgroundColor = [UIColor clearColor];
    solidColorView.rgbwColor = [NSArray arrayWithObjects:[UIColor redColor],[UIColor greenColor],[UIColor blueColor],[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0], nil];
    [solidView addSubview:solidColorView];
    gridSize = 4;
    if (IS_IPHONE_X)
    {
        solidView.frame = CGRectMake(0, yAbove, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove-45);
        solidColorView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove-45);
    }
//    solidView.hidden = YES;
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        [solidView setHidden:NO];
    } completion:nil];
}
-(void)pickSolidColor:(KPSolidColorView *)pickerView didSelectColor:(UIColor *)color;
{
    isfromSolid = YES;
    imgColor = color;
    const  CGFloat *_components = CGColorGetComponents(color.CGColor);
    CGFloat red   = _components[0];
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
    
    isChanged = YES;
}
-(NSArray *)CreateNewColors
{
    NSMutableArray * colors = [[NSMutableArray alloc] init];
    NSString * strQuery = [NSString stringWithFormat:@"select * from tbl_solid_color"];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:colors];
    
    NSMutableArray * onlyColorsArr = [[NSMutableArray alloc] init];

    for (int i =4; i<[colors count]; i++)
    {
        CGFloat tmpR = [[[colors objectAtIndex:i] valueForKey:@"color_red"] floatValue];
        CGFloat tmpG = [[[colors objectAtIndex:i] valueForKey:@"color_green"] floatValue];
        CGFloat tmpB = [[[colors objectAtIndex:i] valueForKey:@"color_blue"] floatValue];

        UIColor * tmpColor = [UIColor colorWithRed:tmpR/255.0f green:tmpG/255.0f blue:tmpB/255.0f alpha:1.0];
        [onlyColorsArr addObject:tmpColor];
    }
    return onlyColorsArr;
}

-(void)ShowAddFavColorScreen
{
    AlarmColorSelectVC  * alarmColor = [[AlarmColorSelectVC alloc] init];
    alarmColor.isFromAlarm = NO;
    [self.navigationController pushViewController:alarmColor animated:YES];
}
-(void)GetFavoriteColors:(NSNotification *)notify
{
    NSDictionary *dict = [notify object];
    NSString * strValue = [dict valueForKey:@"value"];

    UIColor * rgbColor = [self colorWithHexString:strValue];
    const  CGFloat *_components = CGColorGetComponents(rgbColor.CGColor);
    CGFloat red   = _components[0] * 255;
    CGFloat green = _components[1] * 255;
    CGFloat blue  = _components[2] * 255;
    
    NSString * strQry = [NSString stringWithFormat:@"select * from Solid_Fav_Color where color_name = '%@' and user_id = '%@'",strValue,CURRENT_USER_ID];
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:strQry resultsArray:tmpArr];
    if ([tmpArr count]==0)
    {
        NSString * strQuery = [NSString stringWithFormat:@"insert into 'Solid_Fav_Color'('color_name','color_rgb','color_red','color_green','color_blue','user_id') values('%@','%@','%f','%f','%f','%@')",strValue,strValue,red,green,blue,CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:strQuery];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateFavColors" object:nil];
    }
}
-(void)selectedIndexforFavDelete:(NSMutableDictionary *)dataDict;
{
    NSString * msgStr = [NSString stringWithFormat:@"Are you sure. You want to delete this Favourite Color?"];
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    [alert addButton:@"Yes" withActionBlock:^{
        {
            NSString * strDelete = [NSString stringWithFormat:@"delete from Solid_Fav_Color where id ='%@'",strDeleteFavColor];
            [[DataBaseManager dataBaseManager] execute:strDelete];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateFavColors" object:nil];
            //Remove here
        }
    }];
    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:msgStr
           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
       withDoneButtonTitle:@"No" andButtons:nil];
    
}
#pragma mark - FOR PATTERN VIEW
-(void)setPatternView
{

    int yHeight = (blueSegmentedControl.frame.size.height + blueSegmentedControl.frame.origin.y)*approaxSize + 0;
    patternView  = [[UIView alloc] init];
    patternView.frame = CGRectMake(0,yHeight  , DEVICE_WIDTH, DEVICE_HEIGHT-yHeight);
    patternView.backgroundColor = [UIColor blackColor];
    patternView.hidden = YES;
    [self.view addSubview:patternView];
    
    [tblView removeFromSuperview];
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, DEVICE_HEIGHT-yHeight) style:UITableViewStylePlain];
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblView.tableFooterView = [UIView new];
    [patternView addSubview:tblView];
    if (IS_IPHONE_X)
    {
        tblView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-yHeight-45);
    }
    
    [UIView transitionWithView:patternView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        [patternView setHidden:NO];
    } completion:nil];

}
-(void)sendPattern
{
    isfromSolid = NO;
    
    [APP_DELEGATE sendSignalViaScan:@"Pattern" withDeviceID:globalGroupId withValue:[NSString stringWithFormat:@"%ld",(long)selecedPtrn]]; //KalpeshScanCode
    if (globalPeripheral.state ==CBPeripheralStateConnected)
    {
        NSInteger int1 = [@"50" integerValue];
        NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];
        
        NSMutableData * collectChekData = [[NSMutableData alloc] init];
        
        globalCount = globalCount + 1;
        
        NSInteger int2 = globalCount;
        NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2];
        collectChekData = [data2 mutableCopy];
        
        NSInteger int3 = [@"9000" integerValue];
        NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2];
        [collectChekData appendData:data3];
        
        NSInteger int4 = [globalGroupId integerValue];
        NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2];
        [collectChekData appendData:data4];
        
        NSInteger int5 = [@"0" integerValue];
        NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2];
        [collectChekData appendData:data5];
        
        NSInteger int6 = [@"67" integerValue];
        NSData * data6 = [[NSData alloc] initWithBytes:&int6 length:2];
        [collectChekData appendData:data6];
        
        NSInteger int7 = selecedPtrn;
        NSData * data7 = [[NSData alloc] initWithBytes:&int7 length:1];
        [collectChekData appendData:data7];
        
        NSData * finalCheckData = [APP_DELEGATE GetCountedCheckSumData:collectChekData];
        
        completeData = [[NSMutableData alloc] init];
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
}
#pragma mark - FOR WARM WHITE
-(void)setWarmLightheel
{

    bgWhiteView = [[UIView alloc] init];
    bgWhiteView.frame = CGRectMake(0, yAbove, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove-40);
    bgWhiteView.backgroundColor = [UIColor blackColor];
    bgWhiteView.hidden=YES;
    [self.view addSubview:bgWhiteView];
    
    CGSize size = bgWhiteView.bounds.size;
    CGSize wheelSize = CGSizeMake(size.width * .78, size.width * .78);
    
    colorPicker = [[KPWhiteColorImgView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_WIDTH-yAbove-15)];
    colorPicker.frame = CGRectMake(size.width /2 - wheelSize.width / 2,(size.height / 2 - wheelSize.height / 2),wheelSize.width,wheelSize.height);
    colorPicker.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove-35-15);
    colorPicker.image = [UIImage imageNamed:@"WharmLight1.png"];
    colorPicker.pickedColorDelegate = self;
    colorPicker.backgroundColor = [UIColor clearColor];
    colorPicker.layer.masksToBounds=YES;
    colorPicker.userInteractionEnabled = YES;
    [bgWhiteView addSubview:colorPicker];
    
    if (IS_IPHONE_X)
    {
        bgWhiteView.frame = CGRectMake(0, yAbove, DEVICE_WIDTH,DEVICE_HEIGHT-yAbove-15-45-40);
        colorPicker.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove-15-45-40);
        
    }
    colorPicker.currentColorBlock = ^(UIColor *color){
        isfromSolid = NO;
        imgColor = color;
        isChanged = YES;
    };
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        [bgWhiteView setHidden:NO];
    } completion:nil];
}
-(void)btnWarmOptionClick
{
    [backView removeFromSuperview];
    backView = [[UIView alloc]init];
    backView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    backView.backgroundColor = UIColor.blackColor;
    backView.alpha = 0.5;
    [self.view addSubview:backView];
    
    [scrlView removeFromSuperview];
    scrlView = [[UIScrollView alloc] init];
    scrlView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, DEVICE_HEIGHT-355);
    scrlView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:scrlView];
    
    UILabel * lblTitle = [[UILabel alloc] init];
    lblTitle.frame = CGRectMake(0, 0, scrlView.frame.size.width, 50);
    lblTitle.font = [UIFont fontWithName:CGRegular size:textSizes];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.text = @"Select Wheel to change";
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.backgroundColor = [UIColor blackColor];
    [scrlView addSubview:lblTitle];
    
    UILabel * lblline = [[UILabel alloc] init];
    lblline.frame = CGRectMake(0, 49, scrlView.frame.size.width, 0.5);
    lblline.backgroundColor = [UIColor lightGrayColor];
    [scrlView addSubview:lblline];
    
    UIButton * btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = CGRectMake(0, 0, 60, 50);
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes-1];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(btnCloseOptionView) forControlEvents:UIControlEventTouchUpInside];
    [scrlView addSubview:btnCancel];
    
    int xx = 0;
    int yy = 50;
    int cnt = 0;
    int vWidth = (DEVICE_WIDTH/2);
    int vHeighth = (DEVICE_WIDTH/2);
    
    NSArray * imgArr = [NSArray arrayWithObjects:@"WharmLight1.png",@"WharmLight2.png", nil];
    
    for (int i=0; i<[imgArr count]; i++)
    {
            UILabel * lblTmp = [[UILabel alloc] init];
            lblTmp.frame = CGRectMake(xx, yy, vWidth, vHeighth-20);
            lblTmp.backgroundColor = [UIColor clearColor];
            lblTmp.userInteractionEnabled = YES;
            lblTmp.text = @" ";
            [scrlView addSubview:lblTmp];
            
            UIImageView * img = [[UIImageView alloc] init];
            img.frame = CGRectMake(5,10, vWidth-10, vWidth-20);
            img.image = [UIImage imageNamed:[imgArr objectAtIndex:cnt]];
            img.backgroundColor = [UIColor clearColor];
            [lblTmp addSubview:img];
            
            UIButton * btnTap = [UIButton buttonWithType:UIButtonTypeCustom];
            btnTap.frame = lblTmp.frame;
            [btnTap addTarget:self action:@selector(btnWarmChooseClick:) forControlEvents:UIControlEventTouchUpInside];
            btnTap.tag = cnt;
            [scrlView addSubview:btnTap];
            
            xx = vWidth + xx;
            cnt = cnt +1;
    }
    [self hideMorePopUpView:NO];
}
-(void)btnWarmChooseClick:(id)sender
{
    [backView removeFromSuperview];
    isColorOpionWarmON = YES;
    if ([sender tag]==0)
    {
        colorPicker.image = [UIImage imageNamed:@"WharmLight1.png"];
    }
    else if ([sender tag]==1)
    {
        colorPicker.image = [UIImage imageNamed:@"WharmLight2.png"];
    }
    [self hideMorePopUpView:YES];
}
#pragma mark - FOR VOICE
-(void)setVoiceArrays
{
    voiceColors = [[NSMutableArray alloc] init];
    NSString * str = [NSString stringWithFormat:@"select * from tbl_voice_color"];
    [[DataBaseManager dataBaseManager] execute:str resultsArray:voiceColors];

    arrRecognizeList = [[NSMutableArray alloc] init];
    NSString * str1 = [NSString stringWithFormat:@"select color_name from tbl_voice_color"];
    [[DataBaseManager dataBaseManager] getJustValues:str1 resultsArray:arrRecognizeList];
}
-(void)setupVoiceView
{

    voiceView = [[UIView alloc] init];
    voiceView.frame = CGRectMake(0, yAbove, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove);
    voiceView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:voiceView];
    voiceView.hidden=YES;
    

    UIButton * btnInfo = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnInfo addTarget:self action:@selector(SetVoiceHintView) forControlEvents:UIControlEventTouchUpInside];
    btnInfo.frame = CGRectMake(DEVICE_WIDTH-80,0, 80, 80);
    [btnInfo addTarget:self action:@selector(SetVoiceHintView) forControlEvents:UIControlEventTouchUpInside];
    [btnInfo setImage:[UIImage imageNamed:@"info_icon.png"] forState:UIControlStateNormal];
    [btnInfo setTitleColor:global_brown_color forState:UIControlStateNormal];
    [voiceView addSubview:btnInfo];
    
    imgVoice = [[UIImageView alloc] init];
    imgVoice.frame = CGRectMake((DEVICE_WIDTH-175)/2,-80+((DEVICE_HEIGHT-yAbove)-175)/2, 175, 175);
    imgVoice.image = [UIImage imageNamed:@"voice_bg_icon.png"];
    imgVoice.userInteractionEnabled = YES;
    [voiceView addSubview:imgVoice];
    
    btnVoice = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnVoice addTarget:self action:@selector(btnStartListen) forControlEvents:UIControlEventTouchUpInside];
    btnVoice.frame = CGRectMake(0,0, 175, 175);
    [btnVoice setImage:[UIImage imageNamed:@"voice_icon.png"] forState:UIControlStateNormal];
    [btnVoice setTitleColor:global_brown_color forState:UIControlStateNormal];
    [imgVoice addSubview:btnVoice];
    
    lblVoiceStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, imgVoice.frame.size.height + imgVoice.frame.origin.y -20*approaxSize, DEVICE_WIDTH, 100*approaxSize)];
    [lblVoiceStatus setBackgroundColor:[UIColor clearColor]];
    [lblVoiceStatus setText:[NSString stringWithFormat:@"Tap & Speak"]];
    [lblVoiceStatus setTextAlignment:NSTextAlignmentCenter];     [lblVoiceStatus setFont:[UIFont fontWithName:CGRegular size:textSizes+1]];
    lblVoiceStatus.numberOfLines = 0;
    [lblVoiceStatus setTextColor:[UIColor whiteColor]];
    [voiceView addSubview:lblVoiceStatus];

    
    lblVoiceDetected = [[UILabel alloc] initWithFrame:CGRectMake(0, imgVoice.frame.size.height + imgVoice.frame.origin.y + 10*approaxSize, DEVICE_WIDTH, 100*approaxSize)];
    [lblVoiceDetected setBackgroundColor:[UIColor clearColor]];
    [lblVoiceDetected setText:[NSString stringWithFormat:@" "]];
    [lblVoiceDetected setTextAlignment:NSTextAlignmentCenter];
    [lblVoiceDetected setFont:[UIFont fontWithName:CGRegular size:textSizes+1]];
    lblVoiceDetected.numberOfLines = 0;
    [lblVoiceDetected setTextColor:[UIColor whiteColor]];
    [voiceView addSubview:lblVoiceDetected];
    
    UILabel * lblDevice = [[UILabel alloc] initWithFrame:CGRectMake(0, imgVoice.frame.size.height + imgVoice.frame.origin.y + 50*approaxSize, DEVICE_WIDTH, 100*approaxSize)];
    [lblDevice setBackgroundColor:[UIColor clearColor]];
    [lblDevice setText:[NSString stringWithFormat:@"Tap on the mic and speak to change color"]];
    [lblDevice setTextAlignment:NSTextAlignmentCenter];
    [lblDevice setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    lblDevice.numberOfLines = 0;
    [lblDevice setTextColor:[UIColor whiteColor]];
    [voiceView addSubview:lblDevice];
    
    UILabel * lblLine = [[UILabel alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-100)/2, (lblDevice.frame.size.height + lblDevice.frame.origin.y + 20*approaxSize),100,1)];
    [lblLine setBackgroundColor:global_brown_color];
    [voiceView addSubview:lblLine];
    
    if (IS_IPHONE_X)
    {
        voiceView.frame = CGRectMake(0, yAbove, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove-45);
    }
    else if (IS_IPHONE_4)
    {
        imgVoice.frame = CGRectMake((DEVICE_WIDTH-175)/2,-60+((DEVICE_HEIGHT-yAbove)-175)/2, 175, 175);
    }
    
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        [imgVoice setHidden:NO];
    } completion:nil];
}
-(void)btnViewClick
{
    tagsTableVC * tblv = [[tagsTableVC alloc] initWithStyle:UITableViewStyleGrouped];
    tblv.tableView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_WIDTH);
    [self.navigationController presentViewController:tblv animated:YES completion:nil];
}
-(void)setupVoiceLibrary
{
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];
    
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    
    NSString *name = @"NameIWantForMyLanguageModelFiles";
    NSError *err = [lmGenerator generateLanguageModelFromArray:arrRecognizeList withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
    
    lmPath = nil;
    dicPath = nil;
    
    if(err == nil)
    {
        lmPath = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"NameIWantForMyLanguageModelFiles"];
        dicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"NameIWantForMyLanguageModelFiles"];
    }
    else
    {
//        NSLog(@"Error: %@",[err localizedDescription]);
    }
}
-(void)btnStartListen
{
    if (isListening)
    {
        btnVoice.enabled = YES;
        // This is the action for the button which shuts down the recognition loop.
        NSError *error = nil;
        if([OEPocketsphinxController sharedInstance].isListening)
        { // Stop if we are currently listening.
            error = [[OEPocketsphinxController sharedInstance] stopListening];
            if(error)NSLog(@"Error stopping listening in stopButtonAction: %@", error);
        }
        isListening = NO;
        [lblVoiceStatus setText:[NSString stringWithFormat:@"Tap & Speak again."]];
    }
    else
    {
        [lblVoiceStatus setText:[NSString stringWithFormat:@"Listening....."]];

        if ([[OEPocketsphinxController sharedInstance] micPermissionIsGranted])
        {
            btnVoice.enabled = NO;
            // This is the action for the button which starts up the recognition loop again if it has been shut down.
            if(![OEPocketsphinxController sharedInstance].isListening)
            {
                [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
                [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
                // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
            }
               // [self performSelector:@selector(btnStopListen) withObject:nil afterDelay:15];
        }
        else
        {
            [[OEPocketsphinxController sharedInstance] requestMicPermission];
            
            AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
            
            switch (permissionStatus) {
                case AVAudioSessionRecordPermissionUndetermined:{
                    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                        // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
                        if (granted) {
                            // Microphone enabled code
                        }
                        else {
                            // Microphone disabled code
                        }
                    }];
                    break;
                }
                case AVAudioSessionRecordPermissionDenied:
                    // direct to settings...
                    break;
                case AVAudioSessionRecordPermissionGranted:
                    // mic access ok...
                    break;
                default:
                    // this should not happen.. maybe throw an exception.
                    break;
            }
        }
        isListening = YES;
    }
}

-(void)btnStopListen
{
    btnVoice.enabled = YES;
    [lblVoiceStatus setText:[NSString stringWithFormat:@"Tap & Speak again."]];

    // This is the action for the button which shuts down the recognition loop.
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening)
    { // Stop if we are currently listening.
        error = [[OEPocketsphinxController sharedInstance] stopListening];
        if(error)NSLog(@"Error stopping listening in stopButtonAction: %@", error);
    }
}

#pragma mark - FOR ONLY WHITE
-(void)setWhiteView
{
    whiteView = [[UIView alloc] init];
    whiteView.frame = CGRectMake(0, 108, DEVICE_WIDTH, DEVICE_HEIGHT-108);
    whiteView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:whiteView];
    
    CGSize size = whiteView.bounds.size;
    CGSize wheelSize = CGSizeMake(size.width * .9, size.width * .9);

    whiteWheel = [[UIView alloc] initWithFrame:CGRectMake(size.width / 2 - wheelSize.width / 2,size.height * .05,wheelSize.width,wheelSize.height)];
    whiteWheel.backgroundColor = [UIColor whiteColor];
    whiteWheel.layer.cornerRadius = whiteWheel.frame.size.height/2;
    whiteWheel.layer.masksToBounds = YES;
    [whiteView addSubview:whiteWheel];
    [whiteView addSubview:slider];
    
    _brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(20,size.height * .7, DEVICE_WIDTH-40,size.height * .1)];
    _brightnessSlider.minimumValue = 0.0;
    _brightnessSlider.maximumValue = 1.0;
    _brightnessSlider.value = 1.0;
    _brightnessSlider.continuous = true;
    _brightnessSlider.minimumValue = 0.0;
    _brightnessSlider.minimumTrackTintColor = [UIColor whiteColor];
    _brightnessSlider.maximumTrackTintColor = [UIColor grayColor];
    [_brightnessSlider addTarget:self action:@selector(changeBrightness:) forControlEvents:UIControlEventValueChanged];
    [whiteView addSubview:_brightnessSlider];
    
    if (IS_IPHONE_4)
    {
        _brightnessSlider.frame = CGRectMake(20,size.height * .9, DEVICE_WIDTH-40,size.height * .1);
    }
    else if (IS_IPHONE_X)
    {
        whiteView.frame = CGRectMake(0, 108, DEVICE_WIDTH, DEVICE_HEIGHT-108-45);
    }
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        [whiteView setHidden:NO];
    } completion:nil];
}
- (void)colorWheelDidChangeColor:(ISColorWheel *)colorWheel
{
    if (isWhite)
    {
        [APP_DELEGATE sendSignalViaScan:@"White" withDeviceID:globalGroupId withValue:[NSString stringWithFormat:@"%f",_brightnessSlider.value]];
        isChanged = NO;
    }
    else
    {
        imgColor = colorWheel.currentColor;
        const  CGFloat *_components = CGColorGetComponents(colorWheel.currentColor.CGColor);
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
        
        [rgbLbl setText:[NSString stringWithFormat:@"R-->%ld   G-->%ld   B-->%ld",(long)fullRed,(long)fullGreen,(long)fullBlue]];
//        [lblTitle setText:[NSString stringWithFormat:@"R--%ld  G--%ld  B--%ld",(long)fullRed,(long)fullGreen,(long)fullBlue]];

        completeData = [[NSMutableData alloc] init];
        completeData = [dSix mutableCopy];
        [completeData appendData:dSeven];
        [completeData appendData:dR];
        [completeData appendData:dG];
        [completeData appendData:dB];
        
        isChanged = YES;
    }
}
- (void)changeBrightness:(StepSlider *)sender
{
    if (isDeviceWhite)
    {
        [APP_DELEGATE sendSignalViaScan:@"White" withDeviceID:globalGroupId withValue:[NSString stringWithFormat:@"%f", _brightnessSlider.value*255]];
        
        whiteWheel.alpha = _brightnessSlider.value;
        if (isSentNoticication)
        {
        }
        else
        {
            isSentNoticication = YES;
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setValue:@"1" forKey:@"isSwitch"];
            NSString * strSwitchNotify = [NSString stringWithFormat:@"updateDataforONOFF%@",strGlogalNotify];
            [[NSNotificationCenter defaultCenter] postNotificationName:strSwitchNotify object:dict];
            
            _switchLight.isOn = YES;
            [_switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
        }
    }
    else if (isWarmWhite)
    {
        UIColor * tmpColor = [UIColor colorWithRed:fullRed/255.0f green:fullGreen/255.0f blue:fullBlue/255.0f alpha:1];
        
        imgColor = tmpColor;
        
        bgWhiteView.backgroundColor = tmpColor;
        const  CGFloat *_components = CGColorGetComponents(tmpColor.CGColor);
        CGFloat red     = _components[0];
        CGFloat green = _components[1];
        CGFloat blue   = _components[2];
        
        NSInteger sixth = [@"66" integerValue];
        NSData * dSix = [[NSData alloc] initWithBytes:&sixth length:1];
        
        NSInteger seven = [@"00" integerValue];
        NSData * dSeven = [[NSData alloc] initWithBytes:&seven length:1];
        
        fullRed = red * 255.0;
        NSData * dR = [[NSData alloc] initWithBytes:&fullRed length:1];
        
        fullGreen = green * 255;
        NSData * dG = [[NSData alloc] initWithBytes:&fullGreen length:1];
        
        fullBlue = blue * 255;
        NSData * dB = [[NSData alloc] initWithBytes:&fullBlue length:1];
        
        [rgbLbl setText:[NSString stringWithFormat:@"R-->%ld   G-->%ld   B-->%ld",(long)fullRed,(long)fullGreen,(long)fullBlue]];
        
        
        completeData = [[NSMutableData alloc] init];
        completeData = [dSix mutableCopy];
        [completeData appendData:dSeven];
        [completeData appendData:dR];
        [completeData appendData:dG];
        [completeData appendData:dB];
        
        isChanged = YES;
    }
    isBrighNess = YES;
}
-(void)brightcol
{
    if (isBrighNess)
    {
        [_colorWheel setBrightness:_brightnessSlider.value];
        isBrighNess = NO;
    }
}



#pragma mark - CLICK EVENT FOR COLOR, SOLID, WHITE, VOICE, RGB
-(void)SubMenuEventClick:(id)sender
{
    for (int i =0; i<5; i++)
    {
        UIButton * btn = (UIButton *)[self.view viewWithTag:50+i];
        [btn.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSizes]];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    UIButton * btn = (UIButton *)[self.view viewWithTag:[sender tag]];
    [btn.titleLabel setFont:[UIFont fontWithName:CGBold size:textSizes+2]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    voiceView.hidden = YES; patternView.hidden = YES; bgWhiteView.hidden = YES; rgbView.hidden = YES; colorSquareView.hidden = YES;
    _brightnessSlider.hidden = YES; solidView.hidden = YES; musicView.hidden = YES; imgColorOptionView.hidden = YES;
    
    isWarmWhite = NO;
    isfromSolid = NO;
    
    if ([sender tag] == 50)
    {
        imgBack.hidden = true;
        _brightnessSlider.minimumValue = 0.0;
        _brightnessSlider.maximumValue = 1.0;
        _brightnessSlider.value = 1.0;

        isWarmWhite = NO;
        isVoicView = NO;
        isWhite = NO;

        if (isColorOptionON)
        {
            imgColorOptionView.hidden = NO;
            imgColorOptionView.isSquareImage = NO;
            if (selectedWheel==4)
            {
                imgColorOptionView.isSquareImage = YES;
            }
        }
        else
        {
            imgColorOptionView.hidden = YES;
        }
        [UIView transitionWithView:colorSquareView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
            [colorSquareView setHidden:NO];
        } completion:nil];
    }
    else if ([sender tag]==51)
    {
        imgBack.hidden = true;
        isfromSolid = YES;
        if (solidView)
        {
            [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
                [solidView setHidden:NO];
            } completion:nil];

        }
        else
        {
            [self setSolidView];
        }
        isVoicView = NO;
        isWhite = NO;
        isWarmWhite = NO;
    }
    else if ([sender tag]==52)
    {
        imgBack.hidden = true; colorSquareView.hidden = NO;
        isColorOpionWarmON = YES;
        
        if (bgWhiteView)
        {
            [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
                [bgWhiteView setHidden:NO];
            } completion:nil];
        }
        else
        {
            [self setWarmLightheel];
        }
        isWhite  = YES; isWarmWhite = YES; isVoicView = NO; colorPicker.isSquareImage = YES;
    }
    else if ([sender tag]==53)
    {
        imgBack.hidden = false;

        isWhite  = NO; isWarmWhite = NO; isVoicView = YES;

        if (voiceView)
        {
        }
        else
        {
            [self setupVoiceView];
        }
        if (isVoiceCreated)
        {
        }
        else
        {
            [APP_DELEGATE showScannerView:@"Setting up Voice View"];
            [self performSelector:@selector(setupVoiceLibrary) withObject:nil afterDelay:1];
            [self performSelector:@selector(stopIndicatorPlease) withObject:nil afterDelay:3];
            isVoiceCreated = YES;
        }
        [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
            [voiceView setHidden:NO];
        } completion:nil];

    }
    else if ([sender tag]==54)
    {
        imgBack.hidden = false;

        if (rgbView)
        {
            [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
                [rgbView setHidden:NO];
            } completion:nil];
        }
        else
        {
            [self setupRGBView];
        }
    }
}
-(void)stopIndicatorPlease
{
    [APP_DELEGATE hideScannerView];
    [APP_DELEGATE endHudProcess];
}
-(void)updateBtnClick
{
    AddDeviceVC * addDevice = [[AddDeviceVC alloc] init];
    addDevice.isfromEdit = YES;
    addDevice.isForGroup = YES;
    addDevice.detailDict = deviceDict;
    [self.navigationController pushViewController:addDevice animated:YES];
}
-(void)btnBackClick
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetFavoriteColors" object:nil];
    isMusicModeOn = NO;
    [self stopRecording];
    [APP_DELEGATE stopAdvertisingBaecons];

    if (isFromScan)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (isfromGroup == false)
    {
        if (isFromAll)
        {
            NSString * strUpdate = [NSString stringWithFormat:@"update Device_Table set brightnessValue = '%f', red = '%ld',green = '%ld',blue = '%ld'",brightnessSliderColorView.value/100,(long)fullRed,(long)fullGreen,(long)fullBlue];
            [[DataBaseManager dataBaseManager] execute:strUpdate];
        }
        else
        {
            NSString * strUpdate = [NSString stringWithFormat:@"update Device_Table set brightnessValue = '%f',red = '%ld',green = '%ld',blue = '%ld' where device_id = '%@'",brightnessSliderColorView.value/100,(long)fullRed,(long)fullGreen,(long)fullBlue,globalGroupId];
            [[DataBaseManager dataBaseManager] execute:strUpdate];
        }
    }
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
            [alert makeAlertTypeCaution];
            alert.tag = 222;
            alert.delegate = self;
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"There is something went wrong. Please try again later."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
}
-(void)segmentClick:(NYSegmentedControl *) sender
{
    colorSquareView.hidden = YES; patternView.hidden = YES; bgWhiteView.hidden = YES; rgbView.hidden = YES; optionView.hidden = YES;
    voiceView.hidden = YES; musicView.hidden = YES; solidView.hidden = YES;
    
    isWarmWhite = NO;
    isfromSolid = NO;
    
    if (sender.selectedSegmentIndex==0)
    {
        colorSquareView.hidden = NO; optionView.hidden = NO; imgBack.hidden = YES;

        [UIView transitionWithView:colorSquareView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
            [colorSquareView setHidden:NO];
        } completion:nil];

        if (isColorOptionON)
        {
            imgColorOptionView.hidden = NO; imgColorOptionView.isSquareImage = NO;
            if (selectedWheel==4)
            {
                imgColorOptionView.isSquareImage = YES;
            }
        }
        else
        {
            imgColorOptionView.hidden = YES;
        }
        
        for (int i =0; i<5; i++)
        {
            UIButton * btn = (UIButton *)[self.view viewWithTag:50+i];
            [btn.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSizes]];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        
        UIButton * btn = (UIButton *)[self.view viewWithTag:50];
        [btn.titleLabel setFont:[UIFont fontWithName:CGBold size:textSizes]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else if (sender.selectedSegmentIndex==1)
    {
        imgBack.hidden = true;
        patternSelected = -1;
        if (patternView)
        {
            [UIView transitionWithView:patternView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
                [patternView setHidden:NO];
            } completion:nil];
        }
        else
        {
            [self setPatternView];
        }
        voiceView.hidden = YES; bgWhiteView.hidden = YES; rgbView.hidden = YES; colorSquareView.hidden = YES; _brightnessSlider.hidden = YES;
        solidView.hidden = YES; musicView.hidden = YES;
    }
    else if (sender.selectedSegmentIndex==2)
    {
        imgBack.hidden = false;
        if (musicView)
        {
            [UIView transitionWithView:musicView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
                [musicView setHidden:NO];
            } completion:nil];
        }
        else
        {
            [self CreateMusicView];
        }
    }
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
-(void)doneClicked:(id)sender
{
    [self.view endEditing:YES];
}
#pragma mark - Ble device Connect method
-(void)onConnectWithDevice:(CBPeripheral*)peripheral
{
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [[BLEManager sharedManager] centralmanagerScanStop];
}

-(void)DeviceDidDisConnectNotification:(NSNotification*)notification//Disconnect periperal
{
}
-(void)GlobalBLuetoothCheck
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Vithamas" message:@"Please enablooth Connection. Tap on enable Bluetooth icon by swiping Up." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:true completion:nil];
}
#pragma mark - CentralManager Ble delegate Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
}
#pragma mark - ORBSwitchDelegate
- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue
{
    NSString * deviceID = @"NA";
    deviceID = globalGroupId;
    if (newValue == YES)
    {
        [deviceDict setObject:@"Yes" forKey:@"switch_status"];
    }
    else
    {
        [deviceDict setObject:@"No" forKey:@"switch_status"];
    }
    
    if (isFromAll)
    {
        isAlldevicePowerOn = newValue;
    }
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
        
        completeData = [[NSMutableData alloc] init];
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
#pragma mark- UITableView Methods
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == tblVoices)
    {
        return _dataSource[section][0].category;
    }
    return @"";
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == tblVoices)
    {
        return _dataSource.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblVoices)
    {
        return 1;
    }
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString* cellIdentifier = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    PatternCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    if (tableView == tblVoices)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        if (cell==nil)
        {
            cell = [[PatternCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellIdentifier"];
        }
        
        float heightV = 150*approaxSize;
         NSMutableArray * arrPatternNames = [[NSMutableArray alloc]initWithObjects:@"Dance Party",@"Love Romance",@"Soothing",@"Strobe",@"Disco Strobe", nil];
        
        [cell.parallaxImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%ld.png",indexPath.row+1]]];
        cell.lblName.font = [UIFont fontWithName:CGBold size:textSizes+15];
        cell.lblName.text = [arrPatternNames objectAtIndex:indexPath.row];
        cell.lblLine.frame = CGRectMake(0, heightV-40, DEVICE_WIDTH, 40);
        cell.lblName.frame = CGRectMake(0, 0, DEVICE_WIDTH, heightV);
        
        cell.lblName.textAlignment = NSTextAlignmentCenter;
        cell.lblLine.hidden = YES;
        
        cell.lblPatternHighlighter.hidden = YES;

        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

    return cell;
}
- (void)configureCell:(id)object atIndexPath:(NSIndexPath *)indexPath {
    if (![object isKindOfClass:[AHTagTableViewCell class]]) {
        return;
    }
    AHTagTableViewCell *cell = (AHTagTableViewCell *)object;
    cell.label.tags = _dataSource[indexPath.section];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    patternSelected = indexPath.row;
    if (tableView == tblView)
    {
        selecedPtrn = indexPath.row+1;
        [self sendPattern];
        
        if (isSentNoticication)
        {
        }
        else
        {
            isSentNoticication = YES;
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setValue:@"1" forKey:@"isSwitch"];
            NSString * strSwitchNotify = [NSString stringWithFormat:@"updateDataforONOFF%@",strGlogalNotify];
            [[NSNotificationCenter defaultCenter] postNotificationName:strSwitchNotify object:dict];
            _switchLight.isOn = YES;
            [_switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
            [tblView reloadData];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblVoices)
    {
        return UITableViewAutomaticDimension;
    }
    else
    {
        return 150*approaxSize;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (tableView == tblVoices)
    {
        UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
        v.textLabel.textColor = [UIColor white];
        v.textLabel.font = [UIFont fontWithName:CGBold size:textSizes+1];
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

#pragma mark- Speach to Text Methods
- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID
{
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    for (int i =0; i<[voiceColors count]; i++)
    {
        if ([[[voiceColors objectAtIndex:i]valueForKey:@"color_name"] rangeOfString:hypothesis].location != NSNotFound)
        {
            if ([hypothesis rangeOfString:@"on"].location != NSNotFound)
            {
                NSString * deviceID = @"NA";
                deviceID = globalGroupId;
                [deviceDict setObject:@"Yes" forKey:@"switch_status"];
                
                if (isFromAll)
                {
                    isAlldevicePowerOn = YES;
                }
                if (![deviceID isEqualToString:@"NA"])
                {
                    [self switchOffDevice:deviceID withType:YES];
                }
                lblVoiceDetected.text = @"ON";
            }
            if ([hypothesis rangeOfString:@"off"].location != NSNotFound)
            {
                NSString * deviceID = @"NA";
                deviceID = globalGroupId;
                [deviceDict setObject:@"No" forKey:@"switch_status"];
                
                if (isFromAll)
                {
                    isAlldevicePowerOn = NO;
                }
                if (![deviceID isEqualToString:@"NA"])
                {
                    [self switchOffDevice:deviceID withType:NO];
                }
                lblVoiceDetected.text = @"OFF";

            }
            else
            {
                lblVoiceDetected.text = [[voiceColors objectAtIndex:i] valueForKey:@"color_name"];

                UIColor * rgbColor = [self colorWithHexString:[[voiceColors objectAtIndex:i]valueForKey:@"color_rgb"]];
                imgColor = rgbColor;
                const  CGFloat *_components = CGColorGetComponents(rgbColor.CGColor);
                CGFloat red   = _components[0];
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
                isChanged = NO;
                [APP_DELEGATE sendSignalViaScan:@"ColorChange" withDeviceID:globalGroupId withValue:@"0"]; //KalpeshScanCode

            }
            break;
        }
    }
    [self btnStopListen];
}
- (UIColor *)colorWithHexString:(NSString *)str
{
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [self colorWithHex:x];
}
- (UIColor *)colorWithHex:(UInt32)col
{
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    

    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}
- (void) pocketsphinxDidStartListening {
//    NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
//    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
//    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
//    NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
//    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
//    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
//    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
//    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
//    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
//    NSLog(@"A test file that was submitted for recognition is now complete.");
}

#pragma mark - Check for Connection
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
#pragma mark - RGB VIEW
-(void)setupRGBView
{

    rgbView = [[UIView alloc] init];
    rgbView.frame = CGRectMake(0, yAbove, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove);
    rgbView.backgroundColor = [UIColor clearColor];
    rgbView.hidden = YES;
    [self.view addSubview:rgbView];

    UIImageView* imgRGBBulbBottom = [[UIImageView alloc]init];
    imgRGBBulbBottom.frame = CGRectMake((DEVICE_WIDTH-120)/2, 35, 120, 180);
    imgRGBBulbBottom.contentMode = UIViewContentModeScaleToFill;
    imgRGBBulbBottom.backgroundColor = UIColor.clearColor;
    imgRGBBulbBottom.image = [UIImage imageNamed:@"bulb.png"];
    [rgbView addSubview:imgRGBBulbBottom];
    
    imgRGBBulb = [[UIImageView alloc] init];
    imgRGBBulb.frame = CGRectMake((DEVICE_WIDTH-120)/2,35, 120, 180);
    imgRGBBulb.image = [UIImage imageNamed:@"bulbColor.png"];
    [rgbView addSubview:imgRGBBulb];
    imgRGBBulb.contentMode = UIViewContentModeScaleToFill;
    imgRGBBulb.image = [imgRGBBulb.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [animatedImageView setTintColor:[UIColor whiteColor]];

    self.redSlider = [[JMMarkSlider alloc]initWithFrame:CGRectMake(10, 230, DEVICE_WIDTH-20, 28)];
    self.redSlider.markColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.redSlider.markPositions = @[];
    self.redSlider.markWidth = 1.0;
    self.redSlider.value = 1;
    self.redSlider.tag = 1;
    self.redSlider.continuous = true;
    self.redSlider.selectedBarColor = [UIColor redColor];
    self.redSlider.unselectedBarColor = [UIColor whiteColor];
    [self.redSlider addTarget:self action:@selector(redValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.redSlider.handlerImage = [UIImage imageNamed:@"sliderHandleRed.png"];
    [rgbView addSubview:self.redSlider];
    
    self.greenSlider = [[JMMarkSlider alloc]initWithFrame:CGRectMake(10, 280, DEVICE_WIDTH-20, 28)];
    self.greenSlider.markColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.greenSlider.markPositions = @[];
    self.greenSlider.markWidth = 1.0;
    self.greenSlider.value = 1;
    self.greenSlider.tag = 2;
    self.greenSlider.continuous = true;
    self.greenSlider.selectedBarColor = [UIColor greenColor];
    self.greenSlider.unselectedBarColor = [UIColor whiteColor];
    [self.greenSlider addTarget:self action:@selector(redValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.greenSlider.handlerImage = [UIImage imageNamed:@"sliderHandleGreen.png"];
    [rgbView addSubview:self.greenSlider];
    
    self.blueSlider = [[JMMarkSlider alloc]initWithFrame:CGRectMake(10, 330, DEVICE_WIDTH-20, 28)];
    self.blueSlider.markColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.blueSlider.markPositions = @[];
    self.blueSlider.markWidth = 1.0;
    self.blueSlider.value = 1;
    self.blueSlider.tag = 3;
    self.blueSlider.continuous = true;
    self.blueSlider.selectedBarColor = [UIColor blueColor];
    self.blueSlider.unselectedBarColor = [UIColor whiteColor];
    [self.blueSlider addTarget:self action:@selector(redValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.blueSlider.handlerImage = [UIImage imageNamed:@"sliderHandleBlue.png"];
    [rgbView addSubview:self.blueSlider];
    
    if (IS_IPHONE_4)
    {
        
        imgRGBBulbBottom.frame = CGRectMake((DEVICE_WIDTH-120)/2, 5, 120, 180);
        imgRGBBulb.frame = CGRectMake((DEVICE_WIDTH-120)/2,5, 120, 180);

        self.redSlider.frame = CGRectMake(10, 180, DEVICE_WIDTH-20, 28);
        self.greenSlider.frame = CGRectMake(10, 230, DEVICE_WIDTH-20, 28);
        self.blueSlider.frame = CGRectMake(10, 280, DEVICE_WIDTH-20, 28);
    }
    slideRed = 255.0;
    slideGreen = 255.0;
    slideBlue = 255.0;
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        [rgbView setHidden:NO];
    } completion:nil];
}
- (void)redValueChanged:(JMMarkSlider *)sender
{
    CGFloat slideValue = sender.value;
   
    if ([sender tag]==1)
    {
        slideRed = slideValue*255;
    }
    else if ([sender tag]==2)
    {
        slideGreen = slideValue*255;
    }
    else if ([sender tag]==3)
    {
        slideBlue = slideValue*255;
    }
    
    fullRed = slideRed;
    fullBlue = slideBlue;
    fullGreen = slideGreen;
    
    NSInteger sixth = [@"66" integerValue];
    NSData * dSix = [[NSData alloc] initWithBytes:&sixth length:1];
    
    NSInteger seven = [@"00" integerValue];
    NSData * dSeven = [[NSData alloc] initWithBytes:&seven length:1];
    
    NSData * dR = [[NSData alloc] initWithBytes:&fullRed length:1];
    
    NSData * dG = [[NSData alloc] initWithBytes:&fullGreen length:1];
    
    NSData * dB = [[NSData alloc] initWithBytes:&fullBlue length:1];
    
    completeData = [[NSMutableData alloc] init];
    completeData = [dSix mutableCopy];
    [completeData appendData:dSeven];
    [completeData appendData:dR];
    [completeData appendData:dG];
    [completeData appendData:dB];
    
    imgColor = [UIColor colorWithRed:fullRed/255.0f green:fullGreen/255.0f blue:fullBlue/255.0f alpha:1.0];
    isChanged = YES;
    
    imgRGBBulb.image = [imgRGBBulb.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    /**/

    double newRed = fullRed;
    double newGreen = fullGreen;
    double newBlue = fullBlue;
    
    {
        double lum = (fullRed + fullBlue + fullGreen)/3;
         newRed = (((fullRed-lum)*3)/2)+ 127;
         newGreen = (((fullGreen-lum)*3)/2) +127;
         newBlue = (((fullBlue-lum)*3)/2) +127;
    }
    [imgRGBBulb setTintColor:[UIColor colorWithRed:newRed/255.0f green:newGreen/255.0f blue:newBlue/255.0f alpha:1.0]];
}

#pragma mark - Extra Methods
- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef)inImage
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}
#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
//    NSLog(@"Button Clicked: %ld Title:%@", (long)index, title);
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 222)
    {
        [self.navigationController popViewControllerAnimated:YES];
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
#pragma mark - Collection View Delegate and DataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        return 2;
    }
    return 6;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell*cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    UIImageView *imageView=(UIImageView *)[cell viewWithTag:1];
    imageView.image = [UIImage imageNamed:@"logo.png"];
    UIImageView *checked = (UIImageView*)[cell viewWithTag:3];
    UIView *SelectedView = (UIView*)[cell viewWithTag:2];
    if (cell.selected)
    {
        SelectedView.hidden=NO;
        checked.hidden = NO;
    }
    else
    {
        SelectedView.hidden=YES;
        checked.hidden = YES;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [kpcollectionView cellForItemAtIndexPath:indexPath];
    cell.alpha = 0.5;
}
-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [kpcollectionView cellForItemAtIndexPath:indexPath];
    cell.alpha = 1.0;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Collection View Layout Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger itemsPerRow = rowCount;
    NSInteger spaceMultiplier = (itemsPerRow-1)*cellPaddings;
    if (spaceMultiplier <= 0)
    {
        spaceMultiplier = 0;
    }
    // calculate size for 3 thumbs per line
    CGFloat size = floorf((collectionView.bounds.size.width-spaceMultiplier)/itemsPerRow);
    return CGSizeMake(size, size);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return cellPaddings;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return cellPaddings;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0,0,0,0);
}

- (NSArray *)parseJSON
{
    NSError *error;
    NSURL *URL= [[NSBundle mainBundle] URLForResource:@"TagGroups" withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSArray *objects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    return [objects map:^id(id obj) {
        return [(NSArray *)obj map:^id(id obj) { return [(NSDictionary *)obj tags]; }];
    }];
}
-(void)SetVoiceHintView
{
    [scrlView removeFromSuperview];
    scrlView = [[UIScrollView alloc] init];
    scrlView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH-0, DEVICE_HEIGHT);
    scrlView.backgroundColor = [UIColor clearColor];
    scrlView.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT);
    [self.view addSubview:scrlView];
    
    UIView * backVies = [[UIView alloc] init];
    backVies.frame = CGRectMake(0, 0, DEVICE_WIDTH-0, DEVICE_HEIGHT);;
    backVies.backgroundColor = [UIColor blackColor];
    backVies.alpha = 0.8;
    [scrlView addSubview:backVies];
    
    UILabel * lblTitle = [[UILabel alloc] init];
    lblTitle.frame = CGRectMake(0, 0, scrlView.frame.size.width, 50);
    lblTitle.font = [UIFont fontWithName:CGRegular size:textSizes];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.text = @"Voice commonds to speak";
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.backgroundColor = [UIColor blackColor];
    [scrlView addSubview:lblTitle];
    
    UILabel * lblline = [[UILabel alloc] init];
    lblline.frame = CGRectMake(0, 49, scrlView.frame.size.width, 0.5);
    lblline.backgroundColor = [UIColor lightGrayColor];
    [scrlView addSubview:lblline];
    
    UIButton * btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = CGRectMake(0, 0, 60, 50);
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont fontWithName:CGBold size:textSizes-1];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(btnCloseOptionView) forControlEvents:UIControlEventTouchUpInside];
    [scrlView addSubview:btnCancel];
    
    _dataSource = [self parseJSON];

    tblVoices = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT-50) style:UITableViewStyleGrouped];
    tblVoices.delegate = self;
    tblVoices.dataSource = self;
    tblVoices.backgroundColor = [UIColor clearColor];
    tblVoices.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblVoices.tableFooterView = [UIView new];
    [scrlView addSubview:tblVoices];
    UINib *nib = [UINib nibWithNibName:@"AHTagTableViewCell" bundle:nil];
    [tblVoices registerNib:nib forCellReuseIdentifier:@"cell"];

    [tblVoices reloadData];
    [self hideMorePopUpView:NO];

}
#pragma mark - MUSIC View
-(void)CreateMusicView
{

    int yHeight = (blueSegmentedControl.frame.size.height + blueSegmentedControl.frame.origin.y)*approaxSize + 0;
    
    [musicView removeFromSuperview];
    musicView  = [[UIView alloc] init];
    musicView.frame = CGRectMake(0,yHeight,DEVICE_WIDTH,DEVICE_HEIGHT-yHeight);
    musicView.backgroundColor = [UIColor clearColor];
    musicView.hidden = YES;
    [self.view addSubview:musicView];
    
    long vHeight = 30;
    
    UIImageView * imgMusic = [[UIImageView alloc] init];
    imgMusic.frame = CGRectMake(100, vHeight, DEVICE_WIDTH-200, DEVICE_WIDTH-200);
    imgMusic.backgroundColor = [UIColor clearColor];
    [musicView addSubview:imgMusic];
    
    animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, vHeight-20, DEVICE_WIDTH-0, DEVICE_WIDTH-200+20)];
    [musicView addSubview: animatedImageView];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Equalizer" withExtension:@"gif"];
    animatedImageView.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
//    animatedImageView.hidden = YES;
    animatedImageView.image = [UIImage imageNamed:@"stoppedMusic.png"];
//
//    animation = [[LOTAnimationView alloc] init];
//    animation.frame = CGRectMake(100, vHeight, DEVICE_WIDTH-200, DEVICE_WIDTH-200);
//    animation = [LOTAnimationView animationNamed:@"star_bounce.json"];
//    [musicView addSubview:animation];
//    animation.contentMode = UIViewContentModeScaleAspectFit;

    vHeight = 30+DEVICE_WIDTH-200+20;
    
    btnMusic = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMusic.frame = CGRectMake(50, vHeight, DEVICE_WIDTH-100, 50*approaxSize);
    [btnMusic addTarget:self action:@selector(btnMusicClick:) forControlEvents:UIControlEventTouchUpInside];
    btnMusic.layer.cornerRadius = (50*approaxSize)/2;
    btnMusic.layer.masksToBounds = YES;
    btnMusic.layer.borderWidth = 1.0;
    btnMusic.layer.borderColor = global_brown_color.CGColor;
    [btnMusic setTitle:@"Start Music Mode" forState:UIControlStateNormal];
    [btnMusic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnMusic.backgroundColor = [UIColor blackColor];
    [musicView addSubview:btnMusic];
    
    vHeight = vHeight + 35*approaxSize + 40;
    
    UIImageView * imgMusicPlay = [[UIImageView alloc]init];
    imgMusicPlay.frame = CGRectMake((DEVICE_WIDTH/2)-22, vHeight,44, 44);
    imgMusicPlay.image = [UIImage imageNamed:@"musicPlay.png"];
    imgMusicPlay.backgroundColor = UIColor.clearColor;
    imgMusicPlay.layer.masksToBounds = true;
    imgMusicPlay.layer.cornerRadius = 22;
    [musicView addSubview:imgMusicPlay];
    
    UIButton * btnMusicPlay = [[UIButton alloc]init];
    btnMusicPlay.frame = CGRectMake((DEVICE_WIDTH/2)-30, vHeight,60, 60);
    [btnMusicPlay addTarget:self action:@selector(btnMusicPlayAction) forControlEvents:UIControlEventTouchUpInside];
    btnMusicPlay.layer.masksToBounds = 50;
    btnMusicPlay.layer.cornerRadius = true;
    btnMusicPlay.backgroundColor = UIColor.clearColor;
//    btnMusicPlay.layer.borderWidth = 1.0;
//    btnMusicPlay.layer.borderColor = global_brown_color.CGColor;
//    [btnMusicPlay setImage:[UIImage imageNamed:@"musicPlay.png"] forState:UIControlStateNormal];
    [musicView addSubview:btnMusicPlay];
    
    vHeight = vHeight + 35*approaxSize + 40+ 10;
    if (IS_IPHONE_4)
    {
        vHeight = vHeight-20;
    }
    UILabel * lblHint1 = [[UILabel alloc] init];
    lblHint1.frame = CGRectMake(0, vHeight, DEVICE_WIDTH, 60);
    lblHint1.text = @"You can feel the lighting effects based on the surrounding sounds. So make sure you play music closer to your phone.";
    lblHint1.textColor = [UIColor whiteColor];
    lblHint1.numberOfLines = 0;
    lblHint1.backgroundColor = UIColor.clearColor;
    lblHint1.font = [UIFont fontWithName:CGRegular size:textSizes-1];
    lblHint1.textAlignment = NSTextAlignmentCenter;
    [musicView addSubview:lblHint1];
    
    vHeight = vHeight + 40*approaxSize + 40;

    UILabel * lblHint2 = [[UILabel alloc] init];
    lblHint2.frame = CGRectMake(0, vHeight, DEVICE_WIDTH, 60);
    lblHint2.text = @"The music feature will work if your devices' Microphone is ON. So please enable Microphone permission from Setting.";
    lblHint2.textColor = [UIColor grayColor];
    lblHint2.numberOfLines = 0;
    lblHint2.textAlignment = NSTextAlignmentCenter;
    lblHint2.font = [UIFont fontWithName:CGRegular size:textSizes-2];
//    [musicView addSubview:lblHint2];
    
    if (IS_IPHONE_X)
    {
        musicView.frame = CGRectMake(0, yAbove, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove-45);
        solidColorView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove-45);
    }
 
    
    [UIView transitionWithView:musicView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        [musicView setHidden:NO];
    } completion:nil];
    [self SetupRecording];
}
-(void)btnMusicPlayAction
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"music://"]])
    {
       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"music://"]];
    }
    else
        {
    }
}
-(void)SetupRecording
{
    // kSeconds = 150.0;
//    NSLog(@"startRecording");
    audioRecorder = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                  withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionDefaultToSpeaker
                        error:nil];
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
    if(recordEncoding == ENC_PCM)
    {
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:16000.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    }
    else
    {
        NSNumber *formatObject;
        switch (recordEncoding)
        {
            case (ENC_AAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatMPEG4AAC];
                break;
            case (ENC_ALAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleLossless];
                break;
            case (ENC_IMA4):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
                break;
            case (ENC_ILBC):
                formatObject = [NSNumber numberWithInt: kAudioFormatiLBC];
                break;
            case (ENC_ULAW):
                formatObject = [NSNumber numberWithInt: kAudioFormatULaw];
                break;
            default:
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
        }
        [recordSettings setObject:formatObject forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:16000.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    }
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"recordTest.caf"];
    
    NSURL *url = [NSURL fileURLWithPath:soundFilePath];
    NSError *error = nil;
    audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    audioRecorder.meteringEnabled = YES;
}
-(void)btnMusicClick:(id)sender
{
    if (isMusicModeOn)
    {
        isMusicModeOn = NO;
        [btnMusic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnMusic setTitle:@"Start Music Mode" forState:UIControlStateNormal];
        [self stopRecording];
    }
    else
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        alert.delegate = self;
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"Make sure your player Playing music and volume up to enjoy this feature."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
        
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted)
            {
//                NSLog(@"Permission granted");
                [self startRecording];
                [self performSelector:@selector(firstCalltoSendMusci) withObject:nil afterDelay:3];
                [btnMusic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                isMusicModeOn = YES;
                [btnMusic setTitle:@"Stop Music Mode" forState:UIControlStateNormal];
            }
            else
            {
                    FCAlertView *alert = [[FCAlertView alloc] init];
                    alert.colorScheme = [UIColor blackColor];
                    [alert makeAlertTypeCaution];
                    [alert addButton:@"Go to Setting" withActionBlock:^{
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
                    [alert showAlertInView:self
                                 withTitle:@"Smart Light"
                              withSubtitle:@"Vithamas App requires access to your microphone to work Music!"
                           withCustomImage:[UIImage imageNamed:@"logo.png"]
                       withDoneButtonTitle:@"Ok"
                                andButtons:nil];
            }
        }];
    }
}
-(void) startRecording
{
    animatedImageView.hidden = NO;

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Equalizer" withExtension:@"gif"];
    animatedImageView.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];

    [animatedImageView startAnimating];

    // kSeconds = 150.0;
    [audioRecorder stop];
    
//    if ([audioRecorder prepareToRecord] == YES)
    {
        [audioRecorder prepareToRecord];
        audioRecorder.meteringEnabled = YES;
        [audioRecorder record];
        [audioRecorder updateMeters];
        timerForPitch =[NSTimer scheduledTimerWithTimeInterval: 0.50 target: self selector: @selector(levelTimerCallbackNew:) userInfo: nil repeats: YES];
        timerforMusicCount =[NSTimer scheduledTimerWithTimeInterval: 4.0 target: self selector: @selector(startCountingBits) userInfo: nil repeats: YES];
    }
}
-(void)levelTimerCallbackNew:(NSTimer *)timer
{
    [animation playWithCompletion:^(BOOL animationFinished) {
    }];

    [audioRecorder updateMeters];
    double avgPowerForChannel = pow(10, (0.05 * [audioRecorder averagePowerForChannel:0]));
    double tempVal = ((avgPowerForChannel*1000) - 100)/10;

    if (tempVal<0 || tempVal <3)
    {
        tempVal =  tempVal + 1;
    }
    else if(tempVal >3)
    {
        tempVal = tempVal - 3 ;
    }
    totalMusicBits = tempVal + totalMusicBits;
}
-(void)firstCalltoSendMusci
{
    int sentCount = totalMusicBits;
//    NSLog(@"Total Bits=%d AND Average Bits=%d",sentCount,sentCount/5);
    sentCount = sentCount /5;
    //Send command here
    lastSendMusicBeats = sentCount;
    [self sendMusicBeatswith:sentCount];
}
-(void)startCountingBits
{
    if(isMusicModeOn)
    {
        int sentCount = totalMusicBits;
        sentCount = sentCount /5;
        //    if (sentCount != lastSendMusicBeats)
        {
            lastSendMusicBeats = sentCount;
            [self sendMusicBeatswith:sentCount];
        }
        totalMusicBits = 0;
        //Send command here
    }
    
   
    
}
-(void)sendMusicBeatswith:(int)setCount
{
    bool isAllow = YES;
    if (setCount >10)
    {
        setCount = 10;
    }
    else if (setCount>=-20 && setCount<=-10)
    {
        isAllow = NO;
    }
    else if (setCount >=-10)
    {
        setCount = setCount + 4;
    }
    if (setCount <0)
    {
        isAllow = NO;
    }
    else
    {
        isAllow = YES;
    }
    if(isAllow)
    {
            if (isSentNoticication)
            {
            }
            else
            {
                isSentNoticication = YES;
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                [dict setValue:@"1" forKey:@"isSwitch"];
                NSString * strSwitchNotify = [NSString stringWithFormat:@"updateDataforONOFF%@",strGlogalNotify];
                [[NSNotificationCenter defaultCenter] postNotificationName:strSwitchNotify object:dict];
                _switchLight.isOn = YES;
                [_switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
            }
            if (isMusicModeOn)
            {
                [APP_DELEGATE sendSignalViaScan:@"MusicUUID" withDeviceID:globalGroupId withValue:[NSString stringWithFormat:@"%d",setCount]];
            }
    }
    else
    {
        if (isMusicModeOn)
        {
            [APP_DELEGATE sendSignalViaScan:@"MusicUUID" withDeviceID:globalGroupId withValue:[NSString stringWithFormat:@"0"]];
        }
    }

    totalMusicBits = 0;

//    [btnMusic setTitle:[NSString stringWithFormat:@"%d",setCount+2] forState:UIControlStateNormal];
}
-(void)timeTosendBitstoBLE
{
    totalMusicBits = 0;

}
- (void)levelTimerCallback:(NSTimer *)timer
{
    [audioRecorder updateMeters];
    
    float linear = pow (10, [audioRecorder peakPowerForChannel:0] / 20);
    float linear1 = pow (10, [audioRecorder averagePowerForChannel:0] / 20);
    if (linear1>0.03)
    {
        Pitch = linear1+.20;//pow (10, [audioRecorder averagePowerForChannel:0] / 20);//[audioRecorder peakPowerForChannel:0];
    }
    else
    {
        Pitch = 0.0;
    }
    Pitch =linear1;
    totalMusicBits = totalMusicBits + linear1*100;
}
-(void)stopRecording
{
    animatedImageView.image = [UIImage imageNamed:@"stoppedMusic.png"];
    [btnMusic setTitle:@"Start Music Mode" forState:UIControlStateNormal];
    [audioRecorder stop];
    [timerForPitch invalidate];
    timerForPitch = nil;
    
    [timerforMusicCount invalidate];
    timerforMusicCount = nil;

    [timertoSendMusic invalidate];
    timertoSendMusic = nil;

    [APP_DELEGATE sendSignalViaScan:@"MusicUUID" withDeviceID:globalGroupId withValue:[NSString stringWithFormat:@"%d",0]];
}
-(void)CountMusicBits
{
    
    
}
-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""] && ![strRequest isEqualToString:@" "] && ![strRequest isEqualToString:@"<nil>"])
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
- (void)setGradientBackgroundWithColors:(NSArray *)colors
{
    CAGradientLayer *trackGradientLayer = [CAGradientLayer layer];
    CGRect frame = brightnessSliderColorView.frame;
    frame.size.height = 5.0; //set the height of slider
    trackGradientLayer.frame = frame;
    trackGradientLayer.colors = colors;
    //setting gradient as horizontal
    trackGradientLayer.startPoint = CGPointMake(0.0, 0.5);
    trackGradientLayer.endPoint = CGPointMake(1.0, 0.5);
    
    UIImage *trackImage = [[self imageFromLayer:trackGradientLayer] resizableImageWithCapInsets:UIEdgeInsetsZero];
    [brightnessSliderColorView setMinimumTrackImage:trackImage forState:UIControlStateNormal];
    [brightnessSliderColorView setMaximumTrackImage:trackImage forState:UIControlStateNormal];
}

-(UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, layer.opaque, 0.0);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}
/*- (void)changeBrightness:(id)sender {
    hellSlider = (UISlider *)sender;
    
    UIColor *currentColor = colorView.backgroundColor;
    CGFloat hue, saturation, brightness, alpha;
    BOOL success = [currentColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    brightness = hellSlider.value;
    UIColor *newColor = [UIColor colorWithHue:hue saturation:saturationSlider.value brightness:hellSlider.value alpha:alphaSlider.value];
    
    colorView.backgroundColor = newColor;
    alphaText.text = [NSString stringWithFormat:@"%.2f",alphaSlider.value];
    brightnessText.text = [NSString stringWithFormat:@"%.2f",hellSlider.value];
    saturationText.text = [NSString stringWithFormat:@"%.2f",saturationSlider.value];
 60+78+105+120+168+210+270+294+324+348+470
 
}*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
    470 +
*/

@end
