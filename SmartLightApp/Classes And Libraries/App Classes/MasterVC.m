//
//  MasterVC.m
//  SmartLightApp
//
//  Created by stuart watts on 16/12/2017.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import "MasterVC.h"
#import "MoreOptionCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MasterVC ()<UITableViewDelegate,UITableViewDataSource,URLManagerDelegate,FCAlertViewDelegate>
{
    UITableView * tblContent;
    UIImageView * statusImg;
}
@end

@implementation MasterVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];

    [self setNavigationViewFrames];
    [self setContentViewFrames];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    currentScreen = @"MasterSettings";
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:currentScreen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBleStatus) name:currentScreen object:nil];
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
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.5;
    [viewHeader addSubview:lblBack];

    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Master Settings"];
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
    btnBack.frame = CGRectMake(0, 0, 70, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
    }


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

}
-(void)btnBackClick
{
    isfromAddDevice = YES;
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setContentViewFrames
{
    tblContent = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT-64-49) style:UITableViewStyleGrouped];
    [tblContent setBackgroundColor:[UIColor clearColor]];
    [tblContent setShowsVerticalScrollIndicator:NO];
    tblContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblContent.delegate = self;
    tblContent.dataSource = self;
    [self.view addSubview:tblContent];
    
    if (IS_IPHONE_X)
    {
        tblContent.frame = CGRectMake(0, 88, DEVICE_WIDTH, DEVICE_HEIGHT-45-88);
    }
}

#pragma mark- UITableView delegate method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 44;
    }
    else
    {
        return 44;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 35;
    }
    else
    {
        return 20;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 35)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH-100, 35)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    if (section==0)
    {
        [lblTitle setText:[NSString stringWithFormat:@"Hi %@",CURRENT_USER_NAME]];
    }
    else if (section==1)
    {
        [lblTitle setText:@" "];
    }
    return viewHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = nil;
    
    MoreOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        cell = [[MoreOptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.lblEmail setHidden:YES];
    [cell.imgIcon setHidden:YES];
    
    [cell.lblName setFrame:CGRectMake(20, 10,DEVICE_WIDTH-50,24)];
    [cell.imgArrow setFrame:CGRectMake(DEVICE_WIDTH-20, 17, 10, 10)];
    [cell.imgCellBG setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
    
    if (indexPath.row == 0)
    {
        [cell.lblLineUpper setHidden:NO];
    }
    else
    {
        [cell.lblLineUpper setHidden:YES];
    }
    
    
    cell.lblName.text = @"Reset all devices";
    cell.lblName.textColor = global_brown_color;
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.backgroundColor = [UIColor clearColor];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    [alert addButton:@"Yes" withActionBlock:^{
        [self removeDevice];
    }];
    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Are you sure want to reset all the Smartlight devices?"
           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
       withDoneButtonTitle:@"No" andButtons:nil];

}


-(void)removeDevice
{
    [APP_DELEGATE sendSignalViaScan:@"Delete" withDeviceID:@"0" withValue:@"0"]; //KalpeshScanCode

    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        [self deletewithBluetoothConnected];
    }
    [self CallWebservicetoDeleteEverything];
    NSString * strDeleteDevices = [NSString stringWithFormat:@"Delete from GroupsTable"];
    [[DataBaseManager dataBaseManager] execute:strDeleteDevices];
    
    NSString * strDelete = [NSString stringWithFormat:@"Delete from Device_Table"];
    [[DataBaseManager dataBaseManager] execute:strDelete];
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    alert.tag = 222;
    alert.delegate = self;
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Devices has been reset successfully."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)deletewithBluetoothConnected
{
    NSInteger int1 = [@"50" integerValue];
    NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];
    
    globalCount = globalCount + 1;
    
    NSInteger int2 = globalCount;
    NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2];
    
    NSInteger int3 = [@"9000" integerValue];
    NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2];
    
    NSInteger int4 = [@"0" integerValue];
    NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2];
    
    NSInteger int5 = [@"1234" integerValue];
    NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2];
    
    NSInteger int6 = [@"55" integerValue];
    NSData * data6 = [[NSData alloc] initWithBytes:&int6 length:2];
    
    NSMutableData * completeData = [[NSMutableData alloc] init];
    completeData = [data1 mutableCopy];
    [completeData appendData:data2];
    [completeData appendData:data3];
    [completeData appendData:data4];
    [completeData appendData:data5];
    [completeData appendData:data6];
    
    [[BLEService sharedInstance] writeValuetoDeviceMsg:completeData with:globalPeripheral];
    [[NSUserDefaults standardUserDefaults] setInteger:globalCount forKey:@"GlobalCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
-(void)CallWebservicetoDeleteEverything
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
        
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"DeleteAll";
        manager.delegate = self;
        NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/delete_everything";
        [manager urlCall:strServerUrl withParameters:dict];
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
//                    [[BLEManager sharedManager] connectDevice:globalPeripheral];//kp03-01-2017
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
//    NSLog(@"The result is...%@", result);
    if ([[result valueForKey:@"commandName"] isEqualToString:@"logoutUser"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            
        }
        else
        {
            
        }
    }
}

- (void)onError:(NSError *)error
{
//    NSLog(@"The error is...%@", error);
    
    NSInteger ancode = [error code];
    
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
//    NSLog(@"errorDict===%@",errorDict);
    
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009)
    {
//        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
    }
    else
    {
//        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
    }
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


//-(void)kalpeshFIle
//{
//    NSString *  name = @"sample";  //YOUR FILE NAME
//    NSString * source = [[NSBundle mainBundle] pathForResource:name ofType:@"mp3"]; // SPECIFY YOUR FILE FORMAT
//
//    const char *cString = [source cStringUsingEncoding:NSASCIIStringEncoding];
//
//    CFStringRef str = CFStringCreateWithCString(
//                                                NULL,
//                                                cString,
//                                                kCFStringEncodingMacRoman
//                                                );
//    CFURLRef inputFileURL = CFURLCreateWithFileSystemPath(
//                                                          kCFAllocatorDefault,
//                                                          str,
//                                                          kCFURLPOSIXPathStyle,
//                                                          false
//                                                          );
//
//    ExtAudioFileRef fileRef;
//    ExtAudioFileOpenURL(inputFileURL, &fileRef);
//
//
//    AudioStreamBasicDescription audioFormat;
//    audioFormat.mSampleRate = 44100;   // GIVE YOUR SAMPLING RATE
//    audioFormat.mFormatID = kAudioFormatLinearPCM;
//    audioFormat.mFormatFlags = kLinearPCMFormatFlagIsFloat;
//    audioFormat.mBitsPerChannel = sizeof(Float32) * 8;
//    audioFormat.mChannelsPerFrame = 1; // Mono
//    audioFormat.mBytesPerFrame = audioFormat.mChannelsPerFrame * sizeof(Float32);  // == sizeof(Float32)
//    audioFormat.mFramesPerPacket = 1;
//    audioFormat.mBytesPerPacket = audioFormat.mFramesPerPacket * audioFormat.mBytesPerFrame; // = sizeof(Float32)
//
//    // 3) Apply audio format to the Extended Audio File
//    ExtAudioFileSetProperty(
//                            fileRef,
//                            kExtAudioFileProperty_ClientDataFormat,
//                            sizeof (AudioStreamBasicDescription), //= audioFormat
//                            &audioFormat);
//
//    int numSamples = 1024; //How many samples to read in at a time
//    UInt32 sizePerPacket = audioFormat.mBytesPerPacket; // = sizeof(Float32) = 32bytes
//    UInt32 packetsPerBuffer = numSamples;
//    UInt32 outputBufferSize = packetsPerBuffer * sizePerPacket;
//
//    // So the lvalue of outputBuffer is the memory location where we have reserved space
//    UInt8 *outputBuffer = (UInt8 *)malloc(sizeof(UInt8 *) * outputBufferSize);
//
//
//
//    AudioBufferList convertedData ;//= malloc(sizeof(convertedData));
//
//    convertedData.mNumberBuffers = 1;    // Set this to 1 for mono
//    convertedData.mBuffers[0].mNumberChannels = audioFormat.mChannelsPerFrame;  //also = 1
//    convertedData.mBuffers[0].mDataByteSize = outputBufferSize;
//    convertedData.mBuffers[0].mData = outputBuffer; //
//
//    UInt32 frameCount = numSamples;
//    float *samplesAsCArray;
//    int j =0;
//    double floatDataArray[882000]   ; // SPECIFY YOUR DATA LIMIT MINE WAS 882000 , SHOULD BE EQUAL TO OR MORE THAN DATA LIMIT
//
//    while (frameCount > 0) {
//        ExtAudioFileRead(
//                         fileRef,
//                         &frameCount,
//                         &convertedData
//                         );
//        if (frameCount > 0)  {
//            AudioBuffer audioBuffer = convertedData.mBuffers[0];
//            samplesAsCArray = (float *)audioBuffer.mData; // CAST YOUR mData INTO FLOAT
//
//            for (int i =0; i<1024 /*numSamples */; i++) { //YOU CAN PUT numSamples INTEAD OF 1024
//
//                floatDataArray[j] = (double)samplesAsCArray[i] ; //PUT YOUR DATA INTO FLOAT ARRAY
//                printf("\n%f",floatDataArray[j]);  //PRINT YOUR ARRAY'S DATA IN FLOAT FORM RANGING -1 TO +1
//                j++;
//
//
//            }
//        }
//    }
//
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
