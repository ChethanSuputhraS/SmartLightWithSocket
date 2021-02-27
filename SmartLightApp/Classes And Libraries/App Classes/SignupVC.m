//
//  SignupVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 20/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "SignupVC.h"
@import Firebase;
#import <FirebaseAuth/FIRPhoneAuthProvider.h>
#import "OtpVerifyVC.h"
#import "CountryPicker.h"
#import "webViewVC.h"
@interface SignupVC ()<UIGestureRecognizerDelegate,FCAlertViewDelegate,CountryPickerDelegate, FIRAuthUIDelegate>
{
    NSMutableDictionary * userDetailDict;
    UIImageView * imgCheck;
    BOOL isAgreed;
    CountryPicker * cntryPickerView;

}
@end

@implementation SignupVC
@synthesize isFromEdit;

- (void)viewDidLoad
{
   
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    [self.view addSubview:imgBack];
    
    
    [self setContentViewFrames];
    [self setupforCountryPicker];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
}
#pragma mark - Set UI frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Update Profile"];
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
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
    }
}

-(void)setContentViewFrames
{
    [scrlContent removeFromSuperview];
    scrlContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    scrlContent.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrlContent];
    
    UITapGestureRecognizer * tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    tapGest.delegate = self;
    [scrlContent addGestureRecognizer:tapGest];

    if (isFromEdit)
    {
        [self setNavigationViewFrames];
    }
    UILabel * lblName =  [[UILabel alloc] init];
    lblName.frame = CGRectMake(15, 44, DEVICE_WIDTH-30, 30);
    lblName.textAlignment = NSTextAlignmentCenter;
    lblName.textColor = [UIColor whiteColor];
    lblName.text = @"Sign Up";
    [lblName setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [scrlContent addSubview:lblName];

    
    UIButton * btnSkip = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSkip setFrame:CGRectMake(DEVICE_WIDTH-60, 29, 60, 60)];
    [btnSkip setTitle:@"SKIP" forState:UIControlStateNormal];
    [btnSkip setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSkip.titleLabel setFont:[UIFont fontWithName:CGBold size:textSizes+1]];
    [btnSkip addTarget:self action:@selector(btnSkipClicked) forControlEvents:UIControlEventTouchUpInside];
    [scrlContent addSubview:btnSkip];

    
    [viewPopUp removeFromSuperview];
    viewPopUp = [[UIView alloc] initWithFrame:CGRectMake(15, 100*approaxSize, DEVICE_WIDTH-30, 365*approaxSize)];
    [viewPopUp setBackgroundColor:[UIColor clearColor]];
    viewPopUp.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewPopUp.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    viewPopUp.layer.shadowRadius = 25;
    viewPopUp.layer.shadowOpacity = 0.5;
    [scrlContent addSubview:viewPopUp];
    
    if (IS_IPHONE_4)
    {
        lblName.frame = CGRectMake(15, 30, DEVICE_WIDTH-30, 30);
        viewPopUp.frame = CGRectMake(15, 70, DEVICE_WIDTH-30, 335);
    }
    
    long yy = 15;
    
    UILabel * imgPopUpBG = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewPopUp.frame.size.width, viewPopUp.frame.size.height)];
    [imgPopUpBG setBackgroundColor:[UIColor blackColor]];
    imgPopUpBG.alpha = 0.7;
    imgPopUpBG.layer.cornerRadius = 10;
    imgPopUpBG.userInteractionEnabled = YES;
    [viewPopUp addSubview:imgPopUpBG];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imgPopUpBG.bounds];
    imgPopUpBG.layer.masksToBounds = NO;
    imgPopUpBG.layer.shadowColor = [UIColor whiteColor].CGColor;
    imgPopUpBG.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imgPopUpBG.layer.shadowOpacity = 0.5f;
    imgPopUpBG.layer.shadowPath = shadowPath.CGPath;
    
    txtName = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35*approaxSize)];
    txtName.placeholder = @"Name";
    txtName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtName.delegate = self;
    txtName.autocorrectionType = UITextAutocorrectionTypeNo;
    txtName.textColor = [UIColor whiteColor];
    [txtName setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    txtName.returnKeyType = UIReturnKeyNext;
    [APP_DELEGATE getPlaceholderText:txtName andColor:[UIColor lightGrayColor]];
    [viewPopUp addSubview:txtName];
    txtName.returnKeyType  = UIReturnKeyNext;
    txtName.keyboardAppearance = UIKeyboardAppearanceAlert;
    UILabel * nameLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtName.frame.size.height-2, txtName.frame.size.width,1)];
    [nameLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtName addSubview:nameLine];
    
    yy = yy+50*approaxSize;
    
    txtAccountName = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35*approaxSize)];
    txtAccountName.placeholder = @"Account Name (e.g. Home, Office)";
    txtAccountName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtAccountName.delegate = self;
    txtAccountName.autocorrectionType = UITextAutocorrectionTypeNo;
    txtAccountName.textColor = [UIColor whiteColor];
    [txtAccountName setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    txtAccountName.returnKeyType = UIReturnKeyNext;
    [APP_DELEGATE getPlaceholderText:txtAccountName andColor:[UIColor lightGrayColor]];
    [viewPopUp addSubview:txtAccountName];
    txtAccountName.returnKeyType  = UIReturnKeyNext;
    txtAccountName.keyboardAppearance = UIKeyboardAppearanceAlert;

    UILabel * lblAccline = [[UILabel alloc] initWithFrame:CGRectMake(0, txtAccountName.frame.size.height-2, txtAccountName.frame.size.width,1)];
    [lblAccline setBackgroundColor:[UIColor lightGrayColor]];
    [txtAccountName addSubview:lblAccline];
    
    yy = yy+50*approaxSize;
    
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
    [APP_DELEGATE getPlaceholderText:txtMobile andColor:[UIColor lightGrayColor]];
    txtMobile.keyboardAppearance = UIKeyboardAppearanceAlert;

    UILabel * lblMobileLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtMobile.frame.size.height-2, txtMobile.frame.size.width,1)];
    [lblMobileLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtMobile addSubview:lblMobileLine];
    
    yy = yy+50*approaxSize;
    
    txtPass = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35)];
    txtPass.placeholder = @"Password";
    txtPass.delegate = self;
    txtPass.secureTextEntry = YES;
    txtPass.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtPass.textColor = [UIColor whiteColor];
    [txtPass setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [APP_DELEGATE getPlaceholderText:txtPass andColor:[UIColor lightGrayColor]];
    txtPass.returnKeyType  = UIReturnKeyNext;
    [viewPopUp addSubview:txtPass];
    txtPass.keyboardAppearance = UIKeyboardAppearanceAlert;

    btnShowPass = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowPass.frame = CGRectMake(viewPopUp.frame.size.width-60, yy, 60, 35);
    btnShowPass.backgroundColor = [UIColor clearColor];
    [btnShowPass addTarget:self action:@selector(showPassclick) forControlEvents:UIControlEventTouchUpInside];
    [btnShowPass setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
    [viewPopUp addSubview:btnShowPass];
    
    UILabel * lblPasswordLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtPass.frame.size.height-2, txtPass.frame.size.width,1)];
    [lblPasswordLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtPass addSubview:lblPasswordLine];
    
    yy = yy+50 * approaxSize;
    
    txtEmail = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35*approaxSize)];
    txtEmail.placeholder = @"Email (Optional)";
    txtEmail.delegate = self;
    txtEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtEmail.textColor = [UIColor whiteColor];
    [txtEmail setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    txtEmail.autocorrectionType = UITextAutocorrectionTypeNo;
    txtEmail.keyboardType = UIKeyboardTypeEmailAddress;
    txtEmail.returnKeyType = UIReturnKeyDone;
    [viewPopUp addSubview:txtEmail];
    [APP_DELEGATE getPlaceholderText:txtEmail andColor:[UIColor lightGrayColor]];
    txtEmail.keyboardAppearance = UIKeyboardAppearanceAlert;

    UILabel * lblmailLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtEmail.frame.size.height-2, txtEmail.frame.size.width,1)];
    [lblmailLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtEmail addSubview:lblmailLine];
    
    yy = yy+45*approaxSize;

    if (isFromEdit)
    {
        
    }
    else
    {
        if (IS_IPHONE_4)
        {
            [self setTermsConditions:yy-10];
            yy = yy+35*approaxSize;
        }
        else if (IS_IPHONE_5)
        {
            [self setTermsConditions:yy];
            yy = yy+55*approaxSize;
        }
        else
        {
            [self setTermsConditions:yy];
            yy = yy+55*approaxSize;
        }
    }

    btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 38*approaxSize)];
    [btnNext setTitle:@"Submit" forState:UIControlStateNormal];
    [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNext setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNext.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [btnNext addTarget:self action:@selector(btnNextClicked) forControlEvents:UIControlEventTouchUpInside];
    btnNext.backgroundColor = global_brown_color;
    
    [viewPopUp addSubview:btnNext];
    
    if (isFromEdit)
    {
        [btnNext setTitle:@"SAVE" forState:UIControlStateNormal];
        [self fillForm];
    }
    if(IS_IPHONE_X)
    {
        lblName.frame = CGRectMake(15, 40, DEVICE_WIDTH-30, 30);
    }
    [self setBottomView];
}
-(void)setTermsConditions:(long)withY
{
    imgCheck = [[UIImageView alloc] init];
    imgCheck.image = [UIImage imageNamed:@"checkEmpty.png"];
    imgCheck.frame = CGRectMake(5, withY+8, 20, 20);
    [viewPopUp addSubview:imgCheck];
    
    UIButton * btnAgree = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAgree setFrame:CGRectMake(0, withY-5, 60, 40)];
    [btnAgree addTarget:self action:@selector(agreeClick) forControlEvents:UIControlEventTouchUpInside];
    btnAgree.backgroundColor = [UIColor clearColor];
    [viewPopUp addSubview:btnAgree];
    
    UILabel * lblTerms =[[UILabel alloc] initWithFrame:CGRectMake(30, withY, viewPopUp.frame.size.width-30, 35)];
    lblTerms.font=[UIFont fontWithName:CGRegular size:textSizes];
    lblTerms.textColor=[UIColor whiteColor];
    [viewPopUp addSubview:lblTerms];
    
    NSMutableAttributedString *hintText = [[NSMutableAttributedString alloc] initWithString:@"I agree to the terms and conditions"];
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithName:CGBold size:textSizes];
    UIFontDescriptor *fontDescriptor1 = [UIFontDescriptor fontDescriptorWithName:CGRegular size:textSizes];
    UIFontDescriptor *symbolicFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitTightLeading];
    
    UIFontDescriptor *symbolicFontDescriptor1 = [fontDescriptor1 fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    
    UIFont *fontWithDescriptor = [UIFont fontWithDescriptor:symbolicFontDescriptor size:textSizes];
    UIFont *fontWithDescriptor1 = [UIFont fontWithDescriptor:symbolicFontDescriptor1 size:textSizes];
    
    //Red and large
    [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor, NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, 14)];
    
    //Rest of text -- just futura
    [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor1, NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(14, hintText.length -14)];
    
    lblTerms.textColor=[UIColor whiteColor];
    [lblTerms setAttributedText:hintText];
    
    if (isFromEdit)
    {
        lblTerms.hidden = YES;
    }

    UIButton * btnTermsAndCond = [[UIButton alloc]init];
    btnTermsAndCond.backgroundColor = UIColor.clearColor;
    btnTermsAndCond.frame = CGRectMake(135, withY, viewPopUp.frame.size.width-135, 35);
    [btnTermsAndCond addTarget:self action:@selector(btnTermsAction) forControlEvents:UIControlEventTouchUpInside];
    [viewPopUp addSubview:btnTermsAndCond];
}
-(void)setBottomView
{
    UILabel * loginLbl =[[UILabel alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT-55, DEVICE_WIDTH, 35)];
    loginLbl.font=[UIFont fontWithName:CGRegular size:textSizes];
    loginLbl.textAlignment=NSTextAlignmentCenter;
    loginLbl.textColor=[UIColor whiteColor];
    [scrlContent addSubview:loginLbl];
    
    NSMutableAttributedString *hintText = [[NSMutableAttributedString alloc] initWithString:@"Already have an account? Sign In here"];
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithName:CGBold size:textSizes];
    UIFontDescriptor *fontDescriptor1 = [UIFontDescriptor fontDescriptorWithName:CGRegular size:textSizes];
    UIFontDescriptor *symbolicFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitTightLeading];
    
    UIFontDescriptor *symbolicFontDescriptor1 = [fontDescriptor1 fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    
    UIFont *fontWithDescriptor = [UIFont fontWithDescriptor:symbolicFontDescriptor size:textSizes];
    UIFont *fontWithDescriptor1 = [UIFont fontWithDescriptor:symbolicFontDescriptor1 size:textSizes];
    
    //Red and large
    [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor, NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, 23)];
    
    //Rest of text -- just futura
    [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor1, NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(24, hintText.length - 23-5)];
    
    loginLbl.textColor=[UIColor whiteColor];
    [loginLbl setAttributedText:hintText];
    
    UIButton * btnSignUp = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSignUp.frame = CGRectMake(0, DEVICE_HEIGHT-50, DEVICE_WIDTH, 35);
    [btnSignUp addTarget:self action:@selector(btnLoginBack) forControlEvents:UIControlEventTouchUpInside];
    [scrlContent addSubview:btnSignUp];
    
    if (isFromEdit)
    {
        loginLbl.hidden = YES;
    }
    if (IS_IPHONE_X)
    {
        loginLbl.frame =CGRectMake(0, DEVICE_HEIGHT-50-55, DEVICE_WIDTH, 35);
        btnSignUp.frame = CGRectMake(0, DEVICE_HEIGHT-50-50, DEVICE_WIDTH, 35);
    }
}

-(void)fillForm
{
    userDetailDict = [[NSMutableDictionary alloc] init];
    userDetailDict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserDict"] mutableCopy];
    if ([userDetailDict valueForKey:@"name"] == nil || [[userDetailDict valueForKey:@"name"] length]==0)
    {
        
    }
    else
    {
        txtName.text = [userDetailDict valueForKey:@"name"];
    }
    if ([userDetailDict valueForKey:@"email"] == nil || [[userDetailDict valueForKey:@"email"] length]==0)
    {
        
    }
    else
    {
        txtEmail.text = [userDetailDict valueForKey:@"email"];
    }
    
    if ([userDetailDict valueForKey:@"mobile_no"] == nil || [[userDetailDict valueForKey:@"mobile_no"] length]==0)
    {
        
    }
    else
    {
        txtMobile.text = [userDetailDict valueForKey:@"mobile_no"];
    }
    txtEmail.userInteractionEnabled = NO;
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

#pragma mark - All button click events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
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
-(void)btnLoginBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)showPassclick
{
    if (isShowPassword)
    {
        isShowPassword = NO;
        [btnShowPass setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
        txtPass.secureTextEntry = YES;
    }
    else
    {
        isShowPassword = YES;
        [btnShowPass setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
        txtPass.secureTextEntry = NO;
    }
}
-(void)btnNextClicked
{
    BOOL isAllowed = NO;
    [self hideKeyboard];
    if([txtAccountName.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please enter your account name"];
    }
    else if([txtName.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please enter your name"];
    }
    else if([txtMobile.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please enter your mobile number"];
    }
    else if([txtMobile.text length]<10)
    {
        [self showMessagewithText:@"Mobile number should at least 10 digits"];
    }
    else if([txtMobile.text rangeOfString:@"+"].location != NSNotFound)
    {
        [self showMessagewithText:@"Please enter a valid number"];
    }
    else if([txtPass.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please enter your password"];
    }
    else if([txtPass.text length]<6)
    {
        [self showMessagewithText:@"Password should atleast have 6 characaters."];
    }
    else  if ([txtEmail.text length]>0)
    {
        if(![APP_DELEGATE validateEmail:txtEmail.text])
        {
            [self showMessagewithText:@"Please enter valid email address"];
        }
        else
        {
            isAllowed = YES;
        }
    }
    else
    {
        isAllowed = YES;
    }
    
    if (isAllowed)
    {
        if (isFromEdit)
        {
            if ([APP_DELEGATE isNetworkreachable])
            {
                [self updateProfileService];
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
        else
        {
            if (isAgreed == NO)
            {
                [self showMessagewithText:@"Please agree to Terms and Conditions."];
            }
            else
            {
                
                if ([APP_DELEGATE isNetworkreachable])
                {
                    [self CheckWhetherNumberRegistered];
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
-(void)CheckWhetherNumberRegistered
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Registering..."];

    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    NSString * strPlus = [NSString stringWithFormat:@"%@",txtMobile.text];
    [dict setValue:strPlus forKey:@"mobile_number"];
    
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"check_mobile_number";
    manager.delegate = self;
    NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/check_mobile_number";
    [manager urlCall:strServerUrl withParameters:dict];
    
    [APP_DELEGATE GenerateEncryptedKeyforLogin:txtMobile.text];
}
-(void)checkPhoneNumberWithGivenInput:(NSString *)strMoblie
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Registering..."];
    
    NSString * stringCode = [NSString stringWithFormat:@"%@%@",btnCntryCode.titleLabel.text,strMoblie];
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
         
         OtpVerifyVC *view1 = [[OtpVerifyVC alloc]init];
         view1.verificationID = verificationID;
         dictSignUpData = [[NSMutableDictionary alloc]initWithObjectsAndKeys:txtName.text,@"username",strMoblie,@"mobile_number",txtPass.text,@"password",txtEmail.text,@"email",txtAccountName.text,@"account_name",btnCntryCode.titleLabel.text,@"countryCode",nil];
         view1.dataDict = dictSignUpData;
         [self.navigationController pushViewController:view1 animated:true];
         
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
-(void)RegisterService
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Registering...."];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:txtEmail.text forKey:@"email"];
    [dict setValue:@"123456789" forKey:@"device_token"];
    [dict setValue:txtPass.text forKey:@"password"];
    [dict setValue:txtMobile.text forKey:@"mobile_number"];
    [dict setValue:txtName.text forKey:@"username"];
    [dict setValue:txtAccountName.text forKey:@"account_name"];

    [dict setValue:@"2" forKey:@"device_type"];

    NSString *deviceToken =deviceTokenStr;
    if (deviceToken == nil || deviceToken == NULL)
    {
        [dict setValue:@"sdffds" forKey:@"device_token"];
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
}

-(void)agreeClick
{
    if (isAgreed)
    {
        imgCheck.image = [UIImage imageNamed:@"checkEmpty.png"];
        isAgreed = NO;
    }
    else
    {
        imgCheck.image = [UIImage imageNamed:@"checked.png"];
        isAgreed = YES;
    }
}
-(void)updateProfileService
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Updating details...."];
    
    NSString * strUserId = [userDetailDict valueForKey:@"id"];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:txtName.text forKey:@"name"];
    [dict setValue:txtMobile.text forKey:@"mobile_no"];
    [dict setValue:strUserId forKey:@"user_id"];

    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"UpdateProfile";
    manager.delegate = self;
    NSString *strServerUrl = @"http://succorfish.in/mobile/user/profile/edit";
    [manager urlCall:[NSString stringWithFormat:@"%@",strServerUrl] withParameters:dict];
}
-(void)btnTermsAction
{
    webViewVC*view1 = [[webViewVC alloc]init];
    view1.btnIndex = 7;
    [self.navigationController pushViewController:view1 animated:true];
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
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:@"This email address already registered with us"
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
                    [tmpDict setObject:txtPass.text forKey:@"localPassword"];
                    [tmpDict setValue:@"1" forKey:@"is_active"];

                    [[NSUserDefaults standardUserDefaults] setValue:txtEmail.text forKey:@"CURRENT_USER_EMAIL"];
                    [[NSUserDefaults standardUserDefaults] setValue:txtName.text forKey:@"CURRENT_USER_NAME"];
                    [[NSUserDefaults standardUserDefaults] setValue:txtPass.text forKey:@"CURRENT_USER_PASS"];
                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"IS_LOGGEDIN"];
                    [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"user_id"] forKey:@"CURRENT_USER_ID"];
                    [[NSUserDefaults standardUserDefaults] setValue:txtAccountName.text forKey:@"CURRENT_ACCOUNT_NAME"];

                    [[NSUserDefaults standardUserDefaults] setObject:tmpDict forKey:@"UserDict"];
                    [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"IS_USER_SKIPPED"];
                    [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"IS_USER_LOGGED"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
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
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"This email address already registered with us"] || [[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"This mobile number already registered with us"])
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:@"This email address already registered with us"
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else
            {
                NSString * strMsg = [[result valueForKey:@"result"] valueForKey:@"message"];
                
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:strMsg
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
        
        }
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"UpdateProfile"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            [self updateAllfields];
            
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeSuccess];
            alert.tag = 223;
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"Profile has been updated successfully."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
        else
        {
            NSString * strMsg = [[result valueForKey:@"result"] valueForKey:@"message"];
            
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:strMsg
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"check_mobile_number"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Mobile no is registered with us."] || [[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"This mobile number already registered with us"])
            {
                [self checkPhoneNumberWithGivenInput:[NSString stringWithFormat:@"%@",txtMobile.text]];
            }
            else
            {
                [self checkPhoneNumberWithGivenInput:[NSString stringWithFormat:@"%@",txtMobile.text]];
            }
        }
        else
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Mobile no is registered with us."] || [[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"This mobile number is already registered with us"])
            {
                [self checkPhoneNumberWithGivenInput:[NSString stringWithFormat:@"%@",txtMobile.text]];

            }
            else
            {
                [self checkPhoneNumberWithGivenInput:[NSString stringWithFormat:@"%@",txtMobile.text]];
            }
        }
    }
}
- (void)onError:(NSError *)error
{
    [APP_DELEGATE endHudProcess];

//    NSLog(@"The error is...%@", error);
    
    [btnNext setEnabled:YES];
    
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



#pragma mark - Hide Keyboard
-(void)hideKeyboard
{
    [self.inputView resignFirstResponder];
}
#pragma mark - Textfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    if (textField == txtAccountName)
    {
        [txtName becomeFirstResponder];
    }
    else if (textField == txtName)
    {
        [txtMobile becomeFirstResponder];
    }
    else if (textField == txtMobile)
    {
        [txtPass becomeFirstResponder];
    }
    else if (textField == txtPass)
    {
        [txtEmail becomeFirstResponder];
    }
    else if (textField == txtEmail)
    {
        [txtEmail resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, textField.frame.size.height-2, textField.frame.size.width, 2)];
    [lblLine setBackgroundColor:[UIColor whiteColor]];
    [textField addSubview:lblLine];
    
    if (textField == txtMobile)
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
    [lblLine removeFromSuperview];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == txtMobile)
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
-(void)doneKeyBoarde
{
    if (IS_IPHONE_X)
    {
    }
    [txtMobile resignFirstResponder];
}

-(void)updateAllfields
{
    [userDetailDict setValue:txtName.text forKey:@"name"];
    [userDetailDict setValue:txtMobile.text forKey:@"mobile_no"];
    
    [[NSUserDefaults standardUserDefaults] setObject:userDetailDict forKey:@"UserDict"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
-(void)btnCntryClick
{
    [self.view endEditing:YES];
    [self ShowPicker:YES andView:backPickerView];
}
-(void)btnDoneClicked
{
    [self ShowPicker:NO andView:backPickerView];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
