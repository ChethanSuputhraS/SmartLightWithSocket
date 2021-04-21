//
//  ResetMenuVC.m
//  SmartLightApp
//
//  Created by Kalpesh Panchasara on 31/03/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import "ResetMenuVC.h"
#import "HelpLeftMenuCell.h"
#import "ResetSocketVC.h"
#import "FactoryResetVC.h"


@interface ResetMenuVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ResetMenuVC

- (void)viewDidLoad
{
    self.view.backgroundColor = global_brown_color;
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    int yy = 0;
    if (IS_IPHONE_4)
    {
        yy = 64;
    }
    else if (IS_IPHONE_X)
    {
        yy = 88;
    }
    self.view.backgroundColor = [UIColor colorWithRed:19/255.0 green:24/255.0 blue:27/255.0 alpha:1.0];
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Factory Reset"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * imgMenu = [[UIImageView alloc]initWithFrame:CGRectMake(10,20+7, 33, 30)];
    imgMenu.image = [UIImage imageNamed:@"menu.png"];
    imgMenu.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgMenu];
    
    UIButton * btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMenu setFrame:CGRectMake(0, 0, 80, 64)];
    [btnMenu addTarget:self action:@selector(btnMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnMenu];
    
    yy = yy + 44;
    
    UITableView * tblResetMenu = [[UITableView alloc]initWithFrame:CGRectMake(0, yy+20, DEVICE_WIDTH, DEVICE_HEIGHT-yy-20)];
    tblResetMenu.backgroundColor = UIColor.clearColor;
    tblResetMenu.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblResetMenu.delegate = self;
    tblResetMenu.dataSource = self;
    tblResetMenu.scrollEnabled = false;
    [self.view addSubview:tblResetMenu];
    
    if (IS_IPHONE_X)
    {
        tblResetMenu.frame = CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy);
    }
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
    }
}
#pragma mark - TableView Delegate Methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    HelpLeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[HelpLeftMenuCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    
    cell.lblYoutube.hidden = true;
    cell.lblAppVersion.hidden = true;
    cell.lblYoutube.hidden = false;
    cell.imgCellBG.frame = CGRectMake(0, 0, DEVICE_WIDTH, 55);
    cell.lblName.frame = CGRectMake(10, 0, DEVICE_WIDTH-20, 54);
    cell.imgLogo.hidden =  NO;
    cell.lblName.font = [UIFont fontWithName:CGRegular size:textSizes];

    cell.lblLine.frame = CGRectMake(5,54, DEVICE_WIDTH-10, 0.5);

    if (indexPath.row == 0)
    {
        cell.lblName.text = @"Tap here to Reset Smartlight Device";
    }
    else if (indexPath.row == 1)
    {
        cell.lblName.text = @"Tap here to Reset Powersocket Device";
    }
    
//    arrowRight
//    cell.imgLogo.frame = CGRectMake(DEVICE_WIDTH - 40, 10, 35, 35);
//    cell.imgLogo.image = [UIImage imageNamed:@"arrowRight.png"];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.tintColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        FactoryResetVC * userDetails = [[FactoryResetVC alloc] init];
        [self.navigationController pushViewController:userDetails animated:YES];
    }
    else if (indexPath.row == 1)
    {
        ResetSocketVC * rstSVC = [[ResetSocketVC alloc] init];
        [self.navigationController pushViewController:rstSVC animated:true];
    }
}
#pragma mark- all button deligate
-(void)btnMenuClicked:(id)sender
{
    [self.menuContainerViewController setMenuSlideAnimationFactor:0.5f];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}
@end
