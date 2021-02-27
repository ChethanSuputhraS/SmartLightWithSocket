//
//  ContactUsVC.h
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 01/01/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "contactTblViewCell.h"
#import <MessageUI/MessageUI.h>

@interface ContactUsVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate,MFMailComposeViewControllerDelegate>
{
    UITableView *tblContent;
    UIButton *btnFollow;
}
@end
