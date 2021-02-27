//
//  FactoryResetVC.h
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 10/10/18.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FactoryResetVC : UIViewController
{
    NSString *strSelectedBleAddress,*strDeviceID;
    NSTimer *timerOut;
    
}
@property BOOL isFromAddDevice;
@end
