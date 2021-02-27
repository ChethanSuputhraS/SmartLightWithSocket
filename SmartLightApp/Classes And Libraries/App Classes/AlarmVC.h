//
//  AlarmVC.h
//  SmartLightApp
//
//  Created by stuart watts on 05/04/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ORBSwitch.h"

@interface AlarmVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * tblView;
    NSMutableArray * alarmArr;
    ORBSwitch * tmpSwtch;
    UILabel * lblNoAlarm;
}
@end
