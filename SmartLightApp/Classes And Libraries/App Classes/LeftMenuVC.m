//
//  LeftMenuVC.m
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 01/01/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import "LeftMenuVC.h"
#import "DashboardVC.h"
#import "AlarmVC.h"
#import "SettingsVC.h"
#import "ContactUsVC.h"
#import "HelpLeftMenuVC.h"
#import "ManageAccLeftMenuVC.h"
#import "AboutUsVC.h"
#import "ResetMenuVC.h"
#import "YouTubeVC.h"


@interface LeftMenuVC ()

@end

@implementation LeftMenuVC

- (void)viewDidLoad
{
//    NSLog(@"%@",[[NSArray new]objectAtIndex:10]);
    self.view.backgroundColor = UIColor.clearColor;
    
    arrOptions = [[NSMutableArray alloc] init];
    for (int i = 0; i<8; i++)
    {
    
        NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
        [tempDict setValue:@"no" forKey:@"isSelected"];
        if (i==0) {
            [tempDict setValue:@"Home" forKey:@"name"];
            [tempDict setValue:@"active_home_iconBlack.png" forKey:@"image"];
        }else if (i==1) {
            [tempDict setValue:@"Account" forKey:@"name"];
            [tempDict setValue:@"ic_switch_accountBlack.png" forKey:@"image"];
        }else if (i==2) {
            [tempDict setValue:@"Factory reset device" forKey:@"name"];
            [tempDict setValue:@"resetblack.png" forKey:@"image"];
        }else if (i==3) {
            [tempDict setValue:@"Help" forKey:@"name"];
            [tempDict setValue:@"helpBlack.png" forKey:@"image"];
        }else if (i==4) {
            [tempDict setValue:@"Buy now" forKey:@"name"];
            [tempDict setValue:@"buynow" forKey:@"image"];
        }else if (i==5) {
            [tempDict setValue:@"Demo videos" forKey:@"name"];
            [tempDict setValue:@"youtubebl.png" forKey:@"image"];
        }else if (i==6) {
            [tempDict setValue:@"About Us" forKey:@"name"];
            [tempDict setValue:@"about_icon" forKey:@"image"];
        }else if (i==7) {
            [tempDict setValue:@"Contact Us" forKey:@"name"];
            [tempDict setValue:@"phoneBlack.png" forKey:@"image"];
        }
        
        [arrOptions addObject:tempDict];
    }
    [self setContentViewFrames];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getUserInformation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserInformationNotification:) name:@"getUserInformation" object:nil];


    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)getUserInformationNotification:(NSNotification*)notification
{
    if ([IS_USER_SKIPPED isEqualToString:@"YES"])
    {
        [lblAccName setText:[NSString stringWithFormat:@"Guest User"]];
        [lblPhone setText:[NSString stringWithFormat:@""]];
    }
    else
    {
        [lblAccName setText:[NSString stringWithFormat:@"%@", [self checkforValidString:CURRENT_ACCOUNT_NAME]]];
        [lblPhone setText:[NSString stringWithFormat:@"%@", [self checkforValidString:CURRENT_USER_MOBILE]]];
    }
}
#pragma mark - Set Content Frames
-(void)setContentViewFrames
{
    int leftMenuWidth = DEVICE_WIDTH - (50*approaxSize);
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0,20,leftMenuWidth, 190)];
    [viewHeader setBackgroundColor:global_brown_color];
    [self.view addSubview:viewHeader];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.startPoint = CGPointMake(0.0, 0.5);
//    gradient.endPoint = CGPointMake(1.0, 0.5);
   
    gradient.colors = @[(id)[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1].CGColor, (id)[UIColor colorWithRed:163.0/255.0 green:31.0/255.0 blue:17.0/255.0 alpha:1].CGColor];
    
    gradient.frame = viewHeader.bounds;
    [viewHeader.layer insertSublayer:gradient atIndex:0];
    
    UIImageView *imgLogo = [[UIImageView alloc]init];
    imgLogo.backgroundColor = UIColor.clearColor;
    imgLogo.contentMode = UIViewContentModeScaleAspectFit ;
    imgLogo.frame = CGRectMake(10,0,leftMenuWidth-20, 100);
    imgLogo.image = [UIImage imageNamed:@"logo.png"];
    [viewHeader addSubview:imgLogo];
    
    UILabel * lblTitle = [[UILabel alloc]init];
    lblTitle.backgroundColor = UIColor.clearColor;
    lblTitle.textColor = UIColor.whiteColor;
    lblTitle.font = [UIFont fontWithName:CGBold size:textSizes];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.frame = CGRectMake(0, 100,leftMenuWidth, 44);
    lblTitle.text = @"Vithamas Technologies";
    [viewHeader addSubview:lblTitle];

    lblAccName = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, leftMenuWidth, 30)];
    [lblAccName setBackgroundColor:[UIColor clearColor]];
    lblAccName.textAlignment = NSTextAlignmentCenter;
    [lblAccName setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [lblAccName setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblAccName];
    
    lblPhone = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, leftMenuWidth, 30)];
    [lblPhone setBackgroundColor:[UIColor clearColor]];
    lblPhone.textAlignment = NSTextAlignmentCenter;
    [lblPhone setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [lblPhone setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblPhone];

    tblContent =[[UITableView alloc]initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, self.view.frame.size.height-200) style:UITableViewStylePlain];
    [tblContent setBackgroundColor:[UIColor whiteColor]];
    tblContent.showsVerticalScrollIndicator = NO;
    tblContent.showsHorizontalScrollIndicator=NO;
    tblContent.scrollEnabled = false;
    [tblContent setDelegate:self];
    [tblContent setDataSource:self];
    [tblContent setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tblContent];
    
    if ([IS_USER_SKIPPED isEqualToString:@"YES"])
    {
        [lblAccName setText:[NSString stringWithFormat:@"Guest User"]];
        [lblPhone setText:[NSString stringWithFormat:@""]];
        
    }
    else
    {
        [lblAccName setText:[NSString stringWithFormat:@"%@", [self checkforValidString:CURRENT_ACCOUNT_NAME]]];
        [lblPhone setText:[NSString stringWithFormat:@"%@", [self checkforValidString:CURRENT_USER_MOBILE]]];
    }

    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0,44,leftMenuWidth, 180);
        tblContent.frame = CGRectMake(0, 222, self.view.frame.size.width, self.view.frame.size.height-222-40);
        
    }
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        viewHeader.frame = CGRectMake(0,20,leftMenuWidth, 170);
        imgLogo.frame = CGRectMake(10,0,leftMenuWidth-20, 75);
        lblTitle.frame = CGRectMake(0, 70,leftMenuWidth, 44);
        lblAccName.frame = CGRectMake(0, 100, leftMenuWidth, 30);
        lblPhone.frame = CGRectMake(0, 120, leftMenuWidth, 30);
        tblContent.frame = CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height-170);
    }
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        tblContent.scrollEnabled = YES;
        viewHeader.frame = CGRectMake(0,20,leftMenuWidth, 170);
        tblContent.frame = CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height-170);
    }

}

#pragma mark - Button Click
-(void)btnMenuClicked:(id)sender
{
    [self.menuContainerViewController setMenuSlideAnimationFactor:0.5f];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
}
#pragma mark- UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrOptions count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_4)
    {
        return 44;
    }
    else
    {
        return 50;
    }
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 20;
//}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
//    [viewHeader setBackgroundColor:[UIColor clearColor]];
//    return viewHeader;
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0.1;
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellID = nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[[arrOptions objectAtIndex:indexPath.row] valueForKey:@"name"]];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:CGRegular size:15];
    
    cell.imageView.image =  [UIImage imageNamed:[NSString stringWithFormat:@"%@",[[arrOptions objectAtIndex:indexPath.row] valueForKey:@"image"]]];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        globalDashBoardVC = [[DashboardVC alloc] init];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:globalDashBoardVC];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    else if (indexPath.row == 1)
    {
        ManageAccLeftMenuVC *demoController = [[ManageAccLeftMenuVC alloc] init];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:demoController];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    else if (indexPath.row == 2)
    {
        ResetMenuVC *rstVC = [[ResetMenuVC alloc] init];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:rstVC];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    else if (indexPath.row == 3)
    {
        HelpLeftMenuVC *demoController = [[HelpLeftMenuVC alloc] init];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:demoController];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    else if (indexPath.row == 4)
    {
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:@"https://www.amazon.in/dp/B07QGVQ1HH/"]];
    }
    else if (indexPath.row == 5)
    {
        YouTubeVC * youtVC = [[YouTubeVC alloc] init];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:youtVC];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

    }
    else if (indexPath.row == 6)
    {
        AboutUsVC *demoController = [[AboutUsVC alloc] init];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:demoController];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    else if (indexPath.row == 7)
    {
        ContactUsVC *demoController = [[ContactUsVC alloc] init];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:demoController];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark-  error popup
-(void)AlertViewFCTypeCautionCheck:(NSString *)strMsg
{
    [APP_DELEGATE endHudProcess];
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"Vithamas"
                  withSubtitle:strMsg
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
}
@end
