//
//  LeftMenuVC.h
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 01/01/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftMenuVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray * arrOptions;
    UILabel *lblAccName,*lblPhone;
    UITableView * tblContent;
}
@end
