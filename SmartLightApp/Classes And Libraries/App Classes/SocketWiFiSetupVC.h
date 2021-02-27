//
//  SocketWiFiSetupVC.h
//  SmartLightApp
//
//  Created by Vithamas Technologies on 25/01/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SocketWiFiSetupVC : UIViewController
{
    

}
@property(nonatomic,strong)NSString * strWifiConfig;
@property(nonatomic,strong)CBPeripheral * peripheralPss;
@property(nonatomic,strong)NSString * strBleAddress;

-(void)FoundNumberofWIFITOsetting:(NSMutableArray *)arrayWifiList;
-(void)WifiPasswordAcknowledgementTowifiSetting:(NSString *)strStatus;


@end

NS_ASSUME_NONNULL_END
