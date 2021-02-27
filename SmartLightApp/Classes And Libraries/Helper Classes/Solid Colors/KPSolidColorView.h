//
//  KPSolidColorView.h
//  SmartLightApp
//
//  Created by stuart watts on 30/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KPSolidColorView;
@protocol KPSolidColorDelegate <NSObject>

-(void)pickSolidColor:(KPSolidColorView *)pickerView didSelectColor:(UIColor *)color;
-(void)selectedIndexforFavDelete:(NSMutableDictionary *)dataDict;


@end

@interface KPSolidColorView : UIView  <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    __weak id<KPSolidColorDelegate> delegate;
     NSArray *colors;
    UIImageView * btnCheckMark;
    NSIndexPath * selectedIndexPath;
}
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, weak) id<KPSolidColorDelegate> delegate;
@property (nonatomic, strong, readonly) UICollectionView * collectionView;
@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, assign) CGFloat cellPaddings;
@property (nonatomic, assign) BOOL highlightSelection;
@property (nonatomic, strong) UIColor *selectionBorderColor;
@property (nonatomic, strong) NSMutableArray * favColors;
@property (nonatomic, strong) NSArray * rgbwColor;


-(void)setColors:(NSArray *)colors; 
@end
