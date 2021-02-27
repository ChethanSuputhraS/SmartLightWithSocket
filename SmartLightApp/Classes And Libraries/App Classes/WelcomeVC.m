//
//  WelcomeVC.m
//  SmartLightApp
//
//  Created by stuart watts on 29/08/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "WelcomeVC.h"

@interface WelcomeVC ()
{
    UIButton * skipBtn ;
}
@end

@implementation WelcomeVC
@synthesize isFromManul;

- (void)viewDidLoad
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.startPoint = CGPointMake(0.0, 0.5);
//    gradient.endPoint = CGPointMake(1.0, 0.5);
   
    gradient.colors = @[(id)[UIColor colorWithRed:123.0/255.0 green:27.0/255.0 blue:19.0/255.0 alpha:1].CGColor, (id)[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    gradient.frame = self.view.bounds;
    [self.view.layer insertSublayer:gradient atIndex:0];

    if (IS_IPHONE_4)
    {
        strImgforDevice = @"4";
    }
    else if (IS_IPHONE_5)
    {
        strImgforDevice = @"5";
    }
    else if (IS_IPHONE_6)
    {
        strImgforDevice = @"6";
    }
    else if (IS_IPHONE_6plus)
    {
        strImgforDevice = @"6plus";
    }
    else if (IS_IPHONE_X)
    {
        strImgforDevice = @"x";
    }
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self setPageControll];
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIView *statusBar;
    if (@available(iOS 13, *))
    {
        statusBar = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame] ;
        statusBar.backgroundColor = global_brown_color;
        [[UIApplication sharedApplication].keyWindow addSubview:statusBar];

     }
    else
    {
        statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    }
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        
        statusBar.backgroundColor = global_brown_color;//set whatever color you like
    }
    
    [APP_DELEGATE hideTabBar:self.tabBarController];
    // Do any additional setup after loading the view.
}
-(void)setPageControll
{
    [scrlContent removeFromSuperview];
    scrlContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    [scrlContent setContentSize:CGSizeMake(scrlContent.frame.size.width*10, DEVICE_HEIGHT-70)];

    [scrlContent setBackgroundColor:[UIColor clearColor]];
    scrlContent.pagingEnabled = YES;
//    scrlContent.bounces = NO;
    scrlContent.delegate = self;
    scrlContent.showsHorizontalScrollIndicator = NO;
    scrlContent.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrlContent];

    if (IS_IPHONE_X)
    {
        scrlContent.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-40);
        [scrlContent setContentSize:CGSizeMake(scrlContent.frame.size.width*10, DEVICE_HEIGHT-40-70)];

    }
    
    NSArray * imgArr= [NSArray arrayWithObjects:@"intro1",@"intro2",@"intro3",@"intro4",@"intro5",@"intro6",@"intro7",@"intro8",@"intro9",@"intro10", nil];
    for (int i=0; i<10; i++)
    {
        UIImageView * imgView = [[UIImageView alloc]init];
        if (IS_IPHONE_X)
        {
            imgView.frame = CGRectMake(i*DEVICE_WIDTH, 0, DEVICE_WIDTH, 666);
        }
        else if (IS_IPHONE_4)
        {
            imgView.frame = CGRectMake(25+(DEVICE_WIDTH*i), 0, 270, 480);
        }
        else
        {
            imgView.frame = CGRectMake(i*DEVICE_WIDTH, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
        }
        NSString * imgName = [NSString stringWithFormat:@"%@.png",[imgArr objectAtIndex:i]];
        [imgView setImage:[UIImage imageNamed:imgName]];
        imgView.backgroundColor = [UIColor clearColor];
        [scrlContent addSubview:imgView];
    }

    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-100)/2, DEVICE_HEIGHT-25 , 100, 20)];
    pageControl.numberOfPages = 10;
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    [pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageControl];
    
    skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    skipBtn.frame = CGRectMake(DEVICE_WIDTH-90, DEVICE_HEIGHT-40, 100, 40);
    [skipBtn setTitle:@"Skip" forState:UIControlStateNormal];
    [skipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [skipBtn addTarget:self action:@selector(skipBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipBtn];
    
    if (IS_IPHONE_X)
    {
        pageControl.frame = CGRectMake((DEVICE_WIDTH-100)/2, DEVICE_HEIGHT-60-25 , 100, 20);
        skipBtn.frame = CGRectMake(DEVICE_WIDTH-90, DEVICE_HEIGHT-60-40, 100, 40);
    }
}
-(void) pageTurn: page
{
    [scrlContent scrollRectToVisible:CGRectMake(scrlContent.frame.size.width * (pageControl.currentPage), 0, scrlContent.frame.size.width, scrlContent.frame.size.height) animated:true];
}
-(void) setIndicatorCurrentPage
{
    int page = (scrlContent.contentOffset.x)/scrlContent.frame.size.width;
    pageControl.currentPage = page;
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setIndicatorCurrentPage];
}
-(void)skipBtnClick
{
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"IS_USER_CAME_FIRST_TIME"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([IS_USER_SKIPPED isEqualToString:@"YES"])
    {
        if (isFromManul == true)
        {
            isFromManul = false;
            [self.navigationController popViewControllerAnimated:true];
        }
        else
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.8];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
            [UIView commitAnimations];
            [APP_DELEGATE goToDashboard];
            [APP_DELEGATE addScannerView];
        }
    }
    else
    {
        if([IS_USER_LOGGED isEqualToString:@"YES"])
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.8];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
            [UIView commitAnimations];
            [APP_DELEGATE goToDashboard];
            [APP_DELEGATE addScannerView];
        }
        else if ([IS_USER_SKIPPED isEqualToString:@"NO"] || [IS_USER_LOGGED isEqualToString:@"NO"])
        {
            [APP_DELEGATE movetoLogin];
            [APP_DELEGATE addScannerView];
        }
        else
        {
            [APP_DELEGATE movetoLogin];
            [APP_DELEGATE addScannerView];
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
