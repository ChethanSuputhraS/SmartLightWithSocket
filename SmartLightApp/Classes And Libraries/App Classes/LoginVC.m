//
//  LoginVC.m
//  SmartLightApp
//
//  Created by stuart watts on 04/04/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "LoginVC.h"
#import "SignupVC.h"
#import "ForgetVC.h"
#import "CountryPicker.h"
#import "ManageAccVC.h"
@interface LoginVC ()<UIGestureRecognizerDelegate,FCAlertViewDelegate,CountryPickerDelegate>
{
    CountryPicker * cntryPickerView;

}
@end

@implementation LoginVC
@synthesize isFromMangeAccount;
- (void)viewDidLoad
{
   
    
    self.title = @"Login";
    
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    [self.view addSubview:imgBack];
    
    isShowPassword = NO;
    
    [self setContentViewFrames];
    [self setupforCountryPicker];

    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIView *statusBar;
    if (@available(iOS 13, *))
    {
        statusBar = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame] ;
        statusBar.backgroundColor = global_brown_color;
        [[UIApplication sharedApplication].keyWindow addSubview:statusBar];

     }
    else
    {
        statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    }

    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        
        statusBar.backgroundColor = [UIColor blackColor];//set whatever color you like
    }
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    self.handle = [[FIRAuth auth]
                   addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
                       // ...
                   }];

    [super viewWillAppear:YES];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [[FIRAuth auth] removeAuthStateDidChangeListener:_handle];
}
#pragma mark - Set UI frames
-(void)setContentViewFrames
{
    scrlContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    scrlContent.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrlContent];
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.5;
    [viewHeader addSubview:lblBack];
    
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Sign in"];
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
    viewHeader.hidden = true;
    
    UITapGestureRecognizer * tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    tapGest.delegate = self;
    [scrlContent addGestureRecognizer:tapGest];

    UILabel * lblName =  [[UILabel alloc] init];
    lblName.frame = CGRectMake(15, 50, DEVICE_WIDTH-30, 30);
    lblName.textAlignment = NSTextAlignmentCenter;
    lblName.textColor = [UIColor whiteColor];
    lblName.text = @"Sign in";
    lblName.font = [UIFont fontWithName:CGRegular size:textSizes+2];
    [scrlContent addSubview:lblName];
    
    UIButton * btnSkip = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSkip setFrame:CGRectMake(DEVICE_WIDTH-60, 35, 60, 60)];
    [btnSkip setTitle:@"SKIP" forState:UIControlStateNormal];
    [btnSkip setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSkip.titleLabel setFont:[UIFont fontWithName:CGBold size:textSizes+1]];
    [btnSkip addTarget:self action:@selector(btnSkipClicked) forControlEvents:UIControlEventTouchUpInside];
    [scrlContent addSubview:btnSkip];
    
    viewPopUp = [[UIView alloc] initWithFrame:CGRectMake(15, 120*approaxSize,DEVICE_WIDTH-30,300*approaxSize)];
    [viewPopUp setBackgroundColor:[UIColor clearColor]];
    viewPopUp.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewPopUp.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    viewPopUp.layer.shadowRadius = 25;
    viewPopUp.layer.shadowOpacity = 0.5;
    [scrlContent addSubview:viewPopUp];
    
    if (IS_IPHONE_4)
    {
        lblName.frame = CGRectMake(15, 30, DEVICE_WIDTH-30, 30);
        viewPopUp.frame = CGRectMake(15, 70, DEVICE_WIDTH-30, 300);
        [btnSkip setFrame:CGRectMake(DEVICE_WIDTH-60, 25, 60, 60)];
    }
    
    long yy = 30;
    
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
    
    btnCntryCode = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCntryCode.frame = CGRectMake(10, yy, 50, 35*approaxSize);
    [btnCntryCode addTarget:self action:@selector(btnCntryClick) forControlEvents:UIControlEventTouchUpInside];
    [btnCntryCode setTitle:@"" forState:UIControlStateNormal];
    btnCntryCode.titleLabel.font = [UIFont fontWithName:CGBold size:textSizes];
    [viewPopUp addSubview:btnCntryCode];
    NSDictionary * dicts = [[NSDictionary alloc] init];
    dicts = [APP_DELEGATE getCountryCodeDictionary];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSString *callingCode = [dicts objectForKey:countryCode];
    NSString * strPlus = @"+";
    [btnCntryCode setTitle:[strPlus stringByAppendingString:callingCode] forState:UIControlStateNormal];
    //    [btnCntryCode setTitle:@"+999" forState:UIControlStateNormal];
    
    UILabel * lblCode = [[UILabel alloc] initWithFrame:CGRectMake(5, btnCntryCode.frame.size.height-2, btnCntryCode.frame.size.width-10,1)];
    [lblCode setBackgroundColor:[UIColor lightGrayColor]];
    [btnCntryCode addSubview:lblCode];
    
    txtMobile = [[UITextField alloc] initWithFrame:CGRectMake(60, yy, viewPopUp.frame.size.width-75, 35*approaxSize)];
    txtMobile.placeholder = @"Mobile No.";
    txtMobile.delegate = self;
    txtMobile.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtMobile.textColor = [UIColor whiteColor];
    [txtMobile setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    txtMobile.autocorrectionType = UITextAutocorrectionTypeNo;
    txtMobile.returnKeyType = UIReturnKeyNext;
    txtMobile.keyboardType = UIKeyboardTypePhonePad;
    [viewPopUp addSubview:txtMobile];
    txtMobile.keyboardAppearance = UIKeyboardAppearanceAlert;
    [APP_DELEGATE getPlaceholderText:txtMobile andColor:[UIColor lightGrayColor]];

    
    UILabel * lblEmailLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtMobile.frame.size.height-2, txtMobile.frame.size.width, 1)];
    [lblEmailLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtMobile addSubview:lblEmailLine];
    
    yy = yy + 60;
    
    txtPassword = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35)];
    txtPassword.placeholder = @"Password";
    txtPassword.delegate = self;
    txtPassword.secureTextEntry = YES;
    txtPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtPassword.textColor = [UIColor whiteColor];
    [txtPassword setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [APP_DELEGATE getPlaceholderText:txtPassword andColor:[UIColor lightGrayColor]];
    txtPassword.returnKeyType  = UIReturnKeyDone;
    txtPassword.keyboardAppearance = UIKeyboardAppearanceAlert;
    [viewPopUp addSubview:txtPassword];
    
    UILabel * lblPasswordLine = [[UILabel alloc] initWithFrame:CGRectMake(0,txtPassword.frame.size.height-2, txtPassword.frame.size.width,1)];
    [lblPasswordLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtPassword addSubview:lblPasswordLine];
    
    btnShowPass = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowPass.frame = CGRectMake(viewPopUp.frame.size.width-60, yy, 60, 35);
    btnShowPass.backgroundColor = [UIColor clearColor];
    [btnShowPass addTarget:self action:@selector(showPassclick) forControlEvents:UIControlEventTouchUpInside];
    [btnShowPass setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
    [viewPopUp addSubview:btnShowPass];
    
    yy = yy + 50*approaxSize;
    
    imgCheck = [[UIImageView alloc] init];
    imgCheck.image = [UIImage imageNamed:@"checkEmpty.png"];
    imgCheck.frame = CGRectMake(15, yy+5, 20, 20);
    [viewPopUp addSubview:imgCheck];
    
    UILabel * lblRemember =  [[UILabel alloc] init];
    lblRemember.frame = CGRectMake(45, yy, DEVICE_WIDTH-30, 30);
    lblRemember.textColor = [UIColor whiteColor];
    lblRemember.text = @"Remember Me";
    [lblRemember setFont:[UIFont fontWithName:CGRegular size:textSizes-1]];
    [viewPopUp addSubview:lblRemember];
    
    btnRemember = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRemember setFrame:CGRectMake(0, yy, viewPopUp.frame.size.width-30, 44)];
    [btnRemember addTarget:self action:@selector(btnRememberClick) forControlEvents:UIControlEventTouchUpInside];
    [viewPopUp addSubview:btnRemember];
    
    yy = yy + 45*approaxSize;
    
    btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLogin setFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 44)];
    [btnLogin setTitle:@"Login" forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnLogin.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [btnLogin addTarget:self action:@selector(btnLoginClicked) forControlEvents:UIControlEventTouchUpInside];
    btnLogin.backgroundColor = global_brown_color;
    [viewPopUp addSubview:btnLogin];
    
    yy = yy + 65*approaxSize;
    
    btnForgotPassword = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnForgotPassword setFrame:CGRectMake(40, yy, viewPopUp.frame.size.width-80, 40)];
    [btnForgotPassword setTitle:@"Forgot your password?" forState:UIControlStateNormal];
    [btnForgotPassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnForgotPassword setBackgroundColor:[UIColor clearColor]];
    [btnForgotPassword addTarget:self action:@selector(btnForgotPasswordClicked) forControlEvents:UIControlEventTouchUpInside];
    [btnForgotPassword.titleLabel setFont:[UIFont fontWithName:CGBold size:textSizes]];
    [viewPopUp addSubview:btnForgotPassword];
    
    UILabel * loginLbl =[[UILabel alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT-55, DEVICE_WIDTH, 35)];
    loginLbl.font=[UIFont fontWithName:CGRegular size:textSizes];
    loginLbl.textAlignment=NSTextAlignmentCenter;
    loginLbl.textColor=[UIColor whiteColor];
    [scrlContent addSubview:loginLbl];
    
    NSMutableAttributedString *hintText = [[NSMutableAttributedString alloc] initWithString:@"Don't have an account? Sign Up here"];
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithName:CGRegular size:textSizes];
    UIFontDescriptor *fontDescriptor1 = [UIFontDescriptor fontDescriptorWithName:CGBold size:textSizes];
    UIFontDescriptor *symbolicFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitTightLeading];
    
    UIFontDescriptor *symbolicFontDescriptor1 = [fontDescriptor1 fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFont *fontWithDescriptor = [UIFont fontWithDescriptor:symbolicFontDescriptor size:textSizes];
    UIFont *fontWithDescriptor1 = [UIFont fontWithDescriptor:symbolicFontDescriptor1 size:textSizes];
    
    //Red and large
    [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor, NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, 24)];
    //Rest of text -- just futura
    [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor1, NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(23, hintText.length - 23-5)];
    loginLbl.textColor=[UIColor whiteColor];
    [loginLbl setAttributedText:hintText];
    
    UIButton * btnSignUp = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSignUp.frame = CGRectMake(0, DEVICE_HEIGHT-50, DEVICE_WIDTH, 35);
    [btnSignUp addTarget:self action:@selector(btnSignupClick) forControlEvents:UIControlEventTouchUpInside];
    [scrlContent addSubview:btnSignUp];
    
    if (isFromMangeAccount == true)
    {
        
    }
    else
    {
//        if (CURRENT_USER_MOBILE != [NSNull null])
//        {
//            if (CURRENT_USER_MOBILE != nil && CURRENT_USER_MOBILE != NULL && ![CURRENT_USER_MOBILE isEqualToString:@""])
//            {
//                txtMobile.text = CURRENT_USER_MOBILE;
//            }
//        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"IsRemember"] isEqualToString:@"Yes"])
        {
            if (CURRENT_USER_PASS != [NSNull null])
            {
                if (CURRENT_USER_PASS != nil && CURRENT_USER_PASS != NULL && ![CURRENT_USER_PASS isEqualToString:@""])
                {
                    txtPassword.text = CURRENT_USER_PASS;
                    imgCheck.image = [UIImage imageNamed:@"checked.png"];
                }
            }
            if (CURRENT_USER_MOBILE != [NSNull null])
            {
                if (CURRENT_USER_MOBILE != nil && CURRENT_USER_MOBILE != NULL && ![CURRENT_USER_MOBILE isEqualToString:@""])
                {
                    txtMobile.text = CURRENT_USER_MOBILE;
                    imgCheck.image = [UIImage imageNamed:@"checked.png"];
                }
            }
    }
  
    }
    if(IS_IPHONE_X)
    {
        loginLbl.frame =CGRectMake(0, DEVICE_HEIGHT-50-55, DEVICE_WIDTH, 35);
        btnSignUp.frame = CGRectMake(0, DEVICE_HEIGHT-50-50, DEVICE_WIDTH, 35);
        lblName.frame = CGRectMake(15, 40, DEVICE_WIDTH-30, 30);
        [btnSkip setFrame:CGRectMake(DEVICE_WIDTH-60, 35, 60, 60)];
    }
    if (isFromMangeAccount == true)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 88, 88);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        btnSkip.hidden = true;
        lblName.hidden = true;
        viewHeader.hidden = false;
        btnSignUp.hidden = true;
        loginLbl.hidden = YES;
        [APP_DELEGATE hideTabBar:self.tabBarController];
        
        
    }
    
}

#pragma mark - Set Custom ActionSheet
-(void)setMoreBtnPopUp
{
    [viewOverLay removeFromSuperview];
    viewOverLay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    [self.view addSubview:viewOverLay];
    
    backView = [[UIView alloc] init];
    backView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    backView.backgroundColor = [UIColor blackColor];
    [backView setAlpha:0.7];
    [viewOverLay addSubview:backView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OverLayTaped:)];
    tapRecognizer.numberOfTapsRequired=1;
    [viewOverLay addGestureRecognizer:tapRecognizer];
    
    [viewMore removeFromSuperview];
    viewMore = [[UIView alloc] initWithFrame:CGRectMake(20, DEVICE_HEIGHT, self.view.frame.size.width-40, 180+20)];
    [viewMore setBackgroundColor:[UIColor blackColor]];
    viewMore.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewMore.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    viewMore.layer.shadowRadius = 3;
    viewMore.layer.shadowOpacity = 0.5;
    [viewOverLay addSubview:viewMore];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:viewMore.bounds];
    viewMore.layer.masksToBounds = NO;
    viewMore.layer.shadowColor = [UIColor whiteColor].CGColor;
    viewMore.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    viewMore.layer.shadowOpacity = 0.5f;
    viewMore.layer.shadowPath = shadowPath.CGPath;
    
    int yy = 10;
    
    UILabel *lblTitle =[[UILabel alloc]initWithFrame:CGRectMake(0, 10, viewMore.frame.size.width, 20)];
    lblTitle.text= @"Forgot Password ?";
    lblTitle.textColor=[UIColor darkGrayColor];
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.clipsToBounds=NO;
    [lblTitle setFont:[UIFont fontWithName:CGBold size:textSizes]];
    lblTitle.shadowOffset= CGSizeMake(0.0, -1.0);
    lblTitle.shadowColor=[UIColor clearColor];
    [viewMore addSubview:lblTitle];
    
    yy = yy+25+5;
    
    UILabel *lblmessage =[[UILabel alloc]initWithFrame:CGRectMake(5, yy, viewMore.frame.size.width-10, 50)];
    lblmessage.text= @"Enter your registered Mobile No. to get password!";
    lblmessage.textColor=[UIColor whiteColor];
    lblmessage.textAlignment=NSTextAlignmentCenter;
    lblmessage.clipsToBounds=NO;
    lblmessage.shadowOffset= CGSizeMake(0.0, -1.0);
    lblmessage.shadowColor=[UIColor clearColor];
    [lblmessage setFont:[UIFont fontWithName:CGRegular size:textSizes-1]];
    lblmessage.numberOfLines=0;
    [viewMore addSubview:lblmessage];
    
    yy = yy+50;
    
    txtForgotpasswordEmail = [[UITextField alloc] initWithFrame:CGRectMake(20, yy, viewMore.frame.size.width-40, 35)];
    txtForgotpasswordEmail.placeholder = @"Mobile No";
    txtForgotpasswordEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtForgotpasswordEmail.delegate = self;
    txtForgotpasswordEmail.autocorrectionType = UITextAutocorrectionTypeNo;
    txtForgotpasswordEmail.keyboardType = UIKeyboardTypePhonePad;
    txtForgotpasswordEmail.textColor = [UIColor whiteColor];
    [txtForgotpasswordEmail setFont:[UIFont fontWithName:CGRegular size:textSizes-1]];
    txtForgotpasswordEmail.returnKeyType = UIReturnKeyDone;
    [APP_DELEGATE getPlaceholderText:txtForgotpasswordEmail andColor:[UIColor lightGrayColor]];
    txtForgotpasswordEmail.keyboardAppearance = UIKeyboardAppearanceAlert;
    [viewMore addSubview:txtForgotpasswordEmail];
    
    UILabel * lblEmailLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtMobile.frame.size.height-2, txtForgotpasswordEmail.frame.size.width, 1)];
    [lblEmailLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtForgotpasswordEmail addSubview:lblEmailLine];
    
    yy = yy+40;
    
    lblerror =[[UILabel alloc]initWithFrame:CGRectMake(20, yy, viewMore.frame.size.width-50, 20)];
    lblerror.textAlignment=NSTextAlignmentLeft;
    lblerror.font=[UIFont fontWithName:CGRegular size:textSizes-5];
    lblerror.textColor=[UIColor redColor];
    [viewMore addSubview:lblerror];
    
    btncancel =[UIButton buttonWithType:UIButtonTypeSystem];
    [btncancel setFrame:CGRectMake(0, viewMore.frame.size.height-40, (viewMore.frame.size.width/2)+10, 40)];
    [btncancel setTitle:ALERT_CANCEL forState:UIControlStateNormal];
    [btncancel setBackgroundColor:[UIColor blackColor]];
    [btncancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btncancel.layer.borderWidth=0.5;
    btncancel.layer.borderColor=[UIColor darkGrayColor].CGColor;
    btncancel.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes];
    [btncancel addTarget:self action:@selector(AlertCancleClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewMore addSubview:btncancel];
    
    
    btnOk =[UIButton buttonWithType:UIButtonTypeSystem];
    [btnOk setFrame:CGRectMake((viewMore.frame.size.width/2)-1,viewMore.frame.size.height-40,(viewMore.frame.size.width/2)+1,40)];
    [btnOk setTitle:OK_BTN forState:UIControlStateNormal];
    [btnOk setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnOk.layer.borderWidth=0.5;
    btnOk.backgroundColor = [UIColor blackColor];
    btnOk.layer.borderColor=[UIColor darkGrayColor].CGColor;
    btncancel.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes];
    [btnOk addTarget:self action:@selector(AlertOKClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewMore addSubview:btnOk];
    [viewMore setFrame:CGRectMake(20, DEVICE_HEIGHT, self.view.frame.size.width-40, 200)];
    
    [self hideMorePopUpView:NO];
}
-(void)hideMorePopUpView:(BOOL)isHide
{
    [txtForgotpasswordEmail resignFirstResponder];
    
    if (isHide == YES)
    {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options: UIViewAnimationOptionOverrideInheritedCurve
                         animations:^{
                             viewMore.frame = CGRectMake(20, DEVICE_HEIGHT , DEVICE_WIDTH-40, viewMore.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             [viewMore removeFromSuperview];
                             [viewOverLay removeFromSuperview];
                         }];
    }
    else
    {
        [UIView animateWithDuration:0.5 delay:0.0 options: UIViewAnimationOptionOverrideInheritedCurve
                         animations:^{
                             viewMore.frame = CGRectMake(20, (DEVICE_HEIGHT-(viewMore.frame.size.height))/2 , DEVICE_WIDTH-40, viewMore.frame.size.height);
                         }
                         completion:^(BOOL finished)
         {
             
         }];
    }
}
#pragma mark
-(void) btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
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

-(void)btnLoginClicked
{
    [self hideKeyboard];
    
    if([txtMobile.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please enter your mobile number"];
    }
    else if([txtMobile.text length]<10)
    {
        [self showMessagewithText:@"Mobile number should at least 10 digits"];
    }
    else if ([txtPassword.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please enter your password"];
    }
    else
    {
        if (isFromMangeAccount == true)
        {
            NSMutableArray * arrTable = [[NSMutableArray alloc]init];
            NSString *strTbl = [NSString stringWithFormat:@"Select * from UserAccount_Table where user_mobile_no = '%@'",txtMobile.text];
            [[DataBaseManager dataBaseManager] execute:strTbl resultsArray:arrTable];
            
            if (arrTable.count > 0)
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeWarning];
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:@"This Account has already been added."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else
            {
                [self loginViaEmailWebService];
            }
        }
        else
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
    
    
}

-(void)btnForgotPasswordClicked
{
    [self hideKeyboard];
    ForgetVC *view1 = [[ForgetVC alloc]init];
    [self.navigationController pushViewController:view1 animated:true];
   // [self setMoreBtnPopUp];
    
}
-(void)btnSkipClicked
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
-(void)btnSignupClick
{
    SignupVC * signVC = [[SignupVC alloc] init];
    [self.navigationController pushViewController:signVC animated:YES];
}
-(void)showPassclick
{
    if (isShowPassword)
    {
        isShowPassword = NO;
        [btnShowPass setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
        txtPassword.secureTextEntry = YES;
    }
    else
    {
        isShowPassword = YES;
        [btnShowPass setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
        txtPassword.secureTextEntry = NO;
    }
}
-(void)btnRememberClick
{
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"IsRemember"] isEqualToString:@"Yes"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"No" forKey:@"IsRemember"];
        imgCheck.image = [UIImage imageNamed:@"checkEmpty.png"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"Yes" forKey:@"IsRemember"];
        imgCheck.image = [UIImage imageNamed:@"checked.png"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
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


#pragma mark - custome Alert Clicked
-(void)AlertCancleClicked:(id)sender
{
    [self hideMorePopUpView:YES];
}
-(void)AlertOKClicked:(id)sender
{
    [txtForgotpasswordEmail resignFirstResponder];
    
    if([txtForgotpasswordEmail.text isEqualToString:@""])
    {
        lblerror.text=@"Invalid mobile no";
        lblerror.hidden=NO;
    }
    else if([txtForgotpasswordEmail.text length]<10)
    {
        lblerror.text=@"Invalid mobile no";
        lblerror.hidden=NO;
    }
    else
    {
        lblerror.text=@"";
        lblerror.hidden=YES;
        [txtForgotpasswordEmail resignFirstResponder];
        
        if ([APP_DELEGATE isNetworkreachable])
        {
            [self forgotPasswordWebService];
        }
        else
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"There is no internet connection. Please connect to internet first then try again later."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
}
-(void)cancelBtnClicked:(id)sender
{
    [self hideMorePopUpView:YES];
}

-(void)OverLayTaped:(id)sender
{
}
#pragma mark - Web Service Call
-(void)loginViaEmailWebService
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Logging..."];
    
    [btnLogin setEnabled:NO];
    [activityIndicator startAnimating];
    NSString *websrviceName=@"login";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:txtMobile.text forKey:@"mobile_number"];
    [dict setValue:txtPassword.text forKey:@"password"];
    
    NSString *deviceToken =deviceTokenStr;
    if (deviceToken == nil || deviceToken == NULL)
    {
        [dict setValue:@"123456789" forKey:@"device_token"];    //for simulator
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
    
    if (isFromMangeAccount == NO)
    {
        [APP_DELEGATE GenerateEncryptedKeyforLogin:txtMobile.text];
        [self ResetAllUUIDs];
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
//{
//    //Create Global UUID
//    NSString * strGlobUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"globalUUID"];
//    if ([strGlobUUID isEqual:[NSNull null]] || [strGlobUUID length]==0 || strGlobUUID == nil)
//    {
//        CFUUIDRef udid = CFUUIDCreate(NULL);
//        NSString *udidString = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, udid));
//        [[NSUserDefaults standardUserDefaults] setValue:udidString forKey:@"globalUUID"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//
//    /*-----------Start Location Manager----------*/
//    [self getLocationMethod];
//    /*-------------------------------------------*/
//
//    //Create Color UUID
//    NSString * strColorUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"colorUUID"];
//    if ([strColorUUID isEqual:[NSNull null]] || [strColorUUID length]==0 || strColorUUID == nil)
//    {
//        [self generateUUIDforColor:@"0" withOpcode:@"66"];
//        [self generateUUIDforAdvertising:@"0" withOpcode:@"66"];
//    }
//
//    //Create White Color UUID
//    NSString * strWhiteUDID = [[NSUserDefaults standardUserDefaults] valueForKey:@"whiteColorUDID"];
//    if ([strWhiteUDID isEqual:[NSNull null]] || [strWhiteUDID length]==0 || strWhiteUDID == nil)
//    {
//        [self generateUUIDforColor:@"0" withOpcode:@"70"];
//        [self generateUUIDforAdvertising:@"0" withOpcode:@"70"];
//    }
//
//    //Create OnOff UUID
//    NSString * strOnOffUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"OnOffUUID"];
//    if ([strOnOffUUID isEqual:[NSNull null]] || [strOnOffUUID length]==0 || strOnOffUUID == nil)
//    {
//        [self generateUUIDforColor:@"0" withOpcode:@"85"];
//        [self generateUUIDforAdvertising:@"0" withOpcode:@"85"];
//    }
//
//    //Create Pattern UUID
//    NSString * strPatrnUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"PatternUUID"];
//    if ([strPatrnUUID isEqual:[NSNull null]] || [strPatrnUUID length]==0 || strPatrnUUID == nil)
//    {
//        [self generateUUIDforColor:@"0" withOpcode:@"67"];
//        [self generateUUIDforAdvertising:@"0" withOpcode:@"67"];
//    }
//
//    //Create Delete UUID
//    NSString * strDeleteUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeleteUUID"];
//    if ([strDeleteUUID isEqual:[NSNull null]] || [strDeleteUUID length]==0 || strDeleteUUID == nil)
//    {
//        [self generateUUIDforColor:@"0" withOpcode:@"55"];
//        [self generateUUIDforAdvertising:@"0" withOpcode:@"55"];
//    }
//
//    //Create Ping UUID
//    NSString * strPingUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"PingUUID"];
//    if ([strPingUUID isEqual:[NSNull null]] || [strPingUUID length]==0 || strPingUUID == nil)
//    {
//        [self generateUUIDforColor:@"0" withOpcode:@"112"];
//        [self generateUUIDforAdvertising:@"0" withOpcode:@"112"];
//    }
//
//
//    //Create White color UUID
//    NSString * strWhiteUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"WhiteUUID"];
//    if ([strWhiteUUID isEqual:[NSNull null]] || [strWhiteUUID length]==0 || strWhiteUUID == nil)
//    {
//        [self generateUUIDforColor:@"0" withOpcode:@"82"];
//        [self generateUUIDforAdvertising:@"0" withOpcode:@"82"];
//    }
//
//    //Set Time UUID
//    NSString * stTimeUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"TimeUUID"];
//    if ([stTimeUUID isEqual:[NSNull null]] || [stTimeUUID length]==0 || stTimeUUID == nil)
//    {
//        [self generateUUIDforColor:@"0" withOpcode:@"96"];
//        [self generateUUIDforAdvertising:@"0" withOpcode:@"96"];
//    }
//    //Add Group UUID
//    NSString * strAddGroupUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"AddGroupUUID"];
//    if ([strAddGroupUUID isEqual:[NSNull null]] || [strAddGroupUUID length]==0 || strAddGroupUUID == nil)
//    {
//        [self generateUUIDforColor:@"0" withOpcode:@"8"];
//        [self generateUUIDforAdvertising:@"0" withOpcode:@"8"];
//    }
//    //Delete Group UUID
//    NSString * strDeleteGroupUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeleteGroupUUID"];
//    if ([strDeleteGroupUUID isEqual:[NSNull null]] || [strDeleteGroupUUID length]==0 || strDeleteGroupUUID == nil)
//    {
//        [self generateUUIDforColor:@"0" withOpcode:@"10"];
//        [self generateUUIDforAdvertising:@"0" withOpcode:@"10"];
//    }
//    //Delete Alarm UUID
//    NSString * strRemovealarmUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeleteAlarmUUID"];
//    if ([strRemovealarmUUID isEqual:[NSNull null]] || [strRemovealarmUUID length]==0 || strRemovealarmUUID == nil)
//    {
//        [self generateUUIDforColor:@"0" withOpcode:@"99"];
//        [self generateUUIDforAdvertising:@"0" withOpcode:@"99"];
//    }
//    //Music UUID
//    NSString * strMusicUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"MusicUUID"];
//    if ([strMusicUUID isEqual:[NSNull null]] || [strMusicUUID length]==0 || strMusicUUID == nil)
//    {
//        [self generateUUIDforColor:@"0" withOpcode:@"72"];
//        [self generateUUIDforAdvertising:@"0" withOpcode:@"72"];
//    }
//    //Music UUID
//    NSString * strRememberUDID = [[NSUserDefaults standardUserDefaults] valueForKey:@"RememberUDID"];
//    if ([strRememberUDID isEqual:[NSNull null]] || [strRememberUDID length]==0 || strRememberUDID == nil)
//    {
//        [self generateUUIDforColor:@"0" withOpcode:@"71"];
//        [self generateUUIDforAdvertising:@"0" withOpcode:@"71"];
//    }
//}
-(void)forgotPasswordWebService
{
    [self AlertCancleClicked:nil];
    
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Retrieving Password"];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:txtForgotpasswordEmail.text forKey:@"mobile_number"];
    
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"forgotpassword";
    manager.delegate = self;
    NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/retrive_password";
    [manager urlCall:[NSString stringWithFormat:@"%@",strServerUrl] withParameters:dict];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];
    
//    NSLog(@"The result is...%@", result);
    
    [btnLogin setEnabled:YES];
    [activityIndicator stopAnimating];
    
    if ([[result valueForKey:@"commandName"] isEqualToString:@"login"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if (isFromMangeAccount)
            {
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
                [tmpDict setValue:@"0" forKey:@"is_active"];
                [self addManageAccountWithDetails:tmpDict];
                [self AddAlarmforLoggedinUser];

                [self.navigationController popViewControllerAnimated:true];
                
            }
            else
            {
                
                [[NSUserDefaults standardUserDefaults] setObject:[[result valueForKey:@"result"] valueForKey:@"auth_token"] forKey:@"auth_token"];
                [[NSUserDefaults standardUserDefaults] setValue:txtMobile.text forKey:@"CURRENT_USER_MOBILE"];
                [[NSUserDefaults standardUserDefaults] setValue:txtPassword.text forKey:@"CURRENT_USER_PASS"];
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"IS_LOGGEDIN"];
                
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
                [tmpDict setObject:txtPassword.text forKey:@"localPassword"];
                [tmpDict setValue:@"1" forKey:@"is_active"];
                
                [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"user_id"] forKey:@"CURRENT_USER_ID"];
                [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"username"] forKey:@"CURRENT_USER_NAME"];
                [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"email"] forKey:@"CURRENT_USER_EMAIL"];
                [[NSUserDefaults standardUserDefaults] setValue:[tmpDict objectForKey:@"account_name"] forKey:@"CURRENT_ACCOUNT_NAME"];
                [[NSUserDefaults standardUserDefaults] setObject:tmpDict forKey:@"UserDict"];
                [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"IS_USER_SKIPPED"];
                [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"IS_USER_LOGGED"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self addManageAccountWithDetails:tmpDict];

                
                [self AddAlarmforLoggedinUser];

                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeSuccess];
                alert.delegate = self;
                alert.tag = 222;
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:@"Logged in Successfully."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            
            }
            
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
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"forgotpassword"])
    {
        [btnLogin setEnabled:YES];
        [btnOk setTitle:OK_BTN forState:UIControlStateNormal];
        [btncancel setEnabled:YES];
        [btncancel setTitle:ALERT_CANCEL forState:UIControlStateNormal];

        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeSuccess];
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"Your password has been sent successfully to your registered mobie number. Please check and try again to login."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
        else
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Mobile not registered with us"])
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:@"Mobile not registered with us. Please login with valid mobile number."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
        }
    }
}

- (void)onError:(NSError *)error
{
    [APP_DELEGATE endHudProcess];
    
//    NSLog(@"The error is...%@", error);
    
    [btnLogin setEnabled:YES];
    [activityIndicator stopAnimating];
    
    [btnLogin setEnabled:YES];
    [btnOk setTitle:OK_BTN forState:UIControlStateNormal];
    [btncancel setEnabled:YES];
    [btncancel setTitle:ALERT_CANCEL forState:UIControlStateNormal];
    [ForgotpasswordIndicator stopAnimating];
    
    
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
-(void)addManageAccountWithDetails:(NSMutableDictionary*)tmpDict
{
    NSMutableArray * arrTemp = [[NSMutableArray alloc]init];
    NSString *strTbl = [NSString stringWithFormat:@"Select * from UserAccount_Table where server_user_id = '%@'",[tmpDict valueForKey:@"user_id"]];
    [[DataBaseManager dataBaseManager] execute:strTbl resultsArray:arrTemp];
    
    NSString *deviceToken =deviceTokenStr;
    
    if (isFromMangeAccount == false)
    {
        NSString *strObject = [NSString stringWithFormat:@"update UserAccount_Table set is_active = '0'"];
        [[DataBaseManager dataBaseManager] execute:strObject];
    }
    if (deviceToken == nil || deviceToken == NULL)
    {
        deviceToken = @"12345";
    }
    
    if (arrTemp.count == 0)
    {
        NSString *strDevice = [NSString stringWithFormat:@"insert into 'UserAccount_Table'('server_user_id','user_name','account_name','user_email','user_mobile_no','user_pw','user_token','is_active') values('%@','%@','%@','%@','%@','%@','%@','%@')",[tmpDict valueForKey:@"user_id"],[tmpDict valueForKey:@"username"],[tmpDict valueForKey:@"account_name"],[tmpDict valueForKey:@"email"],txtMobile.text,txtPassword.text,deviceToken,[tmpDict valueForKey:@"is_active"]];
        [[DataBaseManager dataBaseManager] execute:strDevice];
        
    }
    else
    {
        NSString *strDeviceUpdate = [NSString stringWithFormat:@"Update 'UserAccount_Table' set server_user_id = '%@',user_name = '%@',account_name = '%@',user_email = '%@',user_pw = '%@',user_mobile_no = '%@',user_token = '%@',is_active = '%@' where server_user_id = '%@' ",[tmpDict valueForKey:@"user_id"],[tmpDict valueForKey:@"username"],[tmpDict valueForKey:@"account_name"],[tmpDict valueForKey:@"email"],txtPassword.text,txtMobile.text,deviceToken,[tmpDict valueForKey:@"is_active"],[tmpDict valueForKey:@"user_id"]];
        [[DataBaseManager dataBaseManager] execute:strDeviceUpdate];
    }
}
#pragma mark - Hide Keyboard
-(void)hideKeyboard
{
    [txtMobile resignFirstResponder];
    [txtPassword resignFirstResponder];
    [txtForgotpasswordEmail resignFirstResponder];
}

#pragma mark - Textfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtMobile)
    {
        [txtPassword becomeFirstResponder];
    }
    else if (textField == txtPassword)
    {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == txtForgotpasswordEmail)
    {
        [UIView animateWithDuration:0.3 animations:^{
            if (IS_IPHONE_4)
            {
                [viewMore setFrame:CGRectMake(20, (DEVICE_HEIGHT-(viewMore.frame.size.height))/2 -140, DEVICE_WIDTH-40, viewMore.frame.size.height)];
            }else
            {
                [viewMore setFrame:CGRectMake(20, (DEVICE_HEIGHT-(viewMore.frame.size.height))/2- 100 , DEVICE_WIDTH-40, viewMore.frame.size.height)];
            }
        }];
    }
    lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, textField.frame.size.height-2, textField.frame.size.width, 2)];
    [lblLine setBackgroundColor:[UIColor whiteColor]];
    [textField addSubview:lblLine];
    
    if (textField == txtMobile || textField == txtForgotpasswordEmail)
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

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == txtForgotpasswordEmail)
    {
        [UIView animateWithDuration:0.3 animations:^{
            [viewMore setFrame:CGRectMake(20, (DEVICE_HEIGHT-(viewMore.frame.size.height))/2 , DEVICE_WIDTH-40, viewMore.frame.size.height)];
        }];
    }
    [lblLine removeFromSuperview];
}
-(void)doneKeyBoarde
{
    if (IS_IPHONE_X)
    {
        
    }
    [txtForgotpasswordEmail resignFirstResponder];
    [txtMobile resignFirstResponder];
}
- (BOOL)validatePhone:(NSString *)phoneNumber
{
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
}
-(void)tapClick:(UITapGestureRecognizer *)tapClick
{
    [self.view endEditing:YES];
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
#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
//    NSLog(@"Button Clicked: %ld Title:%@", (long)index, title);
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
}

- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
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
    if (![[self checkforValidString:[dicts objectForKey:code]] isEqualToString:@"NA"])
    {
        NSString *callingCode =[strPlus stringByAppendingString:[dicts objectForKey:code]] ;
        [btnCntryCode setTitle:callingCode forState:UIControlStateNormal];
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
*/

@end
