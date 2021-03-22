//
//  webViewVC.m
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 21/02/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import "webViewVC.h"

@interface webViewVC ()

@end

@implementation webViewVC
@synthesize btnIndex;
- (void)viewDidLoad
{
    self.view.backgroundColor = global_brown_color;
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];
    [self setContentViewFrames];
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    self.view.backgroundColor = [UIColor colorWithRed:19/255.0 green:24/255.0 blue:27/255.0 alpha:1.0];
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.5;
    [viewHeader addSubview:lblBack];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Vithamas"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
//    UIImageView * imgMenu = [[UIImageView alloc]initWithFrame:CGRectMake(10,20+7, 33, 30)];
//    imgMenu.image = [UIImage imageNamed:@"menu.png"];
//    imgMenu.backgroundColor = UIColor.clearColor;
//    [viewHeader addSubview:imgMenu];
    
    UIButton * btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMenu setFrame:CGRectMake(0, 0, 80, 64)];
    [btnMenu addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnMenu];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 7+44, 12, 20);
        [btnMenu setFrame:CGRectMake(0, 0, 88, 88)];
//        imgMenu.frame = CGRectMake(10,44+7, 33, 30);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);

    }
}
#pragma mark - set UI Frames
-(void) setContentViewFrames
{
    int yy = 64;
    int zz = 0;
    if (IS_IPHONE_X)
    {
        yy = 88;
        zz = 40;
    }
    if (btnIndex == 0)
    {

        UIWebView * webFB = [[UIWebView alloc]init];
        webFB = [[UIWebView alloc]initWithFrame:CGRectMake(0, yy, self.view.frame.size.width, self.view.frame.size.height-yy-zz)];
        webFB.delegate = self;
        NSURL *url;
        NSURLRequest *request;
        url = [[NSURL alloc]initWithString:@"https://www.facebook.com/Vithamas-Technologies-Pvt-Ltd-299264790734131/"];
        request = [[NSURLRequest alloc]initWithURL:url];
        [webFB loadRequest:request];
        [webFB reload];
        [self.view addSubview:webFB];
    }
    else if (btnIndex == 1)
    {
        UIWebView * webFB = [[UIWebView alloc]init];
        webFB = [[UIWebView alloc]initWithFrame:CGRectMake(0, yy, self.view.frame.size.width, self.view.frame.size.height-yy-zz)];
        webFB.delegate = self;
        NSURL *url;
        NSURLRequest *request;
        url = [[NSURL alloc]initWithString:@"https://www.instagram.com/p/Bt45ZGtguef/?utm_source=ig_share_sheet&igshid=djiwxqxkoev0"];
        request = [[NSURLRequest alloc]initWithURL:url];
        [webFB loadRequest:request];
        [webFB reload];
        [self.view addSubview:webFB];
    }
    else if (btnIndex == 2)
    {
        UIWebView * webFB = [[UIWebView alloc]init];
        webFB = [[UIWebView alloc]initWithFrame:CGRectMake(0, yy, self.view.frame.size.width, self.view.frame.size.height-yy-zz)];
        webFB.delegate = self;
        NSURL *url;
        NSURLRequest *request;
        url = [[NSURL alloc]initWithString:@"https://www.linkedin.com/company/vithamas-technologies-pvt-ltd/"];
        request = [[NSURLRequest alloc]initWithURL:url];
        [webFB loadRequest:request];
        [webFB reload];
        [self.view addSubview:webFB];
    }
    else if (btnIndex == 3)
    {
        UIWebView * webFB = [[UIWebView alloc]init];
        webFB = [[UIWebView alloc]initWithFrame:CGRectMake(0, yy, self.view.frame.size.width, self.view.frame.size.height-yy-zz)];
        webFB.delegate = self;
        NSURL *url;
        NSURLRequest *request;
        url = [[NSURL alloc]initWithString:@"https://www.youtube.com/channel/UCcz1WgCDknJZE_chnqR5D5g"];
        request = [[NSURLRequest alloc]initWithURL:url];
        [webFB loadRequest:request];
        [webFB reload];
        [self.view addSubview:webFB];
    }
    else if (btnIndex == 4)
    {
        UIWebView * webFB = [[UIWebView alloc]init];
        webFB = [[UIWebView alloc]initWithFrame:CGRectMake(0, yy, self.view.frame.size.width, self.view.frame.size.height-yy-zz)];
        webFB.delegate = self;
        NSURL *url;
        NSURLRequest *request;
        url = [[NSURL alloc]initWithString:@"http://vithamastech.com"];
        request = [[NSURLRequest alloc]initWithURL:url];
        [webFB loadRequest:request];
        [webFB reload];
        [self.view addSubview:webFB];
    }
    else if (btnIndex == 5)
    {
        UIWebView * webFB = [[UIWebView alloc]init];
        webFB = [[UIWebView alloc]initWithFrame:CGRectMake(0, yy, self.view.frame.size.width, self.view.frame.size.height-yy-zz)];
        webFB.delegate = self;
        NSURL *url;
        NSURLRequest *request;
        url = [[NSURL alloc]initWithString:@"http://vithamastech.com/cms/about-us"];
        request = [[NSURLRequest alloc]initWithURL:url];
        [webFB loadRequest:request];
        [webFB reload];
        [self.view addSubview:webFB];
    }
    else if (btnIndex == 6)
    {
        UIWebView * webFB = [[UIWebView alloc]init];
        webFB = [[UIWebView alloc]initWithFrame:CGRectMake(0, yy, self.view.frame.size.width, self.view.frame.size.height-yy-zz)];
        webFB.delegate = self;
        NSURL *url;
        NSURLRequest *request;
        url = [[NSURL alloc]initWithString:@"http://vithamastech.com/cms/app-privacy-policy"];
        request = [[NSURLRequest alloc]initWithURL:url];
        [webFB loadRequest:request];
        [webFB reload];
        [self.view addSubview:webFB];
    }
    else if (btnIndex == 7)
    {
        UIWebView * webFB = [[UIWebView alloc]init];
        webFB = [[UIWebView alloc]initWithFrame:CGRectMake(0, yy, self.view.frame.size.width, self.view.frame.size.height-yy-zz)];
        webFB.delegate = self;
        NSURL *url;
        NSURLRequest *request;
        url = [[NSURL alloc]initWithString:@"http://vithamastech.com/cms/app-privacy-policy"];
        request = [[NSURLRequest alloc]initWithURL:url];
        [webFB loadRequest:request];
        [webFB reload];
        [self.view addSubview:webFB];
    }
}
#pragma mark - All button click events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
