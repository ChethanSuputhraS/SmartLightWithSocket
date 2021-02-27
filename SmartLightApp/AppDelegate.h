//
//  AppDelegate.h
//  SmartLightApp
//
//  Created by stuart watts on 22/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

//"have removed fabric script,should add it back later on"//
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DeviceTypes.h"
#import "MBProgressHUD.h"
#import "SCSkypeActivityIndicatorView.h"
#import "MFSideMenu.h"
#import "LeftMenuVC.h"
#import "AddSocketVC.h"
#import "SocketAlarmVC.h"
#import "SocketDetailVC.h"
#import "DashboardVC.h"
#import "SocketWiFiSetupVC.h"



UIImageView *imgNotConnected;
NSString * deviceTokenStr, * currentScreen, * globalUUID, * globalGroupId, * globalDeviceHexId, * strGlogalNotify, * strHexAlarmColor, * strImgforDevice, * strDeleteFavColor;
NSString * strSelectedAddress;
NSDate * dateDeviceLastSync, * dateGroupLastSync;
int statusHeight, textSizes, alarmRed, alarmBlue, alarmGreen;
BOOL  isNonConnectScanning, isDashScanning, isfromBridge, isfromAddDevice, isChanged, globalConnStatus, isAlldevicePowerOn, isOnAddGroup,isTimeSetSuccess,isFeedbackOpen,isFromFactoryRest, isScanningSocket;
BOOL isSearchingfromFactory,isScanCheckforDashboard, isCheckforDashScann, isViewWillAppeared, isUserDetailedCheck;
NSInteger fullRed,fullGreen, fullBlue, alphaGlob, approaxSize, globalCount,updatedRSSI;

CLLocationManager * locationManager;
CBPeripheral * globalPeripheral, * globalSocketPeripheral;
UITabBarController * mainTabBarController;
UIImageView *  bleConnectStatusImg;
NSMutableArray *arrConnectedDevices, * arrGlobalDevices, * arrSocketDevices;
SocketAlarmVC * globalSocketAlarmVC;
SocketDetailVC * globalSocketDetailVC;
DashboardVC * globalDashBoardVC;
SocketWiFiSetupVC * globalSocketWIFiSEtup;


NSMutableArray * arrPeripheralsCheck; 



@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,UITabBarControllerDelegate,URLManagerDelegate,CBPeripheralManagerDelegate,CBPeripheralDelegate>
{
    UIView * viewNetworkConnectionPopUp , * backView;
    NSTimer * timerNetworkConnectionPopUp;
    UILabel * lblTextIndiCator;
    CBPeripheralManager  *bluetoothManager;

    MBProgressHUD *HUD;
    SCSkypeActivityIndicatorView * loaderView;
    MFSideMenuContainerViewController * container;
    LeftMenuVC *sideMenuViewController;
}

@property (strong, nonatomic) UIWindow *window;


#pragma mark - Helper Methods
-(void)goToDashboard;
-(void)logoutAndGoToLogin;
-(void)hudForprocessMethod;
-(void)hudEndProcessMethod;
-(void)getLocationMethod;
-(void)askPushNotificationPermission;
-(void)ShowErrorPopUpWithErrorCode:(NSInteger)errorCode andMessage:(NSString*)errorMessage;
-(void)hideTabBar:(UITabBarController *) tabbarcontroller;
-(void)showTabBar:(UITabBarController *) tabbarcontroller;
-(void)showScannerView:(NSString *)msgStr;
-(void)hideScannerView;
-(void)addScannerView;
-(void)movetoSelectedIndex:(int)selectedInex;
-(void)generateUUIDforColor:(NSString *)deviceID;
-(void)sendSignalViaScan:(NSString *)strType withDeviceID:(NSString *)strDeviceID withValue:(NSString *)strValue;
-(void)justTestinKP:(NSString *)strDeviceId;
-(void)startAdvertisingBeacons;
-(void)stopAdvertisingBaecons;
-(BOOL)isNetworkreachable;
-(BOOL)validateEmail:(NSString*)email;
-(BOOL)detectBluetooth;
-(BOOL)isBluetoothOn;


-(UIColor *) colorWithHexString:(NSString *)stringToConvert;
-(UIImage *)imageFromColor:(UIColor *)color;
-(CGFloat)getHeightForText:(NSString*)givenText andWidth:(CGFloat)givenWidth andFontSize:(CGFloat)fontSize andFontWeight:(CGFloat)fontWeight;
-(NSString*)getCurrentTimeAndDate;
-(NSString*)getCurrentDateOnly;
-(void)startHudProcess:(NSString *)text;
-(void)endHudProcess;
-(void)movetoLogin;
-(NSString *)getStringConvertedinUnsigned:(NSString *)strNormal;
-(void)GenerateEncryptedKeyforLogin:(NSString *)strPassword;
-(NSData *)GetEncryptedKeyforData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength;

-(void)GetCheckSumforString:(NSString *)strNormal;
-(NSData *)GetCountedCheckSumData:(NSData *)chekdData;
-(NSData *)GetDecrypedDataKeyforData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength;
-(NSData *)SendAssociationRequestFirst:(NSString *)strData withKey:(NSString *)strUserKey withBLEAddress:(NSString*)strBleAddress withRawDataLength:(long)dataLength;
-(NSData *)SendAssociationRequestSecond:(NSString *)strData withKey:(NSString *)strUserKey withBLEAddress:(NSString*)strBleAddress withDataLength:(long)dataLength;

-(NSData *)getStringConvertedintoData:(NSString *)strNormal;
-(NSData *)GetCountedCheckSumDataCRC16:(NSData *)chekdData;
-(void)createAllUUIDs;
- (NSDictionary *)getCountryCodeDictionary;
-(NSString*)stringFroHex:(NSString *)hexStr;
-(void)getPlaceholderText:(UITextField *)txtField  andColor:(UIColor*)color;



//SOCKET METHOD
-(NSData *)GetSocketManufactureDataDecrypted:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength;
-(NSData *)GetSocketEncryptedKeyforData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength;
-(NSString *)GetSocketDecrypedData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength;

@end

