//
//  AddDeviceVC.h
//  SmartLightApp
//
//  Created by stuart watts on 22/11/2017.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "FCAlertView.h"
@interface AddDeviceVC : UIViewController
{
    NSString * strRequetAddress;
    FCAlertView *alert;
    NSString * strHexIdofDevice;
    CBPeripheral * tempPeripheral;

}
@property BOOL isForGroup;
@property BOOL isfromEdit;
@property (nonatomic,strong) NSMutableDictionary * detailDict;

@end
