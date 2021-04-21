//
//  SocketWiFiSetupVC.h
//  SmartLightApp
//
//  Created by Vithamas Technologies on 25/01/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SocketWifiSettingDelegate <NSObject>
@optional
-(void)UpdateWifiSetupfromWifiSetting:(NSMutableDictionary *)mqttObject;
@end

@interface SocketWiFiSetupVC : UIViewController
{
    

}
@property (nonatomic,strong)NSString *   isWIFIconfig; 
@property(nonatomic,strong)CBPeripheral * classPeripheral;
@property(nonatomic,strong)NSString * strBleAddress;
@property(nonatomic,strong)NSMutableDictionary * dictData;
@property (nonatomic,weak) id<SocketWifiSettingDelegate>delegate;


@end

NS_ASSUME_NONNULL_END
