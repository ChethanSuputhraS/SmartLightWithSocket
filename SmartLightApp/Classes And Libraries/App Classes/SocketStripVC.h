//
//  SocketStripVC.h
//  SmartLightApp
//
//  Created by stuart watts on 06/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ORBSwitch.h"

@interface SocketStripVC : UIViewController
@property(nonatomic,strong)ORBSwitch * _switchLight;
@property(nonatomic,strong)NSString *  deviceName;
@property(nonatomic,strong)NSMutableDictionary  *  deviceDict;
@property BOOL isFromScan;
@property(nonatomic,strong)NSString *  isfronScreen;
@property BOOL isFromAll;
@property BOOL isfromGroup;

@end
