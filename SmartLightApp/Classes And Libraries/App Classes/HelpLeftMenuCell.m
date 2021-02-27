//
//  HelpLeftMenuCell.m
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 02/01/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import "HelpLeftMenuCell.h"

@implementation HelpLeftMenuCell
@synthesize imgLogo,lblName,lblLine,imgCellBG,lblAppVersion,lblYoutube;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
        
        imgLogo = [[UIImageView alloc]init];
        imgLogo.frame = CGRectMake(10,11, 25, 25);
        imgLogo.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:imgLogo];
        
        lblName = [[UILabel alloc]initWithFrame:CGRectMake(45, 0, 180, 44)];
        lblName.backgroundColor = UIColor.clearColor;
        lblName.textColor = UIColor.whiteColor;
        lblName.font = [UIFont fontWithName:CGRegular size:textSizes+2];
        [self.contentView addSubview:lblName];
    
        
        lblLine = [[UILabel alloc] init];
        lblLine.frame = CGRectMake(5,lblName.frame.origin.y+44, DEVICE_WIDTH-10, 0.5);
        [lblLine setBackgroundColor:[UIColor lightGrayColor]];
        lblLine.alpha = 0.6;
        [self.contentView addSubview:lblLine];
        
        lblAppVersion = [[UILabel alloc]init];
        lblAppVersion.backgroundColor = UIColor.clearColor;
        lblAppVersion.textColor = UIColor.whiteColor;
        lblAppVersion.font = [UIFont fontWithName:CGRegular size:textSizes+1];
        lblAppVersion.hidden = true;
        [self.contentView addSubview:lblAppVersion];
        
        lblYoutube = [[UILabel alloc]initWithFrame:CGRectMake(45, 0, 180, 44)];
        lblYoutube.backgroundColor = UIColor.clearColor;
        lblYoutube.textColor = UIColor.whiteColor;
        lblYoutube.font = [UIFont fontWithName:CGRegular size:textSizes+2];
        lblYoutube.hidden = true;
        [self.contentView addSubview:lblYoutube];
        
    }
    return self;
}
@end
