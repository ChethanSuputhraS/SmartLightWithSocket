//
//  AppDelegate.m
//  SmartLightApp
//
//  Created by stuart watts on 22/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
// VDK - b9290b6418b851ed241d8dfc08e27966

#import "AppDelegate.h"
#import "SetBeaconManager.h"
#import "GetBeaconManager.h"
#import "DataBaseManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "SplashVC.h"
#import "LoginVC.h"
#import "SignupVC.h"
#import "DashboardVC.h"
#import "FavoriteVC.h"
#import "SettingsVC.h"
#import "AlarmVC.h"
#import "MBProgressHUD.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Reachability.h"
#import "NSData+AES.h"
#import "NSData+Conversion.h"
#import "Reachability.h"
#import <CommonCrypto/CommonCrypto.h>
#import "Header.h"
#import "crc16.h"
#import "WelcomeVC.h"
#import "ForgetVC.h"
#import "ManageAccVC.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

@import Firebase;

@interface AppDelegate ()
{
    NSInteger hieghtIcon;
    UILabel * lblLogoName;
    UIImageView * imgLogo;
    UIImageView * imgBG;
    
    NSString * strMain;
    unsigned char strMainResult[16];
    int tmpCount;
    NSTimer * rssiTimer;
    

}
#if __LP64__
typedef unsigned int                    UInt32;
typedef signed int                      SInt32;
#else
typedef unsigned long                   UInt32;
typedef signed long                     SInt32;
#endif
@end

@implementation AppDelegate

//i is the length of cmd
- (Byte)CalcCheckSum:(Byte)i data:(NSMutableData *)cmd
{
    Byte * cmdByte = (Byte *)malloc(i);
    memcpy(cmdByte, [cmd bytes], i);
    Byte local_cs = 0;
    int j = 0;
    while (i>0) {
        local_cs += cmdByte[j];
        i--;
        j++;
    };
    local_cs = local_cs&0xff;
    return local_cs;
}
-(void)updateTimercnt
{
    int randomID = arc4random() % 9000 + 1000;
    NSLog(@"random=%d",randomID);

}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [self CheckHash256];
    NSString * strKey = [[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"];

    NSLog(@"0000000==%@",strKey);
    arrGlobalDevices = [[NSMutableArray alloc] init];
    arrSocketDevices = [[NSMutableArray alloc] init];
    arrPeripheralsCheck = [[NSMutableArray alloc] init];
    
    [rssiTimer invalidate];
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateRSSItimer) userInfo:nil repeats:YES];

    [[NSUserDefaults standardUserDefaults] setValue:@"3A094462FD6210CDE87442CAA9D718F9" forKey:@"VDK"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    deviceTokenStr = @"1234";
    
    NSInteger golbSavedCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"GlobalCount"];
    if (golbSavedCount == 65555)
    {
        globalCount = 0;
    }
    else
    {
        globalCount = golbSavedCount;
    }
    
    [Fabric with:@[[Crashlytics class]]];
    
    textSizes = 16;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSizes = 15;
    }

    [FIRApp configure];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else
    {
        [[UIApplication sharedApplication]enabledRemoteNotificationTypes];
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    }
    
    if (IS_IPHONE_6plus)
    {
        approaxSize = 1.29;
    }
    else if (IS_IPHONE_6)
    {
        approaxSize = 1.17;
    }
    else
    {
        approaxSize = 1;
    }
    [self updateBackgroundImages];
    
    [self createDatabase];

    [self createUUDIsforIOS13Above];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [self InitialBLE];
    SplashVC * splash = [[SplashVC alloc] init];
    UINavigationController * navControl = [[UINavigationController alloc] initWithRootViewController:splash];
    navControl.navigationBarHidden=YES;
    self.window.rootViewController = navControl;

    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted)
        {
//            NSLog(@"Permission granted");
        }
        else
        {
//            NSLog(@"Permission denied");
         
        }
    }];
    
//    -(void)WriteWifiPassword:(NSString *)strPassword
    [[BLEService sharedInstance] WriteWifiPassword:@"#Newbusiness$"];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
        NSArray * tmpArr = [[BLEManager sharedManager]getLastConnected];
        [[BLEManager sharedManager] stopScan];
        [[[BLEManager sharedManager] foundDevices] removeAllObjects];
        for (int i=0; i<tmpArr.count; i++)
        {
            CBPeripheral * p = [tmpArr objectAtIndex:i];
            [[BLEManager sharedManager]disconnectDevice:p];
        }
}
-(void)updateBackgroundImages
{
    if (IS_IPHONE_4)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"iphone4" forKey:@"globalBackGroundImage"];
    }
    else if (IS_IPHONE_5)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"iphone5" forKey:@"globalBackGroundImage"];
    }
    else if (IS_IPHONE_6)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"iphone6" forKey:@"globalBackGroundImage"];
    }
    else if (IS_IPHONE_6plus)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"iphone6+" forKey:@"globalBackGroundImage"];
    }
    else if (IS_IPHONE_X)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"iphonex" forKey:@"globalBackGroundImage"];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}
-(void)createDatabase
{
    [DataBaseManager dataBaseManager];
    [[DataBaseManager dataBaseManager] Create_UserAccount_Table];
    [[DataBaseManager dataBaseManager] addnewBrigthcolumnstoDevice];
    [[DataBaseManager dataBaseManager] AddIdentifierColumntoDeviceTable];
    [[DataBaseManager dataBaseManager] AddSocketStatusColumntoDeviceTable];
    [[DataBaseManager dataBaseManager] AddWifi_ConfigureColumntoDeviceTable];
    [[DataBaseManager dataBaseManager] Create_Socket_AlarmDetail_Table];
    [[NSUserDefaults standardUserDefaults] setValue:@"Yes" forKey:@"FreshDatabased"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Orientation
-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark - Remote notification
-(void)askPushNotificationPermission
{
    /*-------------Push Notitications------------*/
    // Register for Push Notitications, if running iOS 8
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        // Register for Push Notifications before iOS 8
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
        //        [application enabledRemoteNotificationTypes];
    }
    /*-------------------------------------------*/
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:   (UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString   *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    deviceTokenStr = [[[[deviceToken debugDescription]
                        stringByReplacingOccurrencesOfString: @"<" withString: @""]
                       stringByReplacingOccurrencesOfString: @">" withString: @""]
                      stringByReplacingOccurrencesOfString: @" " withString: @""] ;
//    NSLog(@"My device token ============================>>>>>>>>>>>%@",deviceTokenStr);
    
    
    // Pass device token to auth.
    //    [[FIRAuth auth] setAPNSToken:deviceToken type:FIRAuthAPNSTokenTypeProd];
    // Further handling of the device token if needed by the app.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
//    NSLog(@"Failed to get token, error: %@", error);
}
#pragma mark - Go To Dashboard
-(void)goToDashboard
{
    sideMenuViewController = [[LeftMenuVC alloc] init];
    container = [MFSideMenuContainerViewController containerWithCenterViewController:[self navigationController] leftMenuViewController:sideMenuViewController rightMenuViewController:nil];
    container.navigationController.navigationBar.hidden = YES;
    self.window.rootViewController = container;
    
    
    
//    DashboardVC * firstViewController = [[DashboardVC alloc]init];
//    firstViewController.title=@"Dashboard";
//    firstViewController.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"Dashboard" image:[[UIImage imageNamed:@"home_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ] selectedImage:[[UIImage imageNamed:@"active_home_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ];
//    UINavigationController * firstNavigation = [[UINavigationController alloc]initWithRootViewController:firstViewController];
//    firstNavigation.navigationBarHidden = YES;
//
//    FavoriteVC * secondViewController = [[FavoriteVC alloc]init];
//    secondViewController.title=@"Favorite";
//    secondViewController.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"Favorite" image:[[UIImage imageNamed:@"favorite_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ] selectedImage:[[UIImage imageNamed:@"active_favorite_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ];
//    UINavigationController * secondNavigation = [[UINavigationController alloc]initWithRootViewController:secondViewController];
//    secondNavigation.navigationBarHidden = YES;
//
//    AlarmVC * thirdViewController = [[AlarmVC alloc]init];
//    thirdViewController.title = @"Scheduler";
//    thirdViewController.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"Scheduler" image:[[UIImage imageNamed:@"alarm_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ] selectedImage:[[UIImage imageNamed:@"active_alarm_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ];
//    UINavigationController * thirdNavigation = [[UINavigationController alloc]initWithRootViewController:thirdViewController];
//    thirdNavigation.navigationBarHidden = YES;
//
//    SettingsVC * fourthViewController = [[SettingsVC alloc]init];
//    fourthViewController.title = @"Settings";
//    fourthViewController.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"Settings" image:[[UIImage imageNamed:@"settings_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ] selectedImage:[[UIImage imageNamed:@"active_settings_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ];
//    UINavigationController * forthNavigation = [[UINavigationController alloc]initWithRootViewController:fourthViewController];
//    forthNavigation.navigationBarHidden = YES;
//
////    mainTabBarController = [[UITabBarController alloc] init];
////    mainTabBarController.viewControllers = [[NSArray alloc] initWithObjects:firstNavigation,secondNavigation,thirdNavigation,forthNavigation,nil];
////    mainTabBarController.tabBar.tintColor = [UIColor clearColor];
////    mainTabBarController.delegate = self;
////    mainTabBarController.tabBar.barTintColor = [UIColor clearColor];
////    mainTabBarController.selectedIndex = 0;
//
//    //  The color you want the tab bar to be
//    UIColor *barColor = [UIColor colorWithRed:1.0f/255.0 green:1.0f/255.0 blue:1.0f/255.0 alpha:0.44f];
//
//    //  Create a 1x1 image from this color
//    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
//    [barColor set];
//    UIRectFill(CGRectMake(0, 0, 1, 1));
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    //  Apply it to the tab bar
//    [[UITabBar appearance] setBackgroundImage:image];
//
//    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:CGBold size:textSizes-4],
//                                                        NSForegroundColorAttributeName : [UIColor whiteColor]
//                                                        } forState:UIControlStateSelected];
//
//
//    // doing this results in an easier to read unselected state then the default iOS 7 one
//    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:CGRegular size:textSizes-4],
//                                                        NSForegroundColorAttributeName : [UIColor grayColor]
//                                                        } forState:UIControlStateNormal];
//
//    self.window.rootViewController = firstNavigation;
////    self.window.rootViewController = mainTabBarController;
}
#pragma mark - Go To Home
-(void) setSlideRootNavigation
{
    sideMenuViewController = [[LeftMenuVC alloc] init];
    
    container = [MFSideMenuContainerViewController
                 containerWithCenterViewController:[self navigationController]
                 leftMenuViewController:sideMenuViewController
                 rightMenuViewController:nil];
    
    self.window.rootViewController = container;
}
- (UINavigationController *)navigationController
{
    globalDashBoardVC = [[DashboardVC alloc] init];
   UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:globalDashBoardVC];
    nav.navigationBar.hidden = YES;
    return nav;
}
- (DashboardVC *)demoController
{
    return [[DashboardVC alloc] init];
}

-(void)movetoSelectedIndex:(int)selectedInex
{
    [mainTabBarController setSelectedIndex:selectedInex];
}
#pragma mark - Error Message
-(void)ShowErrorPopUpWithErrorCode:(NSInteger)errorCode andMessage:(NSString*)errorMessage
{
    [APP_DELEGATE endHudProcess];

    NSString * strErrorMessage;
    if (errorCode == -1004){
        strErrorMessage = @"Could not connect to the server";
    }    else if (errorCode == -1009){
        strErrorMessage = @"No Network Connection";
    }else if (errorCode == -1005){
        strErrorMessage = @"Network Connection Lost";
        //        strErrorMessage = @"";
    }else if (errorCode == -1001){
        strErrorMessage = @"Request Timed Out";
    }else if (errorCode == customErrorCodeForMessage){//custom message
        strErrorMessage = errorMessage;
    }
    
    
    [viewNetworkConnectionPopUp removeFromSuperview];
    [viewNetworkConnectionPopUp setAlpha:0.0];
    
    if (![strErrorMessage isEqualToString:@""])
    {
        viewNetworkConnectionPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, -64, DEVICE_WIDTH, 64)];
        [viewNetworkConnectionPopUp setBackgroundColor:[UIColor clearColor]];
        [self.window addSubview:viewNetworkConnectionPopUp];
        
        UIView * viewTrans = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewNetworkConnectionPopUp.frame.size.width, viewNetworkConnectionPopUp.frame.size.height)];
        [viewTrans setBackgroundColor:[self colorWithHexString:dark_red_color]];
        [viewTrans setAlpha:0.9];
        [viewNetworkConnectionPopUp addSubview:viewTrans];
        
        UIImageView * imgProfile = [[UIImageView alloc] initWithFrame:CGRectMake(50, 24, 16, 16)];
        [imgProfile setImage:[UIImage imageNamed:@"cross.png"]];
        imgProfile.contentMode = UIViewContentModeScaleAspectFit;
        imgProfile.clipsToBounds = YES;
        //[viewNetworkConnectionPopUp addSubview:imgProfile];
        
        UILabel * lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, DEVICE_WIDTH-40, 44)];
        [lblMessage setBackgroundColor:[UIColor clearColor]];
        [lblMessage setTextColor:[UIColor whiteColor]];
        [lblMessage setTextAlignment:NSTextAlignmentCenter];
        [lblMessage setNumberOfLines:2];
        [lblMessage setText:[NSString stringWithFormat:@"%@",strErrorMessage]];
        [lblMessage setFont:[UIFont systemFontOfSize:14]];
        [viewNetworkConnectionPopUp addSubview:lblMessage];
        
        [UIView transitionWithView:viewNetworkConnectionPopUp duration:0.3
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            [viewNetworkConnectionPopUp setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
                        }
                        completion:^(BOOL finished) {
                        }];
    }
    
    [timerNetworkConnectionPopUp invalidate];
    timerNetworkConnectionPopUp = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(removeNetworkConnectionPopUp:) userInfo:nil repeats:NO];
}

-(void)removeNetworkConnectionPopUp:(NSTimer*)timer
{
    [APP_DELEGATE endHudProcess];

    [UIView transitionWithView:viewNetworkConnectionPopUp duration:0.3
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        [viewNetworkConnectionPopUp setFrame:CGRectMake(0, -64, DEVICE_WIDTH, 64)];
                    }
                    completion:^(BOOL finished)
     {
         [viewNetworkConnectionPopUp removeFromSuperview];
     }];
}
#pragma mark - Hud Method
-(void)hudForprocessMethod
{
    [self hudEndProcessMethod];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:HUD];
    [HUD show:YES];
}
-(void)hudEndProcessMethod
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
    HUD=nil;
}
#pragma mark - Save User Details
-(void)saveUserDetails:(NSMutableDictionary*)userDitails
{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    
    if ([[userDitails valueForKey:@"user"] valueForKey:@"user_id"]){
        if (![[[userDitails valueForKey:@"user"] valueForKey:@"user_id"] isEqual:[NSNull null]] && [[userDitails valueForKey:@"user"] valueForKey:@"user_id"] != nil && [[userDitails valueForKey:@"user"] valueForKey:@"user_id"] != NULL){
            [userDefault setValue:[[[userDitails valueForKey:@"user"] valueForKey:@"user_id"] stringValue] forKey:@"CURRENT_USER_ID"];
        }
    }
    
    if ([[userDitails valueForKey:@"user"] valueForKey:@"access_permission"]){
        if (![[[userDitails valueForKey:@"user"] valueForKey:@"access_permission"] isEqual:[NSNull null]] && [[userDitails valueForKey:@"user"] valueForKey:@"access_permission"] != nil && [[userDitails valueForKey:@"user"] valueForKey:@"access_permission"] != NULL){
            [userDefault setValue:[[userDitails valueForKey:@"user"] valueForKey:@"access_permission"] forKey:@"CURRENT_USER_ACCESS_PERMISSION"];
        }
    }
    
    if ([[userDitails valueForKey:@"user"] valueForKey:@"first_name"]){
        if (![[[userDitails valueForKey:@"user"] valueForKey:@"first_name"] isEqual:[NSNull null]] && [[userDitails valueForKey:@"user"] valueForKey:@"first_name"] != nil && [[userDitails valueForKey:@"user"] valueForKey:@"first_name"] != NULL){
            [userDefault setValue:[[userDitails valueForKey:@"user"] valueForKey:@"first_name"] forKey:@"CURRENT_USER_FIRST_NAME"];
        }
    }
    
    if ([[userDitails valueForKey:@"user"] valueForKey:@"last_name"]){
        if (![[[userDitails valueForKey:@"user"] valueForKey:@"user_id"] isEqual:[NSNull null]] && [[userDitails valueForKey:@"user"] valueForKey:@"last_name"] != nil && [[userDitails valueForKey:@"user"] valueForKey:@"last_name"] != NULL){
            [userDefault setValue:[[userDitails valueForKey:@"user"] valueForKey:@"last_name"] forKey:@"CURRENT_USER_LAST_NAME"];
        }
    }
    
    if ([[userDitails valueForKey:@"user"] valueForKey:@"email"]){
        if (![[[userDitails valueForKey:@"user"] valueForKey:@"email"] isEqual:[NSNull null]] && [[userDitails valueForKey:@"user"] valueForKey:@"email"] != nil && [[userDitails valueForKey:@"user"] valueForKey:@"email"] != NULL){
            [userDefault setValue:[[userDitails valueForKey:@"user"] valueForKey:@"email"] forKey:@"CURRENT_USER_EMAIL"];
        }
    }
    
    if ([[userDitails valueForKey:@"user"] valueForKey:@"photo"]){
        if (![[[userDitails valueForKey:@"user"] valueForKey:@"photo"] isEqual:[NSNull null]] && [[userDitails valueForKey:@"user"] valueForKey:@"photo"] != nil && [[userDitails valueForKey:@"user"] valueForKey:@"photo"] != NULL){
            [userDefault setValue:[[userDitails valueForKey:@"user"] valueForKey:@"photo"] forKey:@"CURRENT_USER_IMAGE"];
        }
    }
    
    [userDefault synchronize];
    
    /*if ([userDitails valueForKey:@"access_token"]){
     if (![[userDitails valueForKey:@"access_token"] isEqual:[NSNull null]] && [userDitails valueForKey:@"access_token"] != nil && [userDitails valueForKey:@"access_token"] != NULL){
     [userDefault setValue:[userDitails valueForKey:@"access_token"] forKey:@"CURRENT_USER_ACCESS_TOKEN"];
     }
     }*/
    
    
    /*NSLog(@"CURRENT_USER_ID===%@",CURRENT_USER_ID);
    NSLog(@"CURRENT_USER_EMAIL===%@",CURRENT_USER_EMAIL);
    NSLog(@"CURRENT_USER_FIRST_NAME===%@",CURRENT_USER_FIRST_NAME);
    NSLog(@"CURRENT_USER_LAST_NAME===%@",CURRENT_USER_LAST_NAME);
    NSLog(@"CURRENT_USER_IMAGE===%@",CURRENT_USER_IMAGE);
    NSLog(@"CURRENT_USER_ACCESS_PERMISSION===%@",CURRENT_USER_ACCESS_PERMISSION);*/
}
#pragma mark - Save Status To Database
-(void)saveServerBeaconsToDatabaseWithArray:(NSMutableArray*)beaconsArray
{
//    NSLog(@"beaconsArray===%@",beaconsArray);
    
    NSString * queryDeleteStr = [NSString stringWithFormat:@"Delete from AppBeacons"];
    [[DataBaseManager dataBaseManager] execute:queryDeleteStr];
    
    for (int i =0; i<[beaconsArray count]; i++)
    {
        NSMutableArray * tempDict = [beaconsArray objectAtIndex:i];
        NSString *queryStr = [NSString stringWithFormat:@"INSERT INTO AppBeacons (server_beacon_id,beacon_name,door_id,door_name,ieee_id) values ('%@','%@','%@','%@','%@')",[tempDict valueForKey:@"id"],[tempDict valueForKey:@"name"],[tempDict valueForKey:@"door_id"],[tempDict valueForKey:@"door_id"],[tempDict valueForKey:@"ieee_id"]];
//        NSLog(@"queryStr--%@",queryStr);
        [[DataBaseManager dataBaseManager] execute:queryStr];
    }
    
    NSMutableArray * arrCheck = [[NSMutableArray alloc] init];
    NSString * queryCheckStr = [NSString stringWithFormat:@"Select * from AppBeacons"];
    [[DataBaseManager dataBaseManager] execute:queryCheckStr resultsArray:arrCheck];
//    NSLog(@"arrCheck===%@",arrCheck);
}

#pragma mark - Global Helper Functions
-(BOOL)validateEmail:(NSString*)email
{
    if( (0 != [email rangeOfString:@"@"].length) &&  (0 != [email rangeOfString:@"."].length) )
    {
        NSMutableCharacterSet *invalidCharSet = [[[NSCharacterSet alphanumericCharacterSet] invertedSet]mutableCopy];
        [invalidCharSet removeCharactersInString:@"_-"];
        
        NSRange range1 = [email rangeOfString:@"@" options:NSCaseInsensitiveSearch];
        
        // If username part contains any character other than "."  "_" "-"
        
        NSString *usernamePart = [email substringToIndex:range1.location];
        NSArray *stringsArray1 = [usernamePart componentsSeparatedByString:@"."];
        for (NSString *string in stringsArray1)
        {
            NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet: invalidCharSet];
            if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])
                return FALSE;
        }
        
        NSString *domainPart = [email substringFromIndex:range1.location+1];
        NSArray *stringsArray2 = [domainPart componentsSeparatedByString:@"."];
        
        for (NSString *string in stringsArray2)
        {
            NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet:invalidCharSet];
            if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])
                return FALSE;
        }
        
        return TRUE;
    }
    else
    {// no '@' or '.' present

        return FALSE;
    }
}

-(UIColor *) colorWithHexString:(NSString *)stringToConvert
{
    // NSLog(@"ColorCode -- %@",stringToConvert);
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    
    if ([cString length] < 6) return [UIColor blackColor];
    
    // strip 0X if it appears
    
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    
    NSRange range;
    
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
            
                           green:((float) g / 255.0f)
            
                            blue:((float) b / 255.0f)
            
                           alpha:1.0f];
}

- (UIImage *)imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(CGFloat)getHeightForText:(NSString*)givenText andWidth:(CGFloat)givenWidth andFontSize:(CGFloat)fontSize andFontWeight:(CGFloat)fontWeight
{
    CGSize boundingSize = CGSizeMake(givenWidth, 0);
    
    CGSize itemTextSize = [givenText boundingRectWithSize:boundingSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular]} context:nil].size;
    
    float textHeight = itemTextSize.height+5;
    
    return textHeight;
}

-(NSString*)getCurrentTimeAndDate
{
    NSDate* date = [NSDate date];
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * currentdate = [df stringFromDate:date];
    return currentdate;
}

-(NSString*)getCurrentDateOnly
{
    NSDate* date = [NSDate date];
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString * currentdate = [df stringFromDate:date];
    return currentdate;
}




-(BOOL)isNetworkreachable
{
    Reachability *networkReachability = [[Reachability alloc] init];
    NetworkStatus networkStatus = [networkReachability internetConnectionStatus];
    if (networkStatus == NotReachable)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark Hud Method
-(void)startHudProcess:(NSString *)text
{
    [HUD removeFromSuperview];
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    HUD.labelText = text;
    [self.window addSubview:HUD];
    [HUD show:YES];
    
}
-(void)endHudProcess
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
    HUD=nil;
}
-(void)movetoLogin
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
    [UIView commitAnimations];
    
    LoginVC * splash = [[LoginVC alloc] init];
    UINavigationController * navControl = [[UINavigationController alloc] initWithRootViewController:splash];
    navControl.navigationBarHidden=YES;
    self.window.rootViewController = navControl;
}
-(void)movetoWelcome
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
    [UIView commitAnimations];
    
    WelcomeVC * splash = [[WelcomeVC alloc] init];
    UINavigationController * navControl = [[UINavigationController alloc] initWithRootViewController:splash];
    navControl.navigationBarHidden=YES;
    self.window.rootViewController = navControl;
}
#pragma mark - Add Scanner view
-(void)addScannerView
{
    backView = [[UIView alloc] initWithFrame:self.window.bounds];
    backView.backgroundColor = [UIColor colorWithRed:15/255.0 green:15/255.0 blue:15/255.0 alpha:0.80];
    [self.window addSubview:backView];
    backView.hidden = YES;
    
    loaderView = [[SCSkypeActivityIndicatorView alloc] init];
    loaderView.frame = CGRectMake((DEVICE_WIDTH-50)/2, (DEVICE_HEIGHT-50)/2, 50, 50);
    [loaderView setNumberOfBubbles:5];
    [loaderView setAnimationDuration:1.5f];
    [loaderView setBubbleSize:CGSizeMake(7.0f, 7.0f)];
    loaderView.bubbleColor = global_brown_color;
    [backView addSubview:loaderView];
    
    lblTextIndiCator = [[UILabel alloc] initWithFrame:CGRectMake(0, ((DEVICE_HEIGHT-50)/2)+80, DEVICE_WIDTH, 44)];
    [lblTextIndiCator setBackgroundColor:[UIColor clearColor]];
    [lblTextIndiCator setText:@"Scanning for devices..."];
    [lblTextIndiCator setTextAlignment:NSTextAlignmentCenter];
    [lblTextIndiCator setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightRegular]];
    [lblTextIndiCator setTextColor:UIColor.whiteColor];
    [backView addSubview:lblTextIndiCator];
    
}
-(void)showScannerView:(NSString *)msgStr;
{
    [loaderView startAnimating];
    backView.hidden = NO;
    [lblTextIndiCator setText:msgStr];
}
-(void)hideScannerView;
{
    [loaderView stopAnimating];
    backView.hidden = YES;
}



#pragma mark  HIDE TAB BAR AT BOTTOM
- (void) hideTabBar:(UITabBarController *) tabbarcontroller
{
    tabbarcontroller.tabBar.hidden = YES;
}

#pragma mark  SHOW TAB BAR AT BOTTOM
- (void) showTabBar:(UITabBarController *) tabbarcontroller
{
    tabbarcontroller.tabBar.hidden = NO;
}
#pragma mark - Clear User Information
-(void)logoutAndGoToLogin
{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_ID"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_FIRST_NAME"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_LAST_NAME"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_EMAIL"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_IMAGE"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_ACCESS_TOKEN"];
    [userDefault synchronize];
    
    if (globalDashBoardVC)
    {
        [globalDashBoardVC DisconnectMQTTSocketServer];
    }
    LoginVC * start_up = [[LoginVC alloc] init];
    UINavigationController *nav =[[UINavigationController alloc] initWithRootViewController:start_up];
    self.window.rootViewController =nav;
    nav.navigationBarHidden=YES;
    [self.window makeKeyAndVisible];
}

#pragma mark - Location manager delegate
-(void)getLocationMethod
{
//    NSLog(@"%s",__FUNCTION__);
    /*-----------Start Location Manager----------*/
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    if(IS_OS_8_OR_LATER) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    /*-------------------------------------------*/
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
    }
//    NSLog(@"appLatitude===%@,appLongitude====%@",appLatitude,appLongitude);
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
//    NSLog(@"error===%@",error);
//    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - iBeacon Setup Methods
-(void)startAdvertisingBeacons
{
    [[SetBeaconManager sharedManager] initializeDeviceAsBeaconService];//kp812
}
-(void)stopAdvertisingBaecons
{
    [[SetBeaconManager sharedManager] stopService];//kp812
}
-(void)createUUDIsforIOS13Above
{
    //Create Global UUID
    NSString * strGlobUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"globalUUID"];
    if ([strGlobUUID isEqual:[NSNull null]] || [strGlobUUID length]==0 || strGlobUUID == nil)
    {
        CFUUIDRef udid = CFUUIDCreate(NULL);
        NSString *udidString = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, udid));
        [[NSUserDefaults standardUserDefaults] setValue:udidString forKey:@"globalUUID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
    /*-----------Start Location Manager----------*/
    [self getLocationMethod];
    /*-------------------------------------------*/
    
    //Identify device UUID
        [self generateUUIDforColor:@"0" withOpcode:@"52"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"52"];
    
    //Create Color UUID
        [self generateUUIDforColor:@"0" withOpcode:@"66"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"66"];
    
    //Create White Color UUID
        [self generateUUIDforColor:@"0" withOpcode:@"70"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"70"];
    
    //Create OnOff UUID
        [self generateUUIDforColor:@"0" withOpcode:@"85"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"85"];
    
    //Create Pattern UUID
        [self generateUUIDforColor:@"0" withOpcode:@"67"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"67"];
    
    //Create Delete UUID
        [self generateUUIDforColor:@"0" withOpcode:@"55"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"55"];
    
    //Create Ping UUID
        [self generateUUIDforColor:@"0" withOpcode:@"112"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"112"];
    
    //Create White color UUID
        [self generateUUIDforColor:@"0" withOpcode:@"82"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"82"];
    
    //Set Time UUID
        [self generateUUIDforColor:@"0" withOpcode:@"96"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"96"];

    //Add Group UUID
        [self generateUUIDforColor:@"0" withOpcode:@"8"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"8"];

    //Delete Group UUID
        [self generateUUIDforColor:@"0" withOpcode:@"10"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"10"];

    //Delete Alarm UUID
        [self generateUUIDforColor:@"0" withOpcode:@"99"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"99"];

    //Music UUID
        [self generateUUIDforColor:@"0" withOpcode:@"72"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"72"];
    
    //Music UUID
        [self generateUUIDforColor:@"0" withOpcode:@"71"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"71"];
   
    //Reset All Default UUID
        [self generateUUIDforColor:@"0" withOpcode:@"155"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"155"];
    
   

    
//    Identify
}
-(void)createAllUUIDs
{
    //Create Global UUID
    NSString * strGlobUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"globalUUID"];
    if ([strGlobUUID isEqual:[NSNull null]] || [strGlobUUID length]==0 || strGlobUUID == nil)
    {
        CFUUIDRef udid = CFUUIDCreate(NULL);
        NSString *udidString = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, udid));
        [[NSUserDefaults standardUserDefaults] setValue:udidString forKey:@"globalUUID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    /*-----------Start Location Manager----------*/
    [self getLocationMethod];
    /*-------------------------------------------*/
    
    //Identify device UUID
    NSString * strIdentifyUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"IdentifyUUID"];
    if ([strIdentifyUUID isEqual:[NSNull null]] || [strIdentifyUUID length]==0 || strIdentifyUUID == nil)
    {
        [self generateUUIDforColor:@"0" withOpcode:@"52"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"52"];
    }
    
    //Create Color UUID
    NSString * strColorUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"colorUUID"];
    if ([strColorUUID isEqual:[NSNull null]] || [strColorUUID length]==0 || strColorUUID == nil)
    {
        [self generateUUIDforColor:@"0" withOpcode:@"66"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"66"];
    }
    
    //Create White Color UUID
    NSString * strWhiteUDID = [[NSUserDefaults standardUserDefaults] valueForKey:@"whiteColorUDID"];
    if ([strWhiteUDID isEqual:[NSNull null]] || [strWhiteUDID length]==0 || strWhiteUDID == nil)
    {
        [self generateUUIDforColor:@"0" withOpcode:@"70"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"70"];
    }
    
    //Create OnOff UUID
    NSString * strOnOffUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"OnOffUUID"];
    if ([strOnOffUUID isEqual:[NSNull null]] || [strOnOffUUID length]==0 || strOnOffUUID == nil)
    {
        [self generateUUIDforColor:@"0" withOpcode:@"85"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"85"];
    }
    
    //Create Pattern UUID
    NSString * strPatrnUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"PatternUUID"];
    if ([strPatrnUUID isEqual:[NSNull null]] || [strPatrnUUID length]==0 || strPatrnUUID == nil)
    {
        [self generateUUIDforColor:@"0" withOpcode:@"67"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"67"];
    }
    
    //Create Delete UUID
    NSString * strDeleteUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeleteUUID"];
    if ([strDeleteUUID isEqual:[NSNull null]] || [strDeleteUUID length]==0 || strDeleteUUID == nil)
    {
        [self generateUUIDforColor:@"0" withOpcode:@"55"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"55"];
    }
    
    //Create Ping UUID
    NSString * strPingUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"PingUUID"];
    if ([strPingUUID isEqual:[NSNull null]] || [strPingUUID length]==0 || strPingUUID == nil)
    {
        [self generateUUIDforColor:@"0" withOpcode:@"112"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"112"];
    }
    
    
    //Create White color UUID
    NSString * strWhiteUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"WhiteUUID"];
    if ([strWhiteUUID isEqual:[NSNull null]] || [strWhiteUUID length]==0 || strWhiteUUID == nil)
    {
        [self generateUUIDforColor:@"0" withOpcode:@"82"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"82"];
    }
    
    //Set Time UUID
    NSString * stTimeUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"TimeUUID"];
    if ([stTimeUUID isEqual:[NSNull null]] || [stTimeUUID length]==0 || stTimeUUID == nil)
    {
        [self generateUUIDforColor:@"0" withOpcode:@"96"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"96"];
    }
    //Add Group UUID
    NSString * strAddGroupUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"AddGroupUUID"];
    if ([strAddGroupUUID isEqual:[NSNull null]] || [strAddGroupUUID length]==0 || strAddGroupUUID == nil)
    {
        [self generateUUIDforColor:@"0" withOpcode:@"8"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"8"];
    }
    //Delete Group UUID
    NSString * strDeleteGroupUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeleteGroupUUID"];
    if ([strDeleteGroupUUID isEqual:[NSNull null]] || [strDeleteGroupUUID length]==0 || strDeleteGroupUUID == nil)
    {
        [self generateUUIDforColor:@"0" withOpcode:@"10"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"10"];
    }
    //Delete Alarm UUID
    NSString * strRemovealarmUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeleteAlarmUUID"];
    if ([strRemovealarmUUID isEqual:[NSNull null]] || [strRemovealarmUUID length]==0 || strRemovealarmUUID == nil)
    {
        [self generateUUIDforColor:@"0" withOpcode:@"99"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"99"];
    }
    //Music UUID
    NSString * strMusicUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"MusicUUID"];
    if ([strMusicUUID isEqual:[NSNull null]] || [strMusicUUID length]==0 || strMusicUUID == nil)
    {
        [self generateUUIDforColor:@"0" withOpcode:@"72"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"72"];
    }
    //Music UUID
    NSString * strRememberUDID = [[NSUserDefaults standardUserDefaults] valueForKey:@"RememberUDID"];
    if ([strRememberUDID isEqual:[NSNull null]] || [strRememberUDID length]==0 || strRememberUDID == nil)
    {
        [self generateUUIDforColor:@"0" withOpcode:@"71"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"71"];
    }
    //Reset All Default UUID
    NSString * strResetDefaultUDID = [[NSUserDefaults standardUserDefaults] valueForKey:@"ResetAllUDID"];
    if ([strResetDefaultUDID isEqual:[NSNull null]] || [strResetDefaultUDID length]==0 || strResetDefaultUDID == nil)
    {
        [self generateUUIDforColor:@"0" withOpcode:@"155"];
        [self generateUUIDforAdvertising:@"0" withOpcode:@"155"];
    }
    
   

    
//    Identify
}
-(void)generateUUIDforAdvertising:(NSString * )deviceID withOpcode:(NSString *)strOpcode
{
    NSString * strTempOpcode = strOpcode;
    if ([strTempOpcode isEqualToString:@"155"])
    {
        strTempOpcode = @"55";
    }
    NSInteger first = [@"100" integerValue];
    NSData *dTTL = [[NSData alloc] initWithBytes:&first length:1];
    
    NSInteger second = [@"3145" integerValue];
    NSData *dSqnce = [[NSData alloc] initWithBytes:&second length:2];
    
    NSInteger third = [@"5682" integerValue];
    NSData * dDeviceID = [[NSData alloc] initWithBytes:&third length:2];
    
    NSInteger fourth = [@"7697" integerValue];;
    NSData * dDestID = [[NSData alloc] initWithBytes:&fourth length:2];
    
    NSInteger fifth = [@"8744" integerValue];
    NSData * dCRC = [[NSData alloc] initWithBytes:&fifth length:2];
    
    NSInteger sixth = [strTempOpcode integerValue];
    NSData * dSix = [[NSData alloc] initWithBytes:&sixth length:1];
    
    NSInteger seven = [@"00" integerValue];
    NSData * dSeven = [[NSData alloc] initWithBytes:&seven length:1];
    
    NSData * dR = [[NSData alloc] initWithBytes:&seven length:1];
    
    NSData * dG = [[NSData alloc] initWithBytes:&seven length:1];
    
    NSData * dB = [[NSData alloc] initWithBytes:&seven length:1];
    
    NSMutableString *nameString = [[NSMutableString alloc]initWithCapacity:0];
    
    [nameString appendString:[NSString stringWithFormat:@"%@",dTTL.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dSqnce.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dDeviceID.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dDestID.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dCRC.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dSix.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dSeven.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dR.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dG.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dB.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dB.debugDescription]];//14
    [nameString appendString:[NSString stringWithFormat:@"%@",dB.debugDescription]];//15
    
    NSString * strFinal = [NSString stringWithFormat:@"%@",nameString];
    strFinal = [strFinal stringByReplacingOccurrencesOfString:@" " withString:@""];
    strFinal = [strFinal stringByReplacingOccurrencesOfString:@">" withString:@""];
    strFinal = [strFinal stringByReplacingOccurrencesOfString:@"<" withString:@""];
    strFinal = [strFinal uppercaseString];
    
    // Append - for iBacon UUID for Raw Data
    NSMutableString * strRawUUID = [[NSMutableString alloc] initWithString:strFinal];
    [strRawUUID insertString:@"-" atIndex:8];
    [strRawUUID insertString:@"-" atIndex:13];
    [strRawUUID insertString:@"-" atIndex:18];
    [strRawUUID insertString:@"-" atIndex:23];

    if ([strOpcode isEqualToString:@"66"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"colorUUID"];
    }
    else if ([strOpcode isEqualToString:@"70"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"whiteColorUDID"];
    }
    else if ([strOpcode isEqualToString:@"85"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"OnOffUUID"];
    }
    else if ([strOpcode isEqualToString:@"67"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"PatternUUID"];
    }
    else if ([strOpcode isEqualToString:@"55"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"DeleteUUID"];
    }
    else if ([strOpcode isEqualToString:@"112"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"PingUUID"];
    }
    else if ([strOpcode isEqualToString:@"82"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"WhiteUUID"];
    }
    else if ([strOpcode isEqualToString:@"96"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"TimeUUID"];
    }
    else if ([strOpcode isEqualToString:@"8"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"AddGroupUUID"];
    }
    else if ([strOpcode isEqualToString:@"10"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"DeleteGroupUUID"];
    }
    else if ([strOpcode isEqualToString:@"99"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"DeleteAlarmUUID"];
    }
    else if ([strOpcode isEqualToString:@"72"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"MusicUUID"];
    }
    else if ([strOpcode isEqualToString:@"71"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"RememberUDID"];
    }
    else if ([strOpcode isEqualToString:@"155"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"ResetAllUDID"];
    }
    else if ([strOpcode isEqualToString:@"52"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"IdentifyUUID"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)generateUUIDforColor:(NSString *)deviceID withOpcode:(NSString *)strOpcode
{
    NSString * strTempOpcode = strOpcode;
    if ([strTempOpcode isEqualToString:@"155"])
    {
        strTempOpcode = @"55";
    }
    NSInteger first = [@"100" integerValue];
    NSData *dTTL = [[NSData alloc] initWithBytes:&first length:1];
    
    NSInteger second = [@"11" integerValue];
    NSData *dSqnce = [[NSData alloc] initWithBytes:&second length:2];
    
    NSInteger third = [@"9000" integerValue];
    NSData * dDeviceID = [[NSData alloc] initWithBytes:&third length:2];
    
    NSInteger fourth = [deviceID integerValue];;
    NSData * dDestID = [[NSData alloc] initWithBytes:&fourth length:2];
    
    NSInteger fifth = [@"1234" integerValue];
    NSData * dCRC = [[NSData alloc] initWithBytes:&fifth length:2];
    
    NSInteger sixth = [strTempOpcode integerValue];
    NSData * dSix = [[NSData alloc] initWithBytes:&sixth length:1];
    
    NSInteger seven = [@"00" integerValue];
    NSData * dSeven = [[NSData alloc] initWithBytes:&seven length:1];
    
    NSData * dR = [[NSData alloc] initWithBytes:&seven length:1];
    
    NSData * dG = [[NSData alloc] initWithBytes:&seven length:1];
    
    NSData * dB = [[NSData alloc] initWithBytes:&seven length:1];
    
    NSMutableString *nameString = [[NSMutableString alloc]initWithCapacity:0];
    
    [nameString appendString:[NSString stringWithFormat:@"%@",dTTL.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dSqnce.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dDeviceID.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dDestID.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dCRC.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dSix.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dSeven.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dR.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dG.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dB.debugDescription]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dB.debugDescription]];//14
    [nameString appendString:[NSString stringWithFormat:@"%@",dB.debugDescription]];//15
    
    NSString * strFinal = [NSString stringWithFormat:@"%@",nameString];
    strFinal = [strFinal stringByReplacingOccurrencesOfString:@" " withString:@""];
    strFinal = [strFinal stringByReplacingOccurrencesOfString:@">" withString:@""];
    strFinal = [strFinal stringByReplacingOccurrencesOfString:@"<" withString:@""];
    strFinal = [strFinal uppercaseString];
    
    //To Encrypt UUID
    //User Pass Key
    NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"passKey"]];
    if ([strOpcode isEqualToString:@"155"])
    {
        NSString * strKeys = [self sha256HashFor:@"%@~vith"];
        NSRange range73 = NSMakeRange(32,32);
        NSString * str3 = [strKeys substringWithRange:range73];
        strUserKey = [self getStringConvertedinUnsigned:str3];
    }
    NSScanner *scannerKey = [NSScanner scannerWithString: strUserKey];
    unsigned char strrDataKey[16];
    unsigned indexKey = 0;
    while (![scannerKey isAtEnd])
    {unsigned value = 0;
        if (![scannerKey scanHexInt: &value]){break;}
        strrDataKey[indexKey++] = value;}
    // Raw UUID Data
    NSString * strFinalData = [self getStringConvertedinUnsigned:strFinal];
    NSScanner *scanner = [NSScanner scannerWithString: strFinalData];
    unsigned char strrRawData[16];
    unsigned index = 0;
    while (![scanner isAtEnd])
    {unsigned value = 0;
        if (![scanner scanHexInt: &value]){break;}
        strrRawData[index++] = value;}
    // AES Encryption
    unsigned char  tempResultOp[16];
    Header_h AES_ECB(strrRawData, strrDataKey, tempResultOp, 1);
    // AES Encryption Result
    NSString * strEncryptUUID = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",tempResultOp[0],tempResultOp[1],tempResultOp[2],tempResultOp[3],tempResultOp[4],tempResultOp[5],tempResultOp[6],tempResultOp[7],tempResultOp[8],tempResultOp[9],tempResultOp[10],tempResultOp[11],tempResultOp[12],tempResultOp[13],tempResultOp[14],tempResultOp[15]];
    
    // Append - for iBacon UUID for Raw Data
//    NSMutableString * strRawUUID = [[NSMutableString alloc] initWithString:strFinal];
//    [strRawUUID insertString:@"-" atIndex:8];
//    [strRawUUID insertString:@"-" atIndex:13];
//    [strRawUUID insertString:@"-" atIndex:18];
//    [strRawUUID insertString:@"-" atIndex:23];
    
//    NSLog(@"Here is Key=%@ Opcode=%@ and Encrypted ID=%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"passKey"],strOpcode, strEncryptUUID);
    if ([strOpcode isEqualToString:@"66"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strEncryptUUID forKey:@"colorEncryptUUID"];
    }
    else if ([strOpcode isEqualToString:@"70"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strEncryptUUID forKey:@"whiteColorEncryptUDID"];
    }
    else if ([strOpcode isEqualToString:@"85"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strEncryptUUID forKey:@"OnOffEncryptUUID"];
    }
    else if ([strOpcode isEqualToString:@"67"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strEncryptUUID forKey:@"PatternEncryptUUID"];
    }
    else if ([strOpcode isEqualToString:@"55"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strEncryptUUID forKey:@"DeleteEncryptUUID"];
    }
    else if ([strOpcode isEqualToString:@"112"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strEncryptUUID forKey:@"PingEncryptUUID"];
    }
    else if ([strOpcode isEqualToString:@"82"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strEncryptUUID forKey:@"WhiteEncryptUUID"];
    }
    else if ([strOpcode isEqualToString:@"96"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strEncryptUUID forKey:@"TimeEncryptUUID"];
    }
    else if ([strOpcode isEqualToString:@"8"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strEncryptUUID forKey:@"AddGroupEncryptUUID"];
    }
    else if ([strOpcode isEqualToString:@"10"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strEncryptUUID forKey:@"DeleteGroupEncryptUUID"];
    }
    else if ([strOpcode isEqualToString:@"99"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strEncryptUUID forKey:@"DeleteAlarmEncryptUUID"];
    }
    else if ([strOpcode isEqualToString:@"72"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strEncryptUUID forKey:@"MusicEncryptedUUID"];
    }
    else if ([strOpcode isEqualToString:@"71"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strEncryptUUID forKey:@"RememberEncryptUDID"];
    }
    else if ([strOpcode isEqualToString:@"155"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strEncryptUUID forKey:@"ResetAllEncryptUDID"];
    }
    else if ([strOpcode isEqualToString:@"52"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strEncryptUUID forKey:@"IdentifyEncryptUDID"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(NSData *)getIntegerXORedwithValue:(NSString *)strEncrypUUID withMajorInt:(int)IntMajor witnMinorInt:(int)IntMinor
{
    NSMutableData * muteData = [[NSMutableData alloc] init];
    int intMajor = IntMajor;
    int intMinor = IntMinor;
    NSData * majorData = [[NSData alloc] initWithBytes:&intMajor length:2];
    NSData * minorData = [[NSData alloc] initWithBytes:&intMinor length:2];
    [muteData appendData:majorData];
    [muteData appendData:minorData];
    
    unsigned char buffer[muteData.length];
    [muteData getBytes:buffer length:muteData.length];
    
    NSScanner *scannerKey = [NSScanner scannerWithString: strEncrypUUID];
    unsigned char strrDataKey[16];
    unsigned indexKey = 0;
    while (![scannerKey isAtEnd])
    {unsigned value = 0;
        if (![scannerKey scanHexInt: &value]){break;}
        strrDataKey[indexKey++] = value;}
    
    for (int i=0; i<4; i++)
    {
        buffer[i] = buffer[i] ^ strrDataKey[i];
    }
    
    NSUInteger size = 4;
    NSData* completeData = [NSData dataWithBytes:(const void *)buffer length:sizeof(unsigned char)*size];
    
//    NSLog(@"Byte Data iBeacon=%@",completeData);
    return completeData;
}
#pragma mark -----------------------
#pragma mark Method to send signal to Peripheral VIS iBeacon
#pragma mark -----------------------
-(void)sendSignalViaScan:(NSString *)strType withDeviceID:(NSString *)strDeviceID withValue:(NSString *)strValue
{
    NSLog(@"Command Type==%@   Value===%@",strType, strValue);
    
    if ([strType isEqualToString:@"ColorChange"])
    {
        int intMajor = [strDeviceID intValue];
        int intMinor = [self search565];
        
        NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"colorEncryptUUID"]];
        NSData* completeData =  [self getIntegerXORedwithValue:strUserKey withMajorInt:intMajor witnMinorInt:intMinor];

        uint8_t * data = (uint8_t *)completeData.bytes;
        uint16_t c_Major = data[1] + ( data[0]<<8);
        int finalMajor = (int)c_Major;
        
        uint16_t c_Minor = data[3] + ( data[2]<<8);
        int finalMinor = (int)c_Minor;

        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:finalMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:finalMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"colorUUID"]]];
//        //NSLog(@"UUID=%@ Mask=%@  Major==%@   Minor ==%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"colorUUID"],[[NSUserDefaults standardUserDefaults] valueForKey:@"colorEncryptUUID"],[NSNumber numberWithInt:finalMajor],[NSNumber numberWithInt:finalMinor]);
    }
    else if ([strType isEqualToString:@"ColorWhiteChange"])
    {
        int intMajor = [strDeviceID intValue];
        int intMinor = [self search565];
        
        NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"whiteColorEncryptUDID"]];
        NSData* completeData =  [self getIntegerXORedwithValue:strUserKey withMajorInt:intMajor witnMinorInt:intMinor];
        
        uint8_t * data = (uint8_t *)completeData.bytes;
        uint16_t c_Major = data[1] + ( data[0]<<8);
        int finalMajor = (int)c_Major;
        
        uint16_t c_Minor = data[3] + ( data[2]<<8);
        int finalMinor = (int)c_Minor;

        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:finalMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:finalMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"whiteColorUDID"]]];
        //NSLog(@"UUID=%@ Mask=%@  Major==%@   Minor ==%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"colorUUID"],[[NSUserDefaults standardUserDefaults] valueForKey:@"colorEncryptUUID"],[NSNumber numberWithInt:finalMajor],[NSNumber numberWithInt:finalMinor]);
    }
    else if ([strType isEqualToString:@"OnOff"])
    {
        int intMajor = [strDeviceID intValue];
        int intMinor = [strValue  intValue];

        NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"OnOffEncryptUUID"]];
        NSData* completeData =  [self getIntegerXORedwithValue:strUserKey withMajorInt:intMajor witnMinorInt:intMinor];
        
        uint8_t * data = (uint8_t *)completeData.bytes;
        uint16_t c_Major = data[1] + ( data[0]<<8);
        int finalMajor = (int)c_Major;
        
        uint16_t c_Minor = data[3] + ( data[2]<<8);
        int finalMinor = (int)c_Minor;
        
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:finalMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:finalMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"OnOffUUID"]]];
        
        NSLog(@"UUID=%@   Major==%@   Minor ==%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"OnOffUUID"],strDeviceID,strValue);
        
    }
    else if ([strType isEqualToString:@"Pattern"])
    {
        int intMajor = [strDeviceID intValue];
        int intMinor = [strValue  intValue];

        NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"PatternEncryptUUID"]];
        NSData* completeData =  [self getIntegerXORedwithValue:strUserKey withMajorInt:intMajor witnMinorInt:intMinor];
        
        uint8_t * data = (uint8_t *)completeData.bytes;
        uint16_t c_Major = data[1] + ( data[0]<<8);
        int finalMajor = (int)c_Major;
        
        uint16_t c_Minor = data[3] + ( data[2]<<8);
        int finalMinor = (int)c_Minor;
        
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:finalMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:finalMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"PatternUUID"]]];
        //NSLog(@"UUID=%@   Major==%@   Minor ==%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"PatternUUID"],strDeviceID,strValue);
    }
    else if ([strType isEqualToString:@"DeleteUUID"])
    {
        int intMajor = [strDeviceID intValue];
        int intMinor = 0;

        NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"DeleteEncryptUUID"]];
        NSData* completeData =  [self getIntegerXORedwithValue:strUserKey withMajorInt:intMajor witnMinorInt:intMinor];
        
        uint8_t * data = (uint8_t *)completeData.bytes;
        uint16_t c_Major = data[1] + ( data[0]<<8);
        int finalMajor = (int)c_Major;
        
        uint16_t c_Minor = data[3] + ( data[2]<<8);
        int finalMinor = (int)c_Minor;
        
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:finalMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:finalMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"DeleteUUID"]]];
        //NSLog(@"UUID=%@   Major==%@   Minor ==0",[[NSUserDefaults standardUserDefaults] valueForKey:@"DeleteUUID"],strDeviceID);
    }
    else if ([strType isEqualToString:@"Ping"])
    {
        int intMajor = 0;
        int intMinor = 0;

        NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"PingEncryptUUID"]];
        NSData* completeData =  [self getIntegerXORedwithValue:strUserKey withMajorInt:intMajor witnMinorInt:intMinor];
        
        uint8_t * data = (uint8_t *)completeData.bytes;
        uint16_t c_Major = data[1] + ( data[0]<<8);
        int finalMajor = (int)c_Major;
        
        uint16_t c_Minor = data[3] + ( data[2]<<8);
        int finalMinor = (int)c_Minor;
        
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:finalMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:finalMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"PingUUID"]]];
        //NSLog(@"UUID=%@   Major==%@   Minor ==0",[[NSUserDefaults standardUserDefaults] valueForKey:@"PingUUID"],strDeviceID);
    }
    else if ([strType isEqualToString:@"White"])
    {
        int intMajor = [strDeviceID intValue];
        int intMinor = [strValue  intValue];

        NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"WhiteEncryptUUID"]];
        NSData* completeData =  [self getIntegerXORedwithValue:strUserKey withMajorInt:intMajor witnMinorInt:intMinor];
        
        uint8_t * data = (uint8_t *)completeData.bytes;
        uint16_t c_Major = data[1] + ( data[0]<<8);
        int finalMajor = (int)c_Major;
        
        uint16_t c_Minor = data[3] + ( data[2]<<8);
        int finalMinor = (int)c_Minor;
        
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:finalMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:finalMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"WhiteUUID"]]];
        //NSLog(@"UUID=%@   Major==%@   Minor ==%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"WhiteUUID"],strDeviceID,strValue);
    }
    else if ([strType isEqualToString:@"TimeSet"])
    {
        int intMajor = 0;
        int intMinor = [self GetConvertedTime];

        NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"TimeEncryptUUID"]];
        NSData* completeData =  [self getIntegerXORedwithValue:strUserKey withMajorInt:intMajor witnMinorInt:intMinor];
        
        uint8_t * data = (uint8_t *)completeData.bytes;
        uint16_t c_Major = data[1] + ( data[0]<<8);
        int finalMajor = (int)c_Major;
        
        uint16_t c_Minor = data[3] + ( data[2]<<8);
        int finalMinor = (int)c_Minor;
        
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:finalMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:finalMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"TimeUUID"]]];
        //NSLog(@"UUID=%@   Major==%@   Minor ==%d",[[NSUserDefaults standardUserDefaults] valueForKey:@"TimeUUID"],strDeviceID,[self GetConvertedTime]);
    }
    else if ([strType isEqualToString:@"AddGroupUUID"])
    {
        int intMajor = [strDeviceID intValue];
        int intMinor = [strValue intValue];
        
        NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"AddGroupEncryptUUID"]];
        NSData* completeData =  [self getIntegerXORedwithValue:strUserKey withMajorInt:intMajor witnMinorInt:intMinor];
        
        uint8_t * data = (uint8_t *)completeData.bytes;
        uint16_t c_Major = data[1] + ( data[0]<<8);
        int finalMajor = (int)c_Major;
        
        uint16_t c_Minor = data[3] + ( data[2]<<8);
        int finalMinor = (int)c_Minor;
        
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:finalMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:finalMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"AddGroupUUID"]]];
        //NSLog(@"UUID=%@   Major==%@   Minor ==%d",[[NSUserDefaults standardUserDefaults] valueForKey:@"AddGroupUUID"],strDeviceID,[self GetConvertedTime]);
    }
    else if ([strType isEqualToString:@"DeleteGroupUUID"])
    {
        int intMajor = [strDeviceID intValue];
        int intMinor = [strValue intValue];

        NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"DeleteGroupEncryptUUID"]];
        NSData* completeData =  [self getIntegerXORedwithValue:strUserKey withMajorInt:intMajor witnMinorInt:intMinor];
        
        uint8_t * data = (uint8_t *)completeData.bytes;
        uint16_t c_Major = data[1] + ( data[0]<<8);
        int finalMajor = (int)c_Major;
        
        uint16_t c_Minor = data[3] + ( data[2]<<8);
        int finalMinor = (int)c_Minor;
        
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:finalMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:finalMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"DeleteGroupUUID"]]];
        //NSLog(@"UUID=%@   Major==%@   Minor ==%d",[[NSUserDefaults standardUserDefaults] valueForKey:@"DeleteGroupUUID"],strDeviceID,[self GetConvertedTime]);
    }
    else if ([strType isEqualToString:@"DeleteAlarmUUID"])
    {
        int intMajor = [strDeviceID intValue];
        int intMinor = [strValue intValue];

        NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"DeleteAlarmEncryptUUID"]];
        NSData* completeData =  [self getIntegerXORedwithValue:strUserKey withMajorInt:intMajor witnMinorInt:intMinor];
        
        uint8_t * data = (uint8_t *)completeData.bytes;
        uint16_t c_Major = data[1] + ( data[0]<<8);
        int finalMajor = (int)c_Major;
        
        uint16_t c_Minor = data[3] + ( data[2]<<8);
        int finalMinor = (int)c_Minor;
        
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:finalMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:finalMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"DeleteAlarmUUID"]]];
        //NSLog(@"UUID=%@   Major==%@   Minor ==%d",[[NSUserDefaults standardUserDefaults] valueForKey:@"DeleteAlarmUUID"],strDeviceID,[self GetConvertedTime]);
    }
    else if ([strType isEqualToString:@"MusicUUID"])
    {
        int intMajor = [strDeviceID intValue];
        int intMinor = [strValue intValue];
        
        NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"MusicEncryptedUUID"]];
        NSData* completeData =  [self getIntegerXORedwithValue:strUserKey withMajorInt:intMajor witnMinorInt:intMinor];
        
        uint8_t * data = (uint8_t *)completeData.bytes;
        uint16_t c_Major = data[1] + ( data[0]<<8);
        int finalMajor = (int)c_Major;
        
        uint16_t c_Minor = data[3] + ( data[2]<<8);
        int finalMinor = (int)c_Minor;
        
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:finalMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:finalMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"MusicUUID"]]];
        //NSLog(@"UUID=%@   Major==%@   Minor ==%d",[[NSUserDefaults standardUserDefaults] valueForKey:@"MusicUUID"],strDeviceID,[self GetConvertedTime]);
    }
    else if ([strType isEqualToString:@"RememberUDID"])
    {
        int intMajor = [strDeviceID intValue];
        int intMinor = [strValue intValue];
        
        NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"RememberEncryptUDID"]];
        NSData* completeData =  [self getIntegerXORedwithValue:strUserKey withMajorInt:intMajor witnMinorInt:intMinor];
        
        uint8_t * data = (uint8_t *)completeData.bytes;
        uint16_t c_Major = data[1] + ( data[0]<<8);
        int finalMajor = (int)c_Major;
        
        uint16_t c_Minor = data[3] + ( data[2]<<8);
        int finalMinor = (int)c_Minor;
        
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:finalMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:finalMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"RememberUDID"]]];
//        //NSLog(@"UUID=%@   Major==%@   Minor ==%d",[[NSUserDefaults standardUserDefaults] valueForKey:@"RememberUDID"],strDeviceID,[self GetConvertedTime]);
    }
    else if ([strType isEqualToString:@"ResetAllUDID"])
    {
        int intMajor = [strDeviceID intValue];
        int intMinor = [strValue intValue];
        
        NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"ResetAllEncryptUDID"]];
        NSData* completeData =  [self getIntegerXORedwithValue:strUserKey withMajorInt:intMajor witnMinorInt:intMinor];
        
        uint8_t * data = (uint8_t *)completeData.bytes;
        uint16_t c_Major = data[1] + ( data[0]<<8);
        int finalMajor = (int)c_Major;
        
        uint16_t c_Minor = data[3] + ( data[2]<<8);
        int finalMinor = (int)c_Minor;
        
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:finalMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:finalMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"ResetAllUDID"]]];
    }
    else if ([strType isEqualToString:@"IdentifyUUID"])
    {
        int intMajor = [strDeviceID intValue];
        int intMinor = 0;
        
        NSString * strUserKey = [self getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"IdentifyEncryptUDID"]];
        NSData* completeData =  [self getIntegerXORedwithValue:strUserKey withMajorInt:intMajor witnMinorInt:intMinor];
        
        uint8_t * data = (uint8_t *)completeData.bytes;
        uint16_t c_Major = data[1] + ( data[0]<<8);
        int finalMajor = (int)c_Major;
        
        uint16_t c_Minor = data[3] + ( data[2]<<8);
        int finalMinor = (int)c_Minor;
        
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:finalMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:finalMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"IdentifyUUID"]]];
        //NSLog(@"UUID=%@   Major==%@   Minor ==0",[[NSUserDefaults standardUserDefaults] valueForKey:@"IdentifyUUID"],strDeviceID);

    }
    
    
    [[SetBeaconManager sharedManager] updateAdvertisedRegion];
}
-(int)search565
{
    //    static uint16 EncodeRGB2ByteFormat(uint8 red, uint8 green, uint8 blue)
    {
        int rgb_value=0, temp_green=0;
        short red = fullRed, green = fullGreen, blue = fullBlue;
        
        /* Remove the last 3 bits of red color */
        red >>= 3;
        
        /* Remove the last 2 bits of green color */
        green >>= 2;
        temp_green = green;
        temp_green <<= 5;
        
        /* Remove the last 3 bits of blue color */
        blue >>= 3;
        
        /* Add red and shift to the right position */
        rgb_value = red;
        rgb_value <<= 11;
        
        /* Add green to the value  */
        rgb_value |= temp_green;
        
        /* Add blue value */
        rgb_value |= blue;
        
//        NSLog(@"RGB=%d",rgb_value);
        return rgb_value;
    }
}

#pragma mark -----------------------
#pragma mark Encryption Methods
#pragma mark Generate Pass Key Methods

-(NSString *)getStringConvertedinUnsigned:(NSString *)strNormal
{
    NSString * strKey = strNormal;
    long ketLength = [strKey length]/2;
    NSString * strVal;
    for (int i=0; i<ketLength; i++)
    {
        NSRange range73 = NSMakeRange(i*2, 2);
        NSString * str3 = [strKey substringWithRange:range73];
        if ([strVal length]==0)
        {
            strVal = [NSString stringWithFormat:@" 0x%@",str3];
        }
        else
        {
            strVal = [strVal stringByAppendingString:[NSString stringWithFormat:@" 0x%@",str3]];
        }
    }
    return strVal;
}
-(void)GenerateEncryptedKeyforLogin:(NSString *)strPassword
{
    strPassword = [NSString stringWithFormat:@"%@~vith",strPassword];
    NSString * strKeys = [self sha256HashFor:strPassword];
    NSRange range73 = NSMakeRange(32,32);
    NSString * str3 = [strKeys substringWithRange:range73];
    [[NSUserDefaults standardUserDefaults] setObject:str3 forKey:@"passKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSLog(@"UserPassKey=%@",str3);
}
-(NSString*)sha256HashFor:(NSString*)input
{
    const char* str = [input UTF8String];
//    const char *str = [input cStringUsingEncoding:NSASCIIStringEncoding];

    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

#pragma mark - For Decrypting Data

-(NSData *)GetDecrypedDataKeyforData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength
{
    //RAW Data of 20 bytes
    NSScanner *scanner = [NSScanner scannerWithString: strData];
    unsigned char strrRawData[20];
    unsigned index = 0;
    while (![scanner isAtEnd])
    {
        unsigned value = 0;
        if (![scanner scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrRawData[index++] = value;
    }
    
    //Password encrypted Key 16 bytes
    NSScanner *scannerKey = [NSScanner scannerWithString: strKey];
    unsigned char strrDataKey[16];
    unsigned indexKey = 0;
    while (![scannerKey isAtEnd])
    {
        unsigned value = 0;
        if (![scannerKey scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrDataKey[indexKey++] = value;
    }
    
    unsigned char  strSentData[] = {0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    
    strSentData[1] = strSentData[1] ^ strrRawData[1];
    strSentData[2] = strSentData[2] ^ strrRawData[2];
    strSentData[3] = strSentData[3] ^ strrRawData[3];
    strSentData[4] = strSentData[4] ^ strrRawData[4];

    unsigned char  tempResultOp[16];
    Header_h AES_ECB(strSentData, strrDataKey, tempResultOp, 1);
    
    for (int i=0; i<15; i++)
    {
        strrRawData[i+5] = strrRawData[i+5] ^ tempResultOp[i];
    }

    NSUInteger size = dataLength;
    NSData* data = [NSData dataWithBytes:(const void *)strrRawData length:sizeof(unsigned char)*size];

    NSString * stringData = [NSString stringWithFormat:@"%@",data.debugDescription];
    stringData = [stringData stringByReplacingOccurrencesOfString:@" " withString:@""];
    stringData = [stringData stringByReplacingOccurrencesOfString:@">" withString:@""];
    stringData = [stringData stringByReplacingOccurrencesOfString:@"<" withString:@""];

    stringData = [stringData substringWithRange:NSMakeRange(2,[stringData length]-2)];
    if ([stringData length]>19)
    {
        NSString * kpstr = [stringData substringWithRange:NSMakeRange(12,4)];
        stringData = [stringData stringByReplacingOccurrencesOfString:kpstr withString:@"0000"];
        NSData * calcData = [self getStringConvertedintoData:stringData];
        NSString * localCheckSum = [NSString stringWithFormat:@"%@",[self GetCountedCheckSumData:calcData].debugDescription];
        localCheckSum = [localCheckSum stringByReplacingOccurrencesOfString:@" " withString:@""];
        localCheckSum = [localCheckSum stringByReplacingOccurrencesOfString:@">" withString:@""];
        localCheckSum = [localCheckSum stringByReplacingOccurrencesOfString:@"<" withString:@""];

//        NSLog(@"Decrypted Data%@",data);

        if ([localCheckSum isEqualToString:kpstr])
        {
        }
        else
        {
            data = [[NSData alloc] init];
        }
    }
    return data;
}
#pragma mark - For Encrypting Data
-(NSData *)GetEncryptedKeyforData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength
{
    NSString * strFinal;
    //RAW Data of 20 bytes
    NSScanner *scanner = [NSScanner scannerWithString: strData];
    unsigned char strrRawData[20];
    unsigned index = 0;
    while (![scanner isAtEnd])
    {
        unsigned value = 0;
        if (![scanner scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrRawData[index++] = value;
    }
    
    //Password encrypted Key 16 bytes
    NSScanner *scannerKey = [NSScanner scannerWithString: strKey];
    unsigned char strrDataKey[16];
    unsigned indexKey = 0;
    while (![scannerKey isAtEnd])
    {
        unsigned value = 0;
        if (![scannerKey scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrDataKey[indexKey++] = value;
    }
    
    unsigned char  strSentData[] = {0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    strSentData[1] = strSentData[1] ^ strrRawData[1];
    strSentData[2] = strSentData[2] ^ strrRawData[2];
    strSentData[3] = strSentData[3] ^ strrRawData[3];
    strSentData[4] = strSentData[4] ^ strrRawData[4];

    unsigned char  tempResultOp[16];
    Header_h AES_ECB(strSentData, strrDataKey, tempResultOp, 1);
    
//    NSLog(@"Encryptioj MASK Result=%@",[NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",tempResultOp[0],tempResultOp[1],tempResultOp[2],tempResultOp[3],tempResultOp[4],tempResultOp[5],tempResultOp[6],tempResultOp[7],tempResultOp[8],tempResultOp[9],tempResultOp[10],tempResultOp[11],tempResultOp[12],tempResultOp[13],tempResultOp[14],tempResultOp[15],tempResultOp[16]]);

    for (int i=0; i<15; i++)
    {
        strrRawData[i+5] = strrRawData[i+5] ^ tempResultOp[i];
    }
    strFinal = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",strrRawData[0],strrRawData[1],strrRawData[2],strrRawData[3],strrRawData[4],strrRawData[5],strrRawData[6],strrRawData[7],strrRawData[8],strrRawData[9],strrRawData[10],strrRawData[11],strrRawData[12],strrRawData[13],strrRawData[14],strrRawData[15],strrRawData[16],strrRawData[17],strrRawData[18],strrRawData[19]];
//    NSLog(@"Encrypted Result=%@",[NSString stringWithFormat:@"%@",strFinal]);
    NSUInteger size = dataLength;
    NSData* data = [NSData dataWithBytes:(const void *)strrRawData length:sizeof(unsigned char)*size];
  return data;
}
#pragma mark - For Associating FIRST part of Key
-(NSData *)SendAssociationRequestFirst:(NSString *)strData withKey:(NSString *)strUserKey withBLEAddress:(NSString*)strBleAddress withRawDataLength:(long)dataLength
{
    tmpCount = tmpCount + 1;
    
    //RAW Data of 20 bytes
    NSScanner *scanner = [NSScanner scannerWithString: strData];
    unsigned char strrRawData[20];
    unsigned index = 0;
    while (![scanner isAtEnd])
    {
        unsigned value = 0;
        if (![scanner scanHexInt: &value])
        {
            break;
        }
        strrRawData[index++] = value;
    }
    
    unsigned char  VDKKey[] = {0x3A, 0x09,0x44, 0x62, 0xFD, 0x62, 0x10, 0xCD,0xE8, 0x74,0x42, 0xCA, 0xA9, 0xD7, 0x18, 0xF9};
    
    //Get BLE ADDRESS
    //UserPass Password encrypted Key 16 bytes
    NSScanner *scannBLE = [NSScanner scannerWithString: strBleAddress];
    unsigned char strrBLE[16];
    unsigned indexBLE = 0;
    while (![scannBLE isAtEnd])
    {
        unsigned value = 0;
        if (![scannBLE scanHexInt: &value])
        {
            break;
        }
        strrBLE[indexBLE++] = value;
    }


    unsigned char  strSentData[] = {0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    
    strSentData[1] = strSentData[1] ^ strrRawData[1];
    strSentData[2] = strSentData[2] ^ strrRawData[2];
    strSentData[3] = strSentData[3] ^ strrRawData[3];
    strSentData[4] = strSentData[4] ^ strrRawData[4];
    strSentData[9] = strSentData[9] ^ strrBLE[0];
    strSentData[10] = strSentData[10] ^ strrBLE[1];
    strSentData[11] = strSentData[11] ^ strrBLE[2];
    strSentData[12] = strSentData[12] ^ strrBLE[3];
    strSentData[13] = strSentData[13] ^ strrBLE[4];
    strSentData[14] = strSentData[14] ^ strrBLE[5];

    unsigned char  tempResultOp[16];
    Header_h AES_ECB(strSentData, VDKKey, tempResultOp, 1);
    
    for (int i=0; i<15; i++)
    {
        strrRawData[i+5] = strrRawData[i+5] ^ tempResultOp[i];
    }
    
    NSUInteger size = dataLength;
    NSData* data = [NSData dataWithBytes:(const void *)strrRawData length:sizeof(unsigned char)*size];
//    NSLog(@"Encrypted Result=%@",[NSString stringWithFormat:@"%@",data]);
    return data;
}
#pragma mark - For Associating SECOND part of Key

-(NSData *)SendAssociationRequestSecond:(NSString *)strData withKey:(NSString *)strUserKey withBLEAddress:(NSString*)strBleAddress withDataLength:(long)dataLength
{
    NSString * strFinal;
    
    //RAW Data of 20 bytes
    NSScanner *scanner = [NSScanner scannerWithString: strData];
    unsigned char strrRawData[20];
    unsigned index = 0;
    while (![scanner isAtEnd])
    {
        unsigned value = 0;
        if (![scanner scanHexInt: &value])
        {
            break;
        }
        strrRawData[index++] = value;
    }
    
    unsigned char  VDKKey[] = {0x3A, 0x09,0x44, 0x62, 0xFD, 0x62, 0x10, 0xCD,0xE8, 0x74,0x42, 0xCA, 0xA9, 0xD7, 0x18, 0xF9};
    //UserPass Password encrypted Key 16 bytes
    NSScanner *scannerKey = [NSScanner scannerWithString: strUserKey];
    unsigned char strrDataKey[16];
    unsigned indexKey = 0;
    while (![scannerKey isAtEnd])
    {
        unsigned value = 0;
        if (![scannerKey scanHexInt: &value])
        {
            break;
        }
        strrDataKey[indexKey++] = value;
    }
    
    //Get BLE ADDRESS
    //UserPass Password encrypted Key 16 bytes
    NSScanner *scannBLE = [NSScanner scannerWithString: strBleAddress];
    unsigned char strrBLE[16];
    unsigned indexBLE = 0;
    while (![scannBLE isAtEnd])
    {
        unsigned value = 0;
        if (![scannBLE scanHexInt: &value])
        {
            break;
        }
        strrBLE[indexBLE++] = value;
    }
    
    unsigned char  strSentData[] = {0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    
    strSentData[1] = strSentData[1] ^ strrRawData[1];
    strSentData[2] = strSentData[2] ^ strrRawData[2];
    strSentData[3] = strSentData[3] ^ strrRawData[3];
    strSentData[4] = strSentData[4] ^ strrRawData[4];
    strSentData[9] = strSentData[9] ^ strrBLE[0];
    strSentData[10] = strSentData[10] ^ strrBLE[1];
    strSentData[11] = strSentData[11] ^ strrBLE[2];
    strSentData[12] = strSentData[12] ^ strrBLE[3];
    strSentData[13] = strSentData[13] ^ strrBLE[4];
    strSentData[14] = strSentData[14] ^ strrBLE[5];
    
    
    unsigned char  tempResultOp[16];
    Header_h AES_ECB(strSentData, VDKKey, tempResultOp, 1);
    
    
    
    for (int i=0; i<15; i++)
    {
        strrRawData[i+5] = strrRawData[i+5] ^ tempResultOp[i];
    }
    strFinal = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",strrRawData[0],strrRawData[1],strrRawData[2],strrRawData[3],strrRawData[4],strrRawData[5],strrRawData[6],strrRawData[7],strrRawData[8],strrRawData[9],strrRawData[10],strrRawData[11],strrRawData[12],strrRawData[13],strrRawData[14],strrRawData[15],strrRawData[16],strrRawData[17],strrRawData[18],strrRawData[19]];
//    NSLog(@"Encrypted Result=%@",[NSString stringWithFormat:@"%@",strFinal]);
    
    NSUInteger size = dataLength;
    NSData* data = [NSData dataWithBytes:(const void *)strrRawData length:sizeof(unsigned char)*size];
    return data;
}
#pragma mark - Checksum Generation Methods

-(void)GetCheckSumforString:(NSString *)strNormal
{
    //RAW Data of 20 bytes
    NSScanner *scanner = [NSScanner scannerWithString: strNormal];
    unsigned char strrRawData[16];
    unsigned index = 0;
    while (![scanner isAtEnd])
    {
        unsigned value = 0;
        if (![scanner scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrRawData[index++] = value;
    }
    unsigned char  finalCheksum[16];
    for (int i=0; i<16; i++)
    {
        if (i==15)
        {
            
        }
        else
        {
            finalCheksum[i] = finalCheksum[i] ^ strrRawData[i+1];
        }
    }

//        NSLog(@"Combined Result=%@",[NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",finalCheksum[0],finalCheksum[1],finalCheksum[2],finalCheksum[3],finalCheksum[4],finalCheksum[5],finalCheksum[6],finalCheksum[7],finalCheksum[8],finalCheksum[9],finalCheksum[10],finalCheksum[11],finalCheksum[12],finalCheksum[13],finalCheksum[14],finalCheksum[15],finalCheksum[16],finalCheksum[17],finalCheksum[18],finalCheksum[19]]);

}
/*-(NSData *)GetCountedCheckSumData:(NSData *)chekdData;
{
    NSUInteger len = [chekdData length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [chekdData bytes], len);
    
    int16 checksum = '\0';
    for (int i = 0; i < len; i++)
    {
        checksum += byteData[i];
    }
    NSData * checkSumData = [[NSData alloc] initWithBytes:&checksum length:2];
    return checkSumData;
}*/

-(NSData *)GetCountedCheckSumData:(NSData *)chekdData;
{
    unsigned char buffer[chekdData.length];
    [chekdData getBytes:buffer length:chekdData.length];
    
    unsigned int yResult =  crc16(buffer, chekdData.length);
//    NSLog(@"Hex value of char is 0x%02x", (unsigned int) yResult);
    NSData * data1 = [[NSData alloc] initWithBytes:&yResult length:2];
//    NSLog(@"Final result=%@",data1);
    return data1;
}
-(NSData *)getStringConvertedintoData:(NSString *)strNormal;
{
    NSMutableData * keyData = [[NSMutableData alloc] init];
    
    NSInteger stringLenth = [strNormal length]/2;
    for (int i=0; i<stringLenth; i++)
    {
        NSRange rangeFirst = NSMakeRange(i*2, 2);
        NSString * strVithCheck = [strNormal substringWithRange:rangeFirst];
        
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
-(int)GetConvertedTime
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger intDay = [self getDayInteger];
    
    //    static uint16 EncodeRGB2ByteFormat(uint8 red, uint8 green, uint8 blue)
    {
        //        int rgb_value=0, temp_green=0;
        short cur_time = intDay, temp_hour = hour, minss = minute;
        
        /* Remove the last 3 bits of red color */
        cur_time <<= 13;
        temp_hour <<= 8;
        cur_time |= temp_hour;
        cur_time |= minute;
//        NSLog(@"RGB=%d",cur_time);
        return cur_time;
    }
}

#pragma mark - BLE Central Manager Methods

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
    NSDictionary *dict = [notification userInfo];
    NSString * checkStr = [NSString stringWithFormat:@"%@",[dict valueForKey:@"kCBAdvDataLocalName"]];
    
    if ([checkStr rangeOfString:@"Vithamas"].location == NSNotFound)
    {
    }
    else
    {
        CBPeripheral *CBP = [notification object];
        if ([[BLEManager sharedManager] foundDevices]>0)
        {
            [self hideScannerView];
        }
        if ([dict valueForKey:@"kCBAdvDataManufacturerData"])
        {
            if (globalPeripheral)
            {
                if (globalPeripheral.state == CBPeripheralStateConnected)
                {
                }
                else
                {
//                    globalPeripheral =CBP;
                    //                    [[BLEManager sharedManager] connectDevice:CBP];
                    //                    NSLog(@"This is connected device====>%@",dict);
                }
            }
            else
            {
//                globalPeripheral =CBP;
                //                [[BLEManager sharedManager] connectDevice:CBP];
                //                NSLog(@"This is connected device====>%@",dict);
            }
        }
    }
}
-(void)DeviceDidConnectNotification:(NSNotification*)notification//Connect periperal
{
    [self hideScannerView];
    CBPeripheral * newPeripheral = (CBPeripheral*) notification.object;
    if (newPeripheral)
    {
//        globalPeripheral = newPeripheral;
    }
    //    [[BLEService sharedInstance] sendNotifications:globalPeripheral withType:NO];
    
    if ([currentScreen isEqualToString:@"AddDevice"])
    {
    }
    else
    {
        [[BLEManager sharedManager] centralmanagerScanStop];
    }
}

-(void)DeviceDidDisConnectNotification:(NSNotification*)notification//Disconnect periperal
{
//    NSLog(@"Device disconnected");
}

- (BOOL)detectBluetooth
{
    
//    if (!bluetoothManager)
//    {
//        NSLog(@"Here its Initialzed once");
//        bluetoothManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
//        bluetoothManager.delegate = self;
//    }
//    else
//    {
//        bluetoothManager.delegate = self;
//    }
//    
//    if (bluetoothManager.state != 5)
//    {
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"GlobalBLuetoothCheck" object:nil];
//
//    }
    return YES; // Show initial state
}
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
    if (peripheralManager.state != CBPeripheralManagerStatePoweredOn)
    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"GlobalBLuetoothCheck" object:nil];

    }
}

-(NSInteger)getDayInteger
{
    NSInteger dayInt = 1;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *dayName = [dateFormatter stringFromDate:[NSDate date]];
    
    if ([dayName isEqualToString:@"Sunday"])
    {
        dayInt= 1;
    }
    else if ([dayName isEqualToString:@"Monday"])
    {
        dayInt =2;
    }
    else if ([dayName isEqualToString:@"Tuesday"])
    {
        dayInt=3;
    }
    else if ([dayName isEqualToString:@"wednesday"])
    {
        dayInt=4;
    }
    else if ([dayName isEqualToString:@"Thursday"])
    {
        dayInt=5;
    }
    else if ([dayName isEqualToString:@"Friday"])
    {
        dayInt =6;
    }
    else if ([dayName isEqualToString:@"Saturday"])
    {
        dayInt=7;
    }
    else
    {
        dayInt=7;
    }
    return dayInt;
}

- (NSDictionary *)getCountryCodeDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
            @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
            @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
            @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
            @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
            @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
            @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
            @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
            @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
            @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
            @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
            @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
            @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
            @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
            @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
            @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
            @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
            @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
            @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
            @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
            @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
            @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
            @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
            @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
            @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
            @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
            @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
            @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
            @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
            @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
            @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
            @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
            @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
            @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
            @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
            @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
            @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
            @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
            @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
            @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
            @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
            @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
            @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
            @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
            @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
            @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
            @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
            @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
            @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
            @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
            @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
            @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
            @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
            @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
            @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
            @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
            @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
            @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
            @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
            @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
            @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
}
-(void)updateRSSItimer
{
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
-(NSString*)stringFroHex:(NSString *)hexStr
{
    unsigned long long startlong;
    NSScanner* scanner1 = [NSScanner scannerWithString:hexStr];
    [scanner1 scanHexLongLong:&startlong];
    double unixStart = startlong;
    NSNumber * startNumber = [[NSNumber alloc] initWithDouble:unixStart];
    return [startNumber stringValue];
}//9686614101

-(void)getPlaceholderText:(UITextField *)txtField  andColor:(UIColor*)color
{
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
          UILabel *placeholderLabel = object_getIvar(txtField, ivar);
          placeholderLabel.textColor = color;
}


#pragma mark - SOCKET DECRYPTION METHOD
-(NSData *)GetSocketManufactureDataDecrypted:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength
{
    //RAW Data of 20 bytes
    NSScanner *scanner = [NSScanner scannerWithString: strData];
    unsigned char strrRawData[20];
    unsigned index = 0;
    while (![scanner isAtEnd])
    {
        unsigned value = 0;
        if (![scanner scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrRawData[index++] = value;
    }
    
    //Password encrypted Key 16 bytes
    NSScanner *scannerKey = [NSScanner scannerWithString: strKey];
    unsigned char strrDataKey[16];
    unsigned indexKey = 0;
    while (![scannerKey isAtEnd])
    {
        unsigned value = 0;
        if (![scannerKey scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrDataKey[indexKey++] = value;
    }
    
    unsigned char  strSentData[] = {0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    
    strSentData[1] = strSentData[1] ^ strrRawData[1];
    strSentData[2] = strSentData[2] ^ strrRawData[2];
    strSentData[3] = strSentData[3] ^ strrRawData[3];
    strSentData[4] = strSentData[4] ^ strrRawData[4];

    unsigned char  tempResultOp[16];
    Header_h AES_ECB(strSentData, strrDataKey, tempResultOp, 1);
    
//       NSLog(@"Encryption MASK Result=%@",[NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",tempResultOp[0],tempResultOp[1],tempResultOp[2],tempResultOp[3],tempResultOp[4],tempResultOp[5],tempResultOp[6],tempResultOp[7],tempResultOp[8],tempResultOp[9],tempResultOp[10],tempResultOp[11],tempResultOp[12],tempResultOp[13],tempResultOp[14],tempResultOp[15]]);

    
    for (int i=0; i<15; i++)
    {
        strrRawData[i+5] = strrRawData[i+5] ^ tempResultOp[i];
    }

    NSUInteger size = dataLength;
    NSData* data = [NSData dataWithBytes:(const void *)strrRawData length:sizeof(unsigned char)*size];

    NSString * stringData = [NSString stringWithFormat:@"%@",data.debugDescription];
    stringData = [stringData stringByReplacingOccurrencesOfString:@" " withString:@""];
    stringData = [stringData stringByReplacingOccurrencesOfString:@">" withString:@""];
    stringData = [stringData stringByReplacingOccurrencesOfString:@"<" withString:@""];

    stringData = [stringData substringWithRange:NSMakeRange(2,[stringData length]-2)];
    if ([stringData length]>19)
    {
        NSString * kpstr = [stringData substringWithRange:NSMakeRange(12,4)];
        stringData = [stringData stringByReplacingOccurrencesOfString:kpstr withString:@"0000"];
        NSData * calcData = [self getStringConvertedintoData:stringData];
        NSString * localCheckSum = [NSString stringWithFormat:@"%@",[self GetCountedCheckSumData:calcData].debugDescription];
        localCheckSum = [localCheckSum stringByReplacingOccurrencesOfString:@" " withString:@""];
        localCheckSum = [localCheckSum stringByReplacingOccurrencesOfString:@">" withString:@""];
        localCheckSum = [localCheckSum stringByReplacingOccurrencesOfString:@"<" withString:@""];
    }
    return data;
}

-(NSData *)GetSocketEncryptedKeyforData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength
{
    //RAW Data of 20 bytes
    NSScanner *scanner = [NSScanner scannerWithString: strData];
    unsigned char strrRawData[16];
    unsigned index = 0;
    while (![scanner isAtEnd])
    {
        unsigned value = 0;
        if (![scanner scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrRawData[index++] = value;
    }
    
    //Password encrypted Key 16 bytes
    NSScanner *scannerKey = [NSScanner scannerWithString: strKey];
    unsigned char strrDataKey[16];
    unsigned indexKey = 0;
    while (![scannerKey isAtEnd])
    {
        unsigned value = 0;
        if (![scannerKey scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrDataKey[indexKey++] = value;
    }
    
    unsigned char  tempResultOp[16];
    Header_h AES_ECB(strrRawData, strrDataKey, tempResultOp, 1);
    
    NSUInteger size = 16;
    NSData* data = [NSData dataWithBytes:(const void *)tempResultOp length:sizeof(unsigned char)*size];
  return data;
}
#pragma mark - For Decrypting Data
-(NSString *)GetSocketDecrypedData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength
{
    //RAW Data of 20 bytes
    NSScanner *scanner = [NSScanner scannerWithString: strData];
    unsigned char strrRawData[16];
    unsigned index = 0;
    while (![scanner isAtEnd])
    {
        unsigned value = 0;
        if (![scanner scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrRawData[index++] = value;
    }

    //Password encrypted Key 16 bytes
    NSScanner *scannerKey = [NSScanner scannerWithString: strKey];
    unsigned char strrDataKey[16];
    unsigned indexKey = 0;
    while (![scannerKey isAtEnd])
    {
        unsigned value = 0;
        if (![scannerKey scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrDataKey[indexKey++] = value;
    }

    unsigned char  strSentData[] = {0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

    strSentData[1] = strSentData[1] ^ strrRawData[1];
    strSentData[2] = strSentData[2] ^ strrRawData[2];
    strSentData[3] = strSentData[3] ^ strrRawData[3];
    strSentData[4] = strSentData[4] ^ strrRawData[4];

    unsigned char  tempResultOp[16];
    Header_h AES_ECB(strrRawData, strrDataKey, tempResultOp, 0);

    NSString * strRawResult = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",tempResultOp[0],tempResultOp[1],tempResultOp[2],tempResultOp[3],tempResultOp[4],tempResultOp[5],tempResultOp[6],tempResultOp[7],tempResultOp[8],tempResultOp[9],tempResultOp[10],tempResultOp[11],tempResultOp[12],tempResultOp[13],tempResultOp[14],tempResultOp[15]];
//    NSLog(@"Rawwww Result=%@",strRawResult);
    return strRawResult;
}

-(void)CheckHash256
{
//    NSString * strData = @"39551712138898479008492112d41129";
    NSString * strData = @"39551712138898479008492112d411290310000103036a0c00012001959529298701070007005500000000000cfffffffffeeaaaaaaaaa65555555554400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c3592e2d923ae4cf92129e27f60a1267e3b13e4992b97e2f9282e641a2f18ccd83a164d994eaf249f341b2359399ba3f9a78a7a26384200232a8729725299599869a666000000ac40a9b4960049510b71b105add309720c16e4050b23022e940937480e5c93b27d6b07fad41b2c0c0e10121b460950da0b4c0caeaa1cad1867bb38e7a31c6181ce08590fb3d834abfc51ac28830057e0067665b84d050e16091d6103354302db7a03311a072b570d5ba6ab1505370c0218a2032068027dc8062c47ae52200ca364a0b30c0c1707186303433b017026b2d845053981087cc10a1d0e16500d36c80ab43805d871034e71b331660461c805b708390b01752f039956b0396d0068d3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a6024F3F4";
    
    NSString * strKeys = [self sha256HashFor:strData];
    NSLog(@"====================Before===========%@",strKeys);
    NSRange range73 = NSMakeRange(32,32);
    NSString * str3 = [strKeys substringWithRange:range73];
    NSLog(@"====================After last 32===========%@",str3);

//    NSString * str = strData;
    NSMutableString * newString = [[NSMutableString alloc] init];
    int i = 0;
    while (i < [str3 length]){
        NSString * hexChar = [str3 substringWithRange: NSMakeRange(i, 2)];
        int value = 0;

        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [newString appendFormat:@"%c", (char)value];
        i+=2;
    }
//    NSLog(@"%@", newString);
////    NSString * strrr = [self stringToHex:strData];
    NSLog(@"====================Before===========%@",newString);
//

//    strUserKey = [self getStringConvertedinUnsigned:str3];

//    NSData* data=[strData dataUsingEncoding:NSUTF8StringEncoding];
//        NSLog(@"====================After last 32===========%@",[self doSha256:data]);
    
    NSString *key = @"This is my random key.";
    NSString *hexKey = @"54686973206973206d792072616e646f6d206b65792e";

    NSString *data = @"This is a data string.";

    NSData *hmac1 = [self hmacForKey:key andStringData:data];
    NSLog(@"hmacForKey   : %@", hmac1);

    NSData *hmac2 = [self hmacForHexKey:hexKey andStringData:data];
    NSLog(@"hmacForHexKey: %@", hmac2);


}

- (NSData *)doSha256:(NSData *)dataIn {
    NSMutableData *macOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(dataIn.bytes, dataIn.length, macOut.mutableBytes);
    return macOut;
}

- (NSString *) stringToHex:(NSString *)str
{
    NSUInteger len = [str length];
    unichar *chars = malloc(len * sizeof(unichar));
    [str getCharacters:chars];

    NSMutableString *hexString = [[NSMutableString alloc] init];

    for(NSUInteger i = 0; i < len; i++ )
    {
        [hexString appendString:[NSString stringWithFormat:@"%x", chars[i]]];
    }
    free(chars);

    return hexString ;
}


- (NSData *)dataFromHexString:(NSString *)sHex {
    const char *chars = [sHex UTF8String];
    int i = 0;
    NSUInteger len = sHex.length;

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

- (NSData *)hmacForHexKey:(NSString *)hexkey andStringData:(NSString *)data
{

    NSData *keyData = [self dataFromHexString:hexkey];

    const char *cKey  = [keyData bytes];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];

    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256, cKey, keyData.length, cData, strlen(cData), cHMAC);

    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];

}

- (NSData *)hmacForKey:(NSString *)key andStringData:(NSString *)data
{

    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];

    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];

}

- (void)testIt {

    NSString *key = @"This is my random key.";
    NSString *hexKey = @"54686973206973206d792072616e646f6d206b65792e";

    NSString *data = @"This is a data string.";

    NSData *hmac1 = [self hmacForKey:key andStringData:data];
    NSLog(@"hmacForKey   : %@", hmac1);

    NSData *hmac2 = [self hmacForHexKey:hexKey andStringData:data];
    NSLog(@"hmacForHexKey: %@", hmac2);
}
@end
/*
 2020-11-25 12:14:23.972182+0530 SmartLightApp[628:186385] =====================================================================Degub=<0a0032c0 050000f0 823638d0 8bb99ddb 51a0d3df 4f>  & =====descroption=<0a0032c0 050000f0 823638d0 8bb99ddb 51a0d3df 4f>
 Printing description of stringData:
 c00500000000f6633000f623002c03710600
 Printing description of kpstr:
 f663
 Printing description of calcData:
 <c0050000 00000000 3000f623 002c0371 0600>
 Printing description of localCheckSum:
 <f663>
 **/
