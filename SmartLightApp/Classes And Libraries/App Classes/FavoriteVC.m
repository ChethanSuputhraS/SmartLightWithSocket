//
//  FavoriteVC.m
//  SmartLightApp
//
//  Created by stuart watts on 05/04/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "FavoriteVC.h"
#import "AddGroupsVC.h"
#import "CustomGroupCell.h"

@interface FavoriteVC ()<FCAlertViewDelegate>
{
    NSMutableArray * syncedDeletedListArr, * tmpGroupArr;
    NSInteger groupSentCount, groupSyncCount,renameIndex;
    NSString * strUpdatedName;
}
@end

@implementation FavoriteVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    selectedDict = [[NSMutableDictionary alloc] init];
    
    [self setNavigationViewFrames];
    [self setMainViewContent];
    [self getDatafromDatabase];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
  
    
    [super viewWillAppear:YES];

    [APP_DELEGATE stopAdvertisingBaecons];
    [APP_DELEGATE showTabBar:self.tabBarController];

    currentScreen = @"Favorite";
    [self getDatafromDatabase];

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    NSString * strSwitchNotify = [NSString stringWithFormat:@"updateDataforONOFFFavorite"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:strSwitchNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataforONOFF:) name:strSwitchNotify object:nil];
    
    [self getDatafromDatabase];
    
    NSString * strScanNotify = [NSString stringWithFormat:@"ResponsefromScanDashFavorite"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:strScanNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ResponsefromScanDash:) name:strScanNotify object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    isDashScanning = NO;
    
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateInternetAvailabilityNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCheckButtonVisibilityNotification object:nil];
    
    NSString * strScanNotify = [NSString stringWithFormat:@"ResponsefromScanDashFavorite"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:strScanNotify object:nil];

//    NSString * strSwitchNotify = [NSString stringWithFormat:@"updateDataforONOFFFavorite"];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:strSwitchNotify object:nil];
}

#pragma mark - Set View Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.4;
    [viewHeader addSubview:lblBack];

    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Favorites"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    imgNetworkStatus = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-70, 32, 60, 20)];
    [imgNetworkStatus setImage:[UIImage imageNamed:@""]];
    [imgNetworkStatus setContentMode:UIViewContentModeScaleAspectFit];
    imgNetworkStatus.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:imgNetworkStatus];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
    }
}
-(void)setMainViewContent
{
    int yy = 64 + 5;
    
    if (IS_IPHONE_X)
    {
        yy = 88 + 10;
    }
    blueSegmentedControl = [[NYSegmentedControl alloc] initWithItems:@[@"Devices", @"Groups"]];
    blueSegmentedControl.titleTextColor = global_brown_color;
    blueSegmentedControl.selectedTitleTextColor = [UIColor whiteColor];
    blueSegmentedControl.segmentIndicatorBackgroundColor = global_brown_color;
    blueSegmentedControl.backgroundColor = [UIColor whiteColor];
    blueSegmentedControl.borderWidth = 0.0f;
    blueSegmentedControl.segmentIndicatorBorderWidth = 0.0f;
    blueSegmentedControl.segmentIndicatorInset = 2.0f;
    blueSegmentedControl.segmentIndicatorBorderColor = self.view.backgroundColor;
    blueSegmentedControl.cornerRadius = 22;
    blueSegmentedControl.usesSpringAnimations = YES;
    [blueSegmentedControl addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventValueChanged];
    blueSegmentedControl.layer.cornerRadius = 22;
    blueSegmentedControl.layer.masksToBounds = YES;
    [self.view addSubview:blueSegmentedControl];
    [blueSegmentedControl setFrame:CGRectMake(30,yy, DEVICE_WIDTH-60, 44)];

    lblSuccessMsg = [[UILabel alloc] initWithFrame:CGRectMake(0, 119, DEVICE_WIDTH, DEVICE_HEIGHT-45-121)];
    [lblSuccessMsg setTextColor:[UIColor colorWithRed:94.0/255.0 green:94.0/255.0 blue:94.0/255.0 alpha:1]];
    [lblSuccessMsg setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lblSuccessMsg setTextAlignment:NSTextAlignmentCenter];
    [lblSuccessMsg setNumberOfLines:3];
    lblSuccessMsg.hidden = YES;
    [lblSuccessMsg setText:@"No favorite devices found"];
    [self.view addSubview:lblSuccessMsg];
    
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, yy+50, DEVICE_WIDTH, DEVICE_HEIGHT-(yy+50)-45) style:UITableViewStylePlain];
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblView.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:tblView];
    
    lblSuccessMsg.hidden=YES;

    sectionArr = [[NSMutableArray alloc] init];
    NSString * str1 = [NSString stringWithFormat:@"Select * from Device_Table where is_favourite = '1' and status = '1' and user_id ='%@' group by ble_address",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:str1 resultsArray:sectionArr];
    
    if ([sectionArr count]==0)
    {
        tblView.hidden=YES;
        lblSuccessMsg.hidden = NO;
    }
    else
    {
        tblView.hidden=NO;
        lblSuccessMsg.hidden = YES;
    }
    [tblView reloadData];
    if (IS_IPHONE_X)
    {
        CGRect tblFrame = tblView.frame;
        tblFrame = CGRectMake(tblFrame.origin.x, tblFrame.origin.y, tblFrame.size.width, tblFrame.size.height-44+6);
        tblView.frame = tblFrame;
    }
}
#pragma mark - Database Methods
-(void)getDatafromDatabase
{
    if (isForGroup)
    {
        isForGroup = YES;
        lblSuccessMsg.hidden = NO;
        
        [lblSuccessMsg setText:@"No favorite groups found"];
        
        groupsArr = [[NSMutableArray alloc] init];
        NSString * str0 = [NSString stringWithFormat:@"Select * from GroupsTable where is_favourite = '1' and user_id ='%@' and status = '1' group by local_group_id order by group_name",CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:str0 resultsArray:groupsArr];
        
        if ([groupsArr count]==0)
        {
            lblSuccessMsg.hidden = NO;
            tblView.hidden=NO;
            noMsgView.hidden = NO;
        }
        else
        {
            lblSuccessMsg.hidden = YES;
            tblView.hidden=NO;
            noMsgView.hidden = YES;
        }
        [tblView reloadData];
    }
    else
    {
        isForGroup = NO;
        lblSuccessMsg.hidden = NO;
        tblView.hidden = YES;
        
        [lblSuccessMsg setText:@"No favorite devices found"];
        
        sectionArr = [[NSMutableArray alloc] init];
        NSString * strQuery = [NSString stringWithFormat:@"Select * from Device_Table where is_favourite = '1' and status = '1' and user_id ='%@' group by ble_address",CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:sectionArr];
        
        if ([sectionArr count]==0)
        {
            tblView.hidden=YES;
            noMsgView.hidden = NO;
            lblSuccessMsg.hidden = NO;
            
        }
        else
        {
            tblView.hidden=NO;
            noMsgView.hidden = YES;
            lblSuccessMsg.hidden = YES;
        }
        [tblView reloadData];
    }
    
}
-(void)updateDataforONOFF:(NSNotification *)notification
{
    NSDictionary *dict = [notification object];
    NSString * strSet = @"No";
    NSString * deviceID = @"0";
    if ([[dict valueForKey:@"isSwitch"] isEqualToString:@"1"])
    {
        strSet = @"Yes";
    }
    else
    {
        strSet = @"No";
    }
    
    if (isAll)
    {
    }
    else
    {
        if ([dict count]>0)
        {
            if (isForGroup)
            {
                if ([groupsArr count]>0)
                {
                    deviceID = [[groupsArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"local_group_id"];
                    [[groupsArr objectAtIndex:selectedIndexPathl.row] setValue:strSet forKey:@"switch_status"];
                    
                    NSString * strUpdate = [NSString stringWithFormat:@"Update GroupsTable set switch_status='%@' where local_group_id = '%@'",strSet,deviceID];
                    [[DataBaseManager dataBaseManager] execute:strUpdate];
                }
            }
            else
            {
                deviceID = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"device_id"];
                [[sectionArr objectAtIndex:selectedIndexPathl.row] setValue:strSet forKey:@"switch_status"];
                
                NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set switch_status='%@' where device_id = '%@'",strSet,deviceID];
                [[DataBaseManager dataBaseManager] execute:strUpdate];
                
                [tblView reloadData];
            }
        }
    }
}
#pragma mark- UITableView Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isForGroup)
    {
        return [groupsArr count];
    }
    else
    {
        return [sectionArr count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isForGroup)
    {
        CustomGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomTableViewGroupCell"];
        if (cell==nil)
        {
            cell = [[CustomGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CustomTableViewGroupCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell._switchLight.delegate = self;
        cell._switchLight.tag = indexPath.row;
        cell.btnEdit.tag = indexPath.row;
        cell.btnDelete.tag = indexPath.row;
        cell.btnFav.tag = indexPath.row;
//        cell.btnback.tag = indexPath.row;
        
        cell.lblName.textColor = global_brown_color;
        cell.btnMore.hidden = YES;
        cell.imgMore.hidden = YES;

        cell.btnMore.tag = indexPath.row;
        [cell.btnEdit addTarget:self action:@selector(btnRenameClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnFav addTarget:self action:@selector(btnFavClick:) forControlEvents:UIControlEventTouchUpInside];
//        cell.btnback.tag = indexPath.row;
        [cell.btnDelete addTarget:self action:@selector(btnGroupDeleteClick:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.btnback addTarget:self action:@selector(tableRowClick:) forControlEvents:UIControlEventTouchUpInside];

        
        cell._switchLight.frame = CGRectMake(DEVICE_WIDTH-110+30+15, 0+10, 60, 40);

        [cell.btnDelete addTarget:self action:@selector(btnGroupDeleteClick:) forControlEvents:UIControlEventTouchUpInside];

        if ([groupsArr count]==0)
        {
        }
        else
        {
            cell.lblName.text = [[groupsArr objectAtIndex:indexPath.row] valueForKey:@"group_name"];
            if ([[[groupsArr objectAtIndex:indexPath.row] valueForKey:@"switch_status"] isEqualToString:@"Yes"])
            {
                [cell._switchLight setIsOn:YES];
                [cell._switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
            }
            else
            {
                [cell._switchLight setIsOn:NO];
                [cell._switchLight setCustomKnobImage:[UIImage imageNamed:@"off_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
            }
            
            if ([[[groupsArr objectAtIndex:indexPath.row] valueForKey:@"is_favourite"] isEqualToString:@"1"])
            {
                [cell.btnFav setImage:[UIImage imageNamed:@"active_favorite_icon.png"] forState:UIControlStateNormal];
            }
            else
            {
                [cell.btnFav setImage:[UIImage imageNamed:@"favorite_icon-1.png"] forState:UIControlStateNormal];
            }
        }
    
        cell.imgBulb.image = [UIImage imageNamed:@"default_group_icon.png"];
        return cell;
    }
    else
    {
        CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomTableViewCell"];
        if (cell==nil)
        {
            cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CustomTableViewCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        cell._switchLight.delegate = self;
        cell._switchLight.tag = indexPath.row;
        cell.btnEdit.tag = indexPath.row;
        cell.btnDelete.tag = indexPath.row;
        cell.btnFav.tag = indexPath.row;
        cell.lblName.textColor = global_brown_color;
        cell.btnMore.tag = indexPath.row;
//        cell.btnback.tag = indexPath.row;
        
        [cell.btnEdit addTarget:self action:@selector(btnRenameClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnFav addTarget:self action:@selector(btnFavClick:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.btnback addTarget:self action:@selector(tableRowClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnDelete addTarget:self action:@selector(btnDeleteClick:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.btnRemember addTarget:self action:@selector(btnRemeberClick:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.lblBleAddress.hidden = NO;
        [cell.btnDelete addTarget:self action:@selector(btnDeleteClick:) forControlEvents:UIControlEventTouchUpInside];

        cell.lblName.text = [[sectionArr objectAtIndex:indexPath.row] valueForKey:@"device_name"];
        cell.lblBleAddress.text = [[[sectionArr objectAtIndex:indexPath.row] valueForKey:@"ble_address"] uppercaseString];
        if ([[[sectionArr objectAtIndex:indexPath.row] valueForKey:@"switch_status"] isEqualToString:@"Yes"])
        {
            [cell._switchLight setIsOn:YES];
            [cell._switchLight setCustomKnobImage:[UIImage imageNamed:@"on_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
        }
        else
        {
            [cell._switchLight setIsOn:NO];
            [cell._switchLight setCustomKnobImage:[UIImage imageNamed:@"off_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
        }
        
        if ([[[sectionArr objectAtIndex:indexPath.row] valueForKey:@"is_favourite"] isEqualToString:@"1"])
        {
            [cell.btnFav setImage:[UIImage imageNamed:@"active_favorite_icon.png"] forState:UIControlStateNormal];
        }
        else
        {
            [cell.btnFav setImage:[UIImage imageNamed:@"favorite_icon-1.png"] forState:UIControlStateNormal];
        }
        
   /*     if ([[[sectionArr objectAtIndex:indexPath.row] valueForKey:@"remember_last_color"] isEqualToString:@"1"])
        {
            cell.btnRemember.titleLabel.layer.shadowColor = [global_brown_color CGColor];
            cell.btnRemember.titleLabel.layer.shadowRadius = 4.0f;
            cell.btnRemember.titleLabel.layer.shadowOpacity = .9;
            cell.btnRemember.titleLabel.layer.shadowOffset = CGSizeZero;
            cell.btnRemember.titleLabel.layer.masksToBounds = NO;
            [cell.btnRemember setTitle:@"Remebered Last Color" forState:UIControlStateNormal];
            [cell.btnRemember setTitleColor:global_brown_color forState:UIControlStateNormal];
        }
        else
        {
            cell.btnRemember.titleLabel.layer.shadowColor = [[UIColor clearColor] CGColor];
            cell.btnRemember.titleLabel.layer.shadowRadius = 1.0f;
            cell.btnRemember.titleLabel.layer.shadowOpacity = 1.0;
            cell.btnRemember.titleLabel.layer.shadowOffset = CGSizeZero;
            cell.btnRemember.titleLabel.layer.masksToBounds = YES;
            [cell.btnRemember setTitle:@"Remeber Last Color?" forState:UIControlStateNormal];
            [cell.btnRemember setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        } */
        NSString * strType = [[sectionArr objectAtIndex:indexPath.row] valueForKey:@"device_type"];
        cell.imgBulb.image = [UIImage imageNamed:[self getImageName:strType]];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //    if (previouIndex)
    //    {
    //        SWTableViewCell *cell = (SWTableViewCell *)[(UITableView *)tblView cellForRowAtIndexPath:previouIndex];
    //        [cell centerView:previouIndex.row];
    //    }
}


#pragma mark - Button Clicks
-(void)segmentClick:(NYSegmentedControl *) sender
{
    if (sender.selectedSegmentIndex==0)
    {
        isForGroup = NO;
        lblSuccessMsg.hidden = NO;
        tblView.hidden = YES;
        
        [lblSuccessMsg setText:@"No favorite devices found"];
        
        sectionArr = [[NSMutableArray alloc] init];
        NSString * strQuery = [NSString stringWithFormat:@"Select * from Device_Table where is_favourite = '1' and status = '1' and user_id ='%@' group by ble_address",CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:sectionArr];
        
        if ([sectionArr count]==0)
        {
            tblView.hidden=YES;
            noMsgView.hidden = NO;
            lblSuccessMsg.hidden = NO;

        }
        else
        {
            tblView.hidden=NO;
            noMsgView.hidden = YES;
            lblSuccessMsg.hidden = YES;
        }
        [tblView reloadData];
    }
    else if (sender.selectedSegmentIndex==1)
    {
        isForGroup = YES;
        lblSuccessMsg.hidden = NO;
        
        [lblSuccessMsg setText:@"No favorite groups found"];

        groupsArr = [[NSMutableArray alloc] init];
        NSString * str0 = [NSString stringWithFormat:@"Select * from GroupsTable where is_favourite = '1' and user_id ='%@' and status = '1' group by local_group_id order by group_name",CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:str0 resultsArray:groupsArr];
        
        if ([groupsArr count]==0)
        {
            lblSuccessMsg.hidden = NO;
            tblView.hidden=NO;
            noMsgView.hidden = NO;
        }
        else
        {
            lblSuccessMsg.hidden = YES;
            tblView.hidden=NO;
            noMsgView.hidden = YES;
        }
        [tblView reloadData];
    }
}

-(void)tableRowClick:(id)sender
{
    if ([APP_DELEGATE detectBluetooth])
    {
        strGlogalNotify = @"Favorite";

        isAll = NO;
        if (previouIndex)
        {
            SWTableViewCell *cell = (SWTableViewCell *)[(UITableView *)tblView cellForRowAtIndexPath:previouIndex];
            [cell centerView:previouIndex.row];
        }
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tblView];
        NSIndexPath *indexPath = [tblView indexPathForRowAtPoint:buttonPosition];
        selectedIndexPathl = indexPath;
        
        if (isForGroup)
        {
            selectedDict = [[NSMutableDictionary alloc] init];
            selectedDict = [groupsArr objectAtIndex:indexPath.row];
            globalGroupId  = [NSString stringWithFormat:@"%@",[selectedDict valueForKey:@"local_group_id"]];
        }
        else
        {
            selectedDict = [[NSMutableDictionary alloc] init];
            selectedDict = [sectionArr objectAtIndex:indexPath.row];
            globalGroupId  = [NSString stringWithFormat:@"%@",[selectedDict valueForKey:@"device_id"]];
        }
        
        DeviceDetailVC * detailVC = [[DeviceDetailVC alloc] init];
        detailVC.deviceDict = selectedDict;
        detailVC.isfromGroup = isForGroup;
        if ([[selectedDict valueForKey:@"device_type"] isEqualToString:@"2"])
        {
            detailVC.isDeviceWhite = YES;
        }
        [self.navigationController pushViewController:detailVC animated:YES];
        
        /*isAction = @"Move";
         isDashScanning = YES;
         globalDeviceHexId = @"71";
         [APP_DELEGATE sendSignalViaScan:@"Ping" withDeviceID:strDeviceID withValue:@"0"]; //KalpeshScanCode
         
         CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tblView];
         NSIndexPath *indexPath = [tblView indexPathForRowAtPoint:buttonPosition];
         selectedIndexPathl = indexPath;
         selectedDict = [[NSMutableDictionary alloc] init];
         selectedDict = [sectionArr objectAtIndex:indexPath.row];*/
    }
}
-(void)btnFavClick:(id)sender
{
    if (isForGroup)
    {
        if ([groupsArr count]> [sender tag])
        {
            if ([[[groupsArr objectAtIndex:[sender tag]] valueForKey:@"is_favourite"] isEqualToString:@"1"])
            {
                NSString * strUpdate = [NSString stringWithFormat:@"Update GroupsTable set is_favourite = '0',is_sync = '0' where local_group_id='%@'",[[groupsArr objectAtIndex:[sender tag]] valueForKey:@"local_group_id"]];
                [[DataBaseManager dataBaseManager] execute:strUpdate];
                [[groupsArr objectAtIndex:[sender tag]]setObject:@"0" forKey:@"is_favourite"];
                [tblView reloadData];
            }
            else
            {
                NSString * strUpdate = [NSString stringWithFormat:@"Update GroupsTable set is_favourite = '1',is_sync = '0' where local_group_id='%@'",[[groupsArr objectAtIndex:[sender tag]] valueForKey:@"local_group_id"]];
                [[DataBaseManager dataBaseManager] execute:strUpdate];
                [[groupsArr objectAtIndex:[sender tag]-1]setObject:@"1" forKey:@"is_favourite"];
                [tblView reloadData];
            }
        }
        [self SaveGroupsDetailstoServer:[sectionArr objectAtIndex:[sender tag]]];
        
    }
    else
    {
        if ([[[sectionArr objectAtIndex:[sender tag]] valueForKey:@"is_favourite"] isEqualToString:@"1"])
        {
            NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set is_favourite = '0', is_sync ='0' where device_id='%@'",[[sectionArr objectAtIndex:[sender tag]] valueForKey:@"device_id"]];
            [[DataBaseManager dataBaseManager] execute:strUpdate];
            [[sectionArr objectAtIndex:[sender tag]]setObject:@"0" forKey:@"is_favourite"];
            [tblView reloadData];
            
            //            if ([IS_USER_SKIPPED isEqualToString:@"NO"])
            //            {
            //                if ([APP_DELEGATE isNetworkreachable])
            //                {
            [self SaveDeviceDetailstoServer:[sectionArr objectAtIndex:[sender tag]]];
            //                }
            //            }
        }
        else
        {
            NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set is_favourite = '1', is_sync ='0' where device_id='%@'",[[sectionArr objectAtIndex:[sender tag]] valueForKey:@"device_id"]];
            [[DataBaseManager dataBaseManager] execute:strUpdate];
            [[sectionArr objectAtIndex:[sender tag]]setObject:@"1" forKey:@"is_favourite"];
            [tblView reloadData];
            
            if ([IS_USER_SKIPPED isEqualToString:@"NO"])
            {
                if ([APP_DELEGATE isNetworkreachable])
                {
                    [self SaveDeviceDetailstoServer:[sectionArr objectAtIndex:[sender tag]]];
                }
            }
        }
    }
}
-(void)btnRenameClick:(id)sender
{
    if (isForGroup)
    {
        selectedIndexPathl = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
        if ([groupsArr count]> selectedIndexPathl.row)
        {
            strRename = [[groupsArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"group_name"];
            strDeviceID = [[groupsArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"local_group_id"];
            strTableId = [[groupsArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"local_group_id"];
        }
        AddGroupsVC * deviceGroup = [[AddGroupsVC alloc] init];
        deviceGroup.detailDict = [groupsArr objectAtIndex:selectedIndexPathl.row];
        deviceGroup.isfromEdit = YES;
        [self.navigationController pushViewController:deviceGroup animated:YES];
    }
    else
    {
        selectedIndexPathl = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
        
        strRename = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"device_name"];
        strDeviceID = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"device_id"];
        globalDeviceHexId = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"hex_device_id"];
        strTableId = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"id"];
        renameIndex = [sender tag];
        
        NSString * msgPlaceHolder = [NSString stringWithFormat:@"Enter Device Name"];
        
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.delegate = self;
        alert.tag = 123;
        alert.colorScheme = global_brown_color;
        
        UITextField *customField = [[UITextField alloc] init];
        customField.placeholder = msgPlaceHolder;
        customField.text = strRename;
        customField.keyboardAppearance = UIKeyboardAppearanceAlert;
        customField.textColor = [UIColor blackColor];

        [alert addTextFieldWithCustomTextField:customField andPlaceholder:nil andTextReturnBlock:^(NSString *text) {
            strUpdatedName = text;
        }];
        [alert addButton:@"Cancel" withActionBlock:^{
            // Put your action here
        }];
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"Enter name"
               withCustomImage:nil
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
}
-(void)btnRemeberClick:(id)sender
{
    //    [NSIndexPath indexPathForRow:[sender tag] inSection:0]
    strDeviceID = [[sectionArr objectAtIndex:[sender tag]] valueForKey:@"device_id"];
    globalDeviceHexId = [[sectionArr objectAtIndex:[sender tag]] valueForKey:@"hex_device_id"];
    strTableId = [[sectionArr objectAtIndex:[sender tag]] valueForKey:@"id"];
    
    NSString * strON;
    if ([[[sectionArr objectAtIndex:[sender tag]] valueForKey:@"remember_last_color"] isEqualToString:@"1"])
    {
        strON = @"0";
    }
    else
    {
        strON = @"1";
    }
    
    [APP_DELEGATE sendSignalViaScan:@"RememberUDID" withDeviceID:strDeviceID withValue:strON]; //KalpeshScanCode
    NSString * strQuery = [NSString stringWithFormat:@"update Device_Table set remember_last_color =%@ where device_id =%@",strON,strDeviceID];
    [[DataBaseManager dataBaseManager] execute:strQuery];
    [[sectionArr objectAtIndex:selectedIndexPathl.row] setValue:strON forKey:@"remember_last_color"];
    [tblView reloadData];
    
    
}
#pragma mark- BLE Methods

-(void)switchOffDevice:(NSString *)sentID withType:(BOOL)isOn
{
    NSString * strON, * strStatus;
    if (isOn)
    {
        strON = @"1";
        strStatus = @"Yes";
    }
    else
    {
        strON = @"0";
        strStatus = @"No";
    }
    [APP_DELEGATE sendSignalViaScan:@"OnOff" withDeviceID:sentID withValue:strON]; //KalpeshScanCode
    
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        NSInteger int1 = [@"50" integerValue];
        NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];
        
        globalCount = globalCount + 1;
        NSInteger int2 = globalCount;
        NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2];
        
        NSInteger int3 = [@"9000" integerValue];
        NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2];
        
        NSInteger int4 = [sentID integerValue];
        NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2];
        
        NSInteger int5 = [@"0" integerValue];
        NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2];
        
        NSInteger int6 = [@"85" integerValue];
        NSData * data6 = [[NSData alloc] initWithBytes:&int6 length:2];
        
        NSInteger int7 = [strON integerValue];
        NSData * data7 = [[NSData alloc] initWithBytes:&int7 length:1];
        
        NSMutableData * checkData = [[NSMutableData alloc] init];
        [checkData appendData:data2];
        [checkData appendData:data3];
        [checkData appendData:data4];
        [checkData appendData:data5];//CRC as 0
        [checkData appendData:data6];
        [checkData appendData:data7];
        
        NSData * checksumData = [APP_DELEGATE GetCountedCheckSumData:checkData];

        NSMutableData *completeData = [[NSMutableData alloc] init];
        completeData = [data1 mutableCopy];
        [completeData appendData:data2];
        [completeData appendData:data3];
        [completeData appendData:data4];
        [completeData appendData:checksumData]; //Updated CRC
        [completeData appendData:data6];
        [completeData appendData:data7];
        
        NSString * StrData = [NSString stringWithFormat:@"%@",completeData.debugDescription];
        StrData = [StrData stringByReplacingOccurrencesOfString:@" " withString:@""];
        StrData = [StrData stringByReplacingOccurrencesOfString:@"<" withString:@""];
        StrData = [StrData stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        NSString * strEncryptedKey = [APP_DELEGATE getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"passKey"]];
        NSString * strFinalData = [APP_DELEGATE getStringConvertedinUnsigned:StrData];
        
        NSData * requestData = [APP_DELEGATE GetEncryptedKeyforData:strFinalData withKey:strEncryptedKey withLength:completeData.length];
        [[BLEService sharedInstance] writeValuetoDeviceMsg:requestData with:globalPeripheral];
        [[NSUserDefaults standardUserDefaults] setInteger:globalCount forKey:@"GlobalCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    if (tmpSwtch.tag ==123)
    {
        [sectionArr setValue:strStatus forKey:@"switch_status"];
        NSString * updateStr = [NSString stringWithFormat:@"Update Device_Table set switch_status = '%@'",strStatus];
        [[DataBaseManager dataBaseManager] execute:updateStr];
    }
    else
    {
        [self updateSwitchStatus:isOn withDeviceID:sentID];
    }
}
-(void)updateSwitchStatus:(BOOL)newValue withDeviceID:(NSString*)deviceID
{
    NSString  * strStatus;
    if (newValue)
    {
        strStatus = @"Yes";
    }
    else
    {
        strStatus = @"No";
    }
    
    if (isForGroup)
    {
        deviceID = [[groupsArr objectAtIndex:switchIndex.row] valueForKey:@"local_group_id"];
        [[groupsArr objectAtIndex:switchIndex.row] setObject:strStatus forKey:@"switch_status"];
        
        NSString * strUpdate = [NSString stringWithFormat:@"Update GroupsTable set switch_status='%@' where local_group_id = '%@'",strStatus,deviceID];
        [[DataBaseManager dataBaseManager] execute:strUpdate];
        
    }
    else
    {
        
        deviceID = [[sectionArr objectAtIndex:switchIndex.row] valueForKey:@"device_id"];
        [[sectionArr objectAtIndex:switchIndex.row] setObject:strStatus forKey:@"switch_status"];
        
        NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set switch_status='%@' where device_id = '%@'",strStatus,deviceID];
        [[DataBaseManager dataBaseManager] execute:strUpdate];
        
    }
}

-(NSString*)hexFromStr:(NSString*)str
{
    NSData* nsData = [str dataUsingEncoding:NSUTF8StringEncoding];
    const char* data = [nsData bytes];
    NSUInteger len = nsData.length;
    NSMutableString* hex = [NSMutableString string];
    for(int i = 0; i < len; ++i)
        [hex appendFormat:@"%02X", data[i]];
    return hex;
}

- (NSData *)dataFromHexString:(NSString*)hexStr
{
    const char *chars = [hexStr UTF8String];
    int i = 0, len = hexStr.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}




-(void)checkTimeOut
{
    [APP_DELEGATE hideScannerView];
    [APP_DELEGATE endHudProcess];
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
    }
    else
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"There is something went wrong. Please check device connection."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
}
-(void)DashBoardConnected
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    alert.tag = 222;
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Device has been connected successfully."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}


#pragma mark - ORBSwitchDelegate

- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue
{
    if (switchObj.tag==123)
    {
        tmpSwtch = switchObj;
        [self switchOffDevice:@"0" withType:newValue];
        isAlldevicePowerOn = newValue;
    }
    else
    {
        CGPoint buttonPosition = [switchObj convertPoint:CGPointZero toView:tblView];
        NSIndexPath *index = [tblView indexPathForRowAtPoint:buttonPosition];
        switchIndex = index;
        
        NSString * deviceID = @"NA";
        if (isForGroup)
        {
            deviceID = [[groupsArr objectAtIndex:index.row] valueForKey:@"local_group_id"];
        }
        else
        {
            deviceID = [[sectionArr objectAtIndex:index.row] valueForKey:@"device_id"];
        }
        
        tmpSwtch = switchObj;
        if (![deviceID isEqualToString:@"NA"])
        {
            [self switchOffDevice:deviceID withType:newValue];
        }
    }
}

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj
{
    //    if (switchObj == _switch4 || switchObj == _switchLight)
    {
        [switchObj setCustomKnobImage:[UIImage imageNamed:(switchObj.isOn) ? @"on_icon" : @"off_icon"]
              inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]
                activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
    }
}
-(void)stopIndicator
{
    [APP_DELEGATE hideScannerView];
    [APP_DELEGATE endHudProcess];
}
-(BOOL)isConnectionAvail
{
    
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        return YES;
    }
    else
    {
        if ([[[BLEManager sharedManager] getLastConnected] count]>0)
        {
            if (globalPeripheral.state == CBPeripheralStateConnected)
            {
                return YES;
                
            }
            else
            {
                
                [APP_DELEGATE showScannerView:@"Connecting..."];
                if (globalPeripheral)
                {
                }
                else
                {
                    isNonConnectScanning = NO;
                    [[BLEManager sharedManager] updateBluetoothState];
                }
                //                [self performSelector:@selector(checkTimeOut) withObject:nil afterDelay:5];
                
                [tmpSwtch setCustomKnobImage:[UIImage imageNamed:(tmpSwtch.isOn) ? @"off_icon" : @"on_icon"]
                     inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]
                       activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
                [tmpSwtch setIsOn:NO];
                return NO;
                
            }
        }
        else
        {
            [APP_DELEGATE showScannerView:@"Connecting..."];
            
            if (globalPeripheral)
            {
            }
            else
            {
                isNonConnectScanning = NO;
                [[BLEManager sharedManager] updateBluetoothState];
            }
            //            [self performSelector:@selector(checkTimeOut) withObject:nil afterDelay:5];
            
            [tmpSwtch setCustomKnobImage:[UIImage imageNamed:(tmpSwtch.isOn) ? @"off_icon" : @"on_icon"]
                 inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]
                   activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
            [tmpSwtch setIsOn:NO];
            return NO;
        }
    }
    return NO;
}
-(NSString *)getImageName:(NSString *)strType
{
    NSString * strImgName = @"default_pic.png";
    
    if ([strType isEqualToString:@"1"])
    {
        strImgName= @"default_pic.png";
    }
    else if ([strType isEqualToString:@"2"])
    {
        strImgName= @"default_pic.png";
    }
    else if ([strType isEqualToString:@"3"])
    {
        strImgName= @"default_switch_icon.png";
    }
    else if ([strType isEqualToString:@"4"])
    {
        strImgName= @"default_socket_icon.png";
    }
    else if ([strType isEqualToString:@"5"])
    {
        strImgName= @"default_fan_icon.png";
    }
    else if ([strType isEqualToString:@"6"])
    {
        strImgName= @"stripwhite.png";
    }
    else if ([strType isEqualToString:@"7"])
    {
        strImgName= @"default_lamp.png";
    }
    else if ([strType isEqualToString:@"8"])
    {
        strImgName= @"default_powerstrip_icon.png";
    }
    return strImgName;
}
-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""])
        {
            strValid = strRequest;
        }
        else
        {
            strValid = @"NA";
        }
    }
    else
    {
        strValid = @"NA";
    }
    return strValid;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Required Methods

#pragma mark - Delete Device Methods
-(void)btnDeleteClick:(id)sender
{
    selectedIndexPathl = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    
    if ([sectionArr count]> selectedIndexPathl.row)
    {
        strRename = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"device_name"];
        strDeviceID = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"device_id"];
        globalDeviceHexId = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"hex_device_id"];
        strTableId = [[sectionArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"id"];
    }
    
    
    NSString * msgStr = [NSString stringWithFormat:@"Are you sure. You want to delete this device ?"];
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    [alert addButton:@"Yes" withActionBlock:^{
        [APP_DELEGATE startHudProcess:@"Removing Device..."];
        [self performSelector:@selector(timeOutForDeleteDevice) withObject:nil afterDelay:5];
        // Put your action here
        if ([sectionArr count]> selectedIndexPathl.row)
        {
            syncedDeletedListArr = [[NSMutableArray alloc] init];
            [self removeDevice];
        }
    }];
    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:msgStr
           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
       withDoneButtonTitle:@"No" andButtons:nil];
}

-(void)removeDevice
{
    [APP_DELEGATE sendSignalViaScan:@"DeleteUUID" withDeviceID:strDeviceID withValue:@"0"]; //KalpeshScanCode
    
    isDashScanning = YES;
    isAction = @"RemoveDevice";
    strGlogalNotify = @"Favorite";
    
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        NSMutableData * collectChekData = [[NSMutableData alloc] init];
        
        NSInteger int1 = [@"100" integerValue];
        NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];
        
        globalCount = globalCount + 1;
        NSInteger int2 = globalCount;
        NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2];
        collectChekData = [data2 mutableCopy];
        
        NSInteger int3 = [@"9000" integerValue];
        NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2];
        [collectChekData appendData:data3];
        
        NSInteger int4 = [strDeviceID integerValue];
        NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2];
        [collectChekData appendData:data4];
        
        NSInteger int5 = [@"0" integerValue];
        NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2];
        [collectChekData appendData:data5];
        
        NSInteger int6 = [@"55" integerValue];
        NSData * data6 = [[NSData alloc] initWithBytes:&int6 length:2];
        [collectChekData appendData:data6];
        
        NSData * finalCheckSumData = [APP_DELEGATE GetCountedCheckSumData:collectChekData];
        
        NSMutableData * completeData = [[NSMutableData alloc] init];
        completeData = [data1 mutableCopy];
        [completeData appendData:data2];
        [completeData appendData:data3];
        [completeData appendData:data4];
        [completeData appendData:finalCheckSumData];
        [completeData appendData:data6];
        
        NSString * StrData = [NSString stringWithFormat:@"%@",completeData.debugDescription];
        StrData = [StrData stringByReplacingOccurrencesOfString:@" " withString:@""];
        StrData = [StrData stringByReplacingOccurrencesOfString:@"<" withString:@""];
        StrData = [StrData stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        NSString * strEncryptedKey = [APP_DELEGATE getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"passKey"]];
        NSString * strFinalData = [APP_DELEGATE getStringConvertedinUnsigned:StrData];
        
        NSData * requestData = [APP_DELEGATE GetEncryptedKeyforData:strFinalData withKey:strEncryptedKey withLength:completeData.length];
        
        [[BLEService sharedInstance] writeValuetoDeviceMsg:requestData with:globalPeripheral];
        [[NSUserDefaults standardUserDefaults] setInteger:globalCount forKey:@"GlobalCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(void)timeOutForDeleteDevice
{
    [APP_DELEGATE endHudProcess];
    if ([isAction isEqualToString:@"DeviceDeleted"])
    {
        
    }
    else
    {
        NSString * strMsg = [NSString stringWithFormat:@"Something went wrong. Please try again."];
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:strMsg
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
}

#pragma mark - Delete Group Methods
-(void)btnGroupDeleteClick:(id)sender
{
    groupSentCount = 0;
    groupSyncCount = 0;
    
    selectedIndexPathl = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    if ([groupsArr count]> selectedIndexPathl.row)
    {
        strRename = [[groupsArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"group_name"];
        strDeviceID = [[groupsArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"local_group_id"];
        strTableId = [[groupsArr objectAtIndex:selectedIndexPathl.row] valueForKey:@"local_group_id"];
    }
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    [alert addButton:@"Yes" withActionBlock:^{
        [APP_DELEGATE startHudProcess:@"Removing Room..."];
        // Put your action here
        if ([groupsArr count]> selectedIndexPathl.row)
        {
            //            [self removeGroup];
            isDashScanning = YES;
            isAction = @"RemoveGroup";
            strGlogalNotify = @"Favorite";
            
            NSString * strQuery = [NSString stringWithFormat:@"Select * from Group_Details_Table where group_id =%@ and status = '1'",strDeviceID];
            tmpGroupArr = [[NSMutableArray alloc] init];
            syncedDeletedListArr = [[NSMutableArray alloc] init];
            [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:tmpGroupArr];
            [self sendDeviceonebyone];
            
        }
    }];
    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Are you sure. You want to delete this Room ?"
           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
       withDoneButtonTitle:@"No" andButtons:nil];
    
}
-(void)sendDeviceonebyone
{
    if ([tmpGroupArr count]> groupSentCount)
    {
        //        if ([[[tmpDevicesArr objectAtIndex:sentCount] valueForKey:@"UpdatedStatus"] isEqualToString:@"delete"])
        {
            NSString * strId = [[tmpGroupArr objectAtIndex:groupSentCount] valueForKey:@"device_id"];
            [self removeGroupwithGroupID:strDeviceID withDevieID:strId];
            [self removeGroupwithGroupID:strDeviceID withDevieID:strId];
            [self removeGroupwithGroupID:strDeviceID withDevieID:strId];
        }
        groupSentCount = groupSentCount + 1;
        [self performSelector:@selector(sendDeviceonebyone) withObject:nil afterDelay:1];
    }
    else
    {
        [self performSelector:@selector(CheckforDeleteGroup) withObject:nil afterDelay:2];
    }
}
-(void)CheckforDeleteGroup
{
    isDashScanning = NO;
    [APP_DELEGATE hudEndProcessMethod];
    
    if (groupSyncCount == groupSentCount)
    {
        NSString * strDelete = [NSString stringWithFormat:@"update GroupsTable set status = '2', is_sync ='0' where local_group_id = '%@' and user_id ='%@' ",strDeviceID,CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:strDelete];
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        
        if ([groupsArr count]> selectedIndexPathl.row)
        {
            dict = [groupsArr objectAtIndex:selectedIndexPathl.row];
            [groupsArr removeObjectAtIndex:selectedIndexPathl.row];
        }
        [dict setObject:@"2" forKey:@"status"];
        [self SaveGroupsDetailstoServer:dict];
        [tblView reloadData];
        isAction = @"";
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeSuccess];
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"Room has been removed successfully."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
    else
    {
        NSString * strMsg = [NSString stringWithFormat:@"There are few devices which are not in range. So we can't delete this Room now."];
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:strMsg
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
}
-(void)removeGroupwithGroupID:(NSString *)strGroupID withDevieID:(NSString *)strDeviceID
{
    [APP_DELEGATE sendSignalViaScan:@"DeleteGroupUUID" withDeviceID:strDeviceID withValue:strGroupID];

    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        NSInteger int1 = [@"50" integerValue];
        NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];
        
        globalCount = globalCount + 1;
        NSInteger int2 = globalCount;
        NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2];
        
        NSInteger int3 = [@"9000" integerValue];
        NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2];
        
        NSInteger int4 = [strDeviceID integerValue];
        NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2];
        
        NSInteger int5 = [@"0" integerValue];
        NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2];
        
        NSInteger int6 = [@"10" integerValue];
        NSData * data6 = [[NSData alloc] initWithBytes:&int6 length:2];
        
        NSInteger int7 = [@"1" integerValue];
        NSData * data7 = [[NSData alloc] initWithBytes:&int7 length:1];
        
        NSInteger int8 = [strGroupID integerValue];
        NSData * data8 = [[NSData alloc] initWithBytes:&int8 length:2];
        
        NSMutableData * checkData = [[NSMutableData alloc] init];
        [checkData appendData:data2];
        [checkData appendData:data3];
        [checkData appendData:data4];
        [checkData appendData:data5];//CRC as 0
        [checkData appendData:data6];
        [checkData appendData:data7];
        [checkData appendData:data8];
        
        NSData * checksumData = [APP_DELEGATE GetCountedCheckSumData:checkData];
        
        NSMutableData * completeData = [[NSMutableData alloc] init];
        completeData = [data1 mutableCopy];
        [completeData appendData:data2];
        [completeData appendData:data3];
        [completeData appendData:data4];
        [completeData appendData:checksumData];
        [completeData appendData:data6];
        [completeData appendData:data7];
        [completeData appendData:data8];
        
        NSString * StrData = [NSString stringWithFormat:@"%@",completeData.debugDescription];
        StrData = [StrData stringByReplacingOccurrencesOfString:@" " withString:@""];
        StrData = [StrData stringByReplacingOccurrencesOfString:@"<" withString:@""];
        StrData = [StrData stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        NSString * strEncryptedKey = [APP_DELEGATE getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults] valueForKey:@"passKey"]];
        NSString * strFinalData = [APP_DELEGATE getStringConvertedinUnsigned:StrData];
        
        NSData * requestData = [APP_DELEGATE GetEncryptedKeyforData:strFinalData withKey:strEncryptedKey withLength:completeData.length];
        
            [[BLEService sharedInstance] writeValuetoDeviceMsg:requestData with:globalPeripheral];
            [[NSUserDefaults standardUserDefaults] setInteger:globalCount forKey:@"GlobalCount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(void)ResponsefromScanDash:(NSNotification *)notification
{
    //    isDashScanning = NO;
    if ([isAction isEqualToString:@"DeviceNameChange"])
    {
        NSString * strDelete = [NSString stringWithFormat:@"Update Device_Table set device_name='%@' where id = '%@'",strChangedDeviceNames,strTableId];
        [[DataBaseManager dataBaseManager] execute:strDelete];
        
        [[sectionArr objectAtIndex:selectedIndexPathl.row] setObject:strChangedDeviceNames forKey:@"device_name"];
        [tblView reloadData];
        
    }
    else if ([isAction isEqualToString:@"RemoveDevice"])
    {
        NSString * kpstr = (NSString*) notification.object;
        
        //globalDeviceHexId
        if ([kpstr rangeOfString:globalDeviceHexId].location == NSNotFound)
        {
        }
        else
        {
            isDashScanning = NO;
            isAction = @"";
            if (![syncedDeletedListArr containsObject:strDeviceID])
            {
                NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set status ='2',is_sync = '0' where device_id = '%@'",strDeviceID];
                [[DataBaseManager dataBaseManager] execute:strUpdate];
                [syncedDeletedListArr addObject:strDeviceID];
                
                if ([sectionArr count] > selectedIndexPathl.row)
                {
                    
                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                    dict = [sectionArr objectAtIndex:selectedIndexPathl.row];
                    [dict setObject:@"0" forKey:@"status"];
                    [self SaveDeviceDetailstoServer:dict];
                    [APP_DELEGATE hudEndProcessMethod];
                    
                    [sectionArr removeObjectAtIndex:selectedIndexPathl.row];
                    [tblView reloadData];
                }
                
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeSuccess];
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:@"Room has been removed successfully."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
        }
    }
    else if ([isAction isEqualToString:@"RemoveGroup"])
    {
        NSString * kpstr = (NSString*) notification.object;
        
        for (int i =0; i<[tmpGroupArr count]; i++)
        {
            NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
            [tmpDict setObject:[[tmpGroupArr objectAtIndex:i] valueForKey:@"device_id"] forKey:@"device_id"];
            NSString * strCompare = [[tmpGroupArr objectAtIndex:i] valueForKey:@"hex_device_id"];
            
            if ([kpstr rangeOfString:strCompare].location == NSNotFound)
            {
            }
            else
            {
                if (![[syncedDeletedListArr valueForKey:@"device_id"] containsObject:[[tmpGroupArr objectAtIndex:i] valueForKey:@"device_id"]])
                {
                    [syncedDeletedListArr addObject:tmpDict];
                    groupSyncCount = groupSyncCount + 1;
                    
                    NSString * strUpdate = [NSString stringWithFormat:@"delete from Group_Details_Table where group_id = '%@' and device_id ='%@' ",[[tmpGroupArr objectAtIndex:i] valueForKey:@"group_id"],[[tmpGroupArr objectAtIndex:i] valueForKey:@"device_id"]];
                    [[DataBaseManager dataBaseManager] execute:strUpdate];
                }
                [[tmpGroupArr objectAtIndex:i] setObject:@"1" forKey:@"isDeleted"];
            }
        }
        
        /*NSString * strDelete = [NSString stringWithFormat:@"Update GroupsTable set status = '0',is_sync = '0' where local_group_id = '%@'",strTableId];
         [[DataBaseManager dataBaseManager] execute:strDelete];
         if ([groupsArr count]> selectedIndexPathl.row)
         {
         [groupsArr removeObjectAtIndex:selectedIndexPathl.row];
         }
         else
         {
         groupsArr = [[NSMutableArray alloc] init];
         NSString * strQuery = [NSString stringWithFormat:@"Select * from GroupsTable where user_id ='%@' and status = '1' group by local_group_id",CURRENT_USER_ID];
         [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:groupsArr];
         }
         [tblView reloadData];*/
    }
    else if([isAction isEqualToString:@"Move"])
    {
        if ([currentScreen isEqualToString:@"Dashboard"])
        {
            DeviceDetailVC * detailVC = [[DeviceDetailVC alloc] init];
            detailVC.deviceDict = selectedDict;
            detailVC.isfromGroup = isForGroup;
            if ([[selectedDict valueForKey:@"device_type"] isEqualToString:@"2"])
            {
                detailVC.isDeviceWhite = YES;
            }
            globalGroupId  = [NSString stringWithFormat:@"%@",[selectedDict valueForKey:@"device_id"]];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }
}


#pragma mark - Save Install records to Database
-(void)SaveDeviceDetailstoServer:(NSMutableDictionary *)inforDict
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        if ([IS_USER_SKIPPED isEqualToString:@"NO"])
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                {
                    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
                    [args setObject:CURRENT_USER_ID forKey:@"user_id"];
                    [args setObject:[inforDict valueForKey:@"device_id"] forKey:@"device_id"];
                    [args setObject:[inforDict valueForKey:@"hex_device_id"] forKey:@"hex_device_id"];
                    [args setObject:[inforDict valueForKey:@"device_name"] forKey:@"device_name"];
                    [args setObject:[inforDict valueForKey:@"device_type"] forKey:@"device_type"];
                    [args setObject:[[inforDict valueForKey:@"ble_address"]uppercaseString] forKey:@"ble_address"];
                    [args setObject:[inforDict valueForKey:@"status"] forKey:@"status"];
                    [args setObject:[inforDict valueForKey:@"is_favourite"] forKey:@"is_favourite"];
                    [args setValue:[inforDict valueForKey:@"remember_last_color"] forKey:@"remember_last_color"];

                    NSString *deviceToken =deviceTokenStr;
                    if (deviceToken == nil || deviceToken == NULL)
                    {
                        [args setValue:@"123456789" forKey:@"device_token"];
                    }
                    else
                    {
                        [args setValue:deviceToken forKey:@"device_token"];
                    }
                    [args setObject:@"1" forKey:@"is_update"];
                    AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
                    //[manager1.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
                    NSString *token=[[NSUserDefaults standardUserDefaults]valueForKey:@"globalCode"];
                    NSString *authorization = [NSString stringWithFormat: @"Basic %@",token];
                    [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
                    [manager1.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                    //manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
                    
                    AFHTTPRequestOperation *op = [manager1 POST:@"http://vithamastech.com/smartlight/api/save_device" parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject)
                                                  {
                                                      NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                                                      dictID = [responseObject mutableCopy];
                                                      if ([dictID valueForKey:@"data"] == [NSNull null] || [dictID valueForKey:@"data"] == nil)
                                                      {
                                                          
                                                      }
                                                      else
                                                      {
                                                          NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set is_sync ='1' where device_id='%@'",[[dictID valueForKey:@"data"]valueForKey:@"device_id"]];
                                                          [[DataBaseManager dataBaseManager] execute:strUpdate];
                                                      }
                                                  }
                                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                            if (error)
                                                            {
//                                                                NSLog(@"Servicer error = %@", error);
                                                            }
                                                        }];
                    [op start];
                }
                // Perform async operation
                // Call your method/function here
                // Example:
                dispatch_sync(dispatch_get_main_queue(), ^{
                    //Method call finish here
                });
            });
        }
    }
}
-(void)SaveGroupsDetailstoServer:(NSMutableDictionary *)inforDict
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        if ([IS_USER_SKIPPED isEqualToString:@"NO"])
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                {
                    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
                    [args setValue:CURRENT_USER_ID forKey:@"user_id"];
                    [args setValue:[inforDict valueForKey:@"local_group_id"] forKey:@"local_group_id"];
                    [args setValue:[inforDict valueForKey:@"local_group_hex_id"] forKey:@"local_group_hex_id"];
                    [args setValue:[inforDict valueForKey:@"group_name"] forKey:@"group_name"];
                    [args setValue:[inforDict valueForKey:@"status"] forKey:@"status"];
                    [args setValue:[inforDict valueForKey:@"is_favourite"] forKey:@"is_favourite"];
                    [args setValue:@"1" forKey:@"is_update"];
                    NSString *deviceToken =deviceTokenStr;
                    if (deviceToken == nil || deviceToken == NULL)
                    {
                        [args setValue:@"123456789" forKey:@"device_token"];
                    }
                    else
                    {
                        [args setValue:deviceToken forKey:@"device_token"];
                    }
                    if ([[inforDict valueForKey:@"is_added_firsttime"] isEqualToString:@"1"])
                    {
                        [args setValue:@"0" forKey:@"is_update"];
                    }
                    //            devices
                    NSString * str =[NSString stringWithFormat:@"Select server_device_id from Group_Details_Table where group_id ='%@'",[inforDict valueForKey:@"local_group_id"]];
                    NSMutableArray * tmparr =[[NSMutableArray alloc] init];
                    [[DataBaseManager dataBaseManager] execute:str resultsArray:tmparr];
                    
                    NSString * deviceStr = [tmparr componentsJoinedByString:@","];
                    [args setValue:deviceStr forKey:@"devices"];
                    
                    AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
                    //[manager1.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
                    NSString *token=[[NSUserDefaults standardUserDefaults]valueForKey:@"globalCode"];
                    NSString *authorization = [NSString stringWithFormat: @"Basic %@",token];
                    [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
                    [manager1.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                    //manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
                    
                    AFHTTPRequestOperation *op = [manager1 POST:@"http://vithamastech.com/smartlight/api/save_group" parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject)
                                                  {
                                                      NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                                                      dictID = [responseObject mutableCopy];
                                                      if ([[dictID valueForKey:@"message"] isEqualToString:@"Group already deleted"])
                                                      {
                                                          NSString * strDeleteGroup = [NSString stringWithFormat:@"delete from GroupsTable where local_group_id = '%@'",[[dictID valueForKey:@"data"]valueForKey:@"local_group_id"]];
                                                          [[DataBaseManager dataBaseManager] execute:strDeleteGroup];
                                                      }
                                                      else
                                                      {
                                                          if ([dictID valueForKey:@"data"] == [NSNull null] || [dictID valueForKey:@"data"] == nil)
                                                          {
                                                          }
                                                          else
                                                          {
                                                              if ([[dictID valueForKey:@"data"] count]>0)
                                                              {
                                                                  NSString * strIDD = [[[dictID valueForKey:@"data"] objectAtIndex:0] valueForKey:@"local_group_id"];
                                                                  
                                                                  NSString * strUpdate = [NSString stringWithFormat:@"Update GroupsTable set is_sync ='1', is_added_firsttime = '2' where local_group_id='%@'",strIDD];
                                                                  [[DataBaseManager dataBaseManager] execute:strUpdate];
                                                                  
                                                                  NSString * strUpdateDetail = [NSString stringWithFormat:@"Update Group_Details_Table set is_sync ='1' where group_id='%@'",strIDD];
                                                                  [[DataBaseManager dataBaseManager] execute:strUpdateDetail];
                                                                  
                                                              }
                                                          }
                                                      }
                                                      
                                                      NSLog(@"Success Response with Result=%@",responseObject);
                                                  }
                                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                            if (error)
                                                            {
                                                                NSLog(@"Servicer error = %@", error);
                                                            }
                                                        }];
                    [op start];
                }
                // Perform async operation
                // Call your method/function here
                // Example:
                dispatch_sync(dispatch_get_main_queue(), ^{
                    //Method call finish here
                });
            });
        }
    }
}
#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
    NSLog(@"Button Clicked: %ld Title:%@", (long)index, title);
    
    if (alertView.tag == 123)
    {
        
    }
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    NSLog(@"Done Button Clicked");
    if (alertView.tag == 123)
    {
        [self ValidationforAddedMessage:strUpdatedName];
    }
}

- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
    NSLog(@"Alert Dismissed");
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
    NSLog(@"Alert Will Appear");
}
-(void)ValidationforAddedMessage:(NSString *)text
{
    if ([[self checkforValidString:text] isEqualToString:@"NA"])
    {
        [self showErrorMessage:@"Please enter valid name."];
    }
    else
    {
        NSString * strDelete = [NSString stringWithFormat:@"Update Device_Table set device_name='%@',is_sync='0' where id = '%@'",strUpdatedName,strTableId];
        [[DataBaseManager dataBaseManager] execute:strDelete];
        
        [[sectionArr objectAtIndex:selectedIndexPathl.row] setObject:text forKey:@"device_name"];
        [tblView reloadData];
        
        if ([IS_USER_SKIPPED isEqualToString:@"NO"])
        {
            if ([APP_DELEGATE isNetworkreachable])
            {
                [self SaveDeviceDetailstoServer:[sectionArr objectAtIndex:renameIndex]];
            }
        }
    }
}
-(void)showErrorMessage:(NSString *)strMessage
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:strMessage
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
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
