//
//  KPCollectionReusableView.m
//  SmartLightApp
//
//  Created by stuart watts on 26/09/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "KPCollectionReusableView.h"

@implementation KPCollectionReusableView
@synthesize lblHeader,btnAdd;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, DEVICE_WIDTH, 50)];
        lblHeader.font = [UIFont fontWithName:CGRegular size:textSizes+1];
        lblHeader.textColor = [UIColor whiteColor];
        [self addSubview:lblHeader];
        
        btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAdd.frame = CGRectMake(DEVICE_WIDTH-60, 0, 50, 50);
        [btnAdd setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
        [self addSubview:btnAdd];
    }
    return self;
}
@end
