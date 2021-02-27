//
//  NewCustomGroupCell.h
//  SmartLightApp
//
//  Created by Vithamas Technologies on 06/02/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewCustomGroupCell : UITableViewCell
{
    
}
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

NS_ASSUME_NONNULL_END
