//
//  ManageAccVC.m
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 29/10/18.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "ManageAccVC.h"
#import "LoginVC.h"
#import "customManageAccTableViewCell.h"
#import "VCFloatingActionButton.h"
@interface ManageAccVC ()<floatMenuDelegate>
{
    VCFloatingActionButton *addFloatButton;
    NSInteger selectedIndex;
}
@end

@implementation ManageAccVC
@synthesize isFromDashboard;
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
    arrTable = [[NSMutableArray alloc]init];
    NSString *strTbl;
    if (isFromDashboard == true)
    {
        strTbl = [NSString stringWithFormat:@"Select * from UserAccount_Table"];
        
    }
    else if(isFromDashboard == false)
    {
        strTbl = [NSString stringWithFormat:@"Select * from UserAccount_Table where is_active = '0'"];
    }
    
    [[DataBaseManager dataBaseManager] execute:strTbl resultsArray:arrTable];
    [tblContent reloadData];
    
    if (arrTable.count == 0)
    {
        tblContent.hidden = TRUE;
        lblDisplayMsg.hidden = FALSE;
    }
    else
    {
        tblContent.hidden = FALSE;
        lblDisplayMsg.hidden = TRUE;
    }
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FloatButtonTapped" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(btnAddAccClick) name:@"FloatButtonTapped" object:nil];
  

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
    [lblTitle setText:@"Manage Accounts"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+3]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];

    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 88, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        btnBack.frame = CGRectMake(0, 0, 88, 88);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        lblTitle.frame = CGRectMake(50, 44, DEVICE_WIDTH-100, 44);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH,88);
    }
   
    
    if (isFromDashboard == true)
    {
        lblTitle.text = @"Switch Account";
        
    }

}
#pragma mark - set UI Frames
-(void) setContentViewFrames
{
    btnAddAccount = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAddAccount.frame = CGRectMake(DEVICE_WIDTH-50, 20, 50, 44);
    btnAddAccount.layer.masksToBounds = YES;
    [btnAddAccount setImage:[UIImage imageNamed:@"ic_add_icon.png"] forState:UIControlStateNormal];
    [btnAddAccount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnAddAccount.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btnAddAccount addTarget:self action:@selector(btnAddAccClick) forControlEvents:UIControlEventTouchUpInside];
 //   [self.view addSubview:btnAddAccount];
    
    tblContent = [[UITableView alloc]init];
    tblContent.frame = CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT-64-44);
    tblContent.backgroundColor = UIColor.clearColor;
    tblContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblContent.delegate = self;
    tblContent.dataSource = self;
    [self.view addSubview:tblContent];
    if (IS_IPHONE_X)
    {
        tblContent.frame = CGRectMake(0, 88, DEVICE_WIDTH, DEVICE_HEIGHT-64-44);

    }
    
    lblDisplayMsg = [[UILabel alloc]initWithFrame:CGRectMake(10, (DEVICE_HEIGHT/2)-30, DEVICE_WIDTH-20, 70)];
    lblDisplayMsg.textColor = UIColor.whiteColor;
    lblDisplayMsg.numberOfLines = 2;
    lblDisplayMsg.textAlignment = NSTextAlignmentCenter;
    lblDisplayMsg.text = @"Currently no accounts have been added.";
    lblDisplayMsg.font = [UIFont fontWithName:CGRegular size:textSizes+5];
    [self.view addSubview:lblDisplayMsg];
    
    
    
    
    addFloatButton = [[VCFloatingActionButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-70, DEVICE_HEIGHT-100, 60, 60) normalImage:[UIImage imageNamed:@"ic_add_icon.png"] andPressedImage:[UIImage imageNamed:@"ic_add_icon.png"] withScrollview:tblContent];
    addFloatButton.backgroundColor = global_brown_color;
    addFloatButton.layer.masksToBounds = true;
    addFloatButton.layer.cornerRadius = 30;
    addFloatButton.delegate = self;
    addFloatButton.hideWhileScrolling = YES;
    [self.view addSubview:addFloatButton];

    
    [tblContent reloadData];
    
    if (arrTable.count == 0)
    {
        tblContent.hidden = TRUE;
        lblDisplayMsg.hidden = FALSE;
    }
    else
    {
        tblContent.hidden = FALSE;
        lblDisplayMsg.hidden = TRUE;
    }
    
    if (isFromDashboard == true)
    {
        btnAddAccount.hidden = true;
        addFloatButton.hidden = true;
    }
 
    
}


#pragma mark - TableView Delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrTable.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    customManageAccTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[customManageAccTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    cell.lblView.hidden = false;
    cell.lblAccName.hidden = false;
    cell.lblMobNo.hidden = false;
//    cell.btnDelete.hidden = false;
    cell.imgDelete.hidden = false;

    cell.imgLogo.hidden = true;
    cell.lblName.hidden = true;
    cell.lblLine.hidden = true;

    

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lblAccName.text = [self checkforValidString:[[arrTable objectAtIndex:indexPath.row] valueForKey: @"account_name"]];
    cell.lblMobNo.text = [[arrTable objectAtIndex:indexPath.row] valueForKey:@"user_mobile_no"];

    
    if (isFromDashboard == true)
    {
        if ([[[arrTable objectAtIndex:indexPath.row] valueForKey:@"is_active"] isEqualToString:@"0"])
        {
            cell.imgDelete.image = [UIImage imageNamed:@"radioUnselectedWhite.png"];
        }
        else
        {
            cell.imgDelete.image = [UIImage imageNamed:@"radioSelectedWhite.png"];
        }
        
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    intSelectedRow = indexPath.row;
    
    if (isFromDashboard == false)
    {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeWarning];
            [alert addButton:@"Yes" withActionBlock:^
             {
                 NSString *strDeleteDevice = [NSString stringWithFormat:@"delete from 'UserAccount_Table' where server_user_id = '%@' ",[[arrTable objectAtIndex:indexPath.row] valueForKey:@"server_user_id"]];
                 [[DataBaseManager dataBaseManager] execute:strDeleteDevice];
                 [arrTable removeObjectAtIndex:indexPath.row];
                 [tblContent reloadData];
        
             }];
            alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"Are you sure that you want to delete this account?."
                   withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
               withDoneButtonTitle:@"No" andButtons:nil];
    }
    else
    {
        if (arrTable.count <=1 )
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"You should have more than 1 Account to switch accounts"
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
        if ([[[arrTable objectAtIndex:intSelectedRow] valueForKey:@"is_active"] isEqualToString:@"0"])
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeWarning];
            [alert addButton:@"Yes" withActionBlock:^
             {
                 
                 if (isFromDashboard == true)
                 {
                     if ([APP_DELEGATE isNetworkreachable])
                     {
                         selectedIndex = indexPath.row;
                         [self CheckUserCredentialDetials];
                     }
                     else
                     {
                         [self setSwitchAccValue];
                         
                     }
                 }
             }];
            alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"Are you sure that you want to switch to this account?."
                   withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
               withDoneButtonTitle:@"No" andButtons:nil];
        }
    }
   

    
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = UIColor.clearColor;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
-(void)setSwitchAccValue
{
    
    
    NSString *strObject = [NSString stringWithFormat:@"update UserAccount_Table set is_active = '0'"];
    [[DataBaseManager dataBaseManager] execute:strObject];
    
    strObject = [NSString stringWithFormat:@"update UserAccount_Table set is_active = '1' where server_user_id = '%@'",[[arrTable objectAtIndex:intSelectedRow]valueForKey:@"server_user_id"]];
    [[DataBaseManager dataBaseManager]execute:strObject];
    
    [arrTable setValue:@"0" forKey:@"is_active"];
    [[arrTable objectAtIndex:intSelectedRow] setObject:@"1" forKey:@"is_active"];
    [tblContent reloadData];
    
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    tmpDict = [[arrTable objectAtIndex:intSelectedRow] mutableCopy];
    
    [APP_DELEGATE GenerateEncryptedKeyforLogin:[tmpDict valueForKey:@"user_mobile_no"]];
    [self ResetAllUUIDs];
    [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"user_mobile_no"] forKey:@"CURRENT_USER_MOBILE"];
    [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"user_pw"] forKey:@"CURRENT_USER_PASS"];
    [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"server_user_id"] forKey:@"CURRENT_USER_ID"];
    [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"user_name"] forKey:@"CURRENT_USER_NAME"];
    [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"user_email"] forKey:@"CURRENT_USER_EMAIL"];
    [[NSUserDefaults standardUserDefaults] setValue:[tmpDict objectForKey:@"account_name"] forKey:@"CURRENT_ACCOUNT_NAME"];
    [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"IS_USER_SKIPPED"];
    [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"IS_USER_LOGGED"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:true];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"getUserInformation" object:nil];

    
    
}
#pragma mark - All button click events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)btnAddAccClick
{
    LoginVC *view1 = [[LoginVC alloc]init];
    view1.isFromMangeAccount = true;
    [self.navigationController pushViewController:view1 animated:true];
}
//-(void)btnDeleteAction:(id)sender
//{
//    FCAlertView *alert = [[FCAlertView alloc] init];
//    alert.colorScheme = [UIColor blackColor];
//    [alert makeAlertTypeWarning];
//    [alert addButton:@"Yes" withActionBlock:^
//     {
//         NSString *strDeleteDevice = [NSString stringWithFormat:@"delete from 'UserAccount_Table' where server_user_id = '%@' ",[[arrTable objectAtIndex:[sender tag]] valueForKey:@"server_user_id"]];
//         [[DataBaseManager dataBaseManager] execute:strDeleteDevice];
//         [arrTable removeObjectAtIndex:[sender tag]];
//         [tblContent reloadData];
//
//     }];
//    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
//    [alert showAlertInView:self
//                 withTitle:@"Smart Light"
//              withSubtitle:@"Are you sure that you want to delete this account?."
//           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
//       withDoneButtonTitle:@"No" andButtons:nil];
//}

#pragma mark - Web Service Call
-(void)loginViaEmailWebService
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Logging..."];
    
    NSString *websrviceName=@"login";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:strMobNo forKey:@"mobile_number"];
    [dict setValue:strPassword forKey:@"password"];
    
    NSString *deviceToken =deviceTokenStr;
    if (deviceToken == nil || deviceToken == NULL)
    {
        [dict setValue:@"123456789" forKey:@"device_token"];
    }
    else
    {
        [dict setValue:deviceToken forKey:@"device_token"];
    }
    [dict setValue:@"ios" forKey:@"device_type"];
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"login";
    manager.delegate = self;
    NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/";
    [manager urlCall:[NSString stringWithFormat:@"%@%@",strServerUrl,websrviceName] withParameters:dict];
    
}
-(void)ResetAllUUIDs
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"globalUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"colorUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"whiteColorUDID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OnOffUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatternUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DeleteUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PingUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"WhiteUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TimeUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AddGroupUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DeleteGroupUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DeleteAlarmUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MusicUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"RememberUDID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IdentifyUUID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [APP_DELEGATE createAllUUIDs];
    
}
-(void)CheckUserCredentialDetials
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
    [dict setValue:CURRENT_USER_PASS forKey:@"password"];
    
    if ([arrTable count]>selectedIndex)
    {
        [dict setValue:[[arrTable objectAtIndex:selectedIndex]valueForKey:@"server_user_id"] forKey:@"user_id"];
        [dict setValue:[[arrTable objectAtIndex:selectedIndex]valueForKey:@"user_pw"] forKey:@"password"];
    }
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"CheckUserDetails";
    manager.delegate = self;
    NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/check_user_details";
    [manager urlCall:strServerUrl withParameters:dict];
}

#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];
    
//    NSLog(@"The result is...%@", result);
    
    if ([[result valueForKey:@"commandName"] isEqualToString:@"login"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            [self setSwitchAccValue];

        }
        else
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:[[result valueForKey:@"result"]valueForKey:@"message"]
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"CheckUserDetails"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"false"])
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Password not matching with database."])
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:@"This Account's credential has been changed. Please try again with correct credentials."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
        
            }
        }
        else
        {
            if ([arrTable count]>selectedIndex)
            {
                strMobNo = [[arrTable objectAtIndex:selectedIndex]valueForKey:@"user_mobile_no"];
                strPassword = [[arrTable objectAtIndex:selectedIndex]valueForKey:@"user_pw"];
                [self loginViaEmailWebService];
            }
        }
    }
}

- (void)onError:(NSError *)error
{
    [APP_DELEGATE endHudProcess];
    
//    NSLog(@"The error is...%@", error);
    
   
    
    NSInteger ancode = [error code];
    
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
//    NSLog(@"errorDict===%@",errorDict);
    
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009)
    {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
    }
    else
    {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
    }
    
    
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
//        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
    }
}
#pragma mark - float Button Delegate
-(void) didSelectMenuOptionAtIndex:(NSInteger)row
{
    LoginVC *view1 = [[LoginVC alloc]init];
    view1.isFromMangeAccount = true;
    [self.navigationController pushViewController:view1 animated:true];
}
- (void)didReceiveMemoryWarning
{
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

