//
//  AlarmColorSelectVC.m
//  SmartLightApp
//
//  Created by stuart watts on 01/06/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "AlarmColorSelectVC.h"
#import "KPWhiteColorImgView.h"

@interface AlarmColorSelectVC ()
{
    KPWhiteColorImgView * imgColorOptionView;
    UISlider *brightnessSliderColorView;
    UILabel *lblThumbTint;
    CGFloat intBrightnessValue;
}
@end

@implementation AlarmColorSelectVC
@synthesize isFromAlarm, isFromEdit;
- (void)viewDidLoad
{
    self.view.backgroundColor = UIColor.blackColor;
    intBrightnessValue = 1.0;

    
    [self setNavigationViewFrames];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    
    if (isFromEdit == NO)
    {
        strHexAlarmColor = [NSString stringWithFormat:@"#%02lX%02lX%02lX",
                            lroundf(1 * 255),
                            lroundf(1 * 255),
                            lroundf(1 * 255)];
    }
    
    
    
    headerhHeight = 64;
    if (IS_IPHONE_X)
    {
        headerhHeight = 88;
    }
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, headerhHeight)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, headerhHeight)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.5;
    [viewHeader addSubview:lblBack];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Set Color for Alarm"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];

    if (isFromAlarm)
    {
        [lblTitle setText:@"Alarm Color"];
    }
    else
    {
        [lblTitle setText:@"Favourite Color"];
        [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    }
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 70, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];
    
    UIButton * btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSave.frame = CGRectMake(DEVICE_WIDTH-60, 20, 60, 44);
    btnSave.layer.masksToBounds = YES;
    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnSave.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    [btnSave.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [btnSave addTarget:self action:@selector(btnSaveClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnSave];
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        btnSave.frame = CGRectMake(DEVICE_WIDTH-60, 40, 60, 44);

    }
    
    UILabel * lblOffBack = [[UILabel alloc] init];
    lblOffBack.backgroundColor = [UIColor blackColor];
    lblOffBack.alpha = 0.5;
    lblOffBack.frame =CGRectMake(0, headerhHeight+5, DEVICE_WIDTH, 40);
    [self.view addSubview:lblOffBack];
    
    UILabel * lblInfo = [[UILabel alloc] init];
    lblInfo.frame = CGRectMake(10, headerhHeight+0, DEVICE_WIDTH, 50);
    lblInfo.text = @"Selected color :";
    lblInfo.font = [UIFont fontWithName:CGRegular size:textSizes];
    lblInfo.textColor = [UIColor whiteColor];
    lblInfo.userInteractionEnabled = YES;
    [self.view addSubview:lblInfo];
    
    lblSelecColor = [[UILabel alloc] init];
    lblSelecColor.backgroundColor = [UIColor whiteColor];
    lblSelecColor.frame = CGRectMake(DEVICE_WIDTH-60, 10, 30, 30);
    lblSelecColor.layer.masksToBounds = YES;
    lblSelecColor.layer.cornerRadius = 15;
    lblSelecColor.layer.borderColor = [UIColor whiteColor].CGColor;
    lblSelecColor.layer.borderWidth = 1.0;
    [lblInfo addSubview:lblSelecColor];
    
    if (isFromEdit)
    {
        UIColor * rgbColor = [self colorWithHexString:strHexAlarmColor];
        lblSelecColor.backgroundColor = rgbColor;
    }
    [self setColorView:headerhHeight+50];
}
-(void)setColorView:(int)yAbove
{
   
    colorSquareView = [[UIView alloc] init];
    colorSquareView.frame = CGRectMake(0, yAbove, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove);
    colorSquareView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:colorSquareView];
  
     /*
    colorPickerView = [[HRColorPickerView alloc] init];
    colorPickerView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove);
    colorPickerView.color = [UIColor redColor];
    [colorPickerView addTarget:self
                        action:@selector(colorDidChange:)
              forControlEvents:UIControlEventValueChanged];
    [colorSquareView addSubview:colorPickerView];*/
    
    imgColorOptionView = [[KPWhiteColorImgView alloc] initWithFrame:CGRectMake(0,0, DEVICE_WIDTH,  DEVICE_HEIGHT-yAbove-80)];
    imgColorOptionView.image = [UIImage imageNamed:@"ic_wheel_two.png"];
    imgColorOptionView.contentMode = UIViewContentModeScaleAspectFit;
    imgColorOptionView.pickedColorDelegate = self;
    imgColorOptionView.backgroundColor = [UIColor clearColor];
    imgColorOptionView.layer.masksToBounds=YES;
    imgColorOptionView.userInteractionEnabled = YES;
    //    imgColorOptionView.layer.cornerRadius = DEVICE_WIDTH/2;
    imgColorOptionView.layer.masksToBounds = YES;
    [colorSquareView addSubview:imgColorOptionView];
    
    
    
    brightnessSliderColorView = [[UISlider alloc]init];
    brightnessSliderColorView.frame = CGRectMake(20,colorSquareView.frame.size.height-40,DEVICE_WIDTH-50, 40);
    brightnessSliderColorView.backgroundColor = UIColor.clearColor;
    brightnessSliderColorView.minimumValue = 0;
    brightnessSliderColorView.maximumValue = 100;
    brightnessSliderColorView.value = 100;
    brightnessSliderColorView.continuous = YES;
    brightnessSliderColorView.minimumTrackTintColor = UIColor.whiteColor;
    brightnessSliderColorView.maximumTrackTintColor = UIColor.lightGrayColor;
    brightnessSliderColorView.thumbTintColor = global_brown_color;
    [brightnessSliderColorView addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
    [colorSquareView addSubview:brightnessSliderColorView];
    
 
    UIImageView * imgFullBrightness = [[UIImageView alloc]init];
    imgFullBrightness.frame = CGRectMake(DEVICE_WIDTH-25,colorSquareView.frame.size.height-30 ,20 ,20 );
    imgFullBrightness.image = [UIImage imageNamed:@"fullBright.png"];
    [colorSquareView addSubview:imgFullBrightness];
    
    
    UIImageView * imgLowBrightness = [[UIImageView alloc]init];
    imgLowBrightness.frame = CGRectMake(5,colorSquareView.frame.size.height-25 ,10 ,10 );
    imgLowBrightness.image = [UIImage imageNamed:@"lowBright.png"];
    [colorSquareView addSubview:imgLowBrightness];
    
    lblThumbTint = [[UILabel alloc]init];
    lblThumbTint.frame = CGRectMake(20, colorSquareView.frame.size.height-40-20, 35, 30);
    lblThumbTint.backgroundColor = UIColor.clearColor;
    lblThumbTint.textAlignment = NSTextAlignmentCenter;
    lblThumbTint.font = [UIFont fontWithName:CGRegular size:textSizes-3];
    // lblThumbTint.text = [NSString stringWithFormat:@"%d",brightnessSliderColorView.value];
    lblThumbTint.textColor = UIColor.whiteColor;
    // [colorSquareView addSubview:lblThumbTint];
    [[brightnessSliderColorView superview]addSubview:lblThumbTint];
    if (IS_IPHONE_X)
    {
        colorSquareView.frame = CGRectMake(0, yAbove, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove-45);
//        colorPickerView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-yAbove-45);
        imgColorOptionView.frame = CGRectMake(0,0,DEVICE_WIDTH,DEVICE_HEIGHT-yAbove-45);
        brightnessSliderColorView.frame = CGRectMake(20,colorSquareView.frame.size.height-40-44,DEVICE_WIDTH-50, 40);
        lblThumbTint.font = [UIFont fontWithName:CGRegular size:textSizes-4];
        imgLowBrightness.frame = CGRectMake(5,colorSquareView.frame.size.height-25-44 ,10 ,10 );
        imgFullBrightness.frame = CGRectMake(DEVICE_WIDTH-25,colorSquareView.frame.size.height-30-44 ,20 ,20 );

    }
  
//    UIImageView * imgFullBrightness = [[UIImageView alloc]init];
//    imgFullBrightness.frame = CGRectMake(0,colorSquareView.frame.size.height-25 ,20 ,20 );
//    imgFullBrightness.image = [UIImage imageNamed:@"fullBright.png"];
//    [colorSquareView addSubview:imgFullBrightness];
//
//
//    UIImageView * imgLowBrightness = [[UIImageView alloc]init];
//    imgLowBrightness.frame = CGRectMake(250+10,colorSquareView.frame.size.height-20 ,10 ,10 );
//    imgLowBrightness.image = [UIImage imageNamed:@"lowBright.png"];
//    [colorSquareView addSubview:imgLowBrightness];
    
    imgColorOptionView.currentColorBlock = ^(UIColor *color){
        
        isChanged = YES;
        CGFloat brightness;
        [color getHue:NULL saturation:NULL brightness:&brightness alpha:NULL];
        if (brightness>=0.1)
        {
            UIColor * newColor;
            if (intBrightnessValue < 0) intBrightnessValue = 0;
            
            CGFloat r, g, b, a;
            if ([color getRed:&r green:&g blue:&b alpha:&a])
                newColor  = [UIColor colorWithRed:MAX(r * intBrightnessValue, 0.0)
                                       green:MAX(g * intBrightnessValue, 0.0)
                                        blue:MAX(b * intBrightnessValue, 0.0)
                                       alpha:a];
            
            selectedColors = color;
//            NSArray *colors = [NSArray arrayWithObjects:(id)color.CGColor, (id)color.CGColor, nil];
//            brightnessSliderColorView.thumbTintColor = color;
//            [self setGradientBackgroundWithColors:colors];

            if (newColor == nil)
            {
                newColor = UIColor.whiteColor;
            }
            const  CGFloat *_components = CGColorGetComponents(newColor.CGColor);
            CGFloat red   = _components[0];
            CGFloat green = _components[1];
            CGFloat blue   = _components[2];
            
            alarmRed = red * 255;
            alarmGreen = green * 255;
            alarmBlue = blue * 255;
            
            strHexAlarmColor = [NSString stringWithFormat:@"#%02lX%02lX%02lX",
                                lroundf(red * 255),
                                lroundf(green * 255),
                                lroundf(blue * 255)];
            
            if (selectedColors != [UIColor whiteColor])
            {
                lblSelecColor.backgroundColor = newColor;
            }
        }
    };
}

-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)btnSaveClick
{
    if (selectedColors == nil)
    {
        selectedColors = UIColor.whiteColor;
    }
    
    if([[self checkforValidString:strHexAlarmColor]isEqualToString:@"NA"])
    {
        strHexAlarmColor = [NSString stringWithFormat:@"#%02lX%02lX%02lX",
                            lroundf(1 * 255),
                            lroundf(1 * 255),
                            lroundf(1 * 255)];
    }
  
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setValue:strHexAlarmColor forKey:@"value"];
    
    if (isFromAlarm)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAlarmColors" object:selectedColors];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetFavoriteColors" object:dict];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (UIColor *)adjustedColorForColor:(UIColor *)c : (double)percent
{
    if (percent < 0) percent = 0;
    
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r * percent, 0.0)
                               green:MAX(g * percent, 0.0)
                                blue:MAX(b * percent, 0.0)
                               alpha:a];
    return nil;
}

//- (void)colorDidChange:(HRColorPickerView *)colorPickerView
#pragma mark - COLOR FROM IMAGE (WARM AND COLOR OTHER OPTIONS)
- (void)pickedColor:(UIColor*)color atPoint:(CGPoint)point
{
    CGFloat brightness;
    [color getHue:NULL saturation:NULL brightness:&brightness alpha:NULL];
    if (brightness>=0.1)
    {
        UIColor *newColor = [self adjustedColorForColor:color :intBrightnessValue];
        selectedColors = color;
        
        const  CGFloat *_components = CGColorGetComponents(newColor.CGColor);
        CGFloat red   = _components[0];
        CGFloat green = _components[1];
        CGFloat blue   = _components[2];
        
        alarmRed = red * 255;
        alarmGreen = green * 255;
        alarmBlue = blue * 255;
        
        strHexAlarmColor = [NSString stringWithFormat:@"#%02lX%02lX%02lX",
                            lroundf(red * 255),
                            lroundf(green * 255),
                            lroundf(blue * 255)];
        
        if (selectedColors != [UIColor whiteColor])
        {
            lblSelecColor.backgroundColor = newColor;
        }
    }
}
-(void)brightnessChanged:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    intBrightnessValue = slider.value/100;
//    if (intBrightnessValue<=0.4)
//    {
//        intBrightnessValue = 0.40;
//    }
    if (selectedColors == nil)
    {
        selectedColors = UIColor.whiteColor;
    }
    CGFloat finalValue = (0.7 * (intBrightnessValue * 100) + 30 )/100;

    UIColor *newColor = [self adjustedColorForColor:selectedColors :finalValue];
    

    const  CGFloat *_components = CGColorGetComponents(newColor.CGColor);
    CGFloat red   = _components[0] ;
    CGFloat green = _components[1] ;
    CGFloat blue  = _components[2] ;
    
    strHexAlarmColor = [NSString stringWithFormat:@"#%02lX%02lX%02lX",
                        lroundf(red * 255),
                        lroundf(green * 255),
                        lroundf(blue * 255)];
    
    
    [lblSelecColor setBackgroundColor:[UIColor colorWithRed:red green:green blue:blue alpha:1.0]];

    
    int currentvalue = slider.value;
    
    CGRect trackRect = [slider trackRectForBounds:slider.bounds];
    CGRect thumbRect = [slider thumbRectForBounds:slider.bounds
                                        trackRect:trackRect
                                            value:slider.value];
    lblThumbTint.center = CGPointMake(thumbRect.origin.x +slider.frame.origin.x+20,slider.frame.origin.y-10);
    
    NSString *strlbl = [[NSString alloc]initWithFormat:@"%d %@",currentvalue,@"%"];
    lblThumbTint.text = strlbl;
    
}
-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""] && ![strRequest isEqualToString:@"<nil>"])
        {
            strValid = strRequest;
        }
        else
        {
            strValid = @"NA";
        }
    }
    else
    {
        strValid = @"NA";
    }
    return strValid;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIColor *)colorWithHexString:(NSString *)str
{
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [self colorWithHex:x];
}
- (UIColor *)colorWithHex:(UInt32)col
{
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    
    
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}
- (void)setGradientBackgroundWithColors:(NSArray *)colors
{
    CAGradientLayer *trackGradientLayer = [CAGradientLayer layer];
    CGRect frame = brightnessSliderColorView.frame;
    frame.size.height = 5.0; //set the height of slider
    trackGradientLayer.frame = frame;
    trackGradientLayer.colors = colors;
    //setting gradient as horizontal
    trackGradientLayer.startPoint = CGPointMake(0.0, 0.5);
    trackGradientLayer.endPoint = CGPointMake(1.0, 0.5);
    
    UIImage *trackImage = [[self imageFromLayer:trackGradientLayer] resizableImageWithCapInsets:UIEdgeInsetsZero];
    [brightnessSliderColorView setMinimumTrackImage:trackImage forState:UIControlStateNormal];
    [brightnessSliderColorView setMaximumTrackImage:trackImage forState:UIControlStateNormal];
}

-(UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, layer.opaque, 0.0);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
