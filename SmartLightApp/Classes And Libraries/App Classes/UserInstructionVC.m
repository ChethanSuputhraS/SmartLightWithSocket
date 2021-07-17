//
//  UserInstructionVC.m
//  SmartLightApp
//
//  Created by Vithamas Technologies on 23/03/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import "UserInstructionVC.h"
#import "LoginVC.h"


@interface UserInstructionVC ()
{
    UIView *viewForLogin ,*viewForGuest,* viewBG ,* viewforText;
    UIButton *  btnNext, *btnYes, *btnNO;
    BOOL isYesSelected;
}
@end

@implementation UserInstructionVC

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
    self.view.backgroundColor = [UIColor colorWithRed:19/255.0 green:24/255.0 blue:27/255.0 alpha:1.0];
    int yy = 60;
    if (IS_IPHONE_X)
    {
        yy = 84;
    }
    viewForLogin = [[UIView alloc] initWithFrame:CGRectMake(0,0,DEVICE_WIDTH-00,DEVICE_HEIGHT)];
    [viewForLogin setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
//    viewForLogin.layer.shadowColor = [UIColor darkGrayColor].CGColor;
//    viewForLogin.layer.shadowOffset = CGSizeMake(0.1, 0.1);
//    viewForLogin.layer.shadowRadius = 25;
//    viewForLogin.layer.shadowOpacity = 0.5;
    [self.view addSubview:viewForLogin];
    
    
    UIImageView * viewForSecured = [[UIImageView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-175)/2, yy+70, 175, 135)];
    viewForSecured.backgroundColor = UIColor.clearColor;
    viewForSecured.image = [UIImage imageNamed:@"securedgreen.png"];
    [self.view addSubview:viewForSecured];
    
    yy = yy + 210;
    
    UILabel * lblSecureLogin = [[UILabel alloc] initWithFrame:CGRectMake(5, yy, DEVICE_WIDTH-10, 50)];
    [lblSecureLogin setBackgroundColor:[UIColor clearColor]];
    [lblSecureLogin setText:@"Want secure connection?"];
    [lblSecureLogin setTextAlignment:NSTextAlignmentCenter];
    [lblSecureLogin setFont:[UIFont fontWithName:CGRegular size:textSizes+7]];
    [lblSecureLogin setTextColor:[UIColor whiteColor]];
    [self.view addSubview:lblSecureLogin];
    
    UIButton *  btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMore setFrame:CGRectMake(DEVICE_WIDTH/2+155, yy , 100, 50)];
//    [btnMore setTitle:@"Know more" forState:UIControlStateNormal];
    [btnMore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnMore.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    btnMore.titleLabel.textAlignment = NSTextAlignmentLeft;
    [btnMore addTarget:self action:@selector(btnMoreClick) forControlEvents:UIControlEventTouchUpInside];
//    btnMore.backgroundColor = global_brown_color;
    [btnMore setImage:[UIImage imageNamed:@"info_icon.png"] forState:UIControlStateNormal];
    btnMore.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    btnLogin.layer.cornerRadius = 10;
    [viewForLogin addSubview:btnMore];
    
    
    yy = yy + 50;
    
    UIImageView * imgPopUpBG = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2-100, yy , 100, 50)];
    [imgPopUpBG setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
//    imgPopUpBG.alpha = 0.5;
    imgPopUpBG.layer.cornerRadius = 10;
    [viewForLogin addSubview:imgPopUpBG];
    
    btnYes = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnYes setFrame:CGRectMake(DEVICE_WIDTH/2-100, yy , 100, 50)];
    [btnYes setTitle:@" YES" forState:UIControlStateNormal];
    [btnYes setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnYes.titleLabel setFont:[UIFont fontWithName:CGBold size:textSizes]];
    btnYes.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btnYes addTarget:self action:@selector(btnYesClick) forControlEvents:UIControlEventTouchUpInside];
    [btnYes setImage:[UIImage imageNamed:@"radioUnselectedWhite.png"] forState:UIControlStateNormal];
//    btnYes.backgroundColor = global_brown_color;
    btnYes.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    btnLogin.layer.cornerRadius = 10;
    [viewForLogin addSubview:btnYes];

    
    UIImageView * imgBGNo = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2+10, yy , 100, 50)];
    [imgBGNo setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
//    imgPopUpBG.alpha = 0.5;
    imgBGNo.layer.cornerRadius = 10;
    [viewForLogin addSubview:imgBGNo];
    
    btnNO = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNO setFrame:CGRectMake(DEVICE_WIDTH/2+10, yy , 100, 50)];
    [btnNO setTitle:@" NO" forState:UIControlStateNormal];
    [btnNO setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNO.titleLabel setFont:[UIFont fontWithName:CGBold size:textSizes]];
    btnNO.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btnNO setImage:[UIImage imageNamed:@"radioSelectedWhite.png"] forState:UIControlStateNormal];
    [btnNO addTarget:self action:@selector(btnNOClick) forControlEvents:UIControlEventTouchUpInside];
//    btnNO.backgroundColor = global_brown_color;
//    btnLogin.layer.cornerRadius = 10;
    btnNO.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [viewForLogin addSubview:btnNO];
    
    yy = yy + 100;
    btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setFrame:CGRectMake(10, yy , DEVICE_WIDTH - 20, 50)];
    [btnNext setTitle:@"Next" forState:UIControlStateNormal];
    [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNext.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    btnNext.titleLabel.textAlignment = NSTextAlignmentLeft;
    [btnNext addTarget:self action:@selector(btnNextClick) forControlEvents:UIControlEventTouchUpInside];
    btnNext.backgroundColor = global_brown_color;
//    btnLogin.layer.cornerRadius = 10;
    [viewForLogin addSubview:btnNext];
    
     isYesSelected = NO;

    yy = yy + 50;
    UILabel * lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(5, yy , viewForLogin.frame.size.width-10, 100)];
    [lblMessage setBackgroundColor:[UIColor clearColor]];
    [lblMessage setText:@"With Login user can secure their devices and only app with same credentials can control their devices."];
//    [lblMessage setTextAlignment:NSTextAlignmentRight];
    [lblMessage setFont:[UIFont fontWithName:CGRegularItalic size:textSizes+2]];
    [lblMessage setTextColor:[UIColor whiteColor]];
    lblMessage.numberOfLines = 6;
//    [viewForLogin addSubview:lblMessage];
    

    
    
    yy = yy + 150;
    UILabel * lblguest = [[UILabel alloc] initWithFrame:CGRectMake(5, yy, viewForLogin.frame.size.width, 50)];
    [lblguest setBackgroundColor:[UIColor clearColor]];
    [lblguest setText:@"GUEST USER"];
//    [lblguest setTextAlignment:NSTextAlignmentCenter];
    [lblguest setFont:[UIFont fontWithName:CGBold size:textSizes+15]];
    [lblguest setTextColor:[UIColor whiteColor]];
//    [viewForLogin addSubview:lblguest];
    
    yy = yy + 50;

    UILabel * lblMessageGuest = [[UILabel alloc] initWithFrame:CGRectMake(5, yy, viewForLogin.frame.size.width-20, 100)];
    [lblMessageGuest setText:@"Login as Guest User will allow user to share device other Guest user and can control as well."];
//    [lblMessageGuest setTextAlignment:NSTextAlignmentCenter];
    [lblMessageGuest setFont:[UIFont fontWithName:CGRegularItalic size:textSizes+2]];
    [lblMessageGuest setTextColor:[UIColor whiteColor]];
    lblMessageGuest.numberOfLines = 6;
//    [viewForLogin addSubview:lblMessageGuest];
    
    yy = yy + 100;
    UIButton * btnGuestUser = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnGuestUser setFrame:CGRectMake(5, yy, 200, 50)];
    [btnGuestUser setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnGuestUser.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [btnGuestUser addTarget:self action:@selector(btnGuestClick) forControlEvents:UIControlEventTouchUpInside];
    btnGuestUser.backgroundColor = global_brown_color;
    [btnGuestUser setTitle:@"Click here to Skip login" forState:UIControlStateNormal];
    [btnGuestUser setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    btnGuestUser.layer.cornerRadius = 10;
    btnGuestUser.titleLabel.textAlignment = NSTextAlignmentLeft;

//    [viewForLogin addSubview:btnGuestUser];
    
    if (IS_IPHONE_X)
    {
//        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
//        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
//        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
    }
}
#pragma mark- Buttons
-(void)btnYesClick
{
    isYesSelected = YES;
    [btnYes setImage:[UIImage imageNamed:@"radioSelectedWhite.png"] forState:UIControlStateNormal];
    [btnNO setImage:[UIImage imageNamed:@"radioUnselectedWhite.png"] forState:UIControlStateNormal];
}
-(void)btnNOClick
{
    isYesSelected = NO;
    [btnYes setImage:[UIImage imageNamed:@"radioUnselectedWhite.png"] forState:UIControlStateNormal];
    [btnNO setImage:[UIImage imageNamed:@"radioSelectedWhite.png"] forState:UIControlStateNormal];

}
-(void)btnNextClick
{
    if (isYesSelected == YES)
    {
        [self btnLoginClick];
    }
    else
    {
        [self btnGuestClick];
    }
}
-(void)btnMoreClick
{
    [self SetupForInstructionView];
}

-(void)btnLoginClick
{
    LoginVC * lVc = [[LoginVC alloc] init];
    [self.navigationController pushViewController:lVc animated:true];
}
-(void)btnGuestClick // skip user
{
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IS_LOGGEDIN"];
    [[NSUserDefaults standardUserDefaults] setValue:@"000" forKey:@"CURRENT_USER_ID"];
    [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"IS_USER_SKIPPED"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self AddAlarmforLoggedinUser];

    [APP_DELEGATE GenerateEncryptedKeyforLogin:@""];
    [self ResetAllUUIDs];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
    [UIView commitAnimations];
    [APP_DELEGATE goToDashboard];
    [APP_DELEGATE addScannerView];
}

-(void)AddAlarmforLoggedinUser
{
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    
    NSString * strCheck = [NSString stringWithFormat:@"select * from Alarm_Table where user_id = '%@'",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strCheck resultsArray:tmpArr];
    
    if ([tmpArr count]==0)
    {
        for (int i = 0; i<6; i++)
        {
            NSString * strIndex = [NSString stringWithFormat:@"%d",i+1];
            NSString * strAlarmDevice = [NSString stringWithFormat:@"insert into 'Alarm_Table'('user_id','status','AlarmIndex') values('%@','%@','%@')",CURRENT_USER_ID,@"2",strIndex];
            [[DataBaseManager dataBaseManager] execute:strAlarmDevice];
        }
    }
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
#pragma mark- Message view
-(void)SetupForInstructionView
{
        [ viewforText removeFromSuperview];
        viewBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
        viewBG .backgroundColor = UIColor.blackColor;
        viewBG.alpha = 0.5;
        [self.view addSubview:viewBG];
    
        viewforText = [[UIView alloc] initWithFrame:CGRectMake(20, DEVICE_HEIGHT, DEVICE_WIDTH-40, 400)];
        viewforText .backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1]; //
        viewforText.layer.cornerRadius = 3;
        viewforText.layer.borderColor = UIColor.lightGrayColor.CGColor;
        viewforText.layer.borderWidth = 0.2;
        viewforText.clipsToBounds = true;
        [self.view addSubview:viewforText];
    
        int yy = 5;
    
        UILabel * lblQuestion1 = [[UILabel alloc] initWithFrame:CGRectMake(5, yy, viewforText.frame.size.width-10, 40)];
        lblQuestion1.text = @"What is secured connection ?";
        lblQuestion1.textColor = UIColor.whiteColor;
        lblQuestion1.textAlignment = NSTextAlignmentCenter;
        lblQuestion1.numberOfLines = 0;
        lblQuestion1.font = [UIFont fontWithName:CGBold size:textSizes+3];
        [viewforText addSubview:lblQuestion1];
    
        yy = yy+50;
    
        UILabel * lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(10, yy , viewforText.frame.size.width-20, 250)];
        [lblMessage setBackgroundColor:[UIColor clearColor]];
        [lblMessage setText:@"Enabling secure connection requires a Login Name and password. The connection with the device will be encrypted and only the app with the login name and password can control the device. You can share the login name and password with family and friends who also can control the device. If security is not enabled anyone with the app can control the device."];
//    [lblMessage setTextAlignment:NSTextAlignmentRight];
        [lblMessage setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
        [lblMessage setTextColor:[UIColor whiteColor]];
        lblMessage.numberOfLines = 0;
       [viewforText addSubview:lblMessage];
    
        yy = yy+150;
    
        UILabel * lblQuestion2 = [[UILabel alloc] initWithFrame:CGRectMake(5, yy, viewforText.frame.size.width-10, 40)];
        lblQuestion2.text = @"What is Guest User Login ?";
        lblQuestion2.textColor = UIColor.whiteColor;
//    lblHint.backgroundColor = UIColor.lightGrayColor;
        lblQuestion2.textAlignment = NSTextAlignmentCenter;
        lblQuestion2.numberOfLines = 0;
        lblQuestion2.font = [UIFont fontWithName:CGBold size:textSizes+3];
//        [viewforText addSubview:lblQuestion2];
    
        yy = yy+30;
        UILabel * lblMessageGuest = [[UILabel alloc] initWithFrame:CGRectMake(10, yy, viewforText.frame.size.width-20, 100)];
        [lblMessageGuest setText:@"Login as Guest User will allow user to share device other Guest user and can control as well."];
//    [lblMessageGuest setTextAlignment:NSTextAlignmentCenter];
        [lblMessageGuest setFont:[UIFont fontWithName:CGRegularItalic size:textSizes+2]];
        [lblMessageGuest setTextColor:[UIColor whiteColor]];
        lblMessageGuest.numberOfLines = 3;
//        [viewforText addSubview:lblMessageGuest];
        
        yy = yy+100;
    
        UIButton *  btnClose = [[UIButton alloc]init];
        btnClose.frame = CGRectMake(20, viewforText.frame.size.height-50, viewforText.frame.size.width-40, 50);
        [btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
        [btnClose setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
//        btnClose.backgroundColor = [UIColor colorWithRed:39.0/255 green:176.0/255 blue:96.0/255 alpha:1];//UIColor.yellowColor;
//        btnNotNow.alpha = 0.7;
        [btnClose setTitle:@"Close" forState:normal];
        [btnClose setTitleColor:UIColor.whiteColor forState:normal];
        btnClose.titleLabel.font = [UIFont fontWithName:CGBold size:textSizes+3];
        [viewforText addSubview:btnClose];
    
        UIButton *  btnSave = [[UIButton alloc]init];
        btnSave.frame = CGRectMake(viewforText.frame.size.width/2, viewforText.frame.size.height-50, viewforText.frame.size.width/2, 50);
        [btnSave addTarget:self action:@selector(btnokClick) forControlEvents:UIControlEventTouchUpInside];
        [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        btnSave.backgroundColor = [UIColor colorWithRed:1 green:155.0/255 blue:0 alpha:1];//UIColor.yellowColor;
        [btnSave setTitle:@"OK" forState:normal];
//        btnSave.alpha = 0.7;
        [btnSave setTitleColor:UIColor.whiteColor forState:normal];
        btnSave.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+2];
//        [viewforText addSubview:btnSave];
    
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
        {
            viewforText.frame = CGRectMake(20, (DEVICE_HEIGHT-400)/2, DEVICE_WIDTH-40, 400);
        }
            completion:NULL];
}
-(void)btnokClick
{
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
    self-> viewforText.frame = CGRectMake(20, DEVICE_HEIGHT, DEVICE_WIDTH-40, 400);
     }
        completion:(^(BOOL finished)
      {
        
    })];
}
-(void)btnCloseClick
{
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
    self-> viewforText.frame = CGRectMake(20, DEVICE_HEIGHT, DEVICE_WIDTH-40, 400);
     }
        completion:(^(BOOL finished)
      {
        [self-> viewBG removeFromSuperview];

    })];
}
@end
