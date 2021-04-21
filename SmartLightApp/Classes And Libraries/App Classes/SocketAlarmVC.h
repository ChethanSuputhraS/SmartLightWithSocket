//
//  SocketAlarmVC.h
//  SmartLightApp
//
//  Created by Kalpesh Panchasara on 06/01/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SocketAlarmDelegate <NSObject>
@optional
-(void)SetupAlarm:(NSMutableData *)alarmDict;
-(void)DeleteAlarm:(NSMutableData *)alarmDict;

@end

@interface SocketAlarmVC : UIViewController
{
    int globalStatusHeight;
    UIView *viewForBG,*viewForDay;
    UIView *timeBackView;
    UIDatePicker * datePicker;
    
    NSMutableArray * dayArr, * tmpArray;
    NSInteger totalDayCount, hours, minutes, sentCount,selday;
    int tblY;
    BOOL isOnPower, isRepeate;
    NSString * strTimeSelected,*strSelected1,*strSelected2,*strSelected3;
    int totalSyncedCount;
    UILabel * lblTime;
    UIButton * btn0, * btn1,* btn2, *btn3, *btn4, *btn5, *btn6,*btnON,*btnOFF;
    int headerhHeight,viewWidth;

    CBPeripheral * classPeripheral;
    
    UITableView * tblAlarms;
    NSInteger  intIndexPath;
    NSMutableDictionary * dictSw;
    NSTimer * timerForDelete;
    
    NSMutableArray * arryAlrams,*arrDayselect;
    NSMutableArray * arrTitle,*arrAlarmDetail;
    
    NSString * strAlramID1,*strAlramID2;
    NSInteger selectedAlarmIndex;
    BOOL isAlarmSavedSucessfully, isViewDisapeared, isDeletedManually;
    NSTimer * timerForSaveAlarm;
    NSMutableData * mqttAlarmData, * bleAlarmData;
    UIScrollView *scrllView;
    BOOL isAlarmRequested;
    NSInteger saveRandomNumber, deleteRandomNumber;
}

@property(nonatomic,assign) NSInteger intSelectedSwitch;
@property(nonatomic,strong)NSString* strTAg;
@property(nonatomic,assign)int intswitchState;
@property(nonatomic,assign)NSString * strMacaddress;
@property(nonatomic,strong)CBPeripheral * periphPass;
@property (nonatomic,weak) id<SocketAlarmDelegate>delegate;
@property(nonatomic,assign) NSMutableDictionary * dictDeviceDetail;


-(void)ALaramSuccessResponseFromDevie;
-(void)DeleteAlarmConfirmFromDevice:(NSMutableDictionary *)dictAlaramID;
-(void)MqttAlarmStatusfromServer:(BOOL)isSuccess withServerResponse:(NSArray *)arrResponse withMacAddress:(NSString *)strBleAddress;
-(void)MqttDeleteAlarmStatusfromServer:(BOOL)isSuccess withServerResponse:(NSArray *)arrResponse withMacaddress:(NSString *)strBleaddress;

@end

NS_ASSUME_NONNULL_END
