//
//  AlarmDetailVC.h
//  SmartLightApp
//
//  Created by stuart watts on 28/05/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmDetailVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    int headerhHeight,viewWidth;
    UILabel * lblTime, *lblSelecColor;
    UIButton * btn0, * btn1,* btn2, *btn3, *btn4, *btn5, *btn6;
    UIButton * btnON, * btnOFF;
    UITableView * tblView;
    NSMutableArray * arrDevices;
    UIView * timeBackView;
    UIDatePicker * datePicker;
    UIView * turnOffView;
    UIView * colorView;
    UIImageView *imgCheckBox2;
    bool isWakeUpClicked;
    UILabel * lblSlowTurnOff;
}
@property (nonatomic,strong) NSMutableDictionary * detailDict;
@property BOOL isFromEdit;
@property (nonatomic,strong) NSString  * strIndex;

@end
