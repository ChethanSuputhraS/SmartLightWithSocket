//
//  AlarmColorSelectVC.h
//  SmartLightApp
//
//  Created by stuart watts on 01/06/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRColorPickerView.h"


@interface AlarmColorSelectVC : UIViewController
{
    int headerhHeight;
    UIView * colorSquareView;
    HRColorPickerView * colorPickerView;
    UILabel * lblSelecColor;
    UIColor * selectedColors;
}
@property BOOL isFromAlarm;
@property BOOL isFromEdit ;
@end
