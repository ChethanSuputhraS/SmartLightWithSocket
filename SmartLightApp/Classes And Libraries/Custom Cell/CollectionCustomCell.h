//
//  CollectionCustomCell.h
//  HQ-INC App
//
//  Created by Kalpesh Panchasara on 15/05/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollectionCustomCell : UICollectionViewCell

@property(nonatomic,strong) UILabel * lblName,*lblBack;
@property(nonatomic,strong)UIImageView *imgViewpProfile;
@property(nonatomic,strong)UIImageView *checkMarkImage;


@end

NS_ASSUME_NONNULL_END
