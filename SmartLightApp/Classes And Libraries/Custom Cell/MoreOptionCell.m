//
//  MoreOptionCell.m
//  AdvisorTLC
//
//  Created by Kalpesh Panchasara on 8/8/16.
//  Copyright © 2016 Kalpesh Panchasara. All rights reserved.
//

#import "MoreOptionCell.h"


@implementation MoreOptionCell

@synthesize imgIcon,imgCellBG,imgArrow,lblName,lblLineUpper,lblLineLower,lblEmail;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        imgCellBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
        imgCellBG.backgroundColor = [UIColor blackColor];
        imgCellBG.alpha = 0.5;
        [self.contentView addSubview:imgCellBG];
        
        imgIcon = [[AsyncImageView alloc] initWithFrame:CGRectMake(15, 12, 20, 20)];
        [imgIcon setImage:[UIImage imageNamed:@"profile_1.jpg"]];
        [imgIcon setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:imgIcon];
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(45, 10,DEVICE_WIDTH-60,24)];
        [lblName setTextColor:[UIColor darkGrayColor]];
        [lblName setBackgroundColor:[UIColor clearColor]];
        [lblName setTextAlignment:NSTextAlignmentLeft];
        [lblName setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
        [self.contentView addSubview:lblName];
        
        lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(60, 34,DEVICE_WIDTH-60,24)];
        [lblEmail setTextColor:[UIColor darkGrayColor]];
        [lblEmail setBackgroundColor:[UIColor clearColor]];
        [lblEmail setTextAlignment:NSTextAlignmentLeft];
        [lblEmail setFont:[UIFont fontWithName:CGRegular size:textSizes]];
        [self.contentView addSubview:lblEmail];
        [lblEmail setHidden:YES];
        
        imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-30, 12, 20, 20)];
        [imgArrow setImage:[UIImage imageNamed:@"right_gray_arrow.png"]];
        [imgArrow setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imgArrow];
        
        lblLineLower = [[UILabel alloc] initWithFrame:CGRectMake(5, 44, DEVICE_WIDTH-10, 0.5)];
        [lblLineLower setBackgroundColor:[UIColor lightGrayColor]];
        lblLineLower.alpha = 0.6;
        [self.contentView addSubview:lblLineLower];
        
       
        
//        _switchLight = [[ORBSwitch alloc] initWithCustomKnobImage:[UIImage imageNamed:@"off_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] frame:CGRectMake(0, 0, 100, 60)];
//        _switchLight.isOn = NO;
//        _switchLight.knobRelativeHeight = 0.8f;
//        _switchLight.frame = CGRectMake(DEVICE_WIDTH-110+30+30, 3, 60, 44);
//        _switchLight.delegate = self;
//        [self.contentView addSubview:_switchLight];
        
        
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
