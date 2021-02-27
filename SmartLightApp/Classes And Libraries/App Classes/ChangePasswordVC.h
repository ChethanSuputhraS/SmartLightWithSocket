//
//  ChangePasswordVC.h
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 05/10/18.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordVC : UIViewController<UITextFieldDelegate,URLManagerDelegate,FCAlertViewDelegate>
{
    UIView * viewPopUp;
    //UIImageView * imgPopUpBG;
    
    
    UILabel *lbl;
    UITextField * txtOldPass;
    UITextField * txtNewPass;
    UITextField * txtConfirmPass;
    UIButton *btnSave;
    
    UIButton * btnShowPassOld;
    UIButton * btnShowPassNew;
    UIButton * btnShowPassConfirm;

    BOOL isShowPasswordOld,isShowPasswordNew, isShowPasswordConf;
    
    UILabel *lblLine;
    UIActivityIndicatorView * activityIndicator;
    
}
@end
