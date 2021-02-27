//
//  SettingsVC.h
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 5/31/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoreOptionCell.h"
#import "WebLinkVC.h"
#import "EditUserDetailsVC.h"
#import "Doorbell.h"

@interface SettingsVC : UIViewController<UITableViewDelegate, UITableViewDataSource,URLManagerDelegate>
{
    UIImageView * imgNetworkStatus;
    
    UIActivityIndicatorView * activityIndicator;
    
    UITableView * tblContent;
    
    NSMutableArray * arrContent;
    
    Doorbell *feedback;
    
    UIScrollView * scrlView;
    UIView*viewSetting;
    UIButton*btn1,*btn2,*btn3,*btn4;
    int intSelectedSettingsValue;
    UIView *backView;
}

@end
