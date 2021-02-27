//
//  CustomGroupCell.h
//  SmartLightApp
//
//  Created by stuart watts on 27/09/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//


@interface CustomGroupCell : UITableViewCell

@property(nonatomic,strong) UILabel * lblBack;
@property(nonatomic,strong) UILabel * lblName;
@property(nonatomic,strong) UILabel * lblLine;
@property(nonatomic,strong) UILabel * lblline2;
@property(nonatomic,strong) UILabel * lblline3;


@property(nonatomic,strong) UIImageView * imgBulb;
@property(nonatomic,strong) UIImageView * imgMore;

@property(nonatomic,strong) UIView * optionView;

@property(nonatomic,strong)ORBSwitch * _switchLight;

@property(nonatomic,strong) UIButton * btnMore;
@property(nonatomic,strong) UIButton * btnFav;
@property(nonatomic,strong) UIButton * btnEdit;
@property(nonatomic,strong) UIButton * btnDelete;
@property(nonatomic,strong) CAGradientLayer *gradient;
@property(nonatomic,strong) UIButton * btnOnCell;

@end
