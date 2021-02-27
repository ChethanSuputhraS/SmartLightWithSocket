//
//  HistoryLogsDetailsCell.m
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 7/21/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import "HistoryLogsDetailsCell.h"

@implementation HistoryLogsDetailsCell

@synthesize lblMessage;
@synthesize lblLine;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(15, 2, DEVICE_WIDTH-20, 46)];
        lblMessage.numberOfLines = 5;
        [lblMessage setBackgroundColor:[UIColor clearColor]];
        [lblMessage setTextColor:[UIColor darkGrayColor]];
        [lblMessage setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightRegular]];
        [lblMessage setTextAlignment:NSTextAlignmentLeft];
        
        //        lblExitTime = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, DEVICE_WIDTH-30, 20)];
        //        [lblExitTime setBackgroundColor:[UIColor clearColor]];
        //        [lblExitTime setTextColor:[UIColor darkGrayColor]];
        //        [lblExitTime setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightRegular]];
        //        [lblExitTime setTextAlignment:NSTextAlignmentLeft];
        
        lblLine = [[UILabel alloc] initWithFrame:CGRectMake(15, 49.5, DEVICE_WIDTH-15, 0.5)];
        [lblLine setBackgroundColor:[UIColor darkGrayColor]];
    }
    
    [self.contentView addSubview:lblMessage];
    //    [self.contentView addSubview:lblExitTime];
        [self.contentView addSubview:lblLine];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
