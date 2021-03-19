//
//  DashboardVC.h
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 5/31/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryLogsCell.h"
#import "NYSegmentedControl.h"
#import "DashboardCell.h"
#import "AddDeviceVC.h"
#import "ORBSwitch.h"
#import "DeviceDetailVC.h"
#import "CustomTableViewCell.h"
#import "SWTableViewCell.h"
#import "SocketStripVC.h"
#import "FCAlertView.h"

@interface DashboardVC : UIViewController<URLManagerDelegate,UITableViewDelegate,UITableViewDataSource,ORBSwitchDelegate,SWTableViewCellDelegate,FCAlertViewDelegate>
{
    FCAlertView *alert;
    int sideBtnIndex;
    UIScrollView * scrlContent;
    UIImageView * imgNetworkStatus, * blbImg;
    long indexCount;
    UIView * viewMessage,* pckrView, *bgBackView,* noMsgView;
    UITableView * tblView;
    UIButton * btnBigAddDevice, * btnAddDevice;
    UIView * sideView;
    UILabel * lblSuccessMsg,*lblAccName;
    UITableView *tblSideView;
    NSMutableArray * optionArr, * bulbArr, * switchArr,* sectionArr, * powerArr , * groupsArr,*sideViewArray;
    NSMutableDictionary * selectedDict;
    NSDictionary * setDict;
    NSString * strRename, * strDeviceID, * isAction, * strTableId, * strChangedDeviceNames;
    NSIndexPath * previouIndex, * switchIndex, * selectedIndexPathl;

    BOOL isForGroup, isAll, isCalledGroup;
    
    NYSegmentedControl *blueSegmentedControl;
    ORBSwitch * tmpSwtch;
    FCAlertView *alertpopup;
    CBCentralManager *centralManager;
    UIView * viewSetting;
    UIButton *btn1,*btn2,*btn3,*btn4;
    int intSelectedSettingsValue;
    CGFloat intBrightnessValue;
    NSTimer *brightTimer;
    BOOL isBrightnessChanged,isWarmWhite;
    CGFloat imageBrighValue;
    NSMutableData *completeData;
    UILabel *lblThumbTint;
    UIView *backView;
    double realBrightnessValue;
    NSMutableDictionary * dictSocketSwitchStatus;
}
#pragma mark- ALL socket method
@property(nonatomic,strong)NSString * strMack;
-(void)NewSocketAddedWithWIFIConfigured:(NSString *)strBleAddress withPeripheral:(CBPeripheral *)peripheral;
-(void)DisconnectMQTTSocketServer;
-(void)UpdateSocketSwithchStatus:(NSArray *)arrData withMacAddress:(NSString *)strAddress;
@end
