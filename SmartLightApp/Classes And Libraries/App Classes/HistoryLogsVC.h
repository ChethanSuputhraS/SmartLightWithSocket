//
//  HistoryLogsVC.h
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 7/21/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryLogsDetailsCell.h"

@interface HistoryLogsVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UIImageView * imgNetworkStatus;
    
    UITableView * tblHistory;
    UILabel * lblErrorMessage;
    
    NSMutableArray * arrHistory;
}

@property(nonatomic,strong)NSMutableDictionary * dictHistoryDetails;

@end
