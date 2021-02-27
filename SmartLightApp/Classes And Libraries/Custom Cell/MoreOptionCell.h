//
//  MoreOptionCell.h
//  AdvisorTLC
//
//  Created by Kalpesh Panchasara on 8/8/16.
//  Copyright © 2016 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface MoreOptionCell : UITableViewCell<ORBSwitchDelegate>
{
    
}

@property(nonatomic,strong)UIImageView * imgCellBG;

@property(nonatomic,strong)AsyncImageView * imgIcon;
@property(nonatomic,strong)UIImageView * imgArrow;
@property(nonatomic,strong)UILabel * lblName;
@property(nonatomic,strong)UILabel * lblEmail;
//@property(nonatomic,strong)ORBSwitch * _switchLight;
@property(nonatomic,strong)UILabel * lblLineUpper;
@property(nonatomic,strong)UILabel * lblLineLower;


@end
