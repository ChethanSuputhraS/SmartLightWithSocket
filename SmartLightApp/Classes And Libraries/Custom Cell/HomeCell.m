//
//  HomeCell.m
//  HoldItWrite
//
//  Created by Kalpesh Panchasara on 12/07/20.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import "HomeCell.h"

@implementation HomeCell
@synthesize lblDeviceName,lblConnect,lblAddress,lblBack,swSocket,imgSwitch,btnAlaram,lblLine;
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
        lblBack.backgroundColor = [UIColor blackColor];
        lblBack.alpha = 0.7;
        lblBack.layer.cornerRadius = 10;
        lblBack.layer.masksToBounds = YES;
        lblBack.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.contentView addSubview:lblBack];
        
        lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, DEVICE_WIDTH-36, 35)];
        lblDeviceName.numberOfLines = 0;
        [lblDeviceName setBackgroundColor:[UIColor clearColor]];
        lblDeviceName.textColor = UIColor.whiteColor;
        [lblDeviceName setFont:[UIFont fontWithName:CGRegular size:textSizes+3]];
        [lblDeviceName setTextAlignment:NSTextAlignmentLeft];
        lblDeviceName.text = @"Device name";
        
        
        lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(18, 30,  DEVICE_WIDTH-36, 25)];
        lblAddress.numberOfLines = 2;
        [lblAddress setBackgroundColor:[UIColor clearColor]];
        [lblAddress setTextColor:[UIColor lightGrayColor]];
        [lblAddress setFont:[UIFont fontWithName:CGRegular size:textSizes]];
        [lblAddress setTextAlignment:NSTextAlignmentLeft];
        lblAddress.text = @"Ble Address";
        
        lblConnect = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-104, 0, DEVICE_WIDTH-70, 60)];
        lblConnect.numberOfLines = 2;
        [lblConnect setBackgroundColor:[UIColor clearColor]];
        [lblConnect setTextColor:[UIColor whiteColor]];
        [lblConnect setFont:[UIFont fontWithName:CGRegular size:textSizes]];
        [lblConnect setTextAlignment:NSTextAlignmentLeft];
        lblConnect.text = @"Connect";
        
           swSocket = [[UISwitch alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-150, 10, 44, 44)];
           swSocket.backgroundColor = UIColor.clearColor;
           swSocket.clipsToBounds = true;
           swSocket.hidden = true;
           [self.contentView addSubview:swSocket];
        
        btnAlaram = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAlaram.frame = CGRectMake(DEVICE_WIDTH-70, 5, 44, 43);
        btnAlaram.backgroundColor = [UIColor clearColor];
        [btnAlaram setImage:[UIImage imageNamed:@"active_alarm_icon.png"] forState:UIControlStateNormal];
        btnAlaram.hidden = true;
        [self.contentView addSubview:btnAlaram];
        
        imgSwitch = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 32, 30)];
        imgSwitch.backgroundColor = UIColor.clearColor;
        imgSwitch.clipsToBounds = true;
        imgSwitch.hidden = true;
        [imgSwitch setImage:[UIImage imageNamed:@"sw.png"]];

        [imgSwitch setContentMode:UIViewContentModeScaleAspectFit];

        [self.contentView addSubview:imgSwitch];
        
        lblLine = [[UILabel alloc] initWithFrame:CGRectMake(5, 50,  DEVICE_WIDTH-10, 0.5)];
        [lblLine setBackgroundColor:[UIColor lightGrayColor]];
        lblLine.hidden = true;
        [self.contentView addSubview:lblLine];
        

        [self.contentView addSubview:lblDeviceName];
        [self.contentView addSubview:lblAddress];
        [self.contentView addSubview:lblConnect];
    }
    return self;
}

@end
