//
//  AuthenticationVC.m
//  SmartLightApp
//
//  Created by stuart watts on 22/11/2017.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import "AuthenticationVC.h"

@interface AuthenticationVC ()<UITextFieldDelegate>
{
    UITextField * txtPassword, *txtEmail;
}
@end

@implementation AuthenticationVC

- (void)viewDidLoad
{
    self.view.backgroundColor = [APP_DELEGATE colorWithHexString:App_Background_color];

    [super viewDidLoad];
    
    [self setNavigationViewFrames];
    [self setMessageViewContent];

    // Do any additional setup after loading the view.
}

#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[APP_DELEGATE colorWithHexString:App_Header_Color]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Add device"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]];
    [lblTitle setTextColor:[APP_DELEGATE colorWithHexString:header_font_color]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 14.5, 15, 20)];
    [backImg setImage:[UIImage imageNamed:@""]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 70, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];
    
    UILabel * lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 63.5, DEVICE_WIDTH, 0.5)];
    [lblLine setBackgroundColor:[UIColor lightGrayColor]];
    [viewHeader addSubview:lblLine];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 88, 88);
    }
}
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)setMessageViewContent
{
    UILabel * lblSuccessMsg = [[UILabel alloc] initWithFrame:CGRectMake(10, 74, DEVICE_WIDTH, 100)];
    [lblSuccessMsg setTextColor:[APP_DELEGATE colorWithHexString:dark_gray_color]];
    [lblSuccessMsg setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
//    [lblSuccessMsg setTextAlignment:NSTextAlignmentCenter];
    [lblSuccessMsg setNumberOfLines:3];
    [lblSuccessMsg setText:@"• Enter password to authenticate your device."];
    [self.view addSubview:lblSuccessMsg];
    
    txtPassword=[[UITextField alloc]initWithFrame:CGRectMake(10, 140, DEVICE_WIDTH-20, 40)];
    txtPassword.backgroundColor = [UIColor clearColor];
    txtPassword.delegate=self;
    txtPassword.placeholder=@"Password";
    [APP_DELEGATE getPlaceholderText:txtPassword andColor:[UIColor lightGrayColor]];

    txtPassword.textColor=[UIColor blackColor];
    txtPassword.keyboardType=UIKeyboardTypeDefault;
    txtPassword.secureTextEntry = YES;
    txtPassword.keyboardAppearance = UIKeyboardAppearanceAlert;
    [self.view addSubview:txtPassword];
    
    UILabel * lblPasswordLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtPassword.frame.size.height-1, txtPassword.frame.size.width, 1)];
    [lblPasswordLine setBackgroundColor:[APP_DELEGATE colorWithHexString:blue_color]];
    [txtPassword addSubview:lblPasswordLine];
    
    int yy = 180 + 40;
    
    UILabel * lblRecovery = [[UILabel alloc] initWithFrame:CGRectMake(10, yy, DEVICE_WIDTH, 30)];
    [lblRecovery setTextColor:[APP_DELEGATE colorWithHexString:dark_gray_color]];
    [lblRecovery setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
//    [lblRecovery setTextAlignment:NSTextAlignmentCenter];
    [lblRecovery setNumberOfLines:3];
    [lblRecovery setText:@"• Choose option to recover your password"];
    [self.view addSubview:lblRecovery];

    yy = yy + 40;

    UIView * bottomView = [[UIView alloc] init];
    bottomView.frame = CGRectMake(0, yy, DEVICE_WIDTH, 50);
    [self.view addSubview:bottomView];
    
    UIButton * btnEmail = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnEmail.backgroundColor = [APP_DELEGATE colorWithHexString:blue_color];
    btnEmail.frame = CGRectMake(20, 10, 30, 30);
    btnEmail.layer.cornerRadius = 15;
    btnEmail.layer.masksToBounds = YES;
    [bottomView addSubview:btnEmail];
    
    UILabel * lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(60, 0,50, 50)];
    [lblEmail setTextColor:[APP_DELEGATE colorWithHexString:dark_gray_color]];
    [lblEmail setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightRegular]];
    [lblEmail setTextAlignment:NSTextAlignmentCenter];
    [lblEmail setNumberOfLines:3];
    [lblEmail setText:@"Email"];
    [bottomView addSubview:lblEmail];
    
    UIButton * btnQues = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnQues.backgroundColor = [UIColor whiteColor];
    btnQues.frame = CGRectMake(160, 10, 30, 30);
    btnQues.layer.cornerRadius = 15;
    btnQues.layer.masksToBounds = YES;
    [bottomView addSubview:btnQues];
    
    UILabel * lblQues = [[UILabel alloc] initWithFrame:CGRectMake(180, 0,180, 50)];
    [lblQues setTextColor:[APP_DELEGATE colorWithHexString:dark_gray_color]];
    [lblQues setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightRegular]];
    [lblQues setTextAlignment:NSTextAlignmentCenter];
    [lblQues setNumberOfLines:3];
    [lblQues setText:@"Secret Question"];
    [bottomView addSubview:lblQues];
    
    
    yy = yy + 60;

    txtEmail=[[UITextField alloc]initWithFrame:CGRectMake(10, yy, DEVICE_WIDTH-20, 40)];
    txtEmail.backgroundColor = [UIColor clearColor];
    txtEmail.delegate=self;
    txtEmail.placeholder=@"Enter Email";
    [APP_DELEGATE getPlaceholderText:txtEmail andColor:[UIColor lightGrayColor]];

    txtEmail.textColor=[UIColor blackColor];
    txtEmail.autocorrectionType = UITextAutocorrectionTypeNo;
    txtEmail.keyboardType=UIKeyboardTypeEmailAddress;
    txtEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtEmail.keyboardAppearance = UIKeyboardAppearanceAlert;
    [self.view addSubview:txtEmail];
    
    UILabel * lblEmailLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtEmail.frame.size.height-1, txtEmail.frame.size.width, 1)];
    [lblEmailLine setBackgroundColor:[APP_DELEGATE colorWithHexString:blue_color]];
    [txtEmail addSubview:lblEmailLine];
    
    
//    UIButton * btnQues = [UIButton buttonWithType:(UIButtonTypeCustom)];
//    btnQues.backgroundColor = [UIColor redColor];
//    btnQues.frame = CGRectMake(160, 5, 40, 40);
//    btnQues.layer.cornerRadius = 20;
//    btnQues.layer.masksToBounds = YES;
//    [bottomView addSubview:btnQues];
//    
//    btnLogin = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2-278/2, yy, 278, 44)];
//    [btnLogin setBackgroundColor:[UIColor clearColor]];
//    [btnLogin setBackgroundImage:[APP_DELEGATE imageFromColor:[UIColor blueColor]] forState:UIControlStateNormal];
//    [btnLogin setTitle:@"Login" forState:UIControlStateNormal];
//    [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    btnLogin.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
//    [btnLogin addTarget:self action:@selector(btnLoginClicked:) forControlEvents:UIControlEventTouchUpInside];
//    btnLogin.layer.cornerRadius = 3.0;
//    btnLogin.clipsToBounds = YES;
//    [scrlContent addSubview:btnLogin];
    
//    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(btnLogin.frame.size.width-40, 7, 30, 30)];
//    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
//    [btnLogin addSubview:activityIndicator];
    
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
