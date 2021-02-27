//
//  LoginVC.h
//  SmartLightApp
//
//  Created by stuart watts on 04/04/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLManager.h"
@import Firebase;
@interface LoginVC : UIViewController<UITextFieldDelegate,URLManagerDelegate>
{
    UIScrollView * scrlContent;
    UIView * viewPopUp;
    
    UITextField * txtMobile;
    UITextField * txtPassword;
    UITextField *txtForgotpasswordEmail;
    UILabel *lblerror;
    
    UIButton *btncancel;
    UIButton *btnOk;
    
    UIButton * btnLogin,* btnDone ,* btnCntryCode;
    UIButton * btnRegister;
    UIButton * btnForgotPassword;
    
    UIActivityIndicatorView * activityIndicator;
    UIActivityIndicatorView * ForgotpasswordIndicator;
    
    UILabel * lblLine;
    
    
    UIView * viewMore;
    UIView * viewOverLay,* backPickerView;
    UIView * backView;
    
    UIButton * btnShowPass;
    
    BOOL isShowPassword;
    
    UIButton * btnRemember;
    UIImageView * imgCheck;
}
@property (nonatomic, strong) FIRAuth * handle;
@property BOOL isFromMangeAccount;

@end
