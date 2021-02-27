//
//  ManageAccVC.h
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 29/10/18.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManageAccVC : UIViewController<UITableViewDelegate,UITableViewDataSource,FCAlertViewDelegate,URLManagerDelegate>
{
    UIButton * btnAddAccount;
    UITableView *tblContent;
    NSMutableArray *arrTable;
    UILabel *lblDisplayMsg;
    long intSelectedRow;
    NSString *strMobNo,*strPassword;
}
@property BOOL isFromDashboard;
@end
