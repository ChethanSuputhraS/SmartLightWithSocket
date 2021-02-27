//
//  KPWhiteColorImgView.m
//  SmartLightApp
//
//  Created by stuart watts on 15/06/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "KPWhiteColorImgView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/CoreAnimation.h>
#import "DeviceDetailVC.h"
#import "UIView+colorOfPoint.h"

static CGFloat ISColorWheel_PointDistance (CGPoint p1, CGPoint p2)
{
    return sqrtf((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}


@interface ISColorKnobView1 : UIView
@property(nonatomic, strong)UIColor* fillColor;
@end

@implementation ISColorKnobView1
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat borderWidth = 3.0f;
    CGRect borderFrame = CGRectInset(self.bounds, borderWidth / 2.0, borderWidth / 2.0);
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextAddEllipseInRect(ctx, borderFrame);
    CGContextFillPath(ctx);
    CGContextSetLineWidth(ctx, borderWidth);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextAddEllipseInRect(ctx, borderFrame);
    CGContextStrokePath(ctx);
}
@end
@implementation KPWhiteColorImgView
{
    CGPoint _touchPoint;
    CGFloat _radius;
}
@synthesize lastColor;
@synthesize pickedColorDelegate;
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.backgroundColor = [UIColor clearColor];
        
        _knobSize = CGSizeMake(24, 24);
        _touchPoint = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        
        self.borderColor = [UIColor whiteColor];
        self.borderWidth = 3.0;
        self.knobView = [[ISColorKnobView1 alloc] init];
        self.knobView.backgroundColor = [UIColor clearColor];
        self.knobView.layer.masksToBounds = YES;
        self.knobView.layer.cornerRadius = 12;
        self.knobView.layer.borderWidth = 3.0;
        self.knobView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    _radius = (MIN(self.bounds.size.width, self.bounds.size.height) / 2.0) - MAX(0.0f, 8);
}
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    CGRect knobWidth = self.knobView.frame;
    knobWidth.size.width = 24;
    knobWidth.size.height = 24;
    self.knobView.frame = knobWidth;
    self.knobView.layer.cornerRadius = 12;
    self.knobView.layer.borderWidth = 3.0;
    
    if (self.hidden==YES)
    {
        [[self nextResponder] touchesEnded:touches withEvent:event];
        return;
    }
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self]; //where image was tapped
    
    self.lastColor = [self colorAtPixel:point];
    if (self.currentColorBlock)
    {
        self.currentColorBlock(self.lastColor);
    }
    self.lastColor = [self colorOfPoint:point];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setTouchPoint:[[touches anyObject] locationInView:self]];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setTouchPoint:[[touches anyObject] locationInView:self]];
    
    CGRect knobWidth = self.knobView.frame;
    knobWidth.size.width = 24;
    knobWidth.size.height = 24;
    self.knobView.frame = knobWidth;
    self.knobView.layer.cornerRadius = 12;
    self.knobView.layer.borderWidth = 5.0;
    self.knobView.layer.borderColor = [UIColor whiteColor].CGColor;

    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self]; //where image was tapped
    
    if (!CGRectContainsPoint((CGRect) {.origin = CGPointZero, .size = self.frame.size}, point))
    {
        return;
    }
    UIColor * tmpColor = [self colorAtPixel:point];
    if (self.currentColorBlock)
    {
        self.currentColorBlock(tmpColor);
    }
}
- (void)updateKnob
{
    if (!_knobView)
    {
        return;
    }
    _knobView.bounds = CGRectMake(0, 0, _knobSize.width, _knobSize.height);
    _knobView.center = _touchPoint;
}
- (void)setKnobView:(UIView *)knobView
{
    if (_knobView)
    {
        [_knobView removeFromSuperview];
    }
    _knobView = knobView;
    if (_knobView)
    {
        self.knobView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self addSubview:_knobView];
    }
    [self updateKnob];
}
- (void)setTouchPoint:(CGPoint)point
{
    if (_isSquareImage)
    {
        _touchPoint = point;
        if (!CGRectContainsPoint((CGRect) {.origin = CGPointZero, .size = self.frame.size}, point))
        {
            return;
        }
        [self updateKnob];
    }
    else
    {
        CGFloat width = self.bounds.size.width;
        CGFloat height = self.bounds.size.height;
        CGPoint center = CGPointMake(width / 2.0, height / 2.0);
        if (ISColorWheel_PointDistance(center, point) < _radius)
        {
            _touchPoint = point;
            [self updateKnob];
        }
        else
        {
            CGPoint vec = CGPointMake(point.x - center.x, point.y - center.y);
            CGFloat extents = sqrtf((vec.x * vec.x) + (vec.y * vec.y));
            vec.x /= extents;
            vec.y /= extents;
            _knobView.center = CGPointMake(center.x + vec.x * _radius, center.y + vec.y * _radius);
        }
    }
}
- (UIColor *)colorAtPixel:(CGPoint)point {
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.image.size.width, self.image.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.image.CGImage;
    NSUInteger width = self.image.size.width;
    NSUInteger height = self.image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast |     kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    //    NSLog(@"%f***%f***%f***%f",red,green,blue,alpha);
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)setImage:(UIImage *)image
{
    UIImage *temp = [self imageForResizeWithImage:image resize:CGSizeMake(self.frame.size.width, self.frame.size.width)];
    [super setImage:temp];
}

- (UIImage *)imageForResizeWithImage:(UIImage *)picture resize:(CGSize)resize {
    CGSize imageSize = resize; //CGSizeMake(25, 25)
    UIGraphicsBeginImageContextWithOptions(imageSize, NO,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    [picture drawInRect:imageRect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

