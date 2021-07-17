//
//  SplashVC.m
//  Indoor Access Control
//
//  Created by Kalpesh Panchasara on 5/31/17.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import "SplashVC.h"
#import <UIView+DCAnimationKit.h>
#import "WelcomeVC.h"

@interface SplashVC ()
{
    NSInteger hieghtIcon;
}
@end

@implementation SplashVC

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    UIImageView * imgBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH,DEVICE_HEIGHT)];
    [self.view addSubview:imgBG];
    
    hieghtIcon = DEVICE_WIDTH-40;
    imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-hieghtIcon)/2, (DEVICE_HEIGHT-hieghtIcon)/2, hieghtIcon,hieghtIcon)];
    [imgLogo setAlpha:1.20];
    [imgLogo setImage:[UIImage imageNamed:@"iTunesArtwork"]];
    [self.view addSubview:imgLogo];
    
    lblLogoName = [[UILabel alloc] initWithFrame:CGRectMake(10, imgLogo.frame.size.height+imgLogo.frame.origin.y + 70, DEVICE_WIDTH-20, 40)];
    [lblLogoName setText:@"Vithamas Technologies"];
    [lblLogoName setFont:[UIFont fontWithName:CGBold size:textSizes+5]];
    [lblLogoName setTextColor:[UIColor whiteColor]];
    [lblLogoName setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:lblLogoName];
    [lblLogoName setAlpha:0.0];
    
    
    [imgLogo bounceIntoView:self.view direction:DCAnimationDirectionTop];
    
    [self performSelector:@selector(gotoNextView) withObject:nil afterDelay:2.5];
     [self performSelector:@selector(logoImageAnimation) withObject:nil afterDelay:1];

}

#pragma mark - logoImageAnimation
-(void)logoImageAnimation
{
//    imgLogo.hidden=NO;
    [lblLogoName setAlpha:1.0];

    [lblLogoName bounceIntoViewAnother:self.view direction:DCAnimationDirectionLeft];

//    [UIView transitionWithView:imgLogo duration:0.3
//                       options:UIViewAnimationOptionAllowAnimatedContent
//                    animations:^{
//                        [imgLogo setAlpha:1.0];
//                    }
//                    completion:^(BOOL finished)
//     {
//         [self performSelector:@selector(logoNameAnimation) withObject:nil afterDelay:.5];
//     }];
}

-(void)logoNameAnimation
{
    [UIView transitionWithView:lblLogoName duration:0.3
                       options:UIViewAnimationOptionAllowAnimatedContent
                    animations:^{
                        [lblLogoName setAlpha:1.0];
                    }
                    completion:^(BOOL finished)
     {
         [self performSelector:@selector(gotoNextView) withObject:nil afterDelay:.5];
     }];
}

#pragma mark - gotoNextView
-(void)gotoNextView
{
    if ([IS_USER_CAME_FIRST_TIME isEqualToString:@"YES"])
    {
        if ([IS_USER_SKIPPED isEqualToString:@"YES"])
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1.3];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
            [UIView commitAnimations];
            [APP_DELEGATE goToDashboard];
            [APP_DELEGATE addScannerView];
        }
        else
        {
            if([IS_USER_LOGGED isEqualToString:@"YES"])
            {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:1.3];
                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
                [UIView commitAnimations];
                [APP_DELEGATE goToDashboard];
                [APP_DELEGATE addScannerView];
            }
            else if ([IS_USER_SKIPPED isEqualToString:@"NO"] || [IS_USER_LOGGED isEqualToString:@"NO"])
            {
//                [APP_DELEGATE movetoLogin];
                [APP_DELEGATE movetoUserInstructionVC];

                [APP_DELEGATE addScannerView];
            }
            else
            {
//                [APP_DELEGATE movetoLogin];
                [APP_DELEGATE movetoUserInstructionVC]; 
                [APP_DELEGATE addScannerView];
            }
        }
    }
    else
    {
        WelcomeVC * welComes =[[WelcomeVC alloc] init];
        [self.navigationController pushViewController:welComes animated:YES];
    }
    
}


#pragma mark - CleanUp
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
