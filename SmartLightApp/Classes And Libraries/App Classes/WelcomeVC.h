//
//  WelcomeVC.h
//  SmartLightApp
//
//  Created by stuart watts on 29/08/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeVC : UIViewController<UIScrollViewDelegate>
{
    UIScrollView * scrlContent;
    UIPageControl * pageControl;

}
@property BOOL isFromManul;

@end
