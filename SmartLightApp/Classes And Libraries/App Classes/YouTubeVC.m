//
//  YouTubeVC.m
//  SmartLightApp
//
//  Created by Ashwin on 9/29/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "YouTubeVC.h"
#import "HelpLeftMenuCell.h"



@interface YouTubeVC ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>
{
    UITableView *tblYoutubeContent;
    UIWebView * webView ;
    BOOL isWebView ;
}
@end

@implementation YouTubeVC

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
-(void)setContentViewFrames
{
    tblYoutubeContent = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT-64-44)];
    tblYoutubeContent.backgroundColor = UIColor.clearColor;
    tblYoutubeContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblYoutubeContent.delegate = self;
    tblYoutubeContent.dataSource = self;
    tblYoutubeContent.scrollEnabled = false;
    [self.view addSubview:tblYoutubeContent];
    
    if (IS_IPHONE_X)
    {
        tblYoutubeContent.frame = CGRectMake(0, 88, DEVICE_WIDTH, DEVICE_HEIGHT-88-44);
    }
}
#pragma mark - TableView Delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    HelpLeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[HelpLeftMenuCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    
    cell.lblName.hidden = true;
    cell.lblAppVersion.hidden = true;
    cell.lblYoutube.hidden = false;
    
    cell.imgLogo.image =  [UIImage imageNamed:@"youtube.png"];
    
    if (indexPath.row == 0)
    {
        cell.lblYoutube.text = @"User Registration";
    }
    else if (indexPath.row == 1)
    {
        cell.lblYoutube.text = @"LED Strip";
    }
    else if (indexPath.row == 2)
    {
        cell.lblYoutube.frame = CGRectMake(45, 0, DEVICE_WIDTH-90, 44);
        cell.lblYoutube.font = [UIFont fontWithName:CGRegular size:textSizes];
        cell.lblYoutube.text = @"Diffrent scenes on the device";
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
-(void)btnBackClick
{
    if (isWebView == true)
    {
        isWebView = false;
        [webView removeFromSuperview];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:true];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    webView.hidden = false;
    if (indexPath.row == 0)
    {
        [self WebViewForYoutube:@"https://www.youtube.com/watch?v=w4ezy3UTCvs"];
    }
    else if (indexPath.row == 1)
    {
        [self WebViewForYoutube:@"https://www.youtube.com/watch?v=aA9gVCdi1RY"];
    }
    else if (indexPath.row == 2)
    {
        [self WebViewForYoutube:@"https://www.youtube.com/watch?v=AFVNHKgV4Bs"];
    }
}
-(void)WebViewForYoutube:(NSString *)strURL
{
    isWebView = true;
    int yy = 64;
    int zz = 0;
    if (IS_IPHONE_X)
    {
        yy = 88;
        zz = 40;
    }
    
    webView = [[UIWebView alloc]init];
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, yy, self.view.frame.size.width, self.view.frame.size.height-yy-zz)];
    webView.delegate = self;
    NSURL *url;
    NSURLRequest *request;
    url = [[NSURL alloc]initWithString: strURL];
    request = [[NSURLRequest alloc]initWithURL:url];
    [webView loadRequest:request];
    [webView reload];
    [self.view addSubview:webView];
}
@end
