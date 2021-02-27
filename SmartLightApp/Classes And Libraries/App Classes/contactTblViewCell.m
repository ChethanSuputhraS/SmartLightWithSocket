//
//  contactTblViewCell.m
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 01/01/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import "contactTblViewCell.h"

@implementation contactTblViewCell
@synthesize imgLogo,lblName,lblContent,lblLine,imgCellBG;
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
        imgLogo.frame = CGRectMake(25,4, 25, 25);
        imgLogo.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:imgLogo];
        
        lblName = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 150, 30)];
        lblName.backgroundColor = UIColor.clearColor;
        lblName.textColor = UIColor.whiteColor;
        lblName.font = [UIFont fontWithName:CGRegular size:textSizes+2];
        [self.contentView addSubview:lblName];
        
        lblContent = [[UILabel alloc]init];
        lblContent.backgroundColor = UIColor.clearColor;
        lblContent.textColor = UIColor.whiteColor;
        lblContent.font = [UIFont fontWithName:CGRegular size:textSizes-1];
        lblContent.textAlignment = NSTextAlignmentNatural;
        [self.contentView addSubview:lblContent];
        
        lblLine = [[UILabel alloc] init];
        [lblLine setBackgroundColor:[UIColor whiteColor]];
        lblLine.alpha = 0.6;
        [self.contentView addSubview:lblLine];
        
    
        
    }
    return self;
}

@end
