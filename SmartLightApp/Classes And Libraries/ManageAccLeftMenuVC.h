//
//  ManageAccLeftMenuVC.h
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 09/01/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManageAccLeftMenuVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *tblContent;
    UILabel * lblName;
}

@end
