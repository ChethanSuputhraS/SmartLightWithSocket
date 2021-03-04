//
//  SocketCell.h
//  SmartLightApp
//
//  Created by Kalpesh Panchasara on 23/02/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SocketCell : UITableViewCell
{
    
}
@property(nonatomic,strong)UILabel * lblDeviceName;
@property(nonatomic,strong)UILabel * lblBack,*lblLine,*lblSettings,*lblLineLower;
@property(nonatomic, strong)UISwitch *swSocket;
@property(nonatomic, strong)UIImageView *imgSwitch;
@property(nonatomic,strong)UIButton * btnAlaram;
@property(nonatomic,strong)UIImageView * imgArrow;


@end

NS_ASSUME_NONNULL_END
