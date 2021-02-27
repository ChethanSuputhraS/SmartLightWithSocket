//
//  KPWhiteColorImgView.h
//  SmartLightApp
//
//  Created by stuart watts on 15/06/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPWhiteColorImgView : UIImageView
{
    UIColor* lastColor;
    id pickedColorDelegate;
    
}
@property (nonatomic, retain) UIColor* lastColor;
@property (nonatomic, retain) id pickedColorDelegate;
@property(nonatomic, strong)UIView* knobView;
@property(nonatomic, assign)CGSize knobSize;
@property(nonatomic, strong)UIColor* borderColor;
@property(nonatomic, assign)CGFloat borderWidth;
@property(nonatomic, strong)UIColor* currentColor;
@property(nonatomic, strong)UIColor* fillColor;
@property (copy, nonatomic) void(^currentColorBlock)(UIColor *color);

@property BOOL isSquareImage;

//- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef)inImage;

@end

