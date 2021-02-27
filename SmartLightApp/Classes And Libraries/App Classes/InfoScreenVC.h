//
//  InfoScreenVC.h
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 5/31/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoScreenVC : UIViewController<UIScrollViewDelegate>
{
    UIScrollView * scrlContent;
    UIPageControl * pageControl;
    
    UIButton * BtnNext;
}

@end
