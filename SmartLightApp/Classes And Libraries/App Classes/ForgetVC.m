//
//  ForgetVC.m
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 05/10/18.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "ForgetVC.h"
#import "GSPasswordInputView.h"
#import "URLManager.h"
#import "OtpVerifyVC.h"
#import "CountryPicker.h"

@interface ForgetVC ()<GSPasswordInputViewDelegate,URLManagerDelegate,FCAlertViewDelegate,CountryPickerDelegate, FIRAuthUIDelegate>
{
    GSPasswordInputView * pwdInputView;
    long lastHeight;
    NSString * strOTPVerifiedID;
    CountryPicker * cntryPickerView;

}
@end

@implementation ForgetVC


- (void)viewDidLoad
{
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];
    [self setContentViewFrames];
    [self setupforCountryPicker];

    
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
    [lblTitle setText:@"Forgot Password?"];
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
    btnBack.frame = CGRectMake(0, 0, 70, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];
    
    lblMessage = [[UILabel alloc]initWithFrame:CGRectMake(0, 74, DEVICE_WIDTH, 50)];
    [lblMessage setBackgroundColor:[UIColor clearColor]];
    [lblMessage setFont:[UIFont fontWithName:CGRegular size:textSizes-1]];
    [lblMessage setTextColor:[UIColor whiteColor]];
    lblMessage.numberOfLines=0;
    lblMessage.textAlignment = NSTextAlignmentCenter;
    lblMessage.text = @"Enter your Phone Number to create new password.";
    [self.view addSubview:lblMessage];
    
    scrlContent = [[UIScrollView alloc]init];
    scrlContent.frame = CGRectMake(0, 124,DEVICE_WIDTH, DEVICE_HEIGHT);
    scrlContent.backgroundColor = UIColor.clearColor;
    scrlContent.delegate = self;
    scrlContent.pagingEnabled = YES;
    scrlContent.showsVerticalScrollIndicator = false;
    scrlContent.contentSize = CGSizeMake(DEVICE_WIDTH*3,DEVICE_HEIGHT);
    scrlContent.scrollEnabled = false;
    [self.view addSubview:scrlContent];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 88, 88);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
    }
}
#pragma mark - Set UI frames
-(void) setContentViewFrames
{
    viewmobile = [[UIView alloc] initWithFrame:CGRectMake(15,10,DEVICE_WIDTH-30,155*approaxSize)];
    [viewmobile setBackgroundColor:[UIColor clearColor]];
    viewmobile.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewmobile.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    viewmobile.layer.shadowRadius = 25;
    viewmobile.layer.shadowOpacity = 0.5;
    [scrlContent addSubview:viewmobile];
    
    UIImageView * imgMobileBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewmobile.frame.size.width, viewmobile.frame.size.height)];
    [imgMobileBG setBackgroundColor:[UIColor blackColor]];
    imgMobileBG.alpha = 0.5;
    imgMobileBG.layer.cornerRadius = 10;
    [viewmobile addSubview:imgMobileBG];
    
    UIBezierPath *mobShadowPath = [UIBezierPath bezierPathWithRect:imgMobileBG.bounds];
    imgMobileBG.layer.masksToBounds = NO;
    imgMobileBG.layer.shadowColor = [UIColor whiteColor].CGColor;
    imgMobileBG.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imgMobileBG.layer.shadowOpacity = 0.5f;
    imgMobileBG.layer.shadowPath = mobShadowPath.CGPath;
    
    long xx = 30;
    
    btnCntryCode = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCntryCode.frame = CGRectMake(10, xx, 50, 35*approaxSize);
    [btnCntryCode addTarget:self action:@selector(btnCntryClick) forControlEvents:UIControlEventTouchUpInside];
    [btnCntryCode setTitle:@"" forState:UIControlStateNormal];
    btnCntryCode.titleLabel.font = [UIFont fontWithName:CGBold size:textSizes];
    [viewmobile addSubview:btnCntryCode];
    NSDictionary * dicts = [[NSDictionary alloc] init];
    dicts = [APP_DELEGATE getCountryCodeDictionary];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSString *callingCode = [dicts objectForKey:countryCode];
    NSString * strPlus = @"+";
    [btnCntryCode setTitle:[strPlus stringByAppendingString:callingCode] forState:UIControlStateNormal];
    
    UILabel * lblCode = [[UILabel alloc] initWithFrame:CGRectMake(5, btnCntryCode.frame.size.height-2, btnCntryCode.frame.size.width-10,1)];
    [lblCode setBackgroundColor:[UIColor lightGrayColor]];
    [btnCntryCode addSubview:lblCode];
    
    txtMobNumber = [[UITextField alloc] initWithFrame:CGRectMake(60, xx, viewmobile.frame.size.width-30-45, 35*approaxSize)];
    txtMobNumber.placeholder = @"Enter Registered Mobile No";
    txtMobNumber.delegate = self;
    txtMobNumber.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtMobNumber.textColor = [UIColor whiteColor];
    [txtMobNumber setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [APP_DELEGATE getPlaceholderText:txtMobNumber andColor:[UIColor lightGrayColor]];

    txtMobNumber.returnKeyType  = UIReturnKeyDone;
    txtMobNumber.keyboardType = UIKeyboardTypePhonePad;
    [viewmobile addSubview:txtMobNumber];
    UILabel * lblMobLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtMobNumber.frame.size.height-2, txtMobNumber.frame.size.width, 1)];
    [lblMobLine setBackgroundColor:[UIColor lightGrayColor]];
     txtMobNumber.keyboardAppearance = UIKeyboardAppearanceAlert;
    [txtMobNumber addSubview:lblMobLine];
    
    xx = xx + 60;
    btnSaveMobile = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSaveMobile = [[UIButton alloc]initWithFrame:CGRectMake(15, xx, viewmobile.frame.size.width-30, 35)];
    btnSaveMobile.backgroundColor = global_brown_color;
    [btnSaveMobile setTitle:@"Submit" forState:UIControlStateNormal];
    [btnSaveMobile setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnSaveMobile.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [btnSaveMobile addTarget:self action:@selector(btnSaveMobile) forControlEvents:UIControlEventTouchUpInside];
    [viewmobile addSubview:btnSaveMobile];
 
    viewOTP = [[UIView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH)+15,10,DEVICE_WIDTH-30,(215+98)*approaxSize)];
    [viewOTP setBackgroundColor:[UIColor clearColor]];
    viewOTP.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewOTP.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    viewOTP.layer.shadowRadius = 25;
    viewOTP.layer.shadowOpacity = 0.5;
    [scrlContent addSubview:viewOTP];
    
    UIImageView * imgOtpBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewOTP.frame.size.width, viewOTP.frame.size.height)];
    [imgOtpBG setBackgroundColor:[UIColor blackColor]];
    imgOtpBG.alpha = 0.5;
    imgOtpBG.layer.cornerRadius = 10;
    [viewOTP addSubview:imgOtpBG];
    
    UIBezierPath *OtpShadowPath = [UIBezierPath bezierPathWithRect:imgOtpBG.bounds];
    imgOtpBG.layer.masksToBounds = NO;
    imgOtpBG.layer.shadowColor = [UIColor whiteColor].CGColor;
    imgOtpBG.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imgOtpBG.layer.shadowOpacity = 0.5f;
    imgOtpBG.layer.shadowPath = OtpShadowPath.CGPath;
    
    long zz = 15;
    
    lblHint =  [[UILabel alloc] init];
    lblHint.frame = CGRectMake(15, zz , viewOTP.frame.size.width-30, 80);
    lblHint.textAlignment = NSTextAlignmentCenter;
    lblHint.numberOfLines = 0;
    lblHint.textColor = [UIColor whiteColor];
    lblHint.text = @"Enter your 6 digit verification code which is sent to your mobile to verify";
    [lblHint setFont:[UIFont fontWithName:CGRegular size:14]];
    [viewOTP addSubview:lblHint];
    
    zz = zz + 80;

    lastHeight = zz;
    [pwdInputView removeFromSuperview];
    pwdInputView = [[GSPasswordInputView alloc] initWithFrame:CGRectMake((viewOTP.frame.size.width-160)/2, (zz)*approaxSize, 160, 40*approaxSize)];
    pwdInputView.numberOfDigit = 6;
    pwdInputView.delegate = self;
    [viewOTP addSubview:pwdInputView];

    zz = zz + 40*approaxSize + 15*approaxSize;

    UIButton * btnSubmitOTP = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSubmitOTP.frame = CGRectMake(15, zz, viewOTP.frame.size.width-30, 38);
    btnSubmitOTP.backgroundColor = global_brown_color;
    [btnSubmitOTP setTitle:@"SUBMIT" forState:UIControlStateNormal];
    [btnSubmitOTP setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSubmitOTP addTarget:self action:@selector(btnSubmitClick) forControlEvents:UIControlEventTouchUpInside];
    [btnSubmitOTP.titleLabel setFont:[UIFont fontWithName:CGRegular size:14]];
    [viewOTP addSubview:btnSubmitOTP];
    
    zz = zz +38 *approaxSize + 10*approaxSize;
    
    UILabel * lblHint2 =  [[UILabel alloc] init];
    lblHint2.frame = CGRectMake(15, zz, viewOTP.frame.size.width-30, 25);
    lblHint2.textAlignment = NSTextAlignmentCenter;
    lblHint2.numberOfLines = 0;
    lblHint2.textColor = [UIColor whiteColor];
    lblHint2.text = @"Didn't recieve the OTP?";
    [lblHint2 setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [viewOTP addSubview:lblHint2];
    
    UIButton * btnResnt = [UIButton buttonWithType:UIButtonTypeCustom];
    btnResnt.frame = CGRectMake(15, (zz + 25), viewOTP.frame.size.width-30, 38);
    [btnResnt setTitle:@"Resend OTP" forState:UIControlStateNormal];
    btnResnt.backgroundColor = UIColor.clearColor;
    [btnResnt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnResnt addTarget:self action:@selector(btnResendOTP) forControlEvents:UIControlEventTouchUpInside];
    [btnResnt.titleLabel setFont:[UIFont fontWithName:CGBold size:textSizes]];
    [viewOTP addSubview:btnResnt];
    
    viewPopUp = [[UIView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH*2)+15,10,DEVICE_WIDTH-30,215*approaxSize)];
    [viewPopUp setBackgroundColor:[UIColor clearColor]];
    viewPopUp.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewPopUp.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    viewPopUp.layer.shadowRadius = 25;
    viewPopUp.layer.shadowOpacity = 0.5;
    [scrlContent addSubview:viewPopUp];
    
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
    
    long yy = 30;
    txtPass = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35*approaxSize)];
    txtPass.placeholder = @"Enter New Password";
    txtPass.delegate = self;
    txtPass.secureTextEntry = YES;
    txtPass.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtPass.textColor = [UIColor whiteColor];
    [txtPass setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [APP_DELEGATE getPlaceholderText:txtPass andColor:[UIColor lightGrayColor]];

    txtPass.returnKeyType  = UIReturnKeyNext;
    [viewPopUp addSubview:txtPass];
    UILabel * lblPassLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtPass.frame.size.height-2, txtPass.frame.size.width, 1)];
    [lblPassLine setBackgroundColor:[UIColor lightGrayColor]];
    txtPass.keyboardAppearance = UIKeyboardAppearanceAlert;
    [txtPass addSubview:lblPassLine];
    
    btnShowPassNew = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowPassNew.frame = CGRectMake(viewPopUp.frame.size.width-60, yy, 60, 35);
    btnShowPassNew.backgroundColor = [UIColor clearColor];
    [btnShowPassNew addTarget:self action:@selector(showPassNewClick) forControlEvents:UIControlEventTouchUpInside];
    [btnShowPassNew setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
    [viewPopUp addSubview:btnShowPassNew];
    
    yy = yy + 60;
    txtConfirmPass = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35)];
    txtConfirmPass.placeholder = @"Confirm your New Password";
    txtConfirmPass.delegate = self;
    txtConfirmPass.secureTextEntry = YES;
    txtConfirmPass.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtConfirmPass.textColor = [UIColor whiteColor];
    [txtConfirmPass setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [APP_DELEGATE getPlaceholderText:txtConfirmPass andColor:[UIColor lightGrayColor]];

    txtConfirmPass.returnKeyType  = UIReturnKeyDone;
    txtConfirmPass.keyboardAppearance = UIKeyboardAppearanceAlert;
    [viewPopUp addSubview:txtConfirmPass];
    lblPassLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtConfirmPass.frame.size.height-2, txtConfirmPass.frame.size.width, 1)];
    [lblPassLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtConfirmPass addSubview:lblPassLine];
    
    btnShowPassConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowPassConfirm.frame = CGRectMake(viewPopUp.frame.size.width-60, yy, 60, 35);
    btnShowPassConfirm.backgroundColor = [UIColor clearColor];
    [btnShowPassConfirm addTarget:self action:@selector(showPassConfirmClick) forControlEvents:UIControlEventTouchUpInside];
    [btnShowPassConfirm setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
    [viewPopUp addSubview:btnShowPassConfirm];
    
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
-(void)setAgainVerify
{
    pwdInputView.delegate = nil;
    [pwdInputView removeFromSuperview];
    pwdInputView = [[GSPasswordInputView alloc] initWithFrame:CGRectMake((viewPopUp.frame.size.width-160)/2, (lastHeight)*approaxSize, 160, 40*approaxSize)];
    pwdInputView.numberOfDigit = 6;
    pwdInputView.delegate = self;
    [viewOTP addSubview:pwdInputView];
}
- (void)didFinishEditingWithInputView:(GSPasswordInputView *)anInputView text:(NSString *)aText;
{
    [anInputView resignFirstResponder];
    codeStr = aText;
}

#pragma mark - Textfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    if (textField == txtPass)
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
    lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, textField.frame.size.height-2, textField.frame.size.width, 2)];
    [lblLine setBackgroundColor:[UIColor whiteColor]];
    [textField addSubview:lblLine];
    
    if (textField == txtMobNumber)
    {
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        numberToolbar.barStyle =  UIBarStyleDefault;
        UIBarButtonItem *space =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *Done = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneKeyBoarde)];
        Done.tintColor=[UIColor blackColor];
        numberToolbar.items = [NSArray arrayWithObjects:space,Done,
                               nil];
        [numberToolbar sizeToFit];
        textField.inputAccessoryView = numberToolbar;
    }
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == txtMobNumber)
    {
        NSCharacterSet* numberCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; ++i)
        {
            unichar c = [string characterAtIndex:i];
            if (![numberCharSet characterIsMember:c])
            {
                return NO;
            }
        }
    }
    return YES;
    
}
-(void)OverLayTaped:(id)sender
{
}

#pragma mark - All button click events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) doneKeyBoarde
{
    [txtMobNumber resignFirstResponder];
}
-(void) btnSaveMobile
{
    [self hideKeyboard];
    
    if([txtMobNumber.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please Enter your mobile number"];

    }
    else if(txtMobNumber.text.length <10)
    {
        [self showMessagewithText:@"Phone number should be atleast 10 digits"];

    }
    else if([txtMobNumber.text rangeOfString:@"+"].location != NSNotFound)
    {
        [self showMessagewithText:@"Please enter a valid number"];
    }
    else
    {
        [self loginViaEmailWebService];
    }

}-(void) btnSubmitClick
{
    [self hideKeyboard];
    
    if ([codeStr length] == 0 || codeStr == nil  || [codeStr isEqualToString:@""])
    {
        [self showMessagewithText:@"Please enter complete verification code"];
    }
    else
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
            [self sendOTPtoServer];
        }
        else
        {
            [self showMessagewithText:@"There is no internet connection.Please connect to the internet first and then try again."];

        }
    }
}
-(void)sendOTPtoServer
{
    [APP_DELEGATE startHudProcess:@"Loading..."];
    FIRAuthCredential *credential = [[FIRPhoneAuthProvider provider]
                                     credentialWithVerificationID:strOTPVerifiedID
                                     verificationCode:codeStr];
    [[FIRAuth auth] signInWithCredential:credential completion:^(FIRAuthDataResult * _Nullable authResult,
                                                          NSError * _Nullable error) {
                                                 [APP_DELEGATE endHudProcess];

                                                 if (error) {
                                                     // ...
                                                     return;
                                                 }
                                                 // User successfully signed in. Get user data from the FIRUser object
                                                 if (authResult == nil)
                                                 {
                                                     return;
                                                     
                                                 }
//                                                 FIRUser *user = authResult.user;
                                                 // ...
//                                                 [self RegisterService];
                                                 [scrlContent setContentOffset:CGPointMake((DEVICE_WIDTH*2), 0)];
                                             }];
}
-(void) btnSaveAction
{
    [self hideKeyboard];
    if([txtPass.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please enter your New Password"];
    }
    else if([txtConfirmPass.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please Confirm Your Password"];
    }
    
    else if (![txtPass.text isEqualToString:[NSString stringWithFormat:@"%@",txtConfirmPass.text]])
    {
        [self showMessagewithText:@"New Password And Confirm Password Should Match"];
    }
    else([txtPass.text isEqualToString:txtConfirmPass.text]);
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
            [self savePasswordAPI];
            
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
-(void)btnCntryClick
{
    [self.view endEditing:YES];
    [self ShowPicker:YES andView:backPickerView];
}
-(void)btnDoneClicked
{
    [self ShowPicker:NO andView:backPickerView];
}
-(void)btnResendOTP
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        NSString * strPlus = [NSString stringWithFormat:@"%@%@",btnCntryCode.titleLabel.text,txtMobNumber.text];
        
        [self checkPhoneNumberWithGivenInput:strPlus];
    }
    else
    {
        [self showMessagewithText:@"There is no internet connection.Please connect to the internet first and then try again"];

    }
}
-(void)showPassNewClick
{
    if (isShowPasswordNew)
    {
        isShowPasswordNew = NO;
        [btnShowPassNew setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
        txtPass.secureTextEntry = YES;
    }
    else
    {
        isShowPasswordNew = YES;
        [btnShowPassNew setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
        txtPass.secureTextEntry = NO;
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

-(void)setupforCountryPicker
{
    [backPickerView removeFromSuperview];
    backPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 250)];
    [backPickerView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:backPickerView];
    
    [cntryPickerView removeFromSuperview];
    cntryPickerView = nil;
    cntryPickerView.delegate=nil;
    cntryPickerView = [[CountryPicker alloc] initWithFrame:CGRectMake(0, 34, DEVICE_WIDTH, 216)];
    cntryPickerView.delegate=self;
    [cntryPickerView setBackgroundColor:[UIColor blackColor]];
    [cntryPickerView setSelectedLocale:[NSLocale currentLocale]];
    [backPickerView addSubview:cntryPickerView];
    
    UIButton * btnDone2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone2 setFrame:CGRectMake(0 , 0, DEVICE_WIDTH, 34)];
    [btnDone2 setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [btnDone2 setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnDone2 addTarget:self action:@selector(btnDoneClicked) forControlEvents:UIControlEventTouchUpInside];
    [backPickerView addSubview:btnDone2];
}
- (void)countryPicker:(__unused CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code withImg:(NSInteger)imgCode
{
    NSString * strPlus = @"+";
    NSDictionary * dicts = [[NSDictionary alloc] init];
    dicts = [APP_DELEGATE getCountryCodeDictionary];
    NSString *callingCode =[strPlus stringByAppendingString:[dicts objectForKey:code]] ;
    [btnCntryCode setTitle:callingCode forState:UIControlStateNormal];
}
#pragma mark - Web Service Call
-(void)loginViaEmailWebService
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Checking details..."];
    
    
    [activityIndicator startAnimating];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    NSString * strPlus = [NSString stringWithFormat:@"%@",txtMobNumber.text];
    [dict setValue:strPlus forKey:@"mobile_number"];


    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"check_mobile_number";
    manager.delegate = self;
    NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/check_mobile_number";
    [manager urlCall:strServerUrl withParameters:dict];
}
-(void) savePasswordAPI
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Setting Password..."];
    
    [btnSave setEnabled:NO];
    [activityIndicator startAnimating];
    NSString *websrviceName=@"set_reset_password";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:txtPass.text forKey:@"old_password"];
    [dict setValue:txtConfirmPass.text forKey:@"new_password"];
    [dict setValue:@"0" forKey:@"isChangePass"];
    [dict setValue:strUserID forKey:@"user_id"];
    
    
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"set_reset_password";
    manager.delegate = self;
    NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/";
    [manager urlCall:[NSString stringWithFormat:@"%@%@",strServerUrl,websrviceName] withParameters:dict]; 
}
#pragma mark - Animations
-(void)ShowPicker:(BOOL)isShow andView:(UIView *)myView
{
    if (isShow == YES)
    {
        [UIView transitionWithView:myView duration:0.4
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            
                            [myView setFrame:CGRectMake(0, DEVICE_HEIGHT-250,DEVICE_WIDTH, 250)];
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
    else
    {
        [UIView transitionWithView:myView duration:0.4
                           options:UIViewAnimationOptionTransitionNone
                        animations:^{
                            [myView setFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 250)];
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];

//    NSLog(@"The result is...%@", result);
    
    [activityIndicator stopAnimating];

    if ([[result valueForKey:@"commandName"] isEqualToString:@"check_mobile_number"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            [self checkPhoneNumberWithGivenInput:[NSString stringWithFormat:@"%@%@",btnCntryCode.titleLabel.text,txtMobNumber.text]];
            [scrlContent setContentOffset:CGPointMake((DEVICE_WIDTH), 0)];
            strUserID = [[[result valueForKey:@"result"] valueForKey:@"data"] valueForKey:@"user_id"];
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
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"set_reset_password"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeSuccess];
            alert.delegate = self;
            alert.tag = 223;
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"Your Password Has Been Changed Successfully"
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
                      withSubtitle:[[result valueForKey:@"result"]valueForKey:@"message"]
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
    
}
- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 223)
    {
        [self.navigationController popViewControllerAnimated:YES];
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
-(void)checkPhoneNumberWithGivenInput:(NSString *)strMoblie
{
    [APP_DELEGATE startHudProcess:@"Checking details..."];

    [[FIRPhoneAuthProvider provider] verifyPhoneNumber:strMoblie UIDelegate:self completion:^(NSString * _Nullable verificationID, NSError * _Nullable error)
    {
        [APP_DELEGATE endHudProcess];

        if (error)
        {
            //[self showMessagePrompt:error.localizedDescription];
            return;
        }
        // Sign in using the verificationID and the code sent to the user
        // ...
        strOTPVerifiedID = verificationID;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:verificationID forKey:@"authVerificationID"];
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeSuccess];
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"OTP sent successfully."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];

        
    }];
}
#pragma mark - Hide Keyboard
-(void)hideKeyboard
{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning
{
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
