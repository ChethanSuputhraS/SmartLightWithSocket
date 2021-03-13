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
-(void)MqttAlarmStatusfromServer:(BOOL)isSuccess;
-(void)MqttDeleteAlarmStatusfromServer:(BOOL)isSuccess;

@end

NS_ASSUME_NONNULL_END
