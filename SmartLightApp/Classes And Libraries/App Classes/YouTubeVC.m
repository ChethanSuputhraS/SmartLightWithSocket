//
//  YouTubeVC.m
//  SmartLightApp
//
//  Created by Ashwin on 9/29/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "YouTubeVC.h"
#import "HelpLeftMenuCell.h"



@interface YouTubeVC ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate,URLManagerDelegate>
{
    UITableView *tblYoutubeContent;
    UIWebView * webView ;
    BOOL isWebView ;
    
    NSMutableArray * arrYoutubelink;
}
@end

@implementation YouTubeVC

- (void)viewDidLoad
{
    self.view.backgroundColor = global_brown_color;
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];
    [self setContentViewFrames];
    
    
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE startHudProcess:@"Loading..."];
        [self GetYoutubeLinksFromAPI];
    }
    else
    {
        [self AlertViewFCTypeCautionCheck:@"Please check internet connection."];
    }
    
    arrYoutubelink = [[NSMutableArray alloc] init];

    NSString * strQuery = [NSString stringWithFormat:@"Select * from youtubeLink_Table"];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:arrYoutubelink];

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
    [lblTitle setText:@"Vithamas"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
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
-(void)setContentViewFrames
{
    tblYoutubeContent = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT-64-44)];
    tblYoutubeContent.backgroundColor = UIColor.clearColor;
    tblYoutubeContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblYoutubeContent.delegate = self;
    tblYoutubeContent.dataSource = self;
    tblYoutubeContent.scrollEnabled = false;
    [self.view addSubview:tblYoutubeContent];
    
    if (IS_IPHONE_X)
    {
        tblYoutubeContent.frame = CGRectMake(0, 88, DEVICE_WIDTH, DEVICE_HEIGHT-88-44);
    }
}
#pragma mark - TableView Delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrYoutubelink.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    HelpLeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[HelpLeftMenuCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    
    cell.lblName.hidden = true;
    cell.lblAppVersion.hidden = true;
    cell.lblYoutube.hidden = false;
    
    cell.imgLogo.image =  [UIImage imageNamed:@"youtube.png"];
    
    if (arrYoutubelink.count > 0)
    {
        cell.lblYoutube.text = [[arrYoutubelink objectAtIndex:indexPath.row] valueForKey:@"title"];
    }


    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    webView.hidden = false;

    if (arrYoutubelink.count > 0)
    {
        NSString * strYoutbeVideo = [NSString stringWithFormat:@"%@%@",[[arrYoutubelink objectAtIndex:indexPath.row] valueForKey:@"youtube_url"],[[arrYoutubelink objectAtIndex:indexPath.row] valueForKey:@"video_id"]];
        
        [self WebViewForYoutube:strYoutbeVideo];
    }

}
-(void)btnBackClick
{
    if (isWebView == true)
    {
        isWebView = false;
        [webView removeFromSuperview];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:true];
    }
}
-(void)btnMenuClicked:(id)sender
{
    [self.menuContainerViewController setMenuSlideAnimationFactor:0.5f];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
}

-(void)WebViewForYoutube:(NSString *)strURL
{
    isWebView = true;
    int yy = 64;
    int zz = 0;
    if (IS_IPHONE_X)
    {
        yy = 88;
        zz = 40;
    }
    
    webView = [[UIWebView alloc]init];
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, yy, self.view.frame.size.width, self.view.frame.size.height-yy-zz)];
    webView.delegate = self;
    NSURL *url;
    NSURLRequest *request;
    url = [[NSURL alloc]initWithString: strURL];
    request = [[NSURLRequest alloc]initWithURL:url];
    [webView loadRequest:request];
    [webView reload];
    [self.view addSubview:webView];
}
-(void)GetYoutubeLinksFromAPI
{
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"youtubeLinks";
    manager.delegate = self;
    NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/video";
    [manager urlCall:strServerUrl withParameters:nil];
    
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
//    NSLog(@"=======Result=======%@",result);
    [APP_DELEGATE endHudProcess];
    
   if ([[result valueForKey:@"commandName"] isEqualToString:@"youtubeLinks"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"false"])
        {
        }
        else
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
            {
                arrYoutubelink = [[result valueForKey:@"result"] valueForKey:@"data"];
//                NSLog(@"YoutubeLinks====>>>>%@",arrYoutubelink);
                [self InsertToDatabase:arrYoutubelink];

                [tblYoutubeContent reloadData];
            }
        }
    }
}
- (void)onError:(NSError *)error
{
    NSLog(@"Error===>>>>%@",error);
    [APP_DELEGATE endHudProcess];
}
#pragma mark-  error popup
-(void)AlertViewFCTypeCautionCheck:(NSString *)strMsg
{
    [APP_DELEGATE endHudProcess];
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"Vithamas"
                  withSubtitle:strMsg
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
}
-(void)InsertToDatabase:(NSMutableArray *)arrData
{
    NSString * strQuery = @"NA";
    
    NSMutableArray *  youtubeListArray = [[NSMutableArray alloc] init];
    strQuery = [NSString stringWithFormat:@"Select * from youtubeLink_Table"];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:youtubeListArray];

    if (youtubeListArray.count > 0)
    {
        strQuery = [NSString stringWithFormat:@"delete from youtubeLink_Table "];
        [[DataBaseManager dataBaseManager] execute:strQuery];
    }
    
    for (int i = 0; i < [arrData count]; i++)
    {
        NSString * strTitle = [[arrData objectAtIndex:i] valueForKey:@"title"];
        NSString * strVideoID = [[arrData objectAtIndex:i] valueForKey:@"video_id"];
        NSString * strCreatedDate = [[arrData objectAtIndex:i] valueForKey:@"created_date"];

        strQuery =[NSString stringWithFormat:@"insert into 'youtubeLink_Table'('title','video_id','created_date') values('%@','%@','%@')",strTitle,strVideoID,strCreatedDate];
        [[DataBaseManager dataBaseManager] executeSw:strQuery];
    }
}
@end
