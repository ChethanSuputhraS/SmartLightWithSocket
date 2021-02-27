//
//  OtpVerifyVC.m
//  SmartLightApp
//
//  Created by stuart watts on 03/10/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "OtpVerifyVC.h"
#import "GSPasswordInputView.h"
@import Firebase;
#import <FirebaseAuth/FIRPhoneAuthProvider.h>

@interface OtpVerifyVC ()<GSPasswordInputViewDelegate,URLManagerDelegate,FCAlertViewDelegate, FIRAuthUIDelegate>
{
    GSPasswordInputView *pwdInputView;
    long lastHeight;
}
@end

@implementation OtpVerifyVC

@synthesize dataDict,verificationID;
- (void)viewDidLoad
{
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    [self.view addSubview:imgBack];
    
    [self setContentViewFrames];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark - Set UI frames
-(void)setContentViewFrames
{
    scrlContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    scrlContent.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrlContent];
    
    UILabel * lblName =  [[UILabel alloc] init];
    lblName.frame = CGRectMake(15, 30, DEVICE_WIDTH-30, 30);
    lblName.textAlignment = NSTextAlignmentCenter;
    lblName.textColor = [UIColor whiteColor];
    lblName.text = @"Verify Mobile No";
    [lblName setFont:[UIFont fontWithName:CGRegular size:textSizes + 2]];
    [scrlContent addSubview:lblName];
    
    if (IS_IPHONE_X)
    {
        lblName.frame = CGRectMake(15, 40, DEVICE_WIDTH-30, 30);
    }

    
    viewPopUp = [[UIView alloc] initWithFrame:CGRectMake(15, 156*approaxSize, DEVICE_WIDTH-30, 288*approaxSize)];
    [viewPopUp setBackgroundColor:[UIColor clearColor]];
    viewPopUp.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewPopUp.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    viewPopUp.layer.shadowRadius = 25;
    viewPopUp.layer.shadowOpacity = 0.5;
    [scrlContent addSubview:viewPopUp];
    
    if (IS_IPHONE_4)
    {
        viewPopUp.frame = CGRectMake(15, 110, DEVICE_WIDTH-30, 250);
    }
    
    long yy = 15;
    
    UIImageView * imgPopUpBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewPopUp.frame.size.width, viewPopUp.frame.size.height)];
    [imgPopUpBG setBackgroundColor:[UIColor blackColor]];
    imgPopUpBG.alpha = 0.7;
    imgPopUpBG.layer.cornerRadius = 10;
    [viewPopUp addSubview:imgPopUpBG];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imgPopUpBG.bounds];
    imgPopUpBG.layer.masksToBounds = NO;
    imgPopUpBG.layer.shadowColor = [UIColor whiteColor].CGColor;
    imgPopUpBG.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imgPopUpBG.layer.shadowOpacity = 0.5f;
    imgPopUpBG.layer.shadowPath = shadowPath.CGPath;
    
    int txtSize = 15;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        txtSize = 14;
    }
    
    lblHint =  [[UILabel alloc] init];
    lblHint.frame = CGRectMake(15, yy, viewPopUp.frame.size.width-30, 80);
    lblHint.textAlignment = NSTextAlignmentCenter;
    lblHint.numberOfLines = 0;
    lblHint.textColor = [UIColor whiteColor];
    lblHint.text = @"Enter your 6 digit verification code which sent to your mobile to verify";
    [lblHint setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [viewPopUp addSubview:lblHint];
    
    yy = yy + 80;
    
    lastHeight = yy;
    [pwdInputView removeFromSuperview];
    pwdInputView = [[GSPasswordInputView alloc] initWithFrame:CGRectMake((viewPopUp.frame.size.width-160)/2, (yy)*approaxSize, 160, 40*approaxSize)];
    pwdInputView.numberOfDigit = 6;
    pwdInputView.delegate = self;
    [viewPopUp addSubview:pwdInputView];
    
    yy = yy + 40*approaxSize + 15*approaxSize;
    
    UIButton * btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSubmit.frame = CGRectMake(15, yy, viewPopUp.frame.size.width-30, 38);
//    [btnSubmit setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    btnSubmit.backgroundColor = global_brown_color;
    [btnSubmit setTitle:@"SUBMIT" forState:UIControlStateNormal];
    [btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSubmit addTarget:self action:@selector(btnSubmitClick) forControlEvents:UIControlEventTouchUpInside];
    [btnSubmit.titleLabel setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [viewPopUp addSubview:btnSubmit];
    
    yy = yy + 38*approaxSize + 10*approaxSize;
    
    UILabel * lblHint2 =  [[UILabel alloc] init];
    lblHint2.frame = CGRectMake(15, yy, viewPopUp.frame.size.width-30, 25);
    lblHint2.textAlignment = NSTextAlignmentCenter;
    lblHint2.numberOfLines = 0;
    lblHint2.textColor = [UIColor whiteColor];
    lblHint2.text = @"Didn't recieve the OTP?";
    [lblHint2 setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [viewPopUp addSubview:lblHint2];
    
    UIButton * btnResnt = [UIButton buttonWithType:UIButtonTypeCustom];
    btnResnt.frame = CGRectMake(15, (yy + 25), viewPopUp.frame.size.width-30, 38);
    [btnResnt setTitle:@"Resend OTP" forState:UIControlStateNormal];
    btnResnt.backgroundColor = UIColor.clearColor;
    [btnResnt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnResnt addTarget:self action:@selector(btnResendOTP) forControlEvents:UIControlEventTouchUpInside];
    [btnResnt.titleLabel setFont:[UIFont fontWithName:CGBold size:txtSize]];
    [viewPopUp addSubview:btnResnt];

    [pwdInputView.inputTextField becomeFirstResponder];
}
-(void)setAgainVerify
{
    pwdInputView.delegate = nil;
    [pwdInputView removeFromSuperview];
    pwdInputView = [[GSPasswordInputView alloc] initWithFrame:CGRectMake((viewPopUp.frame.size.width-160)/2, (lastHeight)*approaxSize, 160, 40*approaxSize)];
    pwdInputView.numberOfDigit = 6;
    pwdInputView.delegate = self;
    [viewPopUp addSubview:pwdInputView];
}
- (void)didFinishEditingWithInputView:(GSPasswordInputView *)anInputView text:(NSString *)aText;
{
    [anInputView resignFirstResponder];
    codeStr = aText;
}
-(void)btnSubmitClick
{
    
    if ([codeStr length] == 0 || codeStr == nil  || [codeStr isEqualToString:@" "])
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter verification code." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
            }];
        }];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    }
    else if ([codeStr length]>6)
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter complete verification code." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
            }];
        }];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
        
    }
    else
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
            [self sendOTPtoServer];
        }
        else
        {
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"There is no internet connection. Please connect to internet first then try again later." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                    
                }];
            }];
            [alertView showWithAnimation:Alert_Animation_Type];
        }
    }
}
-(void)btnResendOTP
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        [self checkPhoneNumberWithGivenInput];
    }
    else
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"There is no internet connection. Please connect to internet first then try again later." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                
            }];
        }];
        [alertView showWithAnimation:Alert_Animation_Type];
    }
}

-(void)sendOTPtoServer
{
    [APP_DELEGATE startHudProcess:@"Loading..."];
    FIRAuthCredential *credential = [[FIRPhoneAuthProvider provider]
                                     credentialWithVerificationID:verificationID
                                     verificationCode:codeStr];
    [[FIRAuth auth] signInWithCredential:credential completion:^(FIRAuthDataResult * _Nullable authResult,
                                                          NSError * _Nullable error) {
                                                 [APP_DELEGATE endHudProcess];
                                                 
                                                 if (error) {
                                                     // ...
                                                     [self showMessagewithText:error.localizedDescription];

                                                     return;
                                                 }
                                                 // User successfully signed in. Get user data from the FIRUser object
                                                 if (authResult == nil)
                                                 {
                                                     return;
                                                     
                                                 }
//                                                 FIRUser *user = authResult.user;
                                                 // ...
                                                 [self RegisterService];
                                             }];
}
-(void)showMessagewithText:(NSString *)strText
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeCaution];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:strText
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)RegisterService
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Registering...."];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:[dataDict objectForKey:@"username"] forKey:@"username"];
    [dict setValue:[dataDict objectForKey:@"mobile_number"] forKey:@"mobile_number"];
    [dict setValue:[dataDict objectForKey:@"password"] forKey:@"password"];
    [dict setValue:[dataDict objectForKey:@"email"]  forKey:@"email"];
    [dict setValue:[dataDict objectForKey:@"account_name"]  forKey:@"account_name"];

    [dict setValue:@"2" forKey:@"device_type"];
    
    
    
    NSString *deviceToken =deviceTokenStr;
    if (deviceToken == nil || deviceToken == NULL)
    {
        [dict setValue:@"123456789" forKey:@"device_token"];
    }
    else
    {
        [dict setValue:deviceToken forKey:@"device_token"];
    }
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"sigup";
    manager.delegate = self;
    NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/signup";
    [manager urlCall:strServerUrl withParameters:dict];
    
    [APP_DELEGATE GenerateEncryptedKeyforLogin:[dataDict objectForKey:@"mobile_number"]];
    [self ResetAllUUIDs];

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
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];
//    NSLog(@"The result is...%@", result);
    if ([[result valueForKey:@"commandName"] isEqualToString:@"sigup"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"This email address already registered with us"] || [[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"This mobile number already registered with us"])
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                alert.tag = 223;
                alert.delegate = self;
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:@"This mobile number already registered with us"
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else
            {
                if([[result valueForKey:@"result"] valueForKey:@"data"]!=[NSNull null] || [[result valueForKey:@"result"] valueForKey:@"data"] != nil || ![[[result valueForKey:@"result"] valueForKey:@"data"] isEqualToString:@"<null>"])
                {
                    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                    tmpDict = [[result valueForKey:@"result"] valueForKey:@"data"] ;
                    [tmpDict setObject:[dataDict objectForKey:@"password"] forKey:@"localPassword"];
                    
                    [[NSUserDefaults standardUserDefaults] setValue:[dataDict objectForKey:@"email"] forKey:@"CURRENT_USER_EMAIL"];
                    [[NSUserDefaults standardUserDefaults] setValue:[dataDict objectForKey:@"username"] forKey:@"CURRENT_USER_NAME"];
                    [[NSUserDefaults standardUserDefaults] setValue:[dataDict objectForKey:@"password"] forKey:@"CURRENT_USER_PASS"];
                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"IS_LOGGEDIN"];
                    [[NSUserDefaults standardUserDefaults] setValue:[dataDict objectForKey:@"account_name"] forKey:@"CURRENT_ACCOUNT_NAME"];
                    [[NSUserDefaults standardUserDefaults] setValue:[dataDict objectForKey:@"mobile_number"] forKey:@"CURRENT_USER_MOBILE"];

                    [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"user_id"] forKey:@"CURRENT_USER_ID"];
                    [[NSUserDefaults standardUserDefaults] setObject:tmpDict forKey:@"UserDict"];
                    [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"IS_USER_SKIPPED"];
                    [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"IS_USER_LOGGED"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self addManageAccountWithDetails:tmpDict];

                    [self AddAlarmforLoggedinUser];

                    FCAlertView *alert = [[FCAlertView alloc] init];
                    alert.colorScheme = [UIColor blackColor];
                    [alert makeAlertTypeSuccess];
                    alert.tag = 222;
                    alert.delegate = self;
                    [alert showAlertInView:self
                                 withTitle:@"Smart Light"
                              withSubtitle:@"You have been registered successfully."
                           withCustomImage:[UIImage imageNamed:@"logo.png"]
                       withDoneButtonTitle:nil
                                andButtons:nil];
                    
                }
                else
                {
                    FCAlertView *alert = [[FCAlertView alloc] init];
                    alert.colorScheme = [UIColor blackColor];
                    [alert makeAlertTypeCaution];
                    [alert showAlertInView:self
                                 withTitle:@"Smart Light"
                              withSubtitle:@"Something went wrong. Please try again later."
                           withCustomImage:[UIImage imageNamed:@"logo.png"]
                       withDoneButtonTitle:nil
                                andButtons:nil];
                }
            }
            
        }
        else
        {
            NSString * strMsg = [[result valueForKey:@"result"] valueForKey:@"message"];
            
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            alert.tag = 223;
            alert.delegate = self;
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:strMsg
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
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
    
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009) {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
    } else {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
    }
    
    
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
//        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
    }
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
-(void)addManageAccountWithDetails:(NSMutableDictionary*)tmpDict
{
    NSMutableArray * arrTemp = [[NSMutableArray alloc]init];
    NSString *strTbl = [NSString stringWithFormat:@"Select * from UserAccount_Table where server_user_id = '%@'",[tmpDict valueForKey:@"user_id"]];
    [[DataBaseManager dataBaseManager] execute:strTbl resultsArray:arrTemp];
    
    NSString *deviceToken =deviceTokenStr;
    NSString *strObject = [NSString stringWithFormat:@"update UserAccount_Table set is_active = '0'"];
    [[DataBaseManager dataBaseManager] execute:strObject];
    
    if (deviceToken == nil || deviceToken == NULL)
    {
        deviceToken = @"12345";
    }
    
    if (arrTemp.count == 0)
    {
        NSString *strDevice = [NSString stringWithFormat:@"insert into 'UserAccount_Table'('server_user_id','user_name','account_name','user_email','user_mobile_no','user_pw','user_token','is_active') values('%@','%@','%@','%@','%@','%@','%@','%@')",[dataDict valueForKey:@"user_id"],[dataDict valueForKey:@"username"],[dataDict valueForKey:@"account_name"],[tmpDict valueForKey:@"email"],[dataDict objectForKey:@"mobile_number"],[dataDict objectForKey:@"password"],deviceToken,[tmpDict valueForKey:@"is_active"]];
        [[DataBaseManager dataBaseManager] execute:strDevice];
        
    }
    else
    {
        NSString *strDeviceUpdate = [NSString stringWithFormat:@"Update 'UserAccount_Table' set server_user_id = '%@',user_name = '%@',account_name = '%@',user_email = '%@',user_pw = '%@',user_mobile_no = '%@',user_token = '%@',is_active = '%@' where server_user_id = '%@' ",[tmpDict valueForKey:@"user_id"],[tmpDict valueForKey:@"username"],[tmpDict valueForKey:@"account_name"],[tmpDict valueForKey:@"email"],[dataDict objectForKey:@"password"],[dataDict objectForKey:@"mobile_number"],deviceToken,[tmpDict valueForKey:@"is_active"],[tmpDict valueForKey:@"user_id"]];
        [[DataBaseManager dataBaseManager] execute:strDeviceUpdate];
    }
}
#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 222)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.3];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
        [UIView commitAnimations];
        [APP_DELEGATE goToDashboard];
    }
    else if (alertView.tag ==223)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
}
-(void)checkPhoneNumberWithGivenInput
{
    [APP_DELEGATE startHudProcess:@"Registering..."];
    NSString * stringCode = [NSString stringWithFormat:@"%@%@",[dataDict valueForKey:@"mobile_number"],[dataDict valueForKey:@"countryCode"]];
    [[FIRPhoneAuthProvider provider] verifyPhoneNumber:stringCode UIDelegate:self completion:^(NSString * _Nullable verificationID, NSError * _Nullable error) {
        
        [APP_DELEGATE endHudProcess];
        if (error)
        {
            [self showMessagewithText:error.localizedDescription];
            
            return;
        }
        // Sign in using the verificationID and the code sent to the user
        // ...
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:verificationID forKey:@"authVerificationID"];
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeSuccess];
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"OTP resent successfully."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
        
    }];
    //    [[FIRPhoneAuthProvider provider] verifyPhoneNumber:@""
    //                                            UIDelegate:nil
    //                                            completion:^(NSString * _Nullable verificationID, NSError * _Nullable error) {
    //                                                if (error) {
    //                                                    [self showMessagePrompt:error.localizedDescription];
    //                                                    return;
    //                                                }
    //                                                // Sign in using the verificationID and the code sent to the user
    //                                                // ...
    //                                            }];
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
