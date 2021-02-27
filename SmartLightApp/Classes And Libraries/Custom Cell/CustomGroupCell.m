//
//  CustomGroupCell.m
//  SmartLightApp
//
//  Created by stuart watts on 27/09/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "CustomGroupCell.h"

@implementation CustomGroupCell
@synthesize lblBack,lblName,lblLine,lblline2,lblline3,imgBulb,imgMore,btnFav,btnEdit,btnDelete,optionView, btnMore,_switchLight,gradient,btnOnCell;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(4, 0,DEVICE_WIDTH-8,100)];
//        lblBack.backgroundColor = [UIColor blackColor];
//        lblBack.alpha = 0.3;
        lblBack.userInteractionEnabled = true;
        lblBack.layer.cornerRadius = 5;
        lblBack.layer.masksToBounds = YES;
//        lblBack.layer.borderColor = [UIColor colorWithRed:0 green:174/255.0 blue:273/255.0 alpha:.8].CGColor;
//        lblBack.layer.borderWidth = 1;
        [self.contentView addSubview:lblBack];
        
        imgBulb = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [imgBulb setImage:[UIImage imageNamed:@"default_group_icon.png"]];
        imgBulb.userInteractionEnabled = true;
        [self.contentView addSubview:imgBulb];
        
        btnOnCell = [UIButton buttonWithType:UIButtonTypeCustom];
        btnOnCell.frame = CGRectMake(40, 0, DEVICE_WIDTH-100-57, 60);
        [btnOnCell setBackgroundColor:[UIColor clearColor]];
//        [self.contentView addSubview:btnOnCell];
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(57, 0, DEVICE_WIDTH-100-57, 60)];
        [lblName setTextColor:UIColor.whiteColor];
        [lblName setBackgroundColor:[UIColor clearColor]];
        [lblName setTextAlignment:NSTextAlignmentLeft];
        lblName.userInteractionEnabled = true;
        [lblName setFont:[UIFont systemFontOfSize:textSizes+2 weight:UIFontWeightRegular]];
        lblName.text = @" ";
        lblName.font = [UIFont fontWithName:CGRegular size:textSizes+3];
        [self.contentView addSubview:lblName];
        
        _switchLight = [[ORBSwitch alloc] initWithCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] frame:CGRectMake(0, 0, 100, 60)];
        _switchLight.isOn = YES;
        _switchLight.knobRelativeHeight = 0.8f;
        _switchLight.frame = CGRectMake(DEVICE_WIDTH-100, 11, 60, 40);
        _switchLight.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_switchLight];
        
      
        lblLine = [[UILabel alloc] initWithFrame:CGRectMake(7, 59.5, DEVICE_WIDTH-14, 0.5)];
        [lblLine setBackgroundColor:[UIColor lightGrayColor]];
        lblLine.alpha = 0.6;
        [self.contentView addSubview:lblLine];
        
        float btnWidth = (DEVICE_WIDTH-14)/3;
        
        optionView = [[UIView alloc] initWithFrame:CGRectMake(7, 60, DEVICE_WIDTH-14, 40)];
        [self.contentView addSubview:optionView];
        
        btnFav = [UIButton buttonWithType:UIButtonTypeCustom];
        btnFav.frame = CGRectMake(0, 0, btnWidth, 40);
        [btnFav setImage:[UIImage imageNamed:@"active_favorite_icon.png"] forState:UIControlStateNormal];
        [optionView addSubview:btnFav];
        
        btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        btnEdit.frame = CGRectMake(btnWidth, 0, btnWidth, 40);
        [btnEdit setImage:[UIImage imageNamed:@"edit_icon.png"] forState:UIControlStateNormal];
        [optionView addSubview:btnEdit];
        
        btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        btnDelete.frame = CGRectMake(btnWidth*2, 0, btnWidth, 40);
        [btnDelete setImage:[UIImage imageNamed:@"delete_icon.png"] forState:UIControlStateNormal];
        [optionView addSubview:btnDelete];
        
        lblline2 = [[UILabel alloc] initWithFrame:CGRectMake(btnWidth, 2, 0.5, 36)];
        [lblline2 setBackgroundColor:[UIColor lightGrayColor]];
        lblline2.alpha = 0.6;
        [optionView addSubview:lblline2];
        
        lblline3 = [[UILabel alloc] initWithFrame:CGRectMake(btnWidth*2, 2, 0.5, 36)];
        [lblline3 setBackgroundColor:[UIColor lightGrayColor]];
        lblline3.alpha = 0.6;
        [optionView addSubview:lblline3];
        
        imgMore = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-25, 19, 6, 22)];
        [imgMore setImage:[UIImage imageNamed:@"more_icon.png"]];
        [imgMore setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imgMore];
        
        btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
        btnMore.frame = CGRectMake(DEVICE_WIDTH-44, 0, 44, 60);
        btnMore.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:btnMore];
        
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
