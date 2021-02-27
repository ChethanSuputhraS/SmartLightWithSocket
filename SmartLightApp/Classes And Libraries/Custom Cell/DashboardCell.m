//
//  DashboardCell.m
//  SmartLightApp
//
//  Created by stuart watts on 22/11/2017.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import "DashboardCell.h"

@implementation DashboardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
@synthesize lblLine,lblName,lblReminder,btnMore,imgBulb,imgMore,imgStatus,_switchLight,lblBack, lblColors;
@synthesize lblDays,lblStatus;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(7, 0,DEVICE_WIDTH-14,65)];
        lblBack.backgroundColor = [UIColor blackColor];
        lblBack.alpha = 0.3;
        lblBack.layer.cornerRadius = 5;
        lblBack.layer.masksToBounds = YES;
        lblBack.layer.borderColor = [UIColor colorWithRed:0 green:174/255.0 blue:273/255.0 alpha:.8].CGColor;
        lblBack.layer.borderWidth = 1;
        [self.contentView addSubview:lblBack];

        imgStatus = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 20, 20)];
        [imgStatus setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:imgStatus];
        imgStatus.hidden =YES;
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(20, 0,DEVICE_WIDTH-20,60)];
        [lblName setTextColor:[UIColor whiteColor]];
        [lblName setBackgroundColor:[UIColor clearColor]];
        [lblName setTextAlignment:NSTextAlignmentLeft];
        lblName.text = @" ";
        [self.contentView addSubview:lblName];
    
        _switchLight = [[ORBSwitch alloc] initWithCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] frame:CGRectMake(0, 0, 100, 60)];
        _switchLight.isOn = YES;
        _switchLight.knobRelativeHeight = 0.8f;
        _switchLight.frame = CGRectMake(DEVICE_WIDTH-110+30, 10, 60, 40);
        [self.contentView addSubview:_switchLight];
        
        if (IS_IPHONE_4 || IS_IPHONE_5)
        {
            lblName.frame = CGRectMake(65, 0,135,60);
            lblName.numberOfLines = 0;
            [lblName setFont:[UIFont fontWithName:CGRegular size:textSizes]];
        }
        
        lblDays = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, DEVICE_WIDTH-20, 20)];
        lblDays.textColor = [UIColor lightGrayColor];
        lblDays.text = @"MON, TUE, WED, THU, FRI, SAT, SUN";
        [lblDays setFont:[UIFont fontWithName:CGRegular size:textSizes-3]];
        [self.contentView addSubview:lblDays];
        
        lblColors = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-100, 18, 50, 25)];
        lblColors.hidden = YES;
        lblColors.layer.cornerRadius = 12.5;
        lblColors.layer.masksToBounds = YES;
        lblColors.textColor = [UIColor lightGrayColor];
        lblColors.text = @"OFF";
        [lblColors setFont:[UIFont fontWithName:CGBold size:textSizes-2]];
        [self.contentView addSubview:lblColors];
        
        lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-100, 0, 50, 36)];
        lblStatus.textColor = [UIColor lightGrayColor];
        lblStatus.text = @"ON";
        [lblStatus setFont:[UIFont fontWithName:CGRegular size:textSizes-1]];
        
        btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
        btnMore.frame = CGRectMake(DEVICE_WIDTH-70, 0, 70, 65);
        btnMore.backgroundColor = [UIColor clearColor];
        btnMore.hidden = YES;
        [btnMore setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        btnMore.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes-1];
        [btnMore setImage:[UIImage imageNamed:@"delete_icon"] forState:UIControlStateNormal];
        [self.contentView addSubview:btnMore];
 
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
