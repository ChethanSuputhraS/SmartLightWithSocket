//
//  DashboardNewCell.h
//  SmartLightApp
//
//  Created by Vithamas Technologies on 09/12/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DashboardNewCell : UITableViewCell
{
    
}
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

NS_ASSUME_NONNULL_END
