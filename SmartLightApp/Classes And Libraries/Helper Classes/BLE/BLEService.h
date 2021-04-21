//
//  BLEService.h
//
//
//  Created by Kalpesh Panchasara on 7/11/14.
//  Copyright (c) 2014 Kalpesh Panchasara, Ind. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreBluetooth/CoreBluetooth.h>

/*!
 *  @protocol SGFServiceDelegate
 *
 *  @discussion Delegate for SGFService.
 *
 */
@protocol BLEServiceAddSocketDelegate
@optional
-(void)AuthenticationCompleted:(CBPeripheral *)peripheral;
-(void)ReceivedSwitchStatusfromDevice:(NSMutableDictionary *)dictSwitch;
-(void)ShowNowifiAvailablePopUP;
-(void)AssociationCompleted:(BOOL)isSucess;
-(void)ConfirmDeviceRecievedWifiConfiguredStatus:(NSString *)strStatus;
@required
@end


@protocol BLEServiceDelegate <NSObject>
@optional
-(void)activeDevice:(CBPeripheral*)device;
-(void)updateSignalImage:(int )RSSI forDevice:(CBPeripheral*)device;
@required
-(void)batterySignalValueUpdated:(CBPeripheral*)device withBattLevel:(NSString*)batLevel;
-(void)NoWIIFoundNearby;
-(void)FoundNumberofWIFI:(NSMutableArray *)arrWifi;
-(void)WifiSSIDIndexAcknowlegement:(NSString *)strStatus;
-(void)WifiPasswordAcknowledgement:(NSString *)strStatus;
-(void)RecievedWifiConfiguredStatus:(NSString *)strStatus;
-(void)RecievedRemoveWifiConfiguration;
@end





@interface BLEService : NSObject

/*!
 *  @property delegate
 *
 *  @discussion The delegate object that will receive service events.
 *
 */
@property (nonatomic, weak) id<BLEServiceDelegate>delegate;
@property (nonatomic, weak) id<BLEServiceAddSocketDelegate>addSocketdelegate;

-(id)init;

+ (instancetype)sharedInstance;


/*!
 *  @method initWithDevice:andDelegate:
 *  @discussion If the developer sets the SGFServiceDelegate while creating object for SGFManager then no need to use
 *      this method. If the developer does not set SGFServiceDelegate while creating object for SGFManager then
 *      developer has to call this method manually when device connected.
 *
 */
-(id)initWithDevice:(CBPeripheral*)device andDelegate:(id /*<BLEServiceDelegate>*/)delegate;


/*!
 *  @method startDeviceService
 *
 *  @discussion			This method activates the services of connected devices.
 */
-(void)startDeviceService;


/*!
 *  @method readDeviceBattery:
 *
 *  @param device	The device providing this update.
 *
 *  @discussion			This method starts to reading battery values of device.
 *
 *  @see                batterySignalValueUpdated:withBattLevel:
 */
-(void)readDeviceBattery:(CBPeripheral*)device;

/*!
 *  @method readDeviceRSSI:
 *
 *  @param device	The device providing this update.
 *
 *  @discussion			This method starts to reading RSSI values of device.
 *
 *  @see                updateSignalImage:forDevice:
 */

-(void)readDeviceRSSI:(CBPeripheral*)device;


/*!
 *  @method startBuzzer:
 *
 *  @param device	The device providing this update.
 *
 *  @discussion			This method provides the developer to call raising the alarm in the find device.
 */
-(void)startBuzzer:(CBPeripheral*)device;


/*!
 *  @method stopBuzzer:
 *
 *  @param device	The device providing this update.
 *
 *  @discussion			This method provides the developer to call stop the alarm in the find device.
 */
-(void)stopBuzzer:(CBPeripheral*)device;

-(void) soundBuzzer:(Byte)buzzerValue peripheral:(CBPeripheral *)peripheral;


/*------ new methods-----*/
-(void) CBUUIDnotification:(CBUUID*)su characteristicUUID:(CBUUID*)cu p:(CBPeripheral *)p on:(BOOL)on;
-(void) CBUUIDwriteValue:(CBUUID *)su characteristicUUID:(CBUUID *)cu p:(CBPeripheral *)p data:(NSData *)data;
-(void) soundBuzzerforNotifydevice:(Byte)buzzerValue peripheral:(CBPeripheral *)peripheral;
//-(void) soundbatteryToDevice:(NSString *)buzzerValue peripheral:(CBPeripheral *)peripheral;
//-(void)sendSignalBeforeBattery:(CBPeripheral *)kp;
-(void)sendBatterySignal:(CBPeripheral *)kp;
-(void)startDeviceService:(CBPeripheral *)kpb;
-(void) soundbatteryToDevice:(long long)buzzerValue peripheral:(CBPeripheral *)peripheral;
-(void)sendSignalBeforeBattery:(CBPeripheral *)kp withValue:(NSString *)dataStr;

-(void)sendDeviceType:(CBPeripheral *)kp withValue:(NSString *)dataStr;

-(void)sendingTestToDevice:(NSString *)message with:(CBPeripheral *)peripheral withIndex:(NSString *)strIndex;
-(void)sendHandleString:(CBPeripheral *)peripheral;
-(void)sendingTestToDeviceCanned:(NSString *)message with:(CBPeripheral *)peripheral withIndex:(NSString *)strIndex;
//-(void)writeValuetoDevice:(NSData *)message with:(CBPeripheral *)peripheral;
-(void)sendTimeToDevice:(CBPeripheral *)kp;
-(void)sendMessagetoother:(NSString *)strAll with:(CBPeripheral *)peripheral withIndex:(NSString *)strIndex;
-(void)sendNotifications:(CBPeripheral*)kp withType:(BOOL)isMulti withUUID:(NSString *)strUUID;
-(void)writeValuetoDeviceMsg:(NSData *)message with:(CBPeripheral *)peripheral;
-(void)syncDiverMessage:(NSString *)message with:(CBPeripheral *)peripheral withIndex:(NSString *)strIndex;
-(void)writeColortoDevice:(NSData *)message with:(CBPeripheral *)peripheral withDestID:(NSString *)destID;
-(void) readAuthValuefromManager:(CBPeripheral *)peripherals;
-(void)readFactoryResetValue:(CBPeripheral *)peripherals;


//New Devices Methods
-(void)ConnectOtherDevice:(NSData *)message with:(CBPeripheral *)peripheral;

-(void)sendNotificationsForOff:(CBPeripheral*)kp withType:(BOOL)isMulti;



#pragma mark - ALL SOCKET METHODS
-(void)EnableNotificationsForCommand:(CBPeripheral*)kp withType:(BOOL)isMulti;
-(void)EnableNotificationsForDATA:(CBPeripheral*)kp withType:(BOOL)isMulti;
-(void)GetAuthcodeforSocket:(CBPeripheral *)kp withValue:(NSString *)strValue isforSocketReset:(BOOL)isResetSocket;
-(void)ReceivedDataFromSwitch:(NSString *)opcode withLength:(NSString *)strLength withSelectedSwitch:(NSString *)strSwitchSelect withSwitchState:(NSString *)strSwitchState withPeripheral:(CBPeripheral *)peripheral;

-(void)SendRequestForSwitchState:(NSString *)strop  withLength:(NSString *)strLength withPeripheral:(CBPeripheral *)peripheral;

-(void)RequestForCurentTimeSetINSocket:(NSString *)strop withLength:(NSString *)strLength withperipheral:(CBPeripheral *)peripheral;
-(void)RequestMQTTStatusConnect:(NSString *)strop withLength:(NSString *)strLength withperipheral:(CBPeripheral *)peripheral;
-(void)SendingForCurentTimeSetINSocket:(NSString *)strop withLength:(NSString *)strLength  withTimeInHexa:(NSString *)strCurrentDate withperipheral:(CBPeripheral *)peripheral;
-(void)SendingSSIDandPasswordTotheDevice:(NSString *)strSSIDandPass withOPcode:(NSString *)strOpcode withPeripheral:(CBPeripheral *)peripheral;

-(void)SendDatatoPeripheral:(NSData *)completeData withPeripheral:(CBPeripheral *)Peripheral;
-(void)sendNotificationsSKT:(CBPeripheral*)kp withType:(BOOL)isMulti withUUID:(NSString *)strUUID;
-(void)EnableNotificationsForCommandSKT:(CBPeripheral*)kp withSocketReset:(BOOL)isResetSocket;
-(void)EnableNotificationsForDATASKT:(CBPeripheral*)kp withSocketReset:(BOOL)isResetSocket;


-(void)WriteSocketData:(NSData *)socketData withOpcode:(NSString *)strOpcode withLength:(NSString *)strLength withPeripheral:(CBPeripheral *)peripheral;
-(void)WriteWifiPassword:(NSString *)strPassword withPeripheral:(CBPeripheral *)peripheral;
-(void)WriteSocketDataToResetSocket:(NSData *)socketData withOpcode:(NSString *)strOpcode withLength:(NSString *)strLength withPeripheral:(CBPeripheral *)peripheral;


@end
