//
//  PatternCell.h
//  SmartLightApp
//
//  Created by stuart watts on 07/11/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PatternCell : UITableViewCell

@property (nonatomic, strong) UIImageView *parallaxImage;
@property (nonatomic, strong) UILabel * lblLine;
@property (nonatomic, strong) UILabel * lblName;
@property (nonatomic, strong) UILabel * lblPatternHighlighter;

@end
