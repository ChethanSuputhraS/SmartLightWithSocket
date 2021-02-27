//
//  customManageAccTableViewCell.m
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 29/10/18.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "customManageAccTableViewCell.h"

@implementation customManageAccTableViewCell
@synthesize lblView;
@synthesize lblAccName;
@synthesize lblMobNo;
//@synthesize btnDelete;
@synthesize imgDelete;
@synthesize imgLogo;
@synthesize lblName;
@synthesize lblLine;
@synthesize imgCellBG;

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
        imgCellBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
        imgCellBG.backgroundColor = [UIColor blackColor];
        imgCellBG.alpha = 0.5;
        [self.contentView addSubview:imgCellBG];
        
        lblView = [[UILabel alloc]init];
        lblView.backgroundColor = UIColor.blackColor;
        lblView.font = [UIFont fontWithName:CGRegular size:textSizes];
        lblView.frame = CGRectMake(5, 4, DEVICE_WIDTH-10, 44+5);
        lblView.userInteractionEnabled = true;
        lblView.alpha = 0.5;
        lblView.layer.cornerRadius = 10;
        lblView.layer.masksToBounds = YES;
        [self.contentView addSubview:lblView];
        
        
        imgDelete = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-40, 12+5, 20, 20)];
        imgDelete.image = [UIImage imageNamed:@"delete_icon"];
        [self.contentView addSubview:imgDelete];
        
//        btnDelete = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-45, 5, 45, 42)];
//        btnDelete.backgroundColor = UIColor.clearColor;
//        [self.contentView addSubview:btnDelete];
        
        
        lblAccName = [[UILabel alloc]init];
        lblAccName.backgroundColor = UIColor.clearColor;
        lblAccName.font = [UIFont fontWithName:CGBold size:textSizes+2];
        lblAccName.frame = CGRectMake(15, 5, DEVICE_WIDTH/2, 22);
        lblAccName.textColor = UIColor.whiteColor;
        [self.contentView addSubview:lblAccName];
        
        lblMobNo = [[UILabel alloc]init];
        lblMobNo.backgroundColor = UIColor.clearColor;
        lblMobNo.font = [UIFont fontWithName:CGRegular size:textSizes-2];
        lblMobNo.frame = CGRectMake(15, 22+5, DEVICE_WIDTH-50, 22);
        lblMobNo.textColor = UIColor.lightGrayColor;
        [self.contentView addSubview:lblMobNo];
        
        
        imgLogo = [[UIImageView alloc]init];
        imgLogo.frame = CGRectMake(10,11, 25, 25);
        imgLogo.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:imgLogo];
        
        lblName = [[UILabel alloc]initWithFrame:CGRectMake(45, 0, 200, 44)];
        lblName.backgroundColor = UIColor.clearColor;
        lblName.textColor = UIColor.whiteColor;
        lblName.font = [UIFont fontWithName:CGRegular size:textSizes+1];
        [self.contentView addSubview:lblName];
        
        
        lblLine = [[UILabel alloc] init];
        lblLine.frame = CGRectMake(5,lblName.frame.origin.y+44, DEVICE_WIDTH-10, 0.5);
        [lblLine setBackgroundColor:[UIColor lightGrayColor]];
        lblLine.alpha = 0.6;
        [self.contentView addSubview:lblLine];
    }
    return self;
}
@end
