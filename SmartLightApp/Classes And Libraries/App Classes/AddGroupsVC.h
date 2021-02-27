//
//  AddGroupsVC.h
//  SmartLightApp
//
//  Created by stuart watts on 09/06/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddGroupsVC : UIViewController<UITextFieldDelegate>
{
    UITextField * txtGroupName;
}
@property BOOL isForGroup;
@property BOOL isfromEdit;
@property (nonatomic,strong) NSMutableDictionary * detailDict;

@end
