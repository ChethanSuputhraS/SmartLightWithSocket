//
//  HistoryVC.h
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 5/31/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryCell.h"
#import "HistoryLogsVC.h"

@interface HistoryVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UIImageView * imgNetworkStatus;
    
    UITableView * tblHistory;
    UILabel * lblErrorMessage;
    
    NSMutableArray * arrHistory;
}

@end
