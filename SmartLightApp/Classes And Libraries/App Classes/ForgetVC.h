//
//  ForgetVC.h
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 05/10/18.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgetVC : UIViewController<UITextFieldDelegate,UIScrollViewDelegate,URLManagerDelegate>
{
    UIScrollView * scrlContent;
    
    UIView * viewmobile, *viewOTP, *viewPopUp;
   // UIImageView * imgMobileBG, *imgOtpBG, *imgPopUpBG;
    
    
    UILabel *lblMessage ,*lblHint;
    UITextField * txtMobNumber, *txtOTP, *txtPass;
    UITextField * txtConfirmPass;
    UIButton *btnSaveMobile, *btnSave;
    UIButton * btnNext, * btnCntryCode;
    UIView * viewOverLay, * backPickerView;
    
    UILabel * lblLine;
    UIActivityIndicatorView * activityIndicator;
    NSString * codeStr, *strUserID;
    UIButton *btnShowPassNew, *btnShowPassConfirm;
    BOOL isShowPasswordNew, isShowPasswordConf;
    
    NSMutableDictionary *dictForgetPW;

}
@end
