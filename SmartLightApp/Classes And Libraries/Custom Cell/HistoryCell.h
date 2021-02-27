//
//  HistoryCell.h
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 6/3/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryCell : UITableViewCell
{
    
}

@property(nonatomic,strong)UIImageView * imgIcon;
//@property(nonatomic,strong)UIButton * btnMap;

@property(nonatomic,strong)UIImageView * imgArrow;

@property(nonatomic,strong)UILabel * lblAddress;
@property(nonatomic,strong)UILabel * lblDeviceName;
@property(nonatomic,strong)UILabel * lblConnect;
@property(nonatomic,strong)UILabel * lblLine;
@property(nonatomic,strong)UILabel * lblBack;
@property(nonatomic,strong)UILabel * lblReset;


@end
