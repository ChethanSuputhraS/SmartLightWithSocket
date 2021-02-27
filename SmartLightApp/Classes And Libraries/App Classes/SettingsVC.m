//
//  SettingsVC.m
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 5/31/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import "SettingsVC.h"
#import "BridgeVC.h"
#import "MasterVC.h"
#import "WelcomeVC.h"
#import "ChangePasswordVC.h"
#import <MessageUI/MessageUI.h>
#import "FactoryResetVC.h"
#import "ManageAccVC.h"
@interface SettingsVC ()<MFMailComposeViewControllerDelegate,FCAlertViewDelegate,ORBSwitchDelegate>
{
    UIImageView * statusImg;
    UIImageView * imgBack;
}
@end

@implementation SettingsVC

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
//    imgBack.image = [UIImage imageNamed:CURRENT_BACKGROUND];
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];

    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];

    [self setNavigationViewFrames];
    
    [self setContentViewFrames];
    
    [self setOptionsArray];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [APP_DELEGATE isNetworkreachable];
    currentScreen = @"Settings";
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DoorbellPopupSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DoorbellPopupSuccess) name:@"DoorbellPopupSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DoorbellPopupFailure" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DoorbellPopupFailure) name:@"DoorbellPopupFailure" object:nil];
//    imgBack.image = [UIImage imageNamed:CURRENT_BACKGROUND];
    
    [APP_DELEGATE showTabBar:mainTabBarController];
    
    [imgNotConnected removeFromSuperview];
    imgNotConnected = [[UIImageView alloc]init];
    imgNotConnected.image = [UIImage imageNamed:@"notconnect_iconWhite.png"];
    imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 32, 30, 22);
    imgNotConnected.contentMode = UIViewContentModeScaleAspectFit;
    imgNotConnected.layer.masksToBounds = true;
    [self.view addSubview:imgNotConnected];
    
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
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateInternetAvailabilityNotification object:nil];
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

    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Settings"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+3]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    if (globalConnStatus)
    {
        statusImg.image = [UIImage imageNamed:@"Connected_icon.png"];
    }
    else
    {
        statusImg.image = [UIImage imageNamed:@"notconnect_icon.png"];
    }
    
//    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
//    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
//    [backImg setContentMode:UIViewContentModeScaleAspectFit];
//    backImg.backgroundColor = [UIColor clearColor];
//    [viewHeader addSubview:backImg];
    
    UIImageView * imgMenu = [[UIImageView alloc]initWithFrame:CGRectMake(10,20+7, 33, 30)];
    imgMenu.image = [UIImage imageNamed:@"menu.png"];
    imgMenu.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgMenu];
    
    UIButton * btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMenu setFrame:CGRectMake(0, 0, 80, 64)];
    [btnMenu addTarget:self action:@selector(btnMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnMenu];
    

    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 44, DEVICE_WIDTH-100, 44);
        [btnMenu setFrame:CGRectMake(0, 0, 88, 88)];
        imgMenu.frame = CGRectMake(10,44+7, 33, 30);
    }
}

-(void)setContentViewFrames
{
    tblContent = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT-64-49) style:UITableViewStylePlain];
    [tblContent setBackgroundColor:[UIColor clearColor]];
    [tblContent setShowsVerticalScrollIndicator:NO];
    tblContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblContent.delegate = self;
    tblContent.dataSource = self;
    tblContent.scrollEnabled = false;
    [self.view addSubview:tblContent];
    
    if (IS_IPHONE_X)
    {

        tblContent.frame = CGRectMake(0, 88, DEVICE_WIDTH, DEVICE_HEIGHT-88-49);
    }
}

#pragma mark - Set Option Array
-(void)setOptionsArray
{
    arrContent = [[NSMutableArray alloc] init];
    
    NSArray * nameArr, *imgArr;
    if ([IS_USER_SKIPPED isEqualToString:@"YES"])
    {
        nameArr = [NSArray arrayWithObjects:@"Help",@"About Us",@"Feedback",@"Follow us",@"Login", nil];
        imgArr = [NSArray arrayWithObjects:@"ic_user_manual.png",@"about_icon.png",@"feedback_icon.png",@"follow_icon.png",@"logout.png", nil];
    }
    else
    {
        nameArr = [NSArray arrayWithObjects:@"Change Password",@"Manage Accounts",@"Help",@"About Us",@"Feedback",@"Follow us",@"Logout", nil];
        imgArr = [NSArray arrayWithObjects:@"retrivePass.png",@"ic_manage_account.png",@"ic_user_manual.png",@"about_icon.png",@"feedback_icon.png",@"follow_icon.png",@"logout.png", nil];
    }
    for (int i = 0; i <[nameArr count]; i++)
    {
        NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
        [tempDict setValue:[nameArr objectAtIndex:i]  forKey:@"name"];
        [tempDict setValue:[imgArr objectAtIndex:i] forKey:@"image"];
        [arrContent addObject:tempDict];
    }
}

#pragma mark - Web Service Call
-(void)logoutUserWebService
{
    [activityIndicator startAnimating];
    NSString *websrviceName=@"api/v1/users/logout";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:CURRENT_USER_ACCESS_TOKEN forKey:@"access_token"];

    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"logoutUser";
    manager.delegate = self;
    [manager urlCall:[NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,websrviceName] withParameters:dict];
}

#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
//    NSLog(@"The result is...%@", result);
    [activityIndicator stopAnimating];
    if ([[result valueForKey:@"commandName"] isEqualToString:@"logoutUser"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
             /*NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
             [userDefault setValue:@"" forKey:@"CURRENT_USER_ID"];
             [userDefault synchronize];
             
             LoginVC * splash = [[LoginVC alloc] init];
             UINavigationController * navControl = [[UINavigationController alloc] initWithRootViewController:splash];
             navControl.navigationBarHidden=YES;
             
             AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
             appDelegate.window.rootViewController = navControl;*/
        }
        else
        {
//            URBAlertView * alert =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:[[result valueForKey:@"result"]valueForKey:@"msg"] cancelButtonTitle:OK_BTN otherButtonTitles:nil, nil];
//            [alert showWithAnimation:URBAlertAnimationTopToBottom];
        }
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"GetPassword"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeSuccess];
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"Your password has been sent successfully to your registered mobie number. Please check and try again to login."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
        else
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Mobile not registered with us"])
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:@"Mobile not registered with us. Please login with valid mobile number."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
        }
    }
}
- (void)onError:(NSError *)error
{
//    NSLog(@"The error is...%@", error);
    
    [activityIndicator stopAnimating];
    
    NSInteger ancode = [error code];
    
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
//    NSLog(@"errorDict===%@",errorDict);
    
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009) {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
    } else {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
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
    [userDefault synchronize];
}

#pragma mark- UITableView delegate method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
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
    [cell.imgIcon setHidden:NO];
    [cell.lblName setFrame:CGRectMake(55, 10,DEVICE_WIDTH-50,24)];
    [cell.imgArrow setFrame:CGRectMake(DEVICE_WIDTH-20, 17, 10, 10)];
    [cell.imgCellBG setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
    cell.imgArrow.hidden = NO;
    if (indexPath.row == 2 || indexPath.row ==3)
    {
        cell.imgArrow.hidden = true;
    }
    if (indexPath.row == 0)
    {
        [cell.lblLineUpper setHidden:NO];
    }
    else
    {
        [cell.lblLineUpper setHidden:YES];
    }
    if (indexPath.row==0)
    {
        cell.lblName.text = @"Device Connection";
        cell.imgIcon.image = [UIImage imageNamed:@"bridge2_icon.png"];
    }
    else if (indexPath.row == 1)
    {
        cell.lblName.text = @"Reset device";
        cell.imgIcon.image = [UIImage imageNamed:@"reset.png"];
    }
    else if (indexPath.row == 2)
    {
        cell.lblName.text = @"Delete All Devices";
        cell.imgIcon.image = [UIImage imageNamed:@"ic_delete_device.png"];
    }
    else if (indexPath.row == 3)
    {
        cell.lblName.text = @"Main Power On Setting";
        cell.imgIcon.image = [UIImage imageNamed:@"ic_light_state.png"];
    }
    cell.lblName.textColor = [UIColor whiteColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.backgroundColor = [UIColor clearColor];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0)
    {
        BridgeVC * userDetails = [[BridgeVC alloc] init];
        [self.navigationController pushViewController:userDetails animated:YES];
    }
    else if (indexPath.row == 1)
    {
        FactoryResetVC * userDetails = [[FactoryResetVC alloc] init];
        [self.navigationController pushViewController:userDetails animated:YES];
    }
    else if (indexPath.row == 2)
    {
        if (globalPeripheral.state == CBPeripheralStateConnected)
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeWarning];
            [alert addButton:@"Yes" withActionBlock:
             ^{
                [self removeDevice];
             }];
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"Are you sure want to delete devices"
                   withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
               withDoneButtonTitle:@"No" andButtons:nil];
        }
        else
        {
            [self ShowalertCustion:@"There is no devices to delete."];
        }
    }
    else if (indexPath.row == 3)
    {
        [self btnPowerOnSettingsClicked];
    }
}
-(void)btnWarrantClick
{
    NSString *emailTitle = deviceTokenStr;
    NSString * strName = deviceTokenStr;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    NSString * strMsg = [NSString stringWithFormat:@"%@",strName];
    
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"kalpesh@succorfish.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:strMsg isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    //    UINavigationController * navv = [[UINavigationController alloc] initWithRootViewController:mc];
    [self.navigationController presentViewController:mc animated:YES completion:nil];
    //    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - CleanUp
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)removeDevice
{
    [APP_DELEGATE sendSignalViaScan:@"DeleteUUID" withDeviceID:@"0" withValue:@"0"]; //KalpeshScanCode
    [APP_DELEGATE sendSignalViaScan:@"DeleteUUID" withDeviceID:@"0" withValue:@"0"]; //KalpeshScanCode

    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        [self deletewithBluetoothConnected];
    }
    [self CallWebservicetoDeleteEverything];
    NSString * strDeleteDevices = [NSString stringWithFormat:@"Delete from GroupsTable where user_id='%@'",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strDeleteDevices];
    
    NSString * strDelete = [NSString stringWithFormat:@"Delete from Device_Table where  user_id = '%@'",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strDelete];

    NSString * strDeleteAlarm = [NSString stringWithFormat:@"Delete from Alarm_Table where user_id='%@'",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strDeleteAlarm];

    
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    alert.tag = 222;
    alert.delegate = self;
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"All devices has been deleted successfully."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)ShowalertCustion:(NSString *)strmsg
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeCaution];
    alert.delegate = self;
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:strmsg
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
    
    NSInteger int5 = [@"0" integerValue];
    NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2];
    
    NSInteger int6 = [@"55" integerValue];
    NSData * data6 = [[NSData alloc] initWithBytes:&int6 length:2];
    
    NSMutableData * checkData = [[NSMutableData alloc] init];
    [checkData appendData:data2];
    [checkData appendData:data3];
    [checkData appendData:data4];
    [checkData appendData:data5];//CRC as 0
    [checkData appendData:data6];
    
    NSData * checksumData = [APP_DELEGATE GetCountedCheckSumData:checkData];
    
    NSMutableData * completeData = [[NSMutableData alloc] init];
    completeData = [data1 mutableCopy];
    [completeData appendData:data2];
    [completeData appendData:data3];
    [completeData appendData:data4];
    [completeData appendData:checksumData];
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
-(void)CallWebservicetoDeleteEverything
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
        NSString *deviceToken =deviceTokenStr;
        if (deviceToken == nil || deviceToken == NULL)
        {
            [dict setValue:@"123456789" forKey:@"device_token"];
        }
        else
        {
            [dict setValue:deviceToken forKey:@"device_token"];
        }
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"DeleteAll";
        manager.delegate = self;
        NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/delete_everything";
        [manager urlCall:strServerUrl withParameters:dict];
    }
}
//-(NSString *)checkforValidString:(NSString *)strRequest
//{
//    NSString * strValid;
//    if (![strRequest isEqual:[NSNull null]])
//    {
//        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""])
//        {
//            strValid = strRequest;
//        }
//        else
//        {
//            strValid = @" ";
//        }
//    }
//    else
//    {
//        strValid = @" ";
//    }
//    return strValid;
//}
#pragma mark - All button click events
-(void)btnMenuClicked:(id)sender
{
        [self.menuContainerViewController setMenuSlideAnimationFactor:0.5f];
        [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
            
        }];
}
-(void)btnPowerOnSettingsClicked
{
    [backView removeFromSuperview];
    backView = [[UIView alloc]init];
    backView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    backView.backgroundColor = UIColor.blackColor;
    backView.alpha = 0.5;
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
    lblTitle.font = [UIFont fontWithName:CGBold size:textSizes+10];
    lblTitle.backgroundColor = [UIColor clearColor];
    [viewSetting addSubview:lblTitle];
    
    UIButton *btnCancel = [[UIButton alloc]init];
    btnCancel.frame = CGRectMake(0, viewSetting.frame.size.height-44, (viewSetting.frame.size.width/2)-1, 44);
    btnCancel.backgroundColor = global_brown_color;
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    btnCancel.titleLabel.textColor = UIColor.whiteColor;
    btnCancel.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+3];
    [btnCancel addTarget:self action:@selector(btnCancelAction) forControlEvents:UIControlEventTouchUpInside];
    [viewSetting addSubview:btnCancel];
    
    UIButton *btnSave = [[UIButton alloc]init];
    btnSave.frame = CGRectMake((viewSetting.frame.size.width/2)+1, viewSetting.frame.size.height-44, (viewSetting.frame.size.width/2)-1, 44);
    btnSave.backgroundColor = global_brown_color;
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    btnSave.titleLabel.textColor = UIColor.whiteColor;
    [btnSave addTarget:self action:@selector(btnSaveAction) forControlEvents:UIControlEventTouchUpInside];
    btnSave.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+3];
    [viewSetting addSubview:btnSave];
    
    int yy = 44+10;
    btn1 = [[UIButton alloc]init];
    btn1.frame = CGRectMake(10,yy,viewSetting.frame.size.width-20,44);
    btn1.backgroundColor = [UIColor clearColor];
    [btn1 setTitle:@"  Cool White" forState:UIControlStateNormal];
    [btn1 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btn1.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes];
    [btn1 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    btn1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn1 addTarget:self action:@selector(btn1Action) forControlEvents:UIControlEventTouchUpInside];
    [viewSetting addSubview:btn1];
    
    yy = yy+50;
    btn2 = [[UIButton alloc]init];
    btn2.frame = CGRectMake(10,yy,viewSetting.frame.size.width-20,44);
    btn2.backgroundColor = [UIColor clearColor];
    [btn2 setTitle:@"  Last Set Color" forState:UIControlStateNormal];
    [btn2 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+2];
    [btn2 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    btn2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn2 addTarget:self action:@selector(btn2Action) forControlEvents:UIControlEventTouchUpInside];
    [viewSetting addSubview:btn2];
    
    yy = yy+50;
    btn3 = [[UIButton alloc]init];
    btn3.frame = CGRectMake(10,yy,viewSetting.frame.size.width-20,44);
    btn3.backgroundColor = [UIColor clearColor];
    [btn3 setTitle:@"  Warm White" forState:UIControlStateNormal];
    [btn3 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btn3.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+2];
    [btn3 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    btn3.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn3 addTarget:self action:@selector(btn3Action) forControlEvents:UIControlEventTouchUpInside];
    [viewSetting addSubview:btn3];
    
    yy = yy+50;
    btn4 = [[UIButton alloc]init];
    btn4.frame = CGRectMake(10,yy,viewSetting.frame.size.width-20,44);
    btn4.backgroundColor = [UIColor clearColor];
    [btn4 setTitle:@"  Mood Lightning" forState:UIControlStateNormal];
    [btn4 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btn4.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+2];
    [btn4 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    btn4.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn4 addTarget:self action:@selector(btn4Action) forControlEvents:UIControlEventTouchUpInside];
    [viewSetting addSubview:btn4];
    
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"globalRememberLastColor"] isEqualToString:@"0"])
    {
        [btn1 setImage:[UIImage imageNamed:@"radioSelectedBlack.png"] forState:UIControlStateNormal];
        
    }
    else  if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"globalRememberLastColor"] isEqualToString:@"1"])
    {
        [btn2 setImage:[UIImage imageNamed:@"radioSelectedBlack.png"] forState:UIControlStateNormal];
        
    }
    else  if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"globalRememberLastColor"] isEqualToString:@"2"])
    {
        [btn3 setImage:[UIImage imageNamed:@"radioSelectedBlack.png"] forState:UIControlStateNormal];
        
    }
    else  if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"globalRememberLastColor"] isEqualToString:@"3"])
    {
        [btn4 setImage:[UIImage imageNamed:@"radioSelectedBlack.png"] forState:UIControlStateNormal];
        
    }
    else
    {
        [btn1 setImage:[UIImage imageNamed:@"radioSelectedBlack.png"] forState:UIControlStateNormal];
    }
    [self ShowPicker:YES andView:viewSetting];

}
-(void)btn1Action
{
    intSelectedSettingsValue = 0;
    [btn1 setImage:[UIImage imageNamed:@"radioSelectedBlack.png"] forState:UIControlStateNormal];
    [btn2 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    [btn3 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    [btn4 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    
}
-(void)btn2Action
{
    intSelectedSettingsValue = 1;
    [btn2 setImage:[UIImage imageNamed:@"radioSelectedBlack.png"] forState:UIControlStateNormal];
    [btn1 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    [btn3 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    [btn4 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    
}
-(void)btn3Action
{
    intSelectedSettingsValue = 2;
    [btn3 setImage:[UIImage imageNamed:@"radioSelectedBlack.png"] forState:UIControlStateNormal];
    [btn2 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    [btn1 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    [btn4 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    
}
-(void)btn4Action
{
    intSelectedSettingsValue = 3;
    [btn4 setImage:[UIImage imageNamed:@"radioSelectedBlack.png"] forState:UIControlStateNormal];
    [btn2 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    [btn3 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
    [btn1 setImage:[UIImage imageNamed:@"radioUnselectedBlack.png"] forState:UIControlStateNormal];
}
-(void)btnCancelAction
{
    [self ShowPicker:NO andView:viewSetting];
}
-(void)btnSaveAction
{
    [self ShowPicker:NO andView:viewSetting];

        [self AlertPopForSetting:@"Main Power Setting Saved."];
        
        [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",intSelectedSettingsValue] forKey:@"globalRememberLastColor"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        NSString * strON = [NSString stringWithFormat:@"%d",intSelectedSettingsValue];
        NSString * strQuery = [NSString stringWithFormat:@"update Device_Table set remember_last_color =%@",strON];
        [[DataBaseManager dataBaseManager] execute:strQuery];

}

#pragma mark - feedBackBtn Click
-(void)feedBackBtnClick
{
    NSString *appId = @"9306";
    NSString *appKey = @"UbNIeUwGQK1jBZEf2Z2ZMJnsnWc6gd1mbh2I1g5H1Y2v1ZlmbRIoA11k6Jrwf9Zm";
    
    if (isFeedbackOpen)
    {
        if (feedback)
        {
            [feedback.dialog.delegate dialogDidCancel:feedback.dialog];
            [feedback.dialog removeFromSuperview];
            feedback=nil;
            feedback = Nil;
            [feedback showFeedbackDialogInViewController:self completion:^(NSError *error, BOOL isCancelled) {
                if (error) {
//                    NSLog(@"%@", error.localizedDescription);
                }
            }];
            
        }
        else
        {
            [feedback.dialog removeFromSuperview];
            
            feedback = [Doorbell doorbellWithApiKey:appKey appId:appId];
            feedback.showEmail = YES;
            feedback.email = @"";
            [feedback showFeedbackDialogInViewController:self completion:^(NSError *error, BOOL isCancelled) {
                if (error) {
//                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        }
        isFeedbackOpen = NO;
    }
    else
    {
        feedback = [Doorbell doorbellWithApiKey:appKey appId:appId];
        feedback.showEmail = YES;
        feedback.email = @"";
        
        [feedback showFeedbackDialogInViewController:self completion:^(NSError *error, BOOL isCancelled) {
            if (error) {
//                NSLog(@"%@", error.localizedDescription);
            }
        }];
        
        isFeedbackOpen = YES;
    }
}
-(void)DoorbellPopupSuccess
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Thanks for submitting feedback."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)DoorbellPopupFailure
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeCaution];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Please enter valid email id."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}

-(void)ShowSquareColorOptions
{
    [scrlView removeFromSuperview];
    scrlView = [[UIScrollView alloc] init];
    scrlView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH-0, DEVICE_HEIGHT);
    scrlView.backgroundColor = [UIColor blackColor];
    scrlView.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT);
    [self.view addSubview:scrlView];
    
    UILabel * lblTitle = [[UILabel alloc] init];
    lblTitle.frame = CGRectMake(70, 0, scrlView.frame.size.width, 50);
    lblTitle.font = [UIFont fontWithName:CGRegular size:textSizes-1];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.text = @"Select background to change";
//    lblTitle.textAlignment = NSTextAlignmentCenter;
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
    [btnCancel addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    [scrlView addSubview:btnCancel];
    
    int xx = 15;
    int yy = 50;
    int cnt = 0;
    int vWidth = (DEVICE_WIDTH/2);
    int vHeighth = (DEVICE_WIDTH/2);
    
    NSArray * imgArr = [NSArray arrayWithObjects:@"ic_wheel_one.png",@"ic_wheel_two.png",@"ic_wheel_three.png",@"ic_wheel_four.png",@"ic_wheel_five.png", nil];
    
    for (int i=0; i<[imgArr count]; i++)
    {
        xx=0;
        for (int j=0; j<2; j++)
        {
            if ([imgArr count]==cnt)
            {
                break;
            }
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
            img.contentMode = UIViewContentModeScaleAspectFit;
            [lblTmp addSubview:img];
            
            UIButton * btnTap = [UIButton buttonWithType:UIButtonTypeCustom];
            btnTap.frame = lblTmp.frame;
            [btnTap addTarget:self action:@selector(btnColorOptionClick:) forControlEvents:UIControlEventTouchUpInside];
            btnTap.tag = cnt;
            [scrlView addSubview:btnTap];
            
            xx = vWidth + xx;
            cnt = cnt +1;
        }
        yy = yy + vHeighth-10 ;
    }
    [self hideMorePopUpView:NO];
}
-(void)btnCloseClick
{
    [self hideMorePopUpView:YES];
}
-(void)hideMorePopUpView:(BOOL)isHide
{
    if (isHide == YES)
    {
        [scrlView drop:^{
            [scrlView removeFromSuperview];
        }];
    }
    else
    {
        scrlView.frame = CGRectMake(0, 20, DEVICE_WIDTH, DEVICE_HEIGHT-20);
        [scrlView bounceIntoViewColorView:self.view direction:DCAnimationDirectionBottom];
    }
}
-(void)btnColorOptionClick:(id)sender
{
    
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
-(void)AlertPopForSetting:(NSString *)strMsg
{
FCAlertView *alert = [[FCAlertView alloc] init];
alert.colorScheme = [UIColor blackColor];
[alert makeAlertTypeSuccess];
[alert showAlertInView:self
             withTitle:@"Smart Light"
          withSubtitle:strMsg
       withCustomImage:[UIImage imageNamed:@"logo.png"]
   withDoneButtonTitle:nil
            andButtons:nil];
    alert.dismissOnOutsideTouch = true;
}
//#pragma mark - ORBSwitchDelegate
//
//- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue
//{
//    NSString * deviceID = @"NA";
//    deviceID = globalGroupId;
//    if (![deviceID isEqualToString:@"NA"])
//    {
//        [self switchOffDevice:deviceID withType:newValue];
//    }
//    NSLog(@"Switch toggled: new state is %@", (newValue) ? @"ON" : @"OFF");
//
//
//
//}
//
//- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj
//{
//    [switchObj setCustomKnobImage:[UIImage imageNamed:(switchObj.isOn) ? @"on_icon" : @"off_icon"]
//          inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]
//            activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
//    //[tblContent reloadData];
//}
//
//-(void)switchOffDevice:(NSString *)sentID withType:(BOOL)isOn
//{
//    NSString * strSwitchIsOn;
//    if (isOn)
//    {
//        strSwitchIsOn = @"1";
//    }
//    else
//    {
//        strSwitchIsOn = @"0";
//    }
//
//    [APP_DELEGATE sendSignalViaScan:@"RememberUDID" withDeviceID:@"0" withValue:strSwitchIsOn]; //KalpeshScanCode
//    NSString * strQuery = [NSString stringWithFormat:@"update Device_Table set remember_last_color =%@",strSwitchIsOn];
//    [[DataBaseManager dataBaseManager] execute:strQuery];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//
//   /* if (globalPeripheral.state == CBPeripheralStateConnected)
//    {
//        NSMutableData * collectChekData = [[NSMutableData alloc] init];
//
//        NSInteger int1 = [@"50" integerValue];
//        NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];
//
//        globalCount = globalCount + 1;
//        NSInteger int2 = globalCount;
//        NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2];
//        collectChekData = [data2 mutableCopy];
//
//        NSInteger int3 = [@"9000" integerValue];
//        NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2];
//        [collectChekData appendData:data3];
//
//        NSInteger int4 = [@"0" integerValue];
//        NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2];
//        [collectChekData appendData:data4];
//
//        NSInteger int5 = [@"0" integerValue];
//        NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2];
//        [collectChekData appendData:data5];
//
//        NSInteger int6 = [@"71" integerValue];
//        NSData * data6 = [[NSData alloc] initWithBytes:&int6 length:2];
//        [collectChekData appendData:data6];
//
//        NSInteger int7 = [strON integerValue];
//        NSData * data7 = [[NSData alloc] initWithBytes:&int7 length:1];
//        [collectChekData appendData:data7];
//
//        NSData * finalCheckData = [APP_DELEGATE GetCountedCheckSumData:collectChekData];
//
//        NSMutableData * completeData = [[NSMutableData alloc] init];
//        completeData = [data1 mutableCopy];
//        [completeData appendData:data2];
//        [completeData appendData:data3];
//        [completeData appendData:data4];
//        [completeData appendData:finalCheckData];
//        [completeData appendData:data6];
//        [completeData appendData:data7];
//
//        NSString * StrData = [NSString stringWithFormat:@"%@",completeData];
//        StrData = [StrData stringByReplacingOccurrencesOfString:@" " withString:@""];
//        StrData = [StrData stringByReplacingOccurrencesOfString:@"<" withString:@""];
//        StrData = [StrData stringByReplacingOccurrencesOfString:@">" withString:@""];
//
//        NSString * strEncryptedKey = [APP_DELEGATE getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"passKey"]];
//        NSString * strFinalData = [APP_DELEGATE getStringConvertedinUnsigned:StrData];
//
//        NSData * requestData = [APP_DELEGATE GetEncryptedKeyforData:strFinalData withKey:strEncryptedKey withLength:completeData.length];
//
//        [[BLEService sharedInstance] writeValuetoDeviceMsg:requestData with:globalPeripheral];
//        [[NSUserDefaults standardUserDefaults] setInteger:globalCount forKey:@"GlobalCount"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }*/
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
/*
 NSString * strON;
 if ([[[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"remember_last_color"] isEqualToString:@"1"])
 {
 strON = @"0";
 }
 else
 {
 strON = @"1";
 }
 
 [APP_DELEGATE sendSignalViaScan:@"RememberUDID" withDeviceID:@"0" withValue:strON]; //KalpeshScanCode
 NSString * strQuery = [NSString stringWithFormat:@"update Device_Table set remember_last_color =%@",strON];
 [[DataBaseManager dataBaseManager] execute:strQuery];
 */
