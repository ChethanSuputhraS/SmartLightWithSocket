//
//  HomeCell.h
//  HoldItWrite
//
//  Created by Kalpesh Panchasara on 12/07/20.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCell : UITableViewCell
{
    
}
@property(nonatomic,strong)UILabel * lblAddress;
@property(nonatomic,strong)UILabel * lblDeviceName;
@property(nonatomic,strong)UILabel * lblConnect;
@property(nonatomic,strong)UILabel * lblBack,*lblLine;
@property(nonatomic, strong)UISwitch *swSocket;
@property(nonatomic, strong)UIImageView *imgSwitch;
@property(nonatomic,strong)UIButton * btnAlaram;
@end
