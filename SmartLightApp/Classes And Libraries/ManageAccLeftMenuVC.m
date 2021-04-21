//
//  ManageAccLeftMenuVC.m
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 09/01/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import "ManageAccLeftMenuVC.h"
#import "customManageAccTableViewCell.h"
#import "ManageAccVC.h"
#import "ChangePasswordVC.h"

@interface ManageAccLeftMenuVC ()

@end

@implementation ManageAccLeftMenuVC

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
    if ([IS_USER_SKIPPED isEqualToString:@"YES"])
    {
        [lblName setText:[NSString stringWithFormat:@"Hi Guest"]];
    }
    else
    {
        [lblName setText:[NSString stringWithFormat:@"Hi %@", [self checkforValidString:CURRENT_USER_NAME]]];
        
    }
    
    [imgNotConnected removeFromSuperview];
    imgNotConnected = [[UIImageView alloc]init];
    imgNotConnected.image = [UIImage imageNamed:@"notconnect_iconWhite.png"];
    imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 32, 30, 22);
    imgNotConnected.contentMode = UIViewContentModeScaleAspectFit;
    imgNotConnected.layer.masksToBounds = true;
    [self.view addSubview:imgNotConnected];
    if (IS_IPHONE_X)
    {
        imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 55, 30, 22);
    }
    
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        imgNotConnected.image = [UIImage imageNamed:@"Connected_icon.png"];
    }
    else
    {
        if (updatedRSSI >= -70)
        {
            if (updatedRSSI < 0)
            {
                imgNotConnected.image = [UIImage imageNamed:@"notconnect_iconOrange.png"];
            }
            else
            {
                imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
            }
        }
        else if (updatedRSSI < -70)
        {
            if (updatedRSSI >= 100)
            {
                imgNotConnected.image = [UIImage imageNamed:@"notconnect_icon.png"];
                
            }
        }
    }
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
    [lblTitle setText:@"Manage Account"];
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
    if(IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        [btnMenu setFrame:CGRectMake(0, 0, 88, 88)];
        imgMenu.frame = CGRectMake(10,44+7, 33, 30);
        lblTitle.frame = CGRectMake(50, 44, DEVICE_WIDTH-100, 44);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH,88);
    }
}
#pragma mark - set UI Frames
-(void) setContentViewFrames
{
    lblName = [[UILabel alloc] initWithFrame:CGRectMake(10, 64, DEVICE_WIDTH, 30)];
    [lblName setBackgroundColor:[UIColor clearColor]];
    lblName.textAlignment = NSTextAlignmentLeft;
    [lblName setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lblName setTextColor:[UIColor whiteColor]];
    [self.view addSubview:lblName];
    
    tblContent = [[UITableView alloc]init];
    tblContent.frame = CGRectMake(0, 64+35, DEVICE_WIDTH, DEVICE_HEIGHT-64-44-35);
    tblContent.backgroundColor = UIColor.clearColor;
    tblContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblContent.scrollEnabled = false;
    tblContent.delegate = self;
    tblContent.dataSource = self;
    [self.view addSubview:tblContent];
    if(IS_IPHONE_X)
    {
        lblName.frame = CGRectMake(10, 88, DEVICE_WIDTH, 30);
        tblContent.frame = CGRectMake(0, 88+35, DEVICE_WIDTH, DEVICE_HEIGHT-64-44-35-40);

    }
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
            strValid = @" ";
        }
    }
    else
    {
        strValid = @" ";
    }
    return strValid;
}
#pragma mark - TableView Delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([IS_USER_SKIPPED isEqualToString:@"YES"])
    {
        return 1;

    }
    else
    {
        return 4;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    customManageAccTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[customManageAccTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    cell.lblView.hidden = true;
    cell.lblAccName.hidden = true;
    cell.lblMobNo.hidden = true;
//    cell.btnDelete.hidden = true;
    cell.imgDelete.hidden = true;

    cell.imgLogo.hidden = false;
    cell.lblName.hidden = false;
    cell.lblLine.hidden = false;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    if ([IS_USER_SKIPPED isEqualToString:@"YES"])
    {
//        NSArray * imgArr = [[NSArray alloc]initWithObjects:@"retrivePass.png",@"ic_manage_account.png",@"ic_switch_accountBlue.png",@"logout.png", nil];
//        cell.imgLogo.image =  [UIImage imageNamed:[NSString stringWithFormat:@"%@",[imgArr objectAtIndex:indexPath.row]]];
//
//        NSArray * nameArr = [[NSArray alloc]initWithObjects:@"Change Password",@"Manage Account",@"Switch Account",@"SignIn", nil];
//        cell.lblName.text = [NSString stringWithFormat:@"%@",[nameArr objectAtIndex:indexPath.row]];
        
        cell.imgLogo.image = [UIImage imageNamed:@"logout.png"];
        cell.lblName.text = @"Sign in";
        cell.lblLine.hidden = YES;
        
    }
    else
    {
        NSArray * imgArr = [[NSArray alloc]initWithObjects:@"retrivePass.png",@"ic_manage_account.png",@"ic_switch_account.png",@"logout.png", nil];
        cell.imgLogo.image =  [UIImage imageNamed:[NSString stringWithFormat:@"%@",[imgArr objectAtIndex:indexPath.row]]];
        
        NSArray * nameArr = [[NSArray alloc]initWithObjects:@"Change Password",@"Manage Account",@"Switch Account",@"Logout", nil];
        cell.lblName.text = [NSString stringWithFormat:@"%@",[nameArr objectAtIndex:indexPath.row]];
    }
   
    
    if (indexPath.row == 0 || indexPath.row == 1 ||  indexPath.row == 2)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        if ([IS_USER_SKIPPED isEqualToString:@"YES"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IS_USER_LOGGED"];
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IS_USER_SKIPPED"];
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"IS_USER_LOGGEDOUT"];

            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PairedDevices"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [self clearUserDefaults];
            
            globalDashBoardVC = [[DashboardVC alloc] init];
            globalSocketAlarmVC = [[SocketAlarmVC alloc] init];
            globalSocketDetailVC = [[SocketDetailVC alloc] init];
            [arrSocketDevices removeAllObjects];

            NSString *strDelete = [NSString stringWithFormat:@"Delete from UserAccount_Table"];
            [[DataBaseManager dataBaseManager] execute:strDelete];

            NSString * strDeviceDelete = [NSString stringWithFormat:@"Delete from Device_Table"];
            [[DataBaseManager dataBaseManager] execute:strDeviceDelete];

            NSString * strSocketDetailDelete = [NSString stringWithFormat:@"Delete from Socket_NameImg_Table"];
            [[DataBaseManager dataBaseManager] execute:strSocketDetailDelete];

            [[BLEManager sharedManager] RemoveDevicefromAutoConnection:@"AllDevices"];
            
            NSArray * arrSmartLights = [[BLEManager sharedManager] getLastSocketConnected];
            for (int i =0; i < [arrSmartLights count]; i++)
            {
                CBPeripheral * p = [arrSmartLights objectAtIndex:i];
                if (p.state == CBPeripheralStateConnected)
                {
                    [[BLEManager sharedManager] disconnectDevice:p];
                }
            }

            [APP_DELEGATE movetoLogin];
        }
        else
        {
            ChangePasswordVC *view1 = [[ChangePasswordVC alloc]init];
            [self.navigationController pushViewController:view1 animated:true];
        }
       
    }
    else if (indexPath.row == 1)
    {
        ManageAccVC *view1 = [[ManageAccVC alloc]init];
        [self.navigationController pushViewController:view1 animated:true];
    }
    else if (indexPath.row == 2)
    {
        ManageAccVC *view1 = [[ManageAccVC alloc]init];
        view1.isFromDashboard = true;
        [self.navigationController pushViewController:view1 animated:true];
    }
    else if (indexPath.row == 3)
    {
        if ([IS_USER_SKIPPED isEqualToString:@"YES"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IS_USER_LOGGED"];
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IS_USER_SKIPPED"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [APP_DELEGATE movetoLogin];
        }
        else
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeWarning];
            [alert addButton:@"Yes" withActionBlock:^{
                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IS_USER_LOGGED"];
                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IS_USER_SKIPPED"];
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"IS_USER_LOGGEDOUT"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PairedDevices"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                [self clearUserDefaults];

                globalDashBoardVC = [[DashboardVC alloc] init];
                globalSocketAlarmVC = [[SocketAlarmVC alloc] init];
                globalSocketDetailVC = [[SocketDetailVC alloc] init];
                [arrSocketDevices removeAllObjects];
                
                NSString *strDelete = [NSString stringWithFormat:@"Delete from UserAccount_Table"];
                [[DataBaseManager dataBaseManager] execute:strDelete];

                NSString * strDeviceDelete = [NSString stringWithFormat:@"Delete from Device_Table"];
                [[DataBaseManager dataBaseManager] execute:strDeviceDelete];

                NSString * strSocketDetailDelete = [NSString stringWithFormat:@"Delete from Socket_NameImg_Table"];
                [[DataBaseManager dataBaseManager] execute:strSocketDetailDelete];

                [[BLEManager sharedManager] RemoveDevicefromAutoConnection:@"AllDevices"];
                
                NSArray * arrSmartLights = [[BLEManager sharedManager] getLastSocketConnected];
                for (int i =0; i < [arrSmartLights count]; i++)
                {
                    CBPeripheral * p = [arrSmartLights objectAtIndex:i];
                    if (p.state == CBPeripheralStateConnected)
                    {
                        [[BLEManager sharedManager] disconnectDevice:p];
                    }
                }
                
                [APP_DELEGATE movetoLogin];

            }];
            alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"Are you sure want to Logout?"
                   withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
               withDoneButtonTitle:@"No" andButtons:nil];
        }
       
    }
}
#pragma mark - All button click events
-(void)btnMenuClicked:(id)sender
{
    [self.menuContainerViewController setMenuSlideAnimationFactor:0.5f];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
}
#pragma mark - Clear User Defaults
-(void)clearUserDefaults
{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_ID"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_ACCESS_TOKEN"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_EMAIL"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_FIRST_NAME"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_LAST_NAME"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_IMAGE"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_PHONE_NUMBER"];
    [userDefault setValue:@"" forKey:@"CURRENT_USER_ACCESS_PERMISSION"];
//    [userDefault setValue:@"" forKey:@"CURRENT_USER_MOBILE"];

    [userDefault synchronize];
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
