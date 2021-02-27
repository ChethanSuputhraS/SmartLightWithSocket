//
//  SignupVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 20/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLManager.h"

@interface SignupVC : UIViewController<UITextFieldDelegate,URLManagerDelegate>
{
    UIScrollView * scrlContent;
    UIView * viewPopUp;
    
    UITextField * txtEmail;
    UITextField * txtName;
    UITextField * txtMobile;
    UITextField * txtPass;
    UITextField * txtConfPass;
    UITextField * txtAccountName;

    UIButton * btnNext, * btnCntryCode;

    UILabel *lblerror;
    UILabel * lblLine;
    
    UIButton * btnShowPass;
    BOOL isShowPassword;

    
    UIView * viewOverLay, * backPickerView;
    NSMutableDictionary *dictSignUpData;
}
@property BOOL isFromEdit;
@end
