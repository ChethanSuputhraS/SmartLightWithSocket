//
//  SocketCell.m
//  SmartLightApp
//
//  Created by Kalpesh Panchasara on 23/02/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import "SocketCell.h"

@implementation SocketCell
@synthesize lblDeviceName,lblBack,swSocket,imgSwitch,btnAlaram,lblLine,lblSettings,imgArrow,lblLineLower,txtOTA,btnMore,btnSocket;
- (void)awakeFromNib
{
    
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
        lblBack.layer.borderColor = [UIColor lightGrayColor].CGColor;
        lblBack.layer.borderWidth = 0.7;
        lblBack.userInteractionEnabled = YES;
        [self.contentView addSubview:lblBack];
        
        lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, DEVICE_WIDTH-100-60, 60)];
        lblDeviceName.numberOfLines = 0;
        [lblDeviceName setBackgroundColor:[UIColor clearColor]];
        lblDeviceName.textColor = UIColor.whiteColor;
        [lblDeviceName setFont:[UIFont fontWithName:CGRegular size:textSizes+3]];
        [lblDeviceName setTextAlignment:NSTextAlignmentLeft];
        lblDeviceName.text = @"";
        
        
        swSocket = [[UISwitch alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-130, 15, 44, 44)];
        swSocket.backgroundColor = UIColor.clearColor;
        swSocket.clipsToBounds = true;
        swSocket.onTintColor = UIColor.greenColor;
        swSocket.tintColor = UIColor.lightGrayColor;
        swSocket.layer.borderWidth = .8;
        swSocket.layer.borderColor = UIColor.lightGrayColor.CGColor;
        swSocket.layer.cornerRadius = 15;
        [lblBack addSubview:swSocket];
        
        
        btnSocket = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 44, 50)];
        btnSocket.backgroundColor = UIColor.clearColor;
        btnSocket.clipsToBounds = true;
        btnSocket.layer.cornerRadius = 15;
        btnSocket.hidden = true;
        [lblBack addSubview:btnSocket];
        
        
        btnAlaram = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAlaram.frame = CGRectMake(DEVICE_WIDTH-70, 8.5, 44, 43);
        btnAlaram.backgroundColor = [UIColor clearColor];
        [btnAlaram setImage:[UIImage imageNamed:@"active_alarm_icon.png"] forState:UIControlStateNormal];
//        [lblBack addSubview:btnAlaram];
        
        btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
        btnMore.frame = CGRectMake(DEVICE_WIDTH-70, 8.5, 44, 44);
        btnMore.backgroundColor = [UIColor clearColor];
        [btnMore setImage:[UIImage imageNamed:@"more_icon.png"] forState:UIControlStateNormal];
        btnMore.hidden = true;
        [lblBack addSubview:btnMore];
        
        
        imgSwitch = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 32, 30)];
        imgSwitch.backgroundColor = UIColor.clearColor;
        imgSwitch.clipsToBounds = true;
        [imgSwitch setImage:[UIImage imageNamed:@"sw.png"]];
        [imgSwitch setContentMode:UIViewContentModeScaleAspectFit];
        [lblBack addSubview:imgSwitch];
        
        lblSettings = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, DEVICE_WIDTH-120, 60)];
        [lblSettings setBackgroundColor:[UIColor clearColor]];
        lblSettings.textColor = UIColor.whiteColor;
        [lblSettings setFont:[UIFont fontWithName:CGRegular size:textSizes+3]];
        [lblSettings setTextAlignment:NSTextAlignmentLeft];
        lblSettings.hidden = true;
        [self.contentView addSubview:lblSettings];
        
        imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-50, 15, 30, 30)];
        [imgArrow setImage:[UIImage imageNamed:@"arrowRight.png"]];
        [imgArrow setContentMode:UIViewContentModeScaleAspectFit];
        imgArrow.hidden = true;
        [self.contentView addSubview:imgArrow];
        
        lblLine = [[UILabel alloc] initWithFrame:CGRectMake(5, 50,  DEVICE_WIDTH-10, 0.5)];
        [lblLine setBackgroundColor:[UIColor lightGrayColor]];
        lblLine.hidden = true;
        [lblBack addSubview:lblLine];
        
        txtOTA = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
        txtOTA.hidden = true;
        txtOTA.placeholder = @"Vithamas";
        [self.contentView addSubview:txtOTA];
        
        
        [lblBack addSubview:lblDeviceName];
    }
    return self;
}


@end
