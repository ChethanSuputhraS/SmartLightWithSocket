//
//  SideTableViewCell.m
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 24/12/18.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "SideTableViewCell.h"

@implementation SideTableViewCell
@synthesize lblSideTitle;
@synthesize imgIcon;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        lblSideTitle = [[UILabel alloc]init];
        //lblSideTitle.frame = CGRectMake(50, 10,DEVICE_WIDTH-60,24);
        lblSideTitle.backgroundColor = UIColor.clearColor;
        lblSideTitle.textColor = UIColor.whiteColor;
        lblSideTitle.textAlignment = NSTextAlignmentLeft;
        lblSideTitle.font = [UIFont fontWithName:CGRegular size:textSizes+2];
        [self.contentView addSubview:lblSideTitle];
        
        imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 20, 20)];
        [imgIcon setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:imgIcon];
        
    }
    return self;
}
@end
