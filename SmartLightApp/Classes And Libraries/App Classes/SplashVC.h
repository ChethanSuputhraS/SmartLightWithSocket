//
//  SplashVC.h
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 5/31/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InfoScreenVC.h"
#import "LoginVC.h"
#import "DashboardVC.h"
#import "InfoScreenVC.h"
#import <OpenEars/OEEventsObserver.h>
@interface SplashVC : UIViewController<OEEventsObserverDelegate>
{
    UILabel * lblLogoName;
    UIImageView * imgLogo;
}
@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;
@end
