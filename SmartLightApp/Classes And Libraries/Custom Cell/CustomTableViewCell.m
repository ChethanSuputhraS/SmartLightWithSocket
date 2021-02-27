//
//  CustomTableViewCell.m
//  SwipeTableCell
//
//  Created by Simon on 4/5/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "CustomTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomTableViewCell
@synthesize lblLine,lblName,lblBleAddress,btnMore,imgBulb,imgMore,_switchLight,lblBack,myCellIndex,optionView,btnOncell;
@synthesize btnFav,btnDelete,btnEdit,lblline2,lblline3, btnSettings,brightnessSlider,imgFullBrightness,imgLowBrightness, gradient;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(2, 0,DEVICE_WIDTH-4,50)];
//        lblBack.backgroundColor = [UIColor redColor];
//        lblBack.alpha = 0.3;
        lblBack.userInteractionEnabled = true;
        lblBack.layer.cornerRadius = 5;
        lblBack.layer.masksToBounds = YES;
//        lblBack.layer.borderColor = [UIColor colorWithRed:0 green:174/255.0 blue:273/255.0 alpha:1].CGColor;
//        lblBack.layer.borderWidth = 1;
        [self.contentView addSubview:lblBack];
        
//        CAGradientLayer *gradient = [CAGradientLayer layer];
//
//        gradient.frame = lblBack.bounds;
//        gradient.colors = @[(id)[UIColor colorWithRed:96.0/255.0 green:56.0/255.0 blue:19.0/255.0 alpha:1].CGColor, (id)[UIColor colorWithRed:178.0/255.0 green:159.0/255.0 blue:148.0/255.0 alpha:1].CGColor];
        
//        [lblBack.layer insertSublayer:gradient atIndex:0];

        imgBulb = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [imgBulb setImage:[UIImage imageNamed:@"default_pic.png"]];
        imgBulb.userInteractionEnabled = true;
        imgBulb.layer.shadowColor = [global_brown_color CGColor];
        imgBulb.layer.shadowRadius = 4.0f;
        imgBulb.layer.shadowOpacity = .9;
        imgBulb.layer.shadowOffset = CGSizeZero;
        imgBulb.layer.masksToBounds = NO;
        [self.contentView addSubview:imgBulb];
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(57, 12, DEVICE_WIDTH-100-57, 35)];
        [lblName setTextColor:UIColor.whiteColor];
        [lblName setBackgroundColor:[UIColor clearColor]];
        [lblName setTextAlignment:NSTextAlignmentLeft];
        lblName.userInteractionEnabled = true;
        lblName.text = @" ";
        lblName.font = [UIFont fontWithName:CGRegular size:textSizes+3];
        [self.contentView addSubview:lblName];
        
        btnOncell = [UIButton buttonWithType:UIButtonTypeCustom];
        btnOncell.frame = CGRectMake(50, 0, DEVICE_WIDTH-100-50, 50);
        btnOncell.backgroundColor = [UIColor clearColor];
//        [self.contentView addSubview:btnOncell];
        
//        lblBleAddress = [[UILabel alloc] initWithFrame:CGRectMake(38, 25+7, DEVICE_WIDTH-100-37, 20)];
//        [lblBleAddress setTextColor:[UIColor whiteColor]];
//        [lblBleAddress setBackgroundColor:[UIColor clearColor]];
//        [lblBleAddress setTextAlignment:NSTextAlignmentLeft];
//        [self.contentView addSubview:lblBleAddress];
//        lblBleAddress.text = @"1234567891234";
//        lblBleAddress.font = [UIFont fontWithName:CGRegular size:textSizes-4];
        
        _switchLight = [[ORBSwitch alloc] initWithCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] frame:CGRectMake(0, 0, 100, 60)];
        _switchLight.isOn = YES;
        _switchLight.knobRelativeHeight = 0.8f;
        _switchLight.frame = CGRectMake(DEVICE_WIDTH-100, 11, 60, 40);
        _switchLight.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_switchLight];
                

        
        lblLine = [[UILabel alloc]init];
        [lblLine setBackgroundColor:[UIColor lightGrayColor]];
        lblLine.alpha = 0.6;
        [self.contentView addSubview:lblLine];
        
        float btnWidth = (DEVICE_WIDTH-14)/4;
        
        optionView = [[UIView alloc]init];
        [self.contentView addSubview:optionView];
        
        btnFav = [UIButton buttonWithType:UIButtonTypeCustom];
        btnFav.frame = CGRectMake(0, 0, btnWidth, 40);
        btnFav.backgroundColor = [UIColor clearColor];
        [btnFav setImage:[UIImage imageNamed:@"active_favorite_icon.png"] forState:UIControlStateNormal];
        [optionView addSubview:btnFav];

        btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        btnEdit.frame = CGRectMake(btnWidth, 0, btnWidth, 40);
        btnEdit.backgroundColor = [UIColor clearColor];
        [btnEdit setImage:[UIImage imageNamed:@"edit_icon.png"] forState:UIControlStateNormal];
        [optionView addSubview:btnEdit];
      
        btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        btnDelete.frame = CGRectMake(btnWidth*2, 0, btnWidth, 40);
        btnDelete.backgroundColor = [UIColor clearColor];
        [btnDelete setImage:[UIImage imageNamed:@"delete_icon.png"] forState:UIControlStateNormal];
        [optionView addSubview:btnDelete];
        
        btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnSettings setImage:[UIImage imageNamed:@"settingsGrey.png"] forState:UIControlStateNormal];
        btnSettings.frame = CGRectMake((btnWidth*3)-5, 0, btnWidth+5, 40);
        btnSettings.backgroundColor = [UIColor clearColor];
        btnSettings.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes-2];
        btnSettings.titleLabel.numberOfLines = 0;
        btnSettings.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btnSettings setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [optionView addSubview:btnSettings];
        
        lblline2 = [[UILabel alloc] initWithFrame:CGRectMake(btnWidth, 2, 0.5, 36)];
        [lblline2 setBackgroundColor:[UIColor lightGrayColor]];
        lblline2.alpha = 0.6;
        [optionView addSubview:lblline2];
        
        lblline3 = [[UILabel alloc] initWithFrame:CGRectMake(btnWidth*2, 2, 0.5, 36)];
        [lblline3 setBackgroundColor:[UIColor lightGrayColor]];
        lblline3.alpha = 0.6;
        [optionView addSubview:lblline3];
        
        UILabel * lblline4 = [[UILabel alloc] initWithFrame:CGRectMake((btnWidth*3)-7, 2, 0.5, 36)];
        [lblline4 setBackgroundColor:[UIColor lightGrayColor]];
        lblline4.alpha = 0.6;
        [optionView addSubview:lblline4];
        
        imgMore = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-25, 19, 6, 22)];
        [imgMore setImage:[UIImage imageNamed:@"more_icon.png"]];
        [imgMore setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imgMore];
        
        btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
        btnMore.frame = CGRectMake(DEVICE_WIDTH-44, 0, 44, 60);
        btnMore.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:btnMore];

        int yy = btnMore.frame.size.width+5;
        
        imgLowBrightness = [[UIImageView alloc]init];
        imgLowBrightness.frame = CGRectMake(10,yy+14 ,12 ,12 );
        imgLowBrightness.image = [UIImage imageNamed:@"lowBright.png"];
        imgLowBrightness.userInteractionEnabled = true;
        imgLowBrightness.hidden = true;
        [self.contentView addSubview:imgLowBrightness];
        
        imgFullBrightness = [[UIImageView alloc]init];
        imgFullBrightness.frame = CGRectMake(DEVICE_WIDTH-30,yy+10,20 ,20 );
        imgFullBrightness.image = [UIImage imageNamed:@"fullBright.png"];
        imgFullBrightness.hidden = true;
        imgFullBrightness.userInteractionEnabled = true;
        [self.contentView addSubview:imgFullBrightness];
        
        brightnessSlider = [[UISlider alloc]init];
        brightnessSlider.frame = CGRectMake(25, yy-5, DEVICE_WIDTH-60, 50);
        brightnessSlider.backgroundColor = UIColor.clearColor;
        brightnessSlider.minimumValue = 0.20;
        brightnessSlider.maximumValue = 1;
        brightnessSlider.value = 1;
//        [brightnessSlider setThumbImage:[UIImage imageNamed:@"on_icon.png"] forState:UIControlStateHighlighted];
        [brightnessSlider setThumbImage:[UIImage imageNamed:@"on_icon.png"] forState:UIControlStateNormal];
        brightnessSlider.continuous = YES;
        brightnessSlider.minimumTrackTintColor = UIColor.whiteColor;
        brightnessSlider.maximumTrackTintColor = UIColor.lightGrayColor;
        brightnessSlider.hidden = true;
        [self.contentView addSubview:brightnessSlider];
        
        gradient = [CAGradientLayer layer];
        gradient.startPoint = CGPointMake(0.0, 0.5);
        gradient.endPoint = CGPointMake(1.0, 0.5);
        gradient.frame = lblBack.bounds;
        [lblBack.layer insertSublayer:gradient atIndex:0];

    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
//[[[sectionArr objectAtIndex:indexPath.row] valueForKey:@"switch_status"] isEqualToString:@"Yes"]
