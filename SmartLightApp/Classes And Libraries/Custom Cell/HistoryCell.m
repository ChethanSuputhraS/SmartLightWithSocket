//
//  HistoryCell.m
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 6/3/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import "HistoryCell.h"

@implementation HistoryCell

@synthesize lblDeviceName,lblConnect;
@synthesize lblLine,imgIcon,lblReset;
//@synthesize btnMap,imgIcon;
@synthesize imgArrow,lblAddress,lblBack;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(7, 0,DEVICE_WIDTH-14,60)];
        lblBack.backgroundColor = [UIColor blackColor];
        lblBack.alpha = 0.3;
        lblBack.layer.cornerRadius = 5;
        lblBack.layer.masksToBounds = YES;
        lblBack.layer.borderColor = global_brown_color.CGColor;
        lblBack.layer.borderWidth = 1;
        [self.contentView addSubview:lblBack];

        
        imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(7+10, 10, 40, 40)];
        [imgIcon setImage:[UIImage imageNamed:@"mobile-icon.png"]];
        imgIcon.contentMode = UIViewContentModeScaleAspectFit;
        
        lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(65, 7, DEVICE_WIDTH-90, 30)];
        lblDeviceName.numberOfLines = 2;
        [lblDeviceName setBackgroundColor:[UIColor clearColor]];
        [lblDeviceName setTextColor:UIColor.whiteColor];
        [lblDeviceName setFont:[UIFont fontWithName:CGRegular size:textSizes]];
        [lblDeviceName setTextAlignment:NSTextAlignmentLeft];
        lblDeviceName.text = @"Smart Bulb";
        
        lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(65, 25+7, DEVICE_WIDTH-90, 20)];
        lblAddress.numberOfLines = 2;
        [lblAddress setBackgroundColor:[UIColor clearColor]];
        [lblAddress setTextColor:[UIColor whiteColor]];
        [lblAddress setFont:[UIFont fontWithName:CGRegular size:textSizes-3]];
        [lblAddress setTextAlignment:NSTextAlignmentLeft];
        lblAddress.text = @"Smart Bulb";
        lblAddress.hidden =YES;
        
        lblConnect = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-94, 0, DEVICE_WIDTH-70, 60)];
        lblConnect.numberOfLines = 2;
        [lblConnect setBackgroundColor:[UIColor clearColor]];
        [lblConnect setTextColor:[UIColor whiteColor]];
        [lblConnect setFont:[UIFont fontWithName:CGRegular size:textSizes-2]];
        [lblConnect setTextAlignment:NSTextAlignmentLeft];
        lblConnect.text = @"Add";
        
        lblLine = [[UILabel alloc] initWithFrame:CGRectMake(15, 49.8, DEVICE_WIDTH-15, 0.2)];
//        [lblLine setBackgroundColor:[UIColor darkGrayColor]];
        
        lblReset = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-60,0, 50, 60)];
        lblReset.backgroundColor = UIColor.clearColor;
        [lblReset setTextColor:[UIColor whiteColor]];
        [lblReset setFont:[UIFont fontWithName:CGRegular size:textSizes-3]];
        [lblReset setTextAlignment:NSTextAlignmentCenter];
        lblReset.hidden = true;
        lblReset.text = @"Tap to Reset";
        lblReset.numberOfLines = 2;


        [self.contentView addSubview:imgIcon];
        [self.contentView addSubview:lblDeviceName];
        [self.contentView addSubview:lblAddress];
        [self.contentView addSubview:lblConnect];
        [self.contentView addSubview:lblLine];
        [self.contentView addSubview:lblReset];

        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
