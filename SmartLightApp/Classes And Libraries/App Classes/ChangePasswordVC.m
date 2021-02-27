//
//  ChangePasswordVC.m
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 05/10/18.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "ChangePasswordVC.h"

@interface ChangePasswordVC ()

@end

@implementation ChangePasswordVC

- (void)viewDidLoad
{
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
    [lblTitle setText:@"Change Password"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 80, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 44, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 88, 88);
        imgNotConnected.frame = CGRectMake(DEVICE_WIDTH-30, 55, 30, 22);
    }
}
#pragma mark - Set UI frames
-(void) setContentViewFrames
{
    viewPopUp = [[UIView alloc] initWithFrame:CGRectMake(15, 134,DEVICE_WIDTH-30,275*approaxSize)];
    [viewPopUp setBackgroundColor:[UIColor clearColor]];
    viewPopUp.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewPopUp.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    viewPopUp.layer.shadowRadius = 25;
    viewPopUp.layer.shadowOpacity = 0.5;
    [self.view addSubview:viewPopUp];
    
    UIImageView * imgPopUpBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewPopUp.frame.size.width, viewPopUp.frame.size.height)];
    [imgPopUpBG setBackgroundColor:[UIColor blackColor]];
    imgPopUpBG.alpha = 0.5;
    imgPopUpBG.layer.cornerRadius = 10;
    [viewPopUp addSubview:imgPopUpBG];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imgPopUpBG.bounds];
    imgPopUpBG.layer.masksToBounds = NO;
    imgPopUpBG.layer.shadowColor = [UIColor whiteColor].CGColor;
    imgPopUpBG.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imgPopUpBG.layer.shadowOpacity = 0.5f;
    imgPopUpBG.layer.shadowPath = shadowPath.CGPath;
    
    lbl = [[UILabel alloc]initWithFrame:CGRectMake(00, 74, DEVICE_WIDTH, 50)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lbl setTextColor:[UIColor whiteColor]];
    lbl.text = @"  Password Can Be Changed Only Once!";
//    [self.view addSubview:lbl];
    
    long yy = 30;
    txtOldPass = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35*approaxSize)];
    txtOldPass.placeholder = @"Old Password";
    txtOldPass.delegate = self;
    txtOldPass.secureTextEntry = YES;
    txtOldPass.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtOldPass.textColor = [UIColor whiteColor];
    [txtOldPass setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [APP_DELEGATE getPlaceholderText:txtOldPass andColor:[UIColor lightGrayColor]];

    txtOldPass.returnKeyType  = UIReturnKeyNext;
    [viewPopUp addSubview:txtOldPass];
    UILabel * lblEmailLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtOldPass.frame.size.height-2, txtOldPass.frame.size.width, 1)];
    [lblEmailLine setBackgroundColor:[UIColor lightGrayColor]];
    txtOldPass.keyboardAppearance = UIKeyboardAppearanceAlert;
    [txtOldPass addSubview:lblEmailLine];
    
    btnShowPassOld = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowPassOld.frame = CGRectMake(viewPopUp.frame.size.width-60, yy, 60, 35);
    btnShowPassOld.backgroundColor = [UIColor clearColor];
    [btnShowPassOld addTarget:self action:@selector(showPassOldClick) forControlEvents:UIControlEventTouchUpInside];
    [btnShowPassOld setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
    [viewPopUp addSubview:btnShowPassOld];
    
    yy = yy + 60;
    txtNewPass = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35)];
    txtNewPass.placeholder = @"New Password";
    txtNewPass.delegate = self;
    txtNewPass.secureTextEntry = YES;
    txtNewPass.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtNewPass.textColor = [UIColor whiteColor];
    [txtNewPass setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [APP_DELEGATE getPlaceholderText:txtNewPass andColor:[UIColor lightGrayColor]];

    txtNewPass.returnKeyType  = UIReturnKeyNext;
    txtNewPass.keyboardAppearance = UIKeyboardAppearanceAlert;
    [viewPopUp addSubview:txtNewPass];
    lblEmailLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtNewPass.frame.size.height-2, txtNewPass.frame.size.width, 1)];
    [lblEmailLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtNewPass addSubview:lblEmailLine];
    
    btnShowPassNew = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowPassNew.frame = CGRectMake(viewPopUp.frame.size.width-60, yy, 60, 35);
    btnShowPassNew.backgroundColor = [UIColor clearColor];
    [btnShowPassNew addTarget:self action:@selector(showPassNewClick) forControlEvents:UIControlEventTouchUpInside];
    [btnShowPassNew setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
    [viewPopUp addSubview:btnShowPassNew];
    
    yy = yy + 60;
    txtConfirmPass = [[UITextField alloc] initWithFrame:CGRectMake(15,yy,viewPopUp.frame.size.width-30, 35)];
    txtConfirmPass.placeholder = @"Confirm Password";
    txtConfirmPass.delegate = self;
    txtConfirmPass.secureTextEntry = YES;
    txtConfirmPass.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtConfirmPass.textColor = [UIColor whiteColor];
    [txtConfirmPass setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [APP_DELEGATE getPlaceholderText:txtConfirmPass andColor:[UIColor lightGrayColor]];

    txtConfirmPass.returnKeyType  = UIReturnKeyDone;
    txtConfirmPass.keyboardAppearance = UIKeyboardAppearanceAlert;
    [viewPopUp addSubview:txtConfirmPass];
    
    btnShowPassConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowPassConfirm.frame = CGRectMake(viewPopUp.frame.size.width-60, yy, 60, 35);
    btnShowPassConfirm.backgroundColor = [UIColor clearColor];
    [btnShowPassConfirm addTarget:self action:@selector(showPassConfirmClick) forControlEvents:UIControlEventTouchUpInside];
    [btnShowPassConfirm setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
    [viewPopUp addSubview:btnShowPassConfirm];
    
    lblEmailLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtConfirmPass.frame.size.height-2, txtConfirmPass.frame.size.width, 1)];             
    [lblEmailLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtConfirmPass addSubview:lblEmailLine];
    
    yy = yy + 60;
    
    btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSave = [[UIButton alloc]initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35)];
    btnSave.backgroundColor = global_brown_color;
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnSave.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [btnSave addTarget:self action:@selector(btnSaveAction) forControlEvents:UIControlEventTouchUpInside];
    [viewPopUp addSubview:btnSave];
}


#pragma mark - Textfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    if (textField == txtOldPass)
    {
        [txtNewPass becomeFirstResponder];
    }
    else if (textField == txtNewPass)
    {
        [txtConfirmPass becomeFirstResponder];
    }
    else if (textField == txtConfirmPass)
    {
        [txtConfirmPass resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [lblLine removeFromSuperview];
    lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, textField.frame.size.height-2, textField.frame.size.width, 2)];
    [lblLine setBackgroundColor:[UIColor whiteColor]];
    [textField addSubview:lblLine];
}

-(void)OverLayTaped:(id)sender
{
}

#pragma mark - All button click events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)showPassOldClick
{
    if (isShowPasswordOld)
    {
        isShowPasswordOld = NO;
        [btnShowPassOld setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
        txtOldPass.secureTextEntry = YES;
    }
    else
    {
        isShowPasswordOld = YES;
        [btnShowPassOld setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
        txtOldPass.secureTextEntry = NO;
    }
}
-(void)showPassNewClick
{
    if (isShowPasswordNew)
    {
        isShowPasswordNew = NO;
        [btnShowPassNew setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
        txtNewPass.secureTextEntry = YES;
    }
    else
    {
        isShowPasswordNew = YES;
        [btnShowPassNew setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
        txtNewPass.secureTextEntry = NO;
    }
}
-(void)showPassConfirmClick
{
    if (isShowPasswordConf)
    {
        isShowPasswordConf = NO;
        [btnShowPassConfirm setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
        txtConfirmPass.secureTextEntry = YES;
    }
    else
    {
        isShowPasswordConf = YES;
        [btnShowPassConfirm setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
        txtConfirmPass.secureTextEntry = NO;
    }
}
-(void) btnSaveAction
{
    [self hideKeyboard];
    if([txtOldPass.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please enter your Old Password"];
    }
    else if([txtNewPass.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please enter your New Password"];
    }
    else if([txtConfirmPass.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please Confirm Your Password"];
    }
    //else if (txtNewPass.text != txtConfirmPass.text)
        else if(![txtNewPass.text isEqualToString:[NSString stringWithFormat:@"%@",txtConfirmPass.text]])
    {
        [self showMessagewithText:@"New Password And Confirm Password Should Match"];
    }
    else if([txtNewPass.text isEqualToString:txtConfirmPass.text])
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
            [self loginViaEmailWebService];
            
        }
        else
        {
            [self showMessagewithText:@"There is no internet connection. Please connect to internet first then try again later."];
        }
    }
    
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
#pragma mark - Web Service Call
-(void)loginViaEmailWebService
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Logging..."];
    
    [btnSave setEnabled:NO];
    [activityIndicator startAnimating];
    NSString *websrviceName=@"set_reset_password";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:txtOldPass.text forKey:@"old_password"];
    [dict setValue:txtNewPass.text forKey:@"new_password"];
    [dict setValue:@"1" forKey:@"isChangePass"];
    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];

    
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"login";
    manager.delegate = self;
    NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/";
    [manager urlCall:[NSString stringWithFormat:@"%@%@",strServerUrl,websrviceName] withParameters:dict];    
}

#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];
    
//    NSLog(@"The result is...%@", result);
    
    [btnSave setEnabled:YES];
    [activityIndicator stopAnimating];
    
    if ([[result valueForKey:@"commandName"] isEqualToString:@"login"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            alert.delegate = self;
            alert.tag = 223;
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"Password has been changed successfully"
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
         else
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            alert.delegate = self;
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:[[result valueForKey:@"result"]valueForKey:@"message"]
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
    
    [activityIndicator stopAnimating];
    

    
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
#pragma mark - Hide Keyboard
-(void)hideKeyboard
{
    [self.view endEditing:YES];
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
