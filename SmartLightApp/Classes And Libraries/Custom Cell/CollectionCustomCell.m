//
//  CollectionCustomCell.m
//  HQ-INC App
//
//  Created by Kalpesh Panchasara on 15/05/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "CollectionCustomCell.h"

@implementation CollectionCustomCell
@synthesize lblName,lblBack;
@synthesize imgViewpProfile,checkMarkImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        imgViewpProfile = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        imgViewpProfile.image = [UIImage imageNamed:@"User.png"];
//        imgViewpProfile.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:imgViewpProfile];
        
        lblBack = [[UILabel alloc ]initWithFrame:CGRectMake(0, self.contentView.frame.size.height - 50, self.contentView.frame.size.width, 50)];
        lblBack.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:lblBack];

        lblName = [[UILabel alloc ]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width-50, 50)];
        lblName.font = [UIFont fontWithName:CGRegular size:25];
        lblName.textColor = UIColor.whiteColor;
        lblName.backgroundColor = [UIColor blackColor];
        lblName.textAlignment = NSTextAlignmentCenter;
//        [lblBack addSubview:lblName];
        
        
        checkMarkImage = [[UIImageView alloc]initWithFrame:CGRectMake(55, 55, 17,17)];
        checkMarkImage.image = [UIImage imageNamed:@"tick.png"];
//        checkMarkImage.contentMode = UIViewContentModeScaleAspectFit;
        checkMarkImage.hidden = true;
        [self.contentView addSubview:checkMarkImage];


        
//        viewpProfileRed = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
//        [self.contentView addSubview:viewpProfileRed];

    }
    return self;
}
@end
