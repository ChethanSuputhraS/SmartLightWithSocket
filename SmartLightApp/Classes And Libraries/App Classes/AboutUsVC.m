//
//  AboutUsVC.m
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 23/02/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import "AboutUsVC.h"
#import "HelpLeftMenuCell.h"
#import "webViewVC.h"
@interface AboutUsVC ()

@end

@implementation AboutUsVC

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
    [lblTitle setText:@"About Us"];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    NSArray * imgArr = [[NSArray alloc]initWithObjects:@"about_icon_white.png",@"privacyPolicy.png",@"appVersion.png", nil];
    cell.imgLogo.image =  [UIImage imageNamed:[NSString stringWithFormat:@"%@",[imgArr objectAtIndex:indexPath.row]]];
    
    NSArray * nameArr = [[NSArray alloc]initWithObjects:@"About Us",@"App Privacy Policy",@"App Version", nil];
    cell.lblName.text = [NSString stringWithFormat:@"%@",[nameArr objectAtIndex:indexPath.row]];
    
    if (indexPath.row == 0 || indexPath.row == 1)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row == 2)
    {
        cell.lblName.frame = CGRectMake(45, 5, 180, 22);
        cell.lblAppVersion.hidden = false;
        cell.lblLine.frame = CGRectMake(5,49, DEVICE_WIDTH-10, 0.5);
        cell.imgCellBG.frame = CGRectMake(0, 0, DEVICE_WIDTH, 49);
    }
    else
    {
        cell.lblAppVersion.hidden = true;
    }
//    cell.backgroundColor = UIColor.yellowColor;
    cell.lblAppVersion.frame = CGRectMake(cell.lblName.frame.origin.x, 27, 180, 22);
    cell.lblAppVersion.text = @"1.0.1";
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (![[self checkforValidString:appVersionString] isEqualToString:@"NA"])
    {
        cell.lblAppVersion.text = appVersionString;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        webViewVC*view1 = [[webViewVC alloc]init];
        view1.btnIndex = 5;
        [self.navigationController pushViewController:view1 animated:true];
    }
    else if (indexPath.row == 1)
    {
        webViewVC*view1 = [[webViewVC alloc]init];
        view1.btnIndex = 6;
        [self.navigationController pushViewController:view1 animated:true];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2)
    {
        return 49;
    }
    else
    {
        return 44;
    }
}
#pragma mark - All button click events
-(void)btnMenuClicked:(id)sender
{
    [self.menuContainerViewController setMenuSlideAnimationFactor:0.5f];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""])
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
