//
//  OtpVerifyVC.h
//  SmartLightApp
//
//  Created by stuart watts on 03/10/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtpVerifyVC : UIViewController<UITextFieldDelegate>
{
    UIScrollView * scrlContent;
    UIView * viewPopUp;
    
    UITextField * txtEmail;
    UILabel * lblHint;
    NSString * codeStr;
}
@property(nonatomic,strong)NSMutableDictionary * dataDict;
@property(nonatomic,strong)NSString  * verificationID;


@end
