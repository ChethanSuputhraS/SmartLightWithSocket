//
//  UIView+colorOfPoint.m
//  SmartLightApp
//
//  Created by stuart watts on 15/06/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "UIView+colorOfPoint.h"
#import <QuartzCore/QuartzCore.h>
@implementation UIView (colorOfPoint)

-(UIColor *) colorOfPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel,
                                                 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0
                                     green:pixel[1]/255.0 blue:pixel[2]/255.0
                                     alpha:pixel[3]/255.0];
    return color;
}

@end
