//
//  WebLinkVC.h
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 6/3/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebLinkVC : UIViewController<UIWebViewDelegate>
{
    UIImageView * imgNetworkStatus;
    
    UIWebView * contentWebView;
    
    UIActivityIndicatorView * activityIndicator;
}

@property(nonatomic,strong)NSString * strWebLink;
@property(nonatomic,strong)NSString * strTitle;

@end
