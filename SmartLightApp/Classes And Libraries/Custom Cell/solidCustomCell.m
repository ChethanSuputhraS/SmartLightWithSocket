//
//  solidCustomCell.m
//  SmartLightApp
//
//  Created by stuart watts on 26/09/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "solidCustomCell.h"

@implementation solidCustomCell
@synthesize lblColor,imgTop, imgCheck;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
         lblColor = [[UILabel alloc] init];
        lblColor.frame = CGRectMake(5, 5, self.frame.size.width-10, self.frame.size.height-10);
        [self.contentView addSubview:lblColor];

         imgTop = [[UIImageView alloc] init];
        imgTop.frame = CGRectMake(5, 5, self.frame.size.width-10, self.frame.size.height-10);
        imgTop.image = [UIImage imageNamed:@"gradeimg.png"];
        [self.contentView addSubview:imgTop];
        
        imgCheck = [[UIImageView alloc] init];
        CGRect viewRect = self.contentView.frame;
        imgCheck.frame = CGRectMake((viewRect.size.width-48)/2, (viewRect.size.height-48)/2, 48, 48);
        imgCheck.image = [UIImage imageNamed:@"solidCheck.png"];
        imgCheck.hidden = YES;
        [self.contentView addSubview:imgCheck];

    }
    return self;
}
@end
