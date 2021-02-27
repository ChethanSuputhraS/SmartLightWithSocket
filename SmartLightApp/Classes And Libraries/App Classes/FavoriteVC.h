//
//  FavoriteVC.h
//  SmartLightApp
//
//  Created by stuart watts on 05/04/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryLogsCell.h"
#import "ORBSwitch.h"
#import "NYSegmentedControl.h"
#import "DeviceDetailVC.h"
#import "CustomTableViewCell.h"
#import "SWTableViewCell.h"
#import "SocketStripVC.h"
#import "DashboardCell.h"
#import "AddDeviceVC.h"

@interface FavoriteVC : UIViewController<URLManagerDelegate,UITableViewDelegate,UITableViewDataSource,ORBSwitchDelegate,SWTableViewCellDelegate>
{
    UIScrollView * scrlContent;
    UIImageView * imgNetworkStatus;

    UIView * viewMessage, * noMsgView;
    UITableView * tblView;
    UILabel * lblSuccessMsg;
    
    NSMutableArray * sectionArr , * groupsArr;
    NSMutableDictionary * selectedDict;
    
    NSString * strRename, * strDeviceID, * isAction, * strTableId, * strChangedDeviceNames;
    NSIndexPath * previouIndex, * switchIndex, * selectedIndexPathl;
    BOOL isForGroup, isAll;
    
    NYSegmentedControl *blueSegmentedControl;
    ORBSwitch * tmpSwtch;


}

@end
