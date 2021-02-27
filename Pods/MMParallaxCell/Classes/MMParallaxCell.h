//
//  MMParallaxCell.h
//  MMParallaxCell
//
//  Created by Ralph Li on 3/27/15.
//  Copyright (c) 2015 LJC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMParallaxCell : UITableViewCell

@property (nonatomic, strong) UIImageView *parallaxImage;
@property (nonatomic, strong) UILabel * lblLine;
@property (nonatomic, strong) UILabel * lblName;
@property (nonatomic, strong) UILabel * lblPatternHighlighter;


@property (nonatomic, assign) CGFloat parallaxRatio; //ratio of cell height, should between [1.0f, 2.0f], default is 1.5f;

@end
