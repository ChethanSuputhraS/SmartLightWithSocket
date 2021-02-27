//
//  PatternCell.m
//  SmartLightApp
//
//  Created by stuart watts on 07/11/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "PatternCell.h"
#define DEVICE_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define DEVICE_WIDTH [[UIScreen mainScreen] bounds].size.width

@implementation PatternCell
@synthesize parallaxImage,lblLine,lblName,lblPatternHighlighter;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
        
        parallaxImage = [[UIImageView alloc] init];
        parallaxImage.frame = CGRectMake(0, 0, DEVICE_WIDTH, 150*approaxSize);
        [self.contentView addSubview:parallaxImage];
        parallaxImage.backgroundColor = [UIColor redColor];
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 150*approaxSize)];
        [lblName setBackgroundColor:[UIColor clearColor]];
        [lblName setTextColor:[UIColor whiteColor]];
        [lblName setFont:[UIFont fontWithName:CGRegular size:textSizes]];
        [self.contentView addSubview:lblName];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected)
    {
        lblName.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        lblName.textColor = UIColor.blackColor;
    }
    else
    {
        lblName.textColor = UIColor.whiteColor;
        lblName.backgroundColor = UIColor.clearColor;
    }
}

@end
