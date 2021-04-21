//
//  HelpLeftMenuVC.m
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 02/01/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import "HelpLeftMenuVC.h"
#import "HelpLeftMenuCell.h"
#import "WelcomeVC.h"
#import "webViewVC.h"
#import "YouTubeVC.h"

@interface HelpLeftMenuVC ()

@end

@implementation HelpLeftMenuVC
- (void)viewDidLoad
{
    self.view.backgroundColor = UIColor.clearColor;
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
-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DoorbellPopupSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DoorbellPopupSuccess) name:@"DoorbellPopupSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DoorbellPopupFailure" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DoorbellPopupFailure) name:@"DoorbellPopupFailure" object:nil];
}

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
    [lblTitle setText:@"Help"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+3]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    //    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
    //    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    //    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    //    backImg.backgroundColor = [UIColor clearColor];
    //    [viewHeader addSubview:backImg];
    //
    UIImageView * imgMenu = [[UIImageView alloc]initWithFrame:CGRectMake(10,20+7, 33, 30)];
    imgMenu.image = [UIImage imageNamed:@"menu.png"];
    imgMenu.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgMenu];
    
    UIButton * btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMenu setFrame:CGRectMake(0, 0, 80, 64)];
    [btnMenu addTarget:self action:@selector(btnMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnMenu];
    
    if (IS_IPHONE_X)
    {
        [btnMenu setFrame:CGRectMake(0, 0, 88, 88)];
        imgMenu.frame = CGRectMake(10,44+7, 33, 30);
        lblTitle.frame = CGRectMake(50, 44, DEVICE_WIDTH-100, 44);
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
    }
}
#pragma mark - set UI Frames
-(void) setContentViewFrames
{
    tblContent = [[UITableView alloc]init];
    tblContent.frame = CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT-64-44);
    tblContent.backgroundColor = UIColor.clearColor;
    tblContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblContent.delegate = self;
    tblContent.dataSource = self;
    tblContent.scrollEnabled = false;
    [self.view addSubview:tblContent];
    if (IS_IPHONE_X)
    {
        tblContent.frame = CGRectMake(0, 88, DEVICE_WIDTH, DEVICE_HEIGHT-88-44);
    }
}
#pragma mark - TableView Delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    HelpLeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[HelpLeftMenuCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.lblAppVersion.hidden = true;
    NSArray * imgArr = [[NSArray alloc]initWithObjects:@"ic_user_manual.png", nil];
    cell.imgLogo.image =  [UIImage imageNamed:[NSString stringWithFormat:@"%@",[imgArr objectAtIndex:indexPath.row]]];
    
    NSArray * nameArr = [[NSArray alloc]initWithObjects:@"User Manual", nil];
    cell.lblName.text = [NSString stringWithFormat:@"%@",[nameArr objectAtIndex:indexPath.row]];
    
    
    if (indexPath.row == 0 || indexPath.row == 1)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        WelcomeVC *view1 = [[WelcomeVC alloc]init];
        view1.isFromManul = true;
        [self.navigationController pushViewController:view1 animated:true];
    }
//    else if (indexPath.row == 1)
//    {
//        UIWebView * webFB = [[UIWebView alloc]init];
//        webFB = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
//        webFB.delegate = self;
//        NSURL *url;
//        NSURLRequest *request;
//        url = [[NSURL alloc]initWithString:@"http://vithamastech.com"];
//        request = [[NSURLRequest alloc]initWithURL:url];
//        [webFB loadRequest:request];
//        [webFB reload];
//        [self.view addSubview:webFB];
//    }
    else if (indexPath.row == 1)
    {
//        YouTubeVC * youtVC = [[YouTubeVC alloc] init];
//        [self.navigationController pushViewController:youtVC animated:true];
    }
    else if (indexPath.row == 2)
    {
//        [self feedBackBtnClick];
    }
}
#pragma mark - All button click events
-(void)btnMenuClicked:(id)sender
{
    [self.menuContainerViewController setMenuSlideAnimationFactor:0.5f];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}
#pragma mark - feedBackBtn Click
-(void)feedBackBtnClick
{
    NSString *appId = @"10087";
    NSString *appKey = @"4NtJGOne7zSRIKyX9LGpPlMYi68aBM3jwksPNEnVuyz2T1AO8NDqdEl64EuYhnlp";
    
    if (isFeedbackOpen)
    {
        if (feedback)
        {
            [feedback.dialog.delegate dialogDidCancel:feedback.dialog];
            [feedback.dialog removeFromSuperview];
            feedback=nil;
            feedback = Nil;
            [feedback showFeedbackDialogInViewController:self completion:^(NSError *error, BOOL isCancelled) {
                if (error)
                {
//                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        }
        else
        {
            [feedback.dialog removeFromSuperview];
            
            feedback = [Doorbell doorbellWithApiKey:appKey appId:appId];
            feedback.showEmail = YES;
            feedback.email = @"";
            [feedback showFeedbackDialogInViewController:self completion:^(NSError *error, BOOL isCancelled) {
                if (error)
                {
//                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        }
        isFeedbackOpen = NO;
    }
    else
    {
        feedback = [Doorbell doorbellWithApiKey:appKey appId:appId];
        feedback.showEmail = YES;
        feedback.email = @"";
        
        [feedback showFeedbackDialogInViewController:self completion:^(NSError *error, BOOL isCancelled) {
            if (error) {
//                NSLog(@"%@", error.localizedDescription);
            }
        }];
        isFeedbackOpen = YES;
    }
}
-(void)DoorbellPopupSuccess
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Thanks for submitting feedback."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)DoorbellPopupFailure
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeCaution];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Please enter valid email id."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}

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
