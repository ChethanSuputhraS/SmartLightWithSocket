//
//  SocketCell.m
//  SmartLightApp
//
//  Created by Kalpesh Panchasara on 23/02/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import "SocketCell.h"

@implementation SocketCell
@synthesize lblDeviceName,lblBack,swSocket,imgSwitch,btnAlaram,lblLine;
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
    {    // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(10, 0,DEVICE_WIDTH-20,60)];
        lblBack.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        lblBack.layer.masksToBounds = YES;
        lblBack.layer.borderColor = UIColor.whiteColor.CGColor; // light graycolor
        lblBack.layer.borderWidth = .6;
        lblBack.layer.cornerRadius = 6;
        lblBack.layer.borderColor = [UIColor whiteColor].CGColor;
        lblBack.userInteractionEnabled = YES;
        [self.contentView addSubview:lblBack];
        
        lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, DEVICE_WIDTH-30, 60)];
        lblDeviceName.numberOfLines = 0;
        [lblDeviceName setBackgroundColor:[UIColor clearColor]];
        lblDeviceName.textColor = UIColor.whiteColor;
        [lblDeviceName setFont:[UIFont fontWithName:CGRegular size:textSizes+3]];
        [lblDeviceName setTextAlignment:NSTextAlignmentLeft];
        lblDeviceName.text = @"";

        swSocket = [[UISwitch alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-150, 15, 44, 44)];
        swSocket.backgroundColor = UIColor.lightGrayColor;
        swSocket.tintColor = [UIColor lightGrayColor];
        swSocket.onTintColor = UIColor.greenColor;
        swSocket.clipsToBounds = true;
        [lblBack addSubview:swSocket];
        /////////viviya 
        btnAlaram = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAlaram.frame = CGRectMake(DEVICE_WIDTH-70, 8.5, 44, 43);
        btnAlaram.backgroundColor = [UIColor clearColor];
        [btnAlaram setImage:[UIImage imageNamed:@"active_alarm_icon.png"] forState:UIControlStateNormal];
        [lblBack addSubview:btnAlaram];
        
        imgSwitch = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 32, 30)];
        imgSwitch.backgroundColor = UIColor.clearColor;
        imgSwitch.clipsToBounds = true;
        [imgSwitch setImage:[UIImage imageNamed:@"sw.png"]];
        [imgSwitch setContentMode:UIViewContentModeScaleAspectFit];
        [lblBack addSubview:imgSwitch];
        
        lblLine = [[UILabel alloc] initWithFrame:CGRectMake(5, 50,  DEVICE_WIDTH-10, 0.5)];
        [lblLine setBackgroundColor:[UIColor lightGrayColor]];
        lblLine.hidden = true;
        [lblBack addSubview:lblLine];
        
        [lblBack addSubview:lblDeviceName];
    }
    return self;
}


@end
