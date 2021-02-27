//
//  CustomTableViewCell.h
//  SwipeTableCell
//
//  Created by Simon on 4/5/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMMarkSlider.h"

@interface CustomTableViewCell : UITableViewCell
@property(nonatomic,strong) UILabel * lblBack, * lblName, * lblBleAddress;
@property(nonatomic,strong) UILabel * lblLine, * lblline2, *lblline3;

@property(nonatomic,strong) UIView * optionView;

@property(nonatomic,strong) UIImageView * imgBulb, * imgMore;

@property(nonatomic,strong) ORBSwitch * _switchLight;

@property(nonatomic,strong) UIButton * btnMore, * btnFav, * btnEdit, * btnDelete, *btnSettings, *btnOncell;
@property(nonatomic,strong)UISlider *brightnessSlider;
@property(nonatomic,strong)UIImageView * imgLowBrightness;
@property(nonatomic,strong)UIImageView * imgFullBrightness;
@property(nonatomic,strong) CAGradientLayer *gradient;
@property NSInteger myCellIndex;

@end
