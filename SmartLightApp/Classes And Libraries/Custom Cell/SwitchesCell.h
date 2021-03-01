//
//  SwitchesCell.h
//  VithamasSocket
//
//  Created by Vithamas Technologies on 30/11/20.
//  Copyright © 2020 Chethan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SwitchesCell : UITableViewCell

@property(nonatomic,strong)UILabel * lblONtime,* lblOFFtime,*lblAlarms,*lblON,*lbldays,*lblOFF;
@property(nonatomic,strong)UILabel * lblBack,*lblLine,*lblWifiSetup,*lblLineParall;
@property(nonatomic,strong)UIButton  * btnDay,*btnon ,*btnoff,*btnTime,*btnDelete,*btnONTimer,*btnOFFTimer,*btnRepeate;
@property(nonatomic,strong)UIButton  *btn0,*btn1,*btn2,*btn3,*btn4,*btn5,*btn6,*btn7;
@property(nonatomic,strong)NSMutableArray * dayArr;
@property(nonatomic,strong)UIImageView * imgCheck;

-(void)UpdateDaysStatus:(NSMutableDictionary *)dayDict;
@end

NS_ASSUME_NONNULL_END
