//
//  SocketAlarmVC.h
//  SmartLightApp
//
//  Created by Kalpesh Panchasara on 06/01/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

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

-(void)ALaramSuccessResponseFromDevie;
-(void)DeleteAlarmConfirmFromDevice:(NSMutableDictionary *)dictAlaramID;

@end

NS_ASSUME_NONNULL_END
