//
//  InfoScreenVC.m
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 5/31/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import "InfoScreenVC.h"
#import "LoginVC.h"

@interface InfoScreenVC ()

@end

@implementation InfoScreenVC

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setContentViewFrames];
}

#pragma mark - Set Frames
-(void)setContentViewFrames
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    [self.view addSubview:view];
    
    scrlContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    scrlContent.bounces = NO;
    scrlContent.delegate = self;
    scrlContent.showsHorizontalScrollIndicator = NO;
    scrlContent.pagingEnabled = YES;
    [self.view addSubview:scrlContent];
    
    
    UIImageView * imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2-204/2, DEVICE_HEIGHT/2-120, 204,80)];
    [imgLogo setAlpha:0.9];
    [imgLogo setImage:[UIImage imageNamed:@"logo.png"]];
    [self.view addSubview:imgLogo];
//    imgLogo.hidden=YES ;
    
    UILabel * lblLogoName = [[UILabel alloc] initWithFrame:CGRectMake(10, DEVICE_HEIGHT/2-30, DEVICE_WIDTH-20, 40)];
    [lblLogoName setText:@"INDOOR ACCESS CONTROL"];
    [lblLogoName setFont:[UIFont systemFontOfSize:20 weight:UIFontWeightBold]];
    [lblLogoName setTextColor:[APP_DELEGATE colorWithHexString:blue_color]];
    [lblLogoName setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:lblLogoName];
    
    UILabel * lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(10, DEVICE_HEIGHT/2+60, DEVICE_WIDTH-20, 40)];
    [lblMessage setText:@"Please  switch on Bluetooth : Go to Settings->Bluetooth"];
    [lblMessage setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightBold]];
    [lblMessage setTextColor:[UIColor darkGrayColor]];
    [lblMessage setNumberOfLines:3];
    [lblMessage setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:lblMessage];
    
    //Please  switch on Bluetooth : Go to Settings->Bluetooth
    
    int xx = 0;
    for (int i = 0; i<4; i++)
//    for (int i = 0; i<1; i++)
    {
        UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(xx, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
        img.contentMode = UIViewContentModeScaleAspectFill;
        if (i==0)
        {
//            img.backgroundColor= [UIColor redColor];
            if (IS_IPHONE_4) {
//                [img setImage:[UIImage imageNamed:@"info1_iPhone4.png"]];
            }else{
//                [img setImage:[UIImage imageNamed:@"info1.png"]];
            }
        }
        else if (i==1)
        {
//            img.backgroundColor= [UIColor greenColor];

            if (IS_IPHONE_4) {
//                [img setImage:[UIImage imageNamed:@"info2_iPhone4.png"]];
            }else{
//                [img setImage:[UIImage imageNamed:@"info2.png"]];
            }
        }
        [scrlContent addSubview:img];
        
        xx = xx+DEVICE_WIDTH;
    }
    
    [scrlContent setContentSize:CGSizeMake(DEVICE_WIDTH*4, DEVICE_HEIGHT)];
    
    
    pageControl = [[UIPageControl alloc] init];
    pageControl.frame = CGRectMake(100,DEVICE_HEIGHT-105,DEVICE_WIDTH-200,20);
    pageControl.numberOfPages = 4;
    pageControl.currentPage = 0;
    pageControl.pageIndicatorTintColor  = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    [self.view addSubview:pageControl];
    
    BtnNext=[UIButton buttonWithType:UIButtonTypeSystem];
    BtnNext.frame=CGRectMake(30, DEVICE_HEIGHT-80, DEVICE_WIDTH-60, 45);
    [BtnNext setTitle:@"GET STARTED" forState:UIControlStateNormal];
    [BtnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [BtnNext addTarget:self action:@selector(btnNextClickedClicked:) forControlEvents:UIControlEventTouchUpInside];
    BtnNext.titleLabel.font=[UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
    [BtnNext setBackgroundColor:[APP_DELEGATE colorWithHexString:blue_color]];
    BtnNext.layer.cornerRadius=4.0;
    BtnNext.clipsToBounds = NO;
    BtnNext.layer.shadowColor = [[UIColor grayColor] CGColor];
    BtnNext.layer.shadowOffset = CGSizeMake(2,2);
    BtnNext.layer.shadowOpacity = 0.5;
    [self.view addSubview:BtnNext];
}

#pragma mark - Button Click
-(void)btnNextClickedClicked:(id)sender
{
    if(pageControl.currentPage==0)
    {
//        [scrlContent setContentOffset:CGPointMake(DEVICE_WIDTH, 0) animated:YES];
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"IS_INFO_SCREEN_VISIBLE_ONCE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if([CURRENT_USER_ID isEqual:[NSNull null]] || [CURRENT_USER_ID isEqualToString:@""] || CURRENT_USER_ID == nil || CURRENT_USER_ID == NULL || [CURRENT_USER_ID isEqualToString:@"(null)"])
        {
            LoginVC * splash = [[LoginVC alloc] init];
            UINavigationController * navControl = [[UINavigationController alloc] initWithRootViewController:splash];
            navControl.navigationBarHidden=YES;
            
            AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
            appDelegate.window.rootViewController = navControl;
        }
        else
        {
            [APP_DELEGATE goToDashboard];
        }
    }
    else if(pageControl.currentPage==1)
    {
        /*[[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"IS_INFO_SCREEN_VISIBLE_ONCE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if([CURRENT_USER_ID isEqual:[NSNull null]] || [CURRENT_USER_ID isEqualToString:@""] || CURRENT_USER_ID == nil || CURRENT_USER_ID == NULL || [CURRENT_USER_ID isEqualToString:@"(null)"])
        {
            LoginVC * splash = [[LoginVC alloc] init];
            UINavigationController * navControl = [[UINavigationController alloc] initWithRootViewController:splash];
            navControl.navigationBarHidden=YES;
            
            AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
            appDelegate.window.rootViewController = navControl;
        }
        else
        {
            [APP_DELEGATE goToDashboard];
        }*/
    }
}

#pragma mark - Scrollview Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2 ) / pageWidth) + 1; //this provide you the page number
    pageControl.currentPage = page; // this displays the white dot as current page
    
    /*if(pageControl.currentPage==0 )
    {
        [BtnNext setTitle:@"Next" forState:UIControlStateNormal];
    }
    else
    {
        [BtnNext setTitle:@"Get Started" forState:UIControlStateNormal];
    }*/
    
    if(pageControl.currentPage==0 ){
        [BtnNext setTitle:@"Get Started" forState:UIControlStateNormal];
    }else{
        [BtnNext setTitle:@"Get Started" forState:UIControlStateNormal];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

#pragma mark - cleanUp
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
