//
//  ContactUsVC.m
//  SmartLightApp
//
//  Created by srivatsa s pobbathi on 01/01/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import "ContactUsVC.h"
#import "webViewVC.h"
@interface ContactUsVC ()

@end

@implementation ContactUsVC

- (void)viewDidLoad
{
    self.view.backgroundColor = UIColor.clearColor;
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];
    [self setContentViewFrames];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    self.view.backgroundColor = [UIColor colorWithRed:19/255.0 green:24/255.0 blue:27/255.0 alpha:1.0];
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.5;
    [viewHeader addSubview:lblBack];
    
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Contact Us"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+3]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * imgMenu = [[UIImageView alloc]initWithFrame:CGRectMake(10,20+7, 33, 30)];
    imgMenu.image = [UIImage imageNamed:@"menu.png"];
    imgMenu.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgMenu];
    
    UIButton * btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMenu setFrame:CGRectMake(0, 0, 80, 64)];
    [btnMenu addTarget:self action:@selector(btnMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnMenu];
    
    
    if (IS_IPHONE_X)
    {
        [btnMenu setFrame:CGRectMake(0, 0, 88, 88)];
        imgMenu.frame = CGRectMake(10,44+7, 33, 30);
        lblTitle.frame = CGRectMake(50, 44, DEVICE_WIDTH-100, 44);
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
    }
}
#pragma mark - set UI Frames
-(void) setContentViewFrames
{
    tblContent =[[UITableView alloc]initWithFrame:CGRectMake(0, 84, self.view.frame.size.width,400) style:UITableViewStylePlain];
    [tblContent setBackgroundColor:[UIColor clearColor]];
    tblContent.showsVerticalScrollIndicator = NO;
    tblContent.showsHorizontalScrollIndicator = NO;
    [tblContent setDelegate:self];
    [tblContent setDataSource:self];
    tblContent.scrollEnabled = false;
    [tblContent setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tblContent];
    
    
    UILabel * lblFollow = [[UILabel alloc]init];
    lblFollow.frame = CGRectMake(10, tblContent.frame.origin.y+tblContent.frame.size.height+10, DEVICE_WIDTH/2, 30);
    lblFollow.backgroundColor = UIColor.clearColor;
    lblFollow.text = @"Follow Us On";
    lblFollow.textColor = UIColor.whiteColor;
    lblFollow.font = [UIFont fontWithName:CGRegular size:textSizes+2];
    lblFollow.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:lblFollow];
    
    NSArray * imgArr = [NSArray arrayWithObjects:@"facebook-box",@"instagram",@"linkedin-box",@"youtube", nil];
    
    NSMutableArray * colorArr = [[NSMutableArray alloc]init];
    [colorArr addObject:[UIColor colorWithRed:50.0/255.0 green:78.0/255.0 blue:170.0/255.0 alpha:1]];
    [colorArr addObject:[UIColor colorWithRed:195.0/255.0 green:42.0/255.0 blue:163.0/255.0 alpha:1]];
    [colorArr addObject:[UIColor colorWithRed:2.0/255.0 green:112.0/255.0 blue:173.0/255.0 alpha:1]];
    [colorArr addObject:[UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1]];


    for (int i=0; i<colorArr.count; i++)
    {
        btnFollow = [[UIButton alloc] initWithFrame:CGRectMake(10+i*(DEVICE_WIDTH/6.5),lblFollow.frame.origin.y+lblFollow.frame.size.height+5,DEVICE_WIDTH/7, DEVICE_WIDTH/7)];
        [btnFollow setTag:i];
        btnFollow.layer.masksToBounds = true;
        btnFollow.layer.cornerRadius = (DEVICE_WIDTH/7)/2;
        NSString * imgName = [NSString stringWithFormat:@"%@.png",[imgArr objectAtIndex:i]];
        [btnFollow setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        btnFollow.backgroundColor = [colorArr objectAtIndex:i];
        [btnFollow addTarget:self action:@selector(btnFollowAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnFollow];
    }
}
#pragma mark- UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return 140;
    }
    else if (indexPath.row == 1)
    {
        return 65;
    }
    else if (indexPath.row == 2)
    {
        return 65;
    }
    else if (indexPath.row == 3)
    {
        return 65;
    }
    else if (indexPath.row == 4)
    {
        return 65;
    }
    else if (indexPath.row == 5)
    {
        return 65;
    }
    return true;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellID = nil;
    contactTblViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
    {
        cell = [[contactTblViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    NSArray * imgArr = [[NSArray alloc]initWithObjects:@"map-marker.png",@"email-plus.png",@"web.png",@"call.png",@"techsupport.png", nil];
    cell.imgLogo.image =  [UIImage imageNamed:[NSString stringWithFormat:@"%@",[imgArr objectAtIndex:indexPath.row]]];
    
    NSArray * nameArr = [[NSArray alloc]initWithObjects:@"Address",@"Email",@"Website",@"Sales",@"Tech Support", nil];
    cell.lblName.text = [NSString stringWithFormat:@"%@",[nameArr objectAtIndex:indexPath.row]];
    
    if (indexPath.row == 0)
    {
        cell.lblContent.frame = CGRectMake(60, 25, DEVICE_WIDTH-60, 100);
        cell.lblLine.frame = CGRectMake(60, cell.lblContent.frame.origin.y+100+5, cell.lblContent.frame.size.width-5, 0.5);
        cell.lblContent.text = @"Vithamas Technologies,\n136/D, Chandana Chethana Complex, Abhishek Road, Vani Vilas Layout, Vijaynagar 2nd Stage, Mysuru-570016, Karnataka, India";
        cell.lblContent.numberOfLines = 5;
        cell.imgCellBG.frame = CGRectMake(0, 0, DEVICE_WIDTH, 140) ;
    }
    else if (indexPath.row == 1)
    {
        cell.lblContent.frame = CGRectMake(60, 25, DEVICE_WIDTH-60, 30);
        cell.lblLine.frame = CGRectMake(60, cell.lblContent.frame.origin.y+30+5, cell.lblContent.frame.size.width-5, 0.5);
        cell.lblContent.text = @"admin@vithamastech.com";
        cell.lblContent.numberOfLines = 1;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imgCellBG.frame = CGRectMake(0, 0, DEVICE_WIDTH, 65) ;

    }
    else if (indexPath.row == 2)
    {
        cell.lblContent.frame = CGRectMake(60, 25, DEVICE_WIDTH-60, 30);
        cell.lblLine.frame = CGRectMake(60, cell.lblContent.frame.origin.y+30+5, cell.lblContent.frame.size.width-5, 0.5);
        cell.lblContent.text = @"http://vithamastech.com";
        cell.lblContent.numberOfLines = 1;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imgCellBG.frame = CGRectMake(0, 0, DEVICE_WIDTH, 65) ;
    }
    else if (indexPath.row == 3)
    {
        cell.lblContent.frame = CGRectMake(60, 25, DEVICE_WIDTH-60, 30);
        cell.lblLine.frame = CGRectMake(60, cell.lblContent.frame.origin.y+30+5, cell.lblContent.frame.size.width-5, 0.5);
        cell.lblContent.text = @"+91 9916602770  (Mon-Fri 11AM - 4PM)";
        cell.lblContent.numberOfLines = 1;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imgCellBG.frame = CGRectMake(0, 0, DEVICE_WIDTH, 65);
        
    }
    else if (indexPath.row == 4)
    {
        cell.lblContent.frame = CGRectMake(60, 25, DEVICE_WIDTH-60, 30);
        cell.lblLine.frame = CGRectMake(60, cell.lblContent.frame.origin.y+30+5, cell.lblContent.frame.size.width-5, 0.5);
        cell.lblContent.text = @"+91 8088523856  (Mon-Fri 11AM - 4PM)";
        cell.lblContent.numberOfLines = 1;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imgCellBG.frame = CGRectMake(0, 0, DEVICE_WIDTH, 65);
    }

    return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        
    }
    else if (indexPath.row == 1)
    {
        [self showMailWithOption:@"Email"];
    }
    else if (indexPath.row == 2)
    {
        webViewVC*view1 = [[webViewVC alloc]init];
        view1.btnIndex = 4;
        [self.navigationController pushViewController:view1 animated:true];
    }
    else if (indexPath.row == 3)
    {

        FCAlertView *  alert2 = [[FCAlertView alloc] init];
        alert2.colorScheme = [UIColor blackColor];
        [alert2 makeAlertTypeCaution];
        [alert2 addButton:@"Call" withActionBlock:
         ^{
            
            NSString *phoneNumber = [@"tel:" stringByAppendingString:@"+91 8088523856"];
            
//            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",phoneNumber]]])
//            {
    //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",phoneNumber]]];
                [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",phoneNumber]]];
//             }
//             else
//             {
//                 NSLog(@"Unable to open");
//             }
         }];
        
        alert2.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
        [alert2 showAlertInView:self
                      withTitle:@"Vithamas"
                   withSubtitle:@"Contact through?"
                withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
            withDoneButtonTitle:@"Cancel" andButtons:nil];
    }
    else if (indexPath.row == 4)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",@"+91 8088523856"]]];
//        [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",@"+91 8088523856"]]];
    }
}
#pragma mark For Sending Mail
-(void)showMailWithOption:(NSString*)mailType
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        [picker setMailComposeDelegate:self];
        
        NSArray * arrReceipients;
        NSString *emailBody  = @"";
        if ([mailType isEqualToString:@"Email"])
        {
            arrReceipients = [NSArray arrayWithObjects:@"admin@vithamastech.com", nil];
            
            [picker setSubject:@"What we can do better"];
        }
        
        [picker setMessageBody:emailBody isHTML:NO];
        [picker setToRecipients:arrReceipients];
        
        [self resignFirstResponder];
        [self.navigationController presentViewController:picker animated:true completion:nil];
    }
    else
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Your mail account is not configured. Please configure your mail account." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:@"Arial" size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                
            }];
        }];
        [alertView showWithAnimation:Alert_Animation_Type];
    }
}
-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *alertTitle;
    NSString *alertMsg;
    
    switch (result) {
            
        case MFMailComposeResultCancelled:
            alertTitle = @"Cancelled";
            alertMsg = @"Mail composition got cancelled";
            break;
        case MFMailComposeResultSaved:
            alertTitle = @"Success - Saved";
            alertMsg = @"Mail got saved successfully!";
            break;
        case MFMailComposeResultSent:
            alertTitle = @"Success - Sent";
            
            alertMsg = @"Mail sent successfully!";
            break;
        case MFMailComposeResultFailed:
            alertTitle = @"Failure";
            alertMsg = @"Sending the mail failed";
            break;
        default:
            alertTitle = @"Failure";
            alertMsg = @"Mail could not be sent";
            break;
    }
    
    if([APP_DELEGATE isNetworkreachable] == NO)
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:alertMsg cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
        [alertView setMessageFont:[UIFont fontWithName:@"Arial" size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                
            }];
        }];
        [alertView showWithAnimation:Alert_Animation_Type];
    }
    else
    {
        if (result == MFMailComposeResultSent)
        {
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:alertMsg cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            
            [alertView setMessageFont:[UIFont fontWithName:@"Arial" size:14]];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                }];
            }];
            [alertView showWithAnimation:Alert_Animation_Type];
        }
        else
        {
            /* URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"You are not in WIFI range at present. When you come in WIFI range, the email will be sent automatically" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
             
             [alertView setMessageFont:[UIFont fontWithName:@"Arial" size:14]];
             [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
             NSLog(@"button tapped: index=%ld", (long)buttonIndex);
             [alertView hideWithCompletionBlock:^{
             NSLog(@"buttonIndex====>%ld",(long)buttonIndex);
             
             }];
             }];
             [alertView showWithAnimation:Alert_Animation_Type];*/
        }
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    //    if (result == MFMailComposeResultSent) {
    //        [self.navigationController popToRootViewControllerAnimated:YES];
    //    }
}
#pragma mark - All button click events
-(void)btnMenuClicked:(id)sender
{
    [self.menuContainerViewController setMenuSlideAnimationFactor:0.5f];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
}
-(void)btnFollowAction:(UIButton*)sender
{
    webViewVC * view1 = [[webViewVC alloc]init];
    view1.btnIndex = sender.tag;
    [self.navigationController pushViewController:view1 animated:true];
    /*
    if (sender.tag == 0)
    {
        UIWebView * webFB = [[UIWebView alloc]init];
        webFB = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
        webFB.delegate = self;
        NSURL *url;
        NSURLRequest *request;
        url = [[NSURL alloc]initWithString:@"https://www.facebook.com/Vithamas-Technologies-Pvt-Ltd-299264790734131/"];
        request = [[NSURLRequest alloc]initWithURL:url];
        [webFB loadRequest:request];
        [webFB reload];
        [self.view addSubview:webFB];
    }

    else if (sender.tag == 1)
    {
        UIWebView * webFB = [[UIWebView alloc]init];
        webFB = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
        webFB.delegate = self;
        NSURL *url;
        NSURLRequest *request;
        url = [[NSURL alloc]initWithString:@"https://www.instagram.com/p/Bt45ZGtguef/?utm_source=ig_share_sheet&igshid=djiwxqxkoev0"];
        request = [[NSURLRequest alloc]initWithURL:url];
        [webFB loadRequest:request];
        [webFB reload];
        [self.view addSubview:webFB];
    }
    else if (sender.tag == 2)
    {
        UIWebView * webFB = [[UIWebView alloc]init];
        webFB = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
        webFB.delegate = self;
        NSURL *url;
        NSURLRequest *request;
        url = [[NSURL alloc]initWithString:@"https://www.linkedin.com/company/vithamas-technologies-pvt-ltd/"];
        request = [[NSURLRequest alloc]initWithURL:url];
        [webFB loadRequest:request];
        [webFB reload];
        [self.view addSubview:webFB];
    }
    else if (sender.tag == 3)
    {
        UIWebView * webFB = [[UIWebView alloc]init];
        webFB = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
        webFB.delegate = self;
        NSURL *url;
        NSURLRequest *request;
        url = [[NSURL alloc]initWithString:@"https://www.youtube.com/channel/UCcz1WgCDknJZE_chnqR5D5g"];
        request = [[NSURLRequest alloc]initWithURL:url];
        [webFB loadRequest:request];
        [webFB reload];
        [self.view addSubview:webFB];
    }
    
*/

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Sales Number - 919916602770 (Monday-Friday 11AM - 4PM)
//Technical Support: +918088523856 (Monday-Friday 11AM - 4PM)
@end

