//
//  HelpLeftMenuVC.h
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 02/01/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Doorbell.h"
@interface HelpLeftMenuVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>
{
    UITableView *tblContent;
    Doorbell *feedback;

}

@end
