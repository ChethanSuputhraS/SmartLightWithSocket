//
//  WebLinkVC.m
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 6/3/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import "WebLinkVC.h"

@interface WebLinkVC ()

@end

@implementation WebLinkVC

@synthesize strWebLink,strTitle;

#pragma mark - Life Cycle
-(instancetype)init
{
    if (self) {
        self.hidesBottomBarWhenPushed=YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self setNavigationViewFrames];
    
    contentWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT-64)];
    [contentWebView setBackgroundColor:[UIColor whiteColor]];
    contentWebView.delegate = self;
    [contentWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",strWebLink]]]];
    [self.view addSubview:contentWebView];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setFrame:CGRectMake(DEVICE_WIDTH/2-15, (DEVICE_HEIGHT)/2-15, 30, 30)];
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInternetAvailabilityNotification:) name:kUpdateInternetAvailabilityNotification object:nil];
    
    [APP_DELEGATE isNetworkreachable];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateInternetAvailabilityNotification object:nil];
}

#pragma mark - Notifications
-(void)updateInternetAvailabilityNotification:(NSNotification*)notification
{
    NSString * strNetworkStatus = (NSString*)notification.object;
    
    if ([strNetworkStatus isEqualToString:@"1"] || [strNetworkStatus isEqualToString:@"2"])
    {
        [imgNetworkStatus setImage:[UIImage imageNamed:@"logo.png"]];
    }
    else
    {
        [imgNetworkStatus setImage:[UIImage imageNamed:@"logo_gray.png"]];
    }
}

#pragma mark - Set UI Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[APP_DELEGATE colorWithHexString:App_Header_Color]];
    [self.view addSubview:viewHeader];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(0, 20, 50, 44)];
    [btnBack setBackgroundColor:[UIColor clearColor]];
    [btnBack setImage:[UIImage imageNamed:Icon_Back_Button] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(btnBackClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnBack];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:strTitle];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightSemibold]];
    [lblTitle setTextColor:[APP_DELEGATE colorWithHexString:header_font_color]];
    [viewHeader addSubview:lblTitle];
    
    imgNetworkStatus = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-70, 32, 60, 20)];
    [imgNetworkStatus setImage:[UIImage imageNamed:@"logo_gray.png"]];
    [imgNetworkStatus setContentMode:UIViewContentModeScaleAspectFit];
    [viewHeader addSubview:imgNetworkStatus];
    
    UILabel * lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 63.5, DEVICE_WIDTH, 0.5)];
    [lblLine setBackgroundColor:[UIColor lightGrayColor]];
    [viewHeader addSubview:lblLine];
}

#pragma mark - Button Clicked
-(void)btnBackClicked:(id)sender
{
    if ([contentWebView canGoBack] ) {
        [contentWebView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    //    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -WebView Delegate
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [activityIndicator startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicator stopAnimating];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activityIndicator stopAnimating];
}

#pragma mark - CleanUp
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
