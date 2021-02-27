//
//  SwitchesCell.m
//  VithamasSocket
//
//  Created by Vithamas Technologies on 30/11/20.
//  Copyright © 2020 Chethan. All rights reserved.
//

#import "SwitchesCell.h"

@implementation SwitchesCell
@synthesize lblBack,btnDay,btnon,btnoff,lblAlarms,lblLine,btnTime,lblWifiSetup,btnDelete,btn0,btn1,btn2,btn3,btn4,btn5,btn6,btn7,lbldays,lblON,lblOFF,lblLineParall,lblONtime,lblOFFtime,btnONTimer,btnOFFTimer;
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
    {
        
        self.backgroundColor = [UIColor clearColor];
        
        int aa = 100;
        float  btnWidth = DEVICE_WIDTH/3;
        
        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(5, 0,DEVICE_WIDTH-10,200)];
        lblBack.backgroundColor = [UIColor blackColor];
        lblBack.alpha = 0.6;
        lblBack.layer.cornerRadius = 10;
        lblBack.layer.masksToBounds = YES;
        lblBack.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.contentView addSubview:lblBack];
        
        lblLine = [[UILabel alloc] initWithFrame:CGRectMake(10, 240,DEVICE_WIDTH-20,.6)];
        lblLine.backgroundColor = [UIColor whiteColor];
//        lblLine.alpha = 0.7;
        lblLine.layer.cornerRadius = 10;
        lblLine.layer.masksToBounds = YES;
        lblLine.layer.borderColor = [UIColor whiteColor].CGColor;
//        [self.contentView addSubview:lblLine];
        
        lblLineParall = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2, 130,.8,60)];
        lblLineParall.backgroundColor = [UIColor whiteColor];
//        lblLine.alpha = 0.7;
        lblLineParall.layer.cornerRadius = 10;
        lblLineParall.layer.masksToBounds = YES;
        lblLineParall.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.contentView addSubview:lblLineParall];
        
        lblAlarms = [[UILabel alloc] initWithFrame:CGRectMake(10, 0,btnWidth,30)];
        lblAlarms.backgroundColor = [UIColor clearColor];
        lblAlarms.textAlignment = NSTextAlignmentLeft;
        lblAlarms.layer.masksToBounds = YES;
        lblAlarms.textColor = [UIColor whiteColor];
        lblAlarms.font = [UIFont fontWithName:CGRegular size:textSizes+2];
        [self.contentView addSubview:lblAlarms];
        
        
        lbldays = [[UILabel alloc] initWithFrame:CGRectMake(10, 30,btnWidth,30)];
        lbldays.backgroundColor = [UIColor clearColor];
        lbldays.textAlignment = NSTextAlignmentLeft;
        lbldays.layer.masksToBounds = YES;
        lbldays.textColor = [UIColor whiteColor];
        lbldays.text = @"Days";
        [self.contentView addSubview:lbldays];
        
        
        lblON = [[UILabel alloc] initWithFrame:CGRectMake(0, 110,DEVICE_WIDTH/2,30)];
        lblON.backgroundColor = [UIColor clearColor];
        lblON.textAlignment = NSTextAlignmentCenter;
        lblON.layer.masksToBounds = YES;
        lblON.textColor = [UIColor whiteColor];
        lblON.text = @"ON Time";

        [self.contentView addSubview:lblON];
        
        lblOFF = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2, 110,DEVICE_WIDTH/2,30)];
        lblOFF.backgroundColor = [UIColor clearColor];
        lblOFF.textAlignment = NSTextAlignmentCenter;
        lblOFF.layer.masksToBounds = YES;
        lblOFF.textColor = [UIColor whiteColor];
        lblOFF.text = @"OFF Time";

        [self.contentView addSubview:lblOFF];
        
        lblONtime = [[UILabel alloc] initWithFrame:CGRectMake(0, 130,DEVICE_WIDTH/2,60)];
        lblONtime.backgroundColor = [UIColor clearColor];
        lblONtime.textAlignment = NSTextAlignmentCenter;
        lblONtime.layer.masksToBounds = YES;
        lblONtime.textColor = [UIColor whiteColor];
        [lblONtime setFont:[UIFont fontWithName:CGRegular size:textSizes+15]];
        [self.contentView addSubview:lblONtime];
        
        lblOFFtime = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2, 130,DEVICE_WIDTH/2,50)];
        lblOFFtime.backgroundColor = [UIColor clearColor];
        lblOFFtime.textAlignment = NSTextAlignmentCenter;
        lblOFFtime.layer.masksToBounds = YES;
        lblOFFtime.textColor = [UIColor whiteColor];
        [lblOFFtime setFont:[UIFont fontWithName:CGRegular size:textSizes+15]];
        [self.contentView addSubview:lblOFFtime];
        
        btnONTimer = [[UIButton alloc] initWithFrame:CGRectMake(0, 130,DEVICE_WIDTH/2,60)];
        [btnONTimer setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:btnONTimer];
        
        btnOFFTimer = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2, 130,DEVICE_WIDTH/2,60)];
        [btnOFFTimer setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:btnOFFTimer];
        
        
        btnDelete = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-55, 10, 50, 44)];
        [btnDelete setBackgroundColor:[UIColor clearColor]];
        btnDelete.backgroundColor = UIColor.clearColor;
        btnDelete.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes];
        btnDelete.titleLabel.textAlignment = NSTextAlignmentRight;
//        [btnDelete setTitle:@" Delete" forState:UIControlStateNormal];
        [btnDelete setImage:[UIImage imageNamed:@"delete_icon.png"] forState:UIControlStateNormal];
//        btnDelete.contentVerticalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.contentView addSubview:btnDelete];
        
        btnDay = [[UIButton alloc] initWithFrame:CGRectMake(15, 50, btnWidth-10, 50)];
        [btnDay setBackgroundColor:[UIColor clearColor]];
        btnDay.backgroundColor = UIColor.clearColor;
        btnDay.titleLabel.numberOfLines = 0;
        btnDay.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes];
        btnDay.titleLabel.textAlignment = NSTextAlignmentLeft;
        [btnDay setTitle:@"Select \n Day" forState:UIControlStateNormal];
        btnDay.layer.borderWidth = 0.6;
        btnDay.layer.borderColor = UIColor.lightGrayColor.CGColor;
        btnDay.layer.cornerRadius = 6;
//        [self.contentView addSubview:btnDay];
        
        btnon = [[UIButton alloc] initWithFrame:CGRectMake(aa+10, 10, btnWidth, 50)];
        [btnon setBackgroundColor:[UIColor clearColor]];
        btnon.backgroundColor = UIColor.clearColor;
        btnon.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+2];
        btnon.titleLabel.textAlignment = NSTextAlignmentLeft;
        [btnon setTitle:@" ON" forState:UIControlStateNormal];
        [btnon setImage:[UIImage imageNamed:@"RadioON.png"] forState:UIControlStateNormal];
        btnon.contentVerticalAlignment = UIControlContentHorizontalAlignmentLeft;
//        [self.contentView addSubview:btnon];
        
        
        btnoff = [[UIButton alloc] initWithFrame:CGRectMake(btnWidth*2, 10, btnWidth, 50)];
        [btnoff setBackgroundColor:[UIColor clearColor]];
        btnoff.backgroundColor = UIColor.clearColor;
        btnoff.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+2];
        btnon.titleLabel.textAlignment = NSTextAlignmentRight;
        [btnoff setTitle:@" OFF" forState:UIControlStateNormal];
        [btnoff setImage:[UIImage imageNamed:@"RadioOff.png"] forState:UIControlStateNormal];
        btnoff.contentVerticalAlignment = UIControlContentHorizontalAlignmentLeft;
//        [self.contentView addSubview:btnoff];
        
//        lbltime = [[UILabel alloc] initWithFrame:CGRectMake(0, 130,DEVICE_WIDTH/2-5, 50)];
//        lbltime.numberOfLines = 0;
//        [lbltime setBackgroundColor:[UIColor clearColor]];
//        lbltime.textColor = UIColor.whiteColor;
//        [lbltime setFont:[UIFont fontWithName:CGRegular size:textSizes+17]];
//        [lbltime setTextAlignment:NSTextAlignmentCenter];
////        lbltime.text = @"Device name";
//        [self.contentView addSubview:lbltime];
        
  
        
        lblWifiSetup = [[UILabel alloc] initWithFrame:CGRectMake(0, 10,btnWidth,30)];
        lblWifiSetup.backgroundColor = [UIColor clearColor];
        lblWifiSetup.textAlignment = NSTextAlignmentCenter;
        lblWifiSetup.layer.masksToBounds = YES;
        lblWifiSetup.textColor = [UIColor whiteColor];
        [self.contentView addSubview:lblWifiSetup];
        
        UIView * dayView = [[UIView alloc] init];
        dayView.frame = CGRectMake(0, 60, DEVICE_WIDTH, 60);
        dayView.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:dayView];
        
        int wh = DEVICE_WIDTH/7;

        for (int i=0; i<7; i++)
        {
            if (i==0)
            {
                btn0  = [UIButton buttonWithType:UIButtonTypeCustom];
                btn0.tag = i;
                btn0.frame = CGRectMake(i*wh+2, 0, wh-2, wh);
                btn0.layer.cornerRadius = wh/2;
                [btn0 setTitle:@"S" forState:UIControlStateNormal];
//                [self setButtonContent:btn0 withTag:i];
                [dayView addSubview:btn0];
            }
            else if (i==1)
            {
                btn1  = [UIButton buttonWithType:UIButtonTypeCustom];
                btn1.tag = i;
                btn1.frame = CGRectMake(i*wh+2, 0, wh-2, wh);
                btn1.layer.cornerRadius = wh/2;
                [btn1 setTitle:@"M" forState:UIControlStateNormal];
//                [self setButtonContent:btn1 withTag:i];
                [dayView addSubview:btn1];
            }
            else if (i==2)
            {
                btn2  = [UIButton buttonWithType:UIButtonTypeCustom];
                btn2.tag = i;
                btn2.frame = CGRectMake(i*wh+2, 0, wh-2, wh);
                btn2.layer.cornerRadius = wh/2;
                [btn2 setTitle:@"T" forState:UIControlStateNormal];
//                [self setButtonContent:btn2 withTag:i];
                [dayView addSubview:btn2];
            }
            else if (i==3)
            {
                btn3  = [UIButton buttonWithType:UIButtonTypeCustom];
                btn3.tag = i;
                btn3.frame = CGRectMake(i*wh+2, 0, wh-2, wh);
                btn3.layer.cornerRadius = wh/2;
                [btn3 setTitle:@"W" forState:UIControlStateNormal];
//                [self setButtonContent:btn3 withTag:i];
                [dayView addSubview:btn3];
            }
            else if (i==4)
            {
                btn4  = [UIButton buttonWithType:UIButtonTypeCustom];
                btn4.tag = i;
                btn4.frame = CGRectMake(i*wh+2, 0, wh-2, wh);
                btn4.layer.cornerRadius = wh/2;
                [btn4 setTitle:@"T" forState:UIControlStateNormal];
//                [self setButtonContent:btn4 withTag:i];
                [dayView addSubview:btn4];
            }
            else if (i==5)
            {
                btn5  = [UIButton buttonWithType:UIButtonTypeCustom];
                btn5.tag = i;
                btn5.frame = CGRectMake(i*wh+2, 0, wh-2, wh);
                btn5.layer.cornerRadius = wh/2;
                [btn5 setTitle:@"F" forState:UIControlStateNormal];
//                [self setButtonContent:btn5 withTag:i];
                [dayView addSubview:btn5];
            }
            else if (i==6)
            {
                btn6  = [UIButton buttonWithType:UIButtonTypeCustom];
                btn6.tag = i;
                btn6.frame = CGRectMake(i*wh+2, 0, wh-2, wh);
                btn6.layer.cornerRadius = wh/2;
                [btn6 setTitle:@"S" forState:UIControlStateNormal];
//                [self setButtonContent:btn6 withTag:i];
                [dayView addSubview:btn6];
            }
        }
        
//        NSLog(@"=========>%@",btn0);
//        NSLog(@"=========>%@",btn1);
//        NSLog(@"=========>%@",btn2);
//        NSLog(@"=========>%@",btn3);
//        NSLog(@"=========>%@",btn4);
//        NSLog(@"=========>%@",btn5);
//        NSLog(@"=========>%@",btn6);

        
    }

    return self;
}

@end
