//
//  DashboardCell.h
//  SmartLightApp
//
//  Created by stuart watts on 22/11/2017.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ORBSwitch.h"

@interface DashboardCell : UITableViewCell

@property(nonatomic,strong)UILabel * lblName;
//@property(nonatomic,strong)UILabel * lblBleAddress;
@property(nonatomic,strong)UILabel * lblReminder;
@property(nonatomic,strong)UILabel * lblLine;
@property(nonatomic,strong)UIImageView * imgBulb;
@property(nonatomic,strong)UIImageView * imgMore;
@property(nonatomic,strong)UIImageView * imgStatus;
@property(nonatomic,strong)UILabel * lblBack;
@property(nonatomic,strong)UILabel * lblDays;
@property(nonatomic,strong)UIButton * btnMore;
@property(nonatomic,strong)ORBSwitch * _switchLight;
@property(nonatomic,strong) UILabel * lblColors;
@property(nonatomic,strong) UILabel * lblStatus;
@end
