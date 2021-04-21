//
//  SocketDetailVC.h
//  SmartLightApp
//
//  Created by Kalpesh Panchasara on 06/01/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CocoaMQTT;

@protocol SocketDetailPageDelegate <NSObject>
@optional
-(void)ConnectedSocketfromSocketDetailPage:(CocoaMQTT *_Nonnull)mqttObject;
@end
NS_ASSUME_NONNULL_BEGIN

@interface SocketDetailVC : UIViewController
{
    UITableView * tblView;
    int globalStatusHeight;
    UIView *viewBGPicker,*pickerSetting;
    UIDatePicker * datePicker;
    NSString *selectedTime;
    UIButton * btnCancel;
    NSString * selectedDate;
    UIView *  viewForTxtBg,*viewTxtfld;
    UITextField *txtDeviceName,*txtRouterName,*txtRouterPassword;
    UIImageView *imgNotConnected, *imgWifiNotConnected;
    NSString * strSSID;
    CBCentralManager * _centralManager;
    NSString * strAllSwSatate;
    NSMutableDictionary *dictFromHomeSwState;
    NSMutableArray * arryDevices, * arrAlarmIdsofDevices;
    BOOL isMQTTConfigured;
    NSTimer * mqttRequestTimeOut, * statusCheckTimer;
    NSString * mqttSwithPreviousStatus;
    NSMutableArray * dictSocketDetail;
    NSInteger currentSocketSelectedImage;
    NSMutableArray * arrSocketNames;
    BOOL isTopicSubscribed;
    MBProgressHUD * intialConnectHud;
    

}
@property(nonatomic,strong) NSMutableDictionary *  deviceDetail;
@property(nonatomic,strong) NSString *  isMQTTselect;
@property(nonatomic,strong) CBPeripheral * classPeripheral;
@property(nonatomic,strong) NSString *  strMacAddress;
@property(nonatomic,strong) NSString *  strWifiConnect;
@property(nonatomic,strong) CocoaMQTT * classMqttObj;
@property (nonatomic,weak) id<SocketDetailPageDelegate>delegate;



-(void)ReceiveAllSoketONOFFState:(NSString *)strState withStatus:(BOOL)isSuccess;
-(void)ReceivedSwitchStatusfromDevice:(NSMutableDictionary *)dictSwitch;
-(void)ReceivedMQTTStatus:(NSDictionary *)dictSwitch;
-(void)AlarmListStoredinDevice:(NSMutableDictionary *)dictAlList;
-(void)ReceivedMQTTResponsefromserver:(NSMutableDictionary *)dictData;
-(void)ReceivedFirmwareVersionFromDevice:(NSString *)strVersion;

@end

NS_ASSUME_NONNULL_END
