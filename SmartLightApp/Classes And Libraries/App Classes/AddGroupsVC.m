//
//  AddGroupsVC.m
//  SmartLightApp
//
//  Created by stuart watts on 09/06/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "AddGroupsVC.h"
#import "HistoryCell.h"
#import "AuthenticationVC.h"
#import "DeviceDetailVC.h"
#import "BridgeVC.h"

@interface AddGroupsVC ()<UITableViewDelegate,UITableViewDataSource,URLManagerDelegate,FCAlertViewDelegate>
{
    UITableView * tblView;
    NSMutableArray * deviceListArray ;
    CBPeripheral * myPeripheral;
    BOOL isOneDvcAdded;
    BOOL isForSingleRemove;
    
    NSString * sentDeviceID, * sentHexId;
    NSInteger groupCount;
    BOOL isAllowOnce, isSentForGroup;
    
    NSMutableArray * groupDeviceSelectedArr;
    NSInteger recieveCount, sentCount;
    NSString * strGroupTxt;
    NSMutableDictionary * selectedDict;
    UIImageView * statusImg;
    
    BOOL isDeviceResponsed;
    NSString * strSelectedSingleDeviceAddres;
    NSString * strSentGroupHexID;
    NSMutableArray * syncedArray;
    NSInteger selcedIndexx;
}
@end

@implementation AddGroupsVC
@synthesize isForGroup,isfromEdit,detailDict;

- (void)viewDidLoad
{
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    [self.view addSubview:imgBack];
    
    [super viewDidLoad];
    
    deviceListArray = [[NSMutableArray alloc] init];
    groupDeviceSelectedArr = [[NSMutableArray alloc] init];
    selectedDict = [[NSMutableDictionary alloc] init];
    
    NSString * strQuery = [NSString stringWithFormat:@"Select * from Device_Table where user_id ='%@' and status = '1' and device_type != '4' group by ble_address",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:deviceListArray];
    

    NSString * tmpStr = [NSString stringWithFormat:@"select * from GroupsTable where user_id = '%@' and status = '1'group by local_group_id",CURRENT_USER_ID];
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:tmpStr resultsArray:tmpArr];
    
    NSString * tmpStr123 = [NSString stringWithFormat:@"select * from Group_Details_Table where group_id = '%@'",[detailDict valueForKey:@"local_group_id"]];
    NSMutableArray * tmpss = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager]execute:tmpStr123 resultsArray:tmpss];
    
    groupCount = [tmpArr count]+1;
    strGroupTxt = [NSString stringWithFormat:@"Group %lu",[tmpArr count]+1];
    
    isOneDvcAdded = NO;
    isForSingleRemove = NO;
    isSentForGroup = NO;
    
    if([deviceListArray count]>0)
    {
        isOneDvcAdded = YES;
        [deviceListArray setValue:@"No" forKey:@"isSelected"];
    }
    [self setNavigationViewFrames];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    currentScreen = @"AddGroupDevice";
    [APP_DELEGATE hideTabBar:self.tabBarController];
    [APP_DELEGATE isNetworkreachable];
    
    
    [self InitialBLE];
    
    [[[BLEManager sharedManager] nonConnectArr] removeAllObjects];
    [[BLEManager sharedManager] rescan];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCheckButtonVisibilityNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showBridgeScreen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBridgeScreen) name:@"showBridgeScreen" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:currentScreen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBleStatus) name:currentScreen object:nil];
    
    [super viewWillAppear:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    isOnAddGroup = NO;
}
-(void)viewDidDisappear:(BOOL)animated
{
    isNonConnectScanning = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallNotificationforAddGroups" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showBridgeScreen" object:nil];
}
#pragma mark - Set Frames
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
    [lblTitle setText:@"Add Room"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    if (isfromEdit)
    {
        [lblTitle setText:@"Update Room"];
    }
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 70, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];
    
    UIButton * btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSave.frame = CGRectMake(DEVICE_WIDTH-60, 20, 60, 44);
    btnSave.layer.masksToBounds = YES;
    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnSave.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    [btnSave.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [btnSave addTarget:self action:@selector(SaveGroupClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnSave];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
        btnSave.frame = CGRectMake(DEVICE_WIDTH-60, 20, 60, 64);
        [self setMainViewContentFrame:88];
    }
    else
    {
        [self setMainViewContentFrame:64];
    }
    
}
-(void)setMainViewContentFrame:(int)yyy
{
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, yyy, DEVICE_WIDTH, 45*approaxSize)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.6;
    [self.view addSubview:lblBack];

    txtGroupName = [[UITextField alloc] initWithFrame:CGRectMake(15, yyy, DEVICE_WIDTH-30, 45*approaxSize)];
    txtGroupName.placeholder = @"Enter Room name";
    txtGroupName.delegate = self;
    txtGroupName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtGroupName.textColor = [UIColor whiteColor];
    [txtGroupName setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    txtGroupName.autocorrectionType = UITextAutocorrectionTypeNo;
    txtGroupName.returnKeyType = UIReturnKeyDone;
    [APP_DELEGATE getPlaceholderText:txtGroupName andColor:[UIColor lightGrayColor]];

    txtGroupName.keyboardAppearance = UIKeyboardAppearanceAlert;
    [self.view addSubview:txtGroupName];
    
    UILabel * lblEmailLine = [[UILabel alloc] initWithFrame:CGRectMake(0, yyy+txtGroupName.frame.size.height-2, DEVICE_WIDTH, 1)];
    [lblEmailLine setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:lblEmailLine];
    
    yyy = yyy + 45*approaxSize;
    
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, yyy, DEVICE_WIDTH, DEVICE_HEIGHT-yyy) style:UITableViewStylePlain];
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblView.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:tblView];
    
    if (IS_IPHONE_X)
    {
        tblView.frame = CGRectMake(0, yyy, DEVICE_WIDTH, DEVICE_HEIGHT-yyy-44);
    }
    if (isfromEdit)
    {
        globalGroupId = [detailDict valueForKey:@"local_group_id"];
        txtGroupName.text = [detailDict valueForKey:@"group_name"];
        
        groupCount = [[detailDict valueForKey:@"local_group_id"] integerValue];
        
        NSString * tmpStr = [NSString stringWithFormat:@"select * from Group_Details_Table where group_id = '%@' and status = '1'",[detailDict valueForKey:@"local_group_id"]];
        NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
        [[DataBaseManager dataBaseManager] execute:tmpStr resultsArray:tmpArr];
        
        for (int k =0; k<[tmpArr count]; k++)
        {
            for (int i=0; i<[deviceListArray count]; i++)
            {
                NSString * str1 = [[[deviceListArray objectAtIndex:i] valueForKey:@"ble_address"] uppercaseString];
                NSString * str2 = [[[tmpArr objectAtIndex:k] valueForKey:@"ble_address"] uppercaseString];
                
                if ([str1 isEqualToString:str2])
                {
                    [[deviceListArray objectAtIndex:i] setObject:@"Yes" forKey:@"isSelected"];
                    [[deviceListArray objectAtIndex:i] setObject:@"1" forKey:@"wasAdded"];
                }
            }
        }
        [tblView reloadData];
    }
}
#pragma mark - Button Click
-(void)btnBackClick
{
    isOnAddGroup = NO;
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
    headerView.backgroundColor = [UIColor blackColor];

    UILabel *lblmenu=[[UILabel alloc]init];
    lblmenu.text = @" Tap to add device in Room.";
    [lblmenu setTextColor:[UIColor whiteColor]];
    [lblmenu setFont:[UIFont fontWithName:CGRegular size:textSizes-1]];
    lblmenu.frame = CGRectMake(7, 0,DEVICE_WIDTH-14,40);
//    lblmenu.layer.cornerRadius = 5;
//    lblmenu.layer.masksToBounds = YES;
//    lblmenu.backgroundColor = global_brown_color;
    [headerView addSubview:lblmenu];
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [deviceListArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReuseActivityCell"];
    if (cell==nil)
    {
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ReuseActivityCell"];
    }
    
    cell.lblConnect.text = @"Add";
    cell.lblDeviceName.frame = CGRectMake(65,12, DEVICE_WIDTH-70, 35);
    [cell.lblDeviceName setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];

//    cell.lblAddress.hidden = NO;
//    cell.lblAddress.text = @"NA";
    cell.imgIcon.hidden = NO;
    
    cell.lblDeviceName.font = [UIFont fontWithName:CGRegular size:textSizes+2];
//    cell.lblAddress.font = [UIFont fontWithName:CGRegular size:textSizes-1];
    cell.lblConnect.font = [UIFont fontWithName:CGRegular size:textSizes-1];
    
    cell.lblConnect.frame = CGRectMake(DEVICE_WIDTH-60, 0, DEVICE_WIDTH-60, 60);
    
    cell.lblDeviceName.text = [[deviceListArray objectAtIndex:indexPath.row] valueForKey:@"device_name"];;
//    cell.lblAddress.text = [[[deviceListArray objectAtIndex:indexPath.row] valueForKey:@"ble_address"] uppercaseString];
    
    if ([[[deviceListArray objectAtIndex:indexPath.row] valueForKey:@"isSelected"]  isEqualToString:@"No"])
    {
        cell.lblConnect.text = @"Add";
        [cell.lblConnect setTextColor:[UIColor whiteColor]];
    }
    else
    {
        cell.lblConnect.text = @"Remove";
        [cell.lblConnect setTextColor:[UIColor redColor]];
        cell.lblConnect.frame = CGRectMake(DEVICE_WIDTH-80, 0, DEVICE_WIDTH-60, 60);
    }
    cell.imgIcon.image = [UIImage imageNamed:@"default_pic.png"];
    NSString * strType = [[deviceListArray objectAtIndex:indexPath.row] valueForKey:@"device_type"];
    if ([strType isEqualToString:@"1"])
    {
        cell.imgIcon.image = [UIImage imageNamed:@"default_pic.png"];
    }
    else if ([strType isEqualToString:@"2"])
    {
        cell.imgIcon.image = [UIImage imageNamed:@"default_pic.png"];
    }
    else if ([strType isEqualToString:@"3"])
    {
        cell.imgIcon.image = [UIImage imageNamed:@"default_switch_icon.png"];
    }
//    else if ([strType isEqualToString:@"4"])
//    {
//        cell.imgIcon.image = [UIImage imageNamed:@"default_socket_icon.png"];
//    }
    else if ([strType isEqualToString:@"5"])
    {
        cell.imgIcon.image = [UIImage imageNamed:@"default_fan_icon.png"];
    }
    else if ([strType isEqualToString:@"6"])
    {
        cell.imgIcon.image = [UIImage imageNamed:@"stripwhite.png"];
    }
    else if ([strType isEqualToString:@"7"])
    {
        cell.imgIcon.image = [UIImage imageNamed:@"default_lamp.png"];
    }
    else if ([strType isEqualToString:@"8"])
    {
        cell.imgIcon.image = [UIImage imageNamed:@"default_powerstrip_icon.png"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (isfromEdit)
    {
        if ([deviceListArray count]>0)
        {
            if ([[[deviceListArray objectAtIndex:indexPath.row] valueForKey:@"wasAdded"]  isEqualToString:@"1"])
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeWarning];
                [alert addButton:@"Yes" withActionBlock:^{
                    
//                    if (globalPeripheral.state == CBPeripheralStateConnected)
                    {
                        [APP_DELEGATE startHudProcess:@"Removing device..."];
                        isForSingleRemove = YES;
                        isDeviceResponsed = NO;
                        [self performSelector:@selector(TimeoutForDeleteDevice) withObject:nil afterDelay:5];
                        selcedIndexx = indexPath.row;
                        sentHexId = [[deviceListArray objectAtIndex:selcedIndexx] valueForKey:@"hex_device_id"];
                        [self removeGroupWithGroupID:globalGroupId withDeviceID:[[deviceListArray objectAtIndex:selcedIndexx] valueForKey:@"device_id"] withHexID:[[deviceListArray objectAtIndex:selcedIndexx] valueForKey:@"hex_device_id"]];
                        // Put your action here
                    }
                    
                }];
                alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:@"Are you sure want to remove this device from Room ?"
                       withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
                   withDoneButtonTitle:@"No" andButtons:nil];
            }
            else
            {
                if ([[[deviceListArray objectAtIndex:indexPath.row] valueForKey:@"isSelected"]  isEqualToString:@"No"])
                {
                    [[deviceListArray objectAtIndex:indexPath.row] setValue:@"Yes" forKey:@"isSelected"];
                }
                else
                {
                    [[deviceListArray objectAtIndex:indexPath.row] setValue:@"No" forKey:@"isSelected"];
                }
            }
        }
    }
    else
    {
        if ([deviceListArray count]>0)
        {
            if ([[[deviceListArray objectAtIndex:indexPath.row] valueForKey:@"isSelected"]  isEqualToString:@"No"])
            {
                [[deviceListArray objectAtIndex:indexPath.row] setValue:@"Yes" forKey:@"isSelected"];
            }
            else
            {
                [[deviceListArray objectAtIndex:indexPath.row] setValue:@"No" forKey:@"isSelected"];
            }
        }
    }
   
    [tblView reloadData];
}

#pragma mark - Textfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - BLE Methods
-(void)InitialBLE
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallNotificationforAddGroups" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deviceDidDisConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deviceDidConnectNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CallNotificationforNonConnect:) name:@"CallNotificationforAddGroups" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidConnectNotification:) name:@"deviceDidConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidDisConnectNotification:) name:@"deviceDidDisConnectNotification" object:nil];
}
-(void)specificNotify:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
}

#pragma mark - SCANNED DEVICE AFTER SENT REQUEST RESULT APPEAR HERE...LOGIC TO CHECK SCANNED DEVICE
-(void)CallNotificationforNonConnect:(NSNotification*)notification//Update peripheral
{
    if (isForSingleRemove)
    {
        NSString * kpstr = (NSString*) notification.object;

        if ([kpstr rangeOfString:sentHexId].location == NSNotFound)
        {
        }
        else
        {
            if (isDeviceResponsed == YES)
            {
                
            }
            else
            {
                isDashScanning = NO;
                isDeviceResponsed = YES;
                [APP_DELEGATE endHudProcess];
                [[deviceListArray objectAtIndex:selcedIndexx] setObject:@"No" forKey:@"isSelected"];
                [[deviceListArray objectAtIndex:selcedIndexx] setObject:@"0" forKey:@"wasAdded"];
                
                NSString * strUpdate = [NSString stringWithFormat:@"delete from Group_Details_Table where group_id = '%@' and hex_device_id ='%@' ",globalGroupId,sentHexId];
                [[DataBaseManager dataBaseManager] execute:strUpdate];
                [tblView reloadData];
                
                [APP_DELEGATE hideScannerView];
                [APP_DELEGATE endHudProcess];
                strSentGroupHexID = [detailDict valueForKey:@"local_group_hex_id"];
                if ([IS_USER_SKIPPED isEqualToString:@"NO"])
                {
                    [self SaveGroupWebservice:globalGroupId hexId:strSentGroupHexID devName:strGroupTxt withCommandName:@"DeleteSingleDevice"];
                }
                else
                {
                    FCAlertView *alert = [[FCAlertView alloc] init];
                    alert.colorScheme = [UIColor blackColor];
                    [alert makeAlertTypeSuccess];
                    alert.tag = 222;
                    alert.delegate = self;
                    [alert showAlertInView:self
                                 withTitle:@"Smart Light"
                              withSubtitle:@"Device has been deleted successfully from Room."
                           withCustomImage:[UIImage imageNamed:@"logo.png"]
                       withDoneButtonTitle:nil
                                andButtons:nil];
                }

            }
        }
    }
    else
    {
        NSString * kpstr = (NSString*) notification.object;

        [self CallbackforGroupsDeviceAddedString:kpstr];
    }
}
-(void)CallbackforGroupsDeviceAddedString:(NSString *)kpstr
{
    kpstr = [kpstr stringByReplacingOccurrencesOfString:@" " withString:@""];
    kpstr = [kpstr stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    if ([kpstr rangeOfString:@"0900"].location == NSNotFound)
    {
    }
    else
    {
        for (int i =0; i<[groupDeviceSelectedArr count]; i++)
        {
            NSString * strCompare = [[groupDeviceSelectedArr objectAtIndex:i] valueForKey:@"hex_device_id"];
            if ([kpstr rangeOfString:strCompare].location == NSNotFound)
            {
            }
            else
            {
                if ([syncedArray count]==0)
                {
                    recieveCount = recieveCount + 1;
                    [syncedArray addObject:[[deviceListArray objectAtIndex:i] valueForKey:@"hex_device_id"]];
                }
                else
                {
                    if (![syncedArray containsObject:[[groupDeviceSelectedArr objectAtIndex:i] valueForKey:@"hex_device_id"]])
                    {
                        recieveCount = recieveCount + 1;
                        [syncedArray addObject:[[deviceListArray objectAtIndex:i] valueForKey:@"hex_device_id"]];
                    }
                }
            }
        }
    }
}

-(void)CallbackforGroupsDeviceAdded:(NSDictionary *)dict
{
    if(isSentForGroup)
    {
        NSData *nameData = [dict valueForKey:@"kCBAdvDataManufacturerData"];
        NSString * checkStr = [NSString stringWithFormat:@"%@",nameData.debugDescription];

        NSArray * tmpArr = [checkStr componentsSeparatedByString:@"0a00"];
        if ([tmpArr count]>1)
        {
            NSString * kpstr = [tmpArr objectAtIndex:1];
            if ([tmpArr count]>2)
            {
                NSRange range71 = NSMakeRange(4, [checkStr length]-4);
                kpstr = [checkStr substringWithRange:range71];
            }
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@" " withString:@""];
            kpstr = [kpstr stringByReplacingOccurrencesOfString:@">" withString:@""];
            
            if ([kpstr rangeOfString:@"0900"].location == NSNotFound)
            {
            }
            else
            {
                for (int i =0; i<[groupDeviceSelectedArr count]; i++)
                {
                    NSString * strCompare = [[groupDeviceSelectedArr objectAtIndex:i] valueForKey:@"hex_device_id"];
                    if ([kpstr rangeOfString:strCompare].location == NSNotFound)
                    {
                    }
                    else
                    {
                        if ([syncedArray count]==0)
                        {
                            recieveCount = recieveCount + 1;
                            [syncedArray addObject:[[deviceListArray objectAtIndex:i] valueForKey:@"hex_device_id"]];
                        }
                        else
                        {
                            if (![syncedArray containsObject:[[groupDeviceSelectedArr objectAtIndex:i] valueForKey:@"hex_device_id"]])
                            {
                                recieveCount = recieveCount + 1;
                                [syncedArray addObject:[[deviceListArray objectAtIndex:i] valueForKey:@"hex_device_id"]];
                            }
                        }
                        
                    }
                }
            }
        }
    }
    else
    {
        //        NSString * strDeviceID = [selectedDict valueForKey:@"device_id"];
        //        NSString * strGroupID = [selectedDict valueForKey:@"local_group_id"];
        //        NSString * strDelete = [NSString stringWithFormat:@"Delete from GroupsTable where device_id = '%@' and local_group_id = '%@'",strDeviceID,strGroupID];
        //        [[DataBaseManager dataBaseManager] execute:strDelete];
    }
}
#pragma mark - Webservice Methods
-(void)SaveGroupWebservice:(NSString *)devID hexId:(NSString*)hexId devName:(NSString *)name withCommandName:(NSString *)strCommand
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
        [dict setValue:devID forKey:@"local_group_id"];
        [dict setValue:hexId forKey:@"local_group_hex_id"];
        [dict setValue:txtGroupName.text forKey:@"group_name"];
        [dict setValue:@"1" forKey:@"status"];
        [dict setValue:@"2" forKey:@"is_favourite"];
        [dict setValue:@"0" forKey:@"is_update"];
        if (isfromEdit)
        {
            [dict setValue:@"1" forKey:@"is_update"];
        }
        NSString *deviceToken =deviceTokenStr;
        if (deviceToken == nil || deviceToken == NULL)
        {
            [dict setValue:@"123456789" forKey:@"device_token"];
        }
        else
        {
            [dict setValue:deviceToken forKey:@"device_token"];
        }
        NSMutableArray * arrDevices = [[NSMutableArray alloc] init];
        
        if (isfromEdit)
        {
            NSMutableArray * arrtmpdevice = [[NSMutableArray alloc] init];

            NSString * tmpStr = [NSString stringWithFormat:@"select * from Group_Details_Table where group_id = '%@' and status = '1' group by server_device_id",[detailDict valueForKey:@"local_group_id"]];
            [[DataBaseManager dataBaseManager] execute:tmpStr resultsArray:arrtmpdevice];
            for (int i = 0; i<[arrtmpdevice count]; i++)
            {
                NSString * strServerID = [[arrtmpdevice objectAtIndex:i] valueForKey:@"server_device_id"];
                [arrDevices addObject:strServerID];
            }
        }
        else
        {
            for (int i = 0; i<[groupDeviceSelectedArr count]; i++)
            {
                NSString * strServerID = [[groupDeviceSelectedArr objectAtIndex:i] valueForKey:@"server_device_id"];
                [arrDevices addObject:strServerID];
            }
            
        }
        NSString * deviceStr;
        if ([arrDevices count]==1)
        {
            deviceStr = [arrDevices objectAtIndex:0];
        }
        else
        {
            deviceStr = [arrDevices componentsJoinedByString:@","];
        }
        [dict setValue:deviceStr forKey:@"devices"];
        
        
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = strCommand;
        manager.delegate = self;
        NSString *strServerUrl = @"http://vithamastech.com/smartlight/api/save_group";
        [manager urlCall:strServerUrl withParameters:dict];
    }
    else
    {
        [APP_DELEGATE hideScannerView];
        [APP_DELEGATE endHudProcess];

        NSString * strMsg = @"Room has been created successfully.";
        if ([strCommand isEqualToString:@"DeleteSingleDevice"])
        {
            strMsg = @"Device has been deleted successfully from Room.";
        }
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeSuccess];
        alert.tag = 222;
        alert.delegate = self;
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:strMsg
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
}

#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE hideScannerView];
    [APP_DELEGATE endHudProcess];
//    NSLog(@"The result is...%@", result);
    if ([[result valueForKey:@"commandName"] isEqualToString:@"SaveGroup"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if ([[result valueForKey:@"message"] isEqualToString:@"Group already deleted"])
            {
                NSString * strDeleteGroup = [NSString stringWithFormat:@"delete from GroupsTable where local_group_id = '%@'",[[result valueForKey:@"data"]valueForKey:@"local_group_id"]];
                [[DataBaseManager dataBaseManager] execute:strDeleteGroup];
                
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                alert.tag = 222;
                alert.delegate = self;
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"Smart Light"
                          withSubtitle:@"This Room has been already deleted. Please create new Room."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else
            {
                if([[result valueForKey:@"result"] valueForKey:@"data"]!=[NSNull null] || [[result valueForKey:@"result"] valueForKey:@"data"] != nil)
                {
                    if ([[[result valueForKey:@"result"] valueForKey:@"data"] count]>0)
                    {
                        NSString * strServerId = [self checkforValidString:[[[[result valueForKey:@"result"] valueForKey:@"data"] objectAtIndex:0] valueForKey:@"device_group_id"]];
                        
                        NSString * strUserId = [[[[result valueForKey:@"result"] valueForKey:@"data"] objectAtIndex:0] valueForKey:@"user_id"];
                        
                        NSString * strDeviceId = [[[[result valueForKey:@"result"] valueForKey:@"data"] objectAtIndex:0] valueForKey:@"local_group_id"];
                        
                        NSString * strCreatedDate = [[[[result valueForKey:@"result"] valueForKey:@"data"] objectAtIndex:0] valueForKey:@"created_date"];
                        
                        NSString * strUpdatedDate = [[[[result valueForKey:@"result"] valueForKey:@"data"] objectAtIndex:0] valueForKey:@"updated_date"];
                        
                        NSString * strTimeStamp = [[[[result valueForKey:@"result"] valueForKey:@"data"] objectAtIndex:0] valueForKey:@"updated_date"];
                        
                        NSString * strGroupName = [[[[result valueForKey:@"result"] valueForKey:@"data"] objectAtIndex:0] valueForKey:@"group_name"];
                        
                        NSString * strFavorite = [[[[result valueForKey:@"result"] valueForKey:@"data"] objectAtIndex:0] valueForKey:@"is_favourite"];

                        NSString * strStatus = [[[[result valueForKey:@"result"] valueForKey:@"data"] objectAtIndex:0] valueForKey:@"status"];

                        
                        NSString * strQuery = [NSString stringWithFormat:@"update GroupsTable set server_group_id = '%@', created_date = '%@', updated_date = '%@', timestamp = '%@', is_sync = '1', is_added_firsttime = '2', group_name = \"%@\", is_favourite = \"%@\", status = \"%@\" where user_id = '%@' and local_group_id ='%@'",strServerId,strCreatedDate,strUpdatedDate,strTimeStamp,strGroupName, strFavorite, strStatus, strUserId, strDeviceId];
                        [[DataBaseManager dataBaseManager] execute:strQuery];
                        
                        NSString * strSubGroupQry = [NSString stringWithFormat:@"update Group_Details_Table set server_group_id = '%@', created_date = '%@','is_sync' = '1' where user_id = '%@' and group_id ='%@'",strServerId,strCreatedDate,strUserId, strDeviceId];
                        [[DataBaseManager dataBaseManager] execute:strSubGroupQry];
                        
                        [APP_DELEGATE endHudProcess];
                        if (isfromEdit)
                        {
                            [self ShowPopupofGroupCreatedwithMessage:@"Room has been updated successfully."];
                        }
                        else
                        {
                            [self ShowPopupofGroupCreatedwithMessage:@"Room has been created successfully."];
                        }
                    }
                    else
                    {
                        [APP_DELEGATE endHudProcess];
                        if (isfromEdit)
                        {
                            [self ShowPopupofGroupCreatedwithMessage:@"Room has been updated successfully."];
                        }
                        else
                        {
                            [self ShowPopupofGroupCreatedwithMessage:@"Room has been created successfully."];
                        }
                    }
                }
            }
        }
        else
        {
            [APP_DELEGATE endHudProcess];
            if (isfromEdit)
            {
                [self ShowPopupofGroupCreatedwithMessage:@"Room has been updated successfully."];
            }
            else
            {
                [self ShowPopupofGroupCreatedwithMessage:@"Room has been created successfully."];
            }
        }
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"DeleteSingleDevice"])
    {
        [APP_DELEGATE endHudProcess];
        [self ShowPopupofGroupCreatedwithMessage:@"Device has been deleted successfully from Room."];
    }
}
- (void)onError:(NSError *)error
{
    [APP_DELEGATE hideScannerView];
    [APP_DELEGATE endHudProcess];
    
//    NSLog(@"The error is...%@", error);
    
    NSInteger ancode = [error code];
    
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
//    NSLog(@"errorDict===%@",errorDict);
    
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009)
    {
//        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
    }
    else
    {
//        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
    }
    
    [APP_DELEGATE endHudProcess];
    
    [self ShowPopupofGroupCreatedwithMessage:@"Room has been created successfully."];

    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
//        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
    }
}

-(void)ShowPopupofGroupCreatedwithMessage:(NSString *)strMessage
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    alert.tag = 222;
    alert.delegate = self;
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:strMessage
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
#pragma mark - BLE EXTRA METHODS
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
-(NSString *)getHaxConvertedfromNormanlString:(NSString *)strNormal
{
    NSString * str = @"NA";
    
    NSString *hexStr = [NSString stringWithFormat:@"%lX",
                        (unsigned long)[strNormal integerValue]];
    
    unsigned long long startlong;
    NSScanner* scanner1 = [NSScanner scannerWithString:hexStr];
    [scanner1 scanHexLongLong:&startlong];
    double unixStart = startlong;
    NSNumber * startNumber = [[NSNumber alloc] initWithDouble:unixStart];
    NSInteger int71 = [startNumber integerValue];
    NSData * data71 = [[NSData alloc] initWithBytes:&int71 length:2];
//    NSLog(@"%@", [NSString stringWithFormat:@"%@", data71]);
    
    NSString * strFinal = [NSString stringWithFormat:@"%@", data71.debugDescription];
    strFinal = [strFinal stringByReplacingOccurrencesOfString:@" " withString:@""];
    strFinal = [strFinal stringByReplacingOccurrencesOfString:@">" withString:@""];
    strFinal = [strFinal stringByReplacingOccurrencesOfString:@"<" withString:@""];
    str = strFinal;
    return str;
}
#pragma mark - GROUPS METHODS
-(void)SaveGroupClick
{
//    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        if ([txtGroupName.text isEqualToString:@""])
        {
            NSString * strMsg = [NSString stringWithFormat:@"Please enter Room Name."];
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
        else
        {
            //    [APP_DELEGATE showScannerView:@"Saving Group...."];
            [txtGroupName resignFirstResponder];
            [APP_DELEGATE startHudProcess:@"Generating Room..."];
            if (isfromEdit)
            {
                [APP_DELEGATE startHudProcess:@"Updating Room..."];
            }
            isForSingleRemove = NO;
            if (isfromEdit)
            {
            }
            else
            {
                int randomValue = (arc4random() % 9999);
                groupCount =  randomValue;
                globalGroupId  =  [NSString stringWithFormat:@"%ld",(long)groupCount];
            }
            
            NSString * strGroupID = [NSString stringWithFormat:@"%@",globalGroupId];
            strSentGroupHexID = [self getHaxConvertedfromNormanlString:strGroupID];
            
            sentCount = 0;
            recieveCount = 0;
            groupDeviceSelectedArr  = [[NSMutableArray alloc] init];
            syncedArray = [[NSMutableArray alloc] init];
            
            BOOL isSelectedAny  =  NO;
            BOOL isAnyNewEdited  =  NO;
            
            for (int i=0; i<[deviceListArray count]; i++)
            {
                if ([[[deviceListArray objectAtIndex:i] valueForKey:@"isSelected"] isEqualToString:@"Yes"])
                {
                    isSelectedAny = YES;
                    if (isfromEdit)
                    {
                        if ([[[deviceListArray objectAtIndex:i] valueForKey:@"wasAdded"] isEqualToString:@"1"])
                        {
                        }
                        else
                        {
                            isAnyNewEdited = YES;
                            [groupDeviceSelectedArr addObject:[deviceListArray objectAtIndex:i]];
                        }
                    }
                    else
                    {
                        [groupDeviceSelectedArr addObject:[deviceListArray objectAtIndex:i]];
                    }
                }
            }
            if (isfromEdit == NO)
            {
                isAnyNewEdited = YES;
            }
            if (isSelectedAny)
            {
                if (isAnyNewEdited)
                {
                    [self sendDeviceonebyone];
                }
                else
                {
                    
                    if ([IS_USER_SKIPPED isEqualToString:@"NO"])
                    {
                        [self SaveGroupWebservice:globalGroupId hexId:strSentGroupHexID devName:strGroupTxt withCommandName:@"SaveGroup"];
                    }
                    else
                    {
                        [APP_DELEGATE hideScannerView];
                        [APP_DELEGATE endHudProcess];

                        FCAlertView *alert = [[FCAlertView alloc] init];
                        alert.colorScheme = [UIColor blackColor];
                        [alert makeAlertTypeSuccess];
                        alert.tag = 222;
                        alert.delegate = self;
                        [alert showAlertInView:self
                                     withTitle:@"Smart Light"
                                  withSubtitle:@"Room has been created successfully."
                               withCustomImage:[UIImage imageNamed:@"logo.png"]
                           withDoneButtonTitle:nil
                                    andButtons:nil];
                    }
                }
            }
            else
            {
                [APP_DELEGATE hideScannerView];
                [APP_DELEGATE endHudProcess];

                NSString * strMsg = [NSString stringWithFormat:@"Please add atleast one device to create Room."];
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
    }
    /*else
    {
        if (isfromEdit)
        {
            NSString * strUpdateGroup = [NSString stringWithFormat:@"Update GroupsTable set group_name ='%@' where local_group_id = '%@'",txtGroupName.text, globalGroupId];
            [[DataBaseManager dataBaseManager] execute:strUpdateGroup];
        }
        [self ConnectionValidationPopup];
    }*/
}
-(void)sendDeviceonebyone
{
    if ([groupDeviceSelectedArr count]> sentCount)
    {
        isSentForGroup = YES;
        isOnAddGroup = YES;

        [self AddGroupViaAdvertiseMentService:[[groupDeviceSelectedArr objectAtIndex:sentCount]valueForKey:@"device_id"]];//Advertise
        if (globalPeripheral.state == CBPeripheralStateConnected)
        {
            [self addGroupswithAddress:[[groupDeviceSelectedArr objectAtIndex:sentCount]valueForKey:@"device_id"]];
            [self addGroupswithAddress:[[groupDeviceSelectedArr objectAtIndex:sentCount]valueForKey:@"device_id"]];
        }
        sentCount = sentCount + 1;
        [self performSelector:@selector(sendDeviceonebyone) withObject:nil afterDelay:1];
    }
    else
    {
        [self performSelector:@selector(checkGroupforSave) withObject:nil afterDelay:2];
    }
}
-(void)AddGroupViaAdvertiseMentService:(NSString *)strDeviceId
{
    if (isfromEdit)
    {
        if (groupCount ==0)
        {
            NSString * strGroupLocal = [detailDict valueForKey:@"local_group_id"];
            groupCount = [strGroupLocal integerValue];
        }
    }
    [APP_DELEGATE sendSignalViaScan:@"AddGroupUUID" withDeviceID:strDeviceId withValue:[NSString stringWithFormat:@"%ld",(long)groupCount]];

}
-(void)addGroupswithAddress:(NSString *)strstring
{
    
    if (isfromEdit)
    {
        if (groupCount ==0)
        {
            NSString * strGroupLocal = [detailDict valueForKey:@"local_group_id"];
            groupCount = [strGroupLocal integerValue];
        }
    }
    
    NSInteger int1 = [@"50" integerValue];
    NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];
    
    globalCount = globalCount + 1;
    NSInteger int2 = globalCount;
    NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2];
    
    NSInteger int3 = [@"9000" integerValue];
    NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2];
    
    NSInteger int4 = [strstring integerValue];
    NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2];
    
    NSInteger int5 = [@"0" integerValue];
    NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2];
    
    NSInteger int6 = [@"8" integerValue];
    NSData * data6 = [[NSData alloc] initWithBytes:&int6 length:2];
    
    NSInteger int7 = [@"1" integerValue];
    NSData * data7 = [[NSData alloc] initWithBytes:&int7 length:1];
    
    NSData * data8 = [[NSData alloc] initWithBytes:&groupCount length:2];
    sentDeviceID = strstring;
    
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
    [completeData appendData:checksumData]; //Updated CRC
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
-(void)checkGroupforSave
{
    /*    if (sentCount == recieveCount)
     {
     
     }
     else
     {
     
     NSString * strMessage = [NSString stringWithFormat:@"There is only %d devices added in group out of %ld. Please make sure that other devices are near by. Do you want to continue with this Group ?",checkSyncedCount,(long)sentCount];
     FCAlertView *alert = [[FCAlertView alloc] init];
     alert.colorScheme = [UIColor blackColor];
     [alert makeAlertTypeCaution];
     [alert showAlertInView:self
     withTitle:@"Smart Light"
     withSubtitle:strMessage
     withCustomImage:[UIImage imageNamed:@"logo.png"]
     withDoneButtonTitle:nil
     andButtons:nil];
     }*/
    
    
    if (recieveCount == 0)
    {
        [APP_DELEGATE endHudProcess];
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"Smart Light"
                  withSubtitle:@"Something went wrong. Please try again."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
    else
    {
        isOnAddGroup = NO;

        NSString * groupHexID;
        
        NSString * strGroupID = [NSString stringWithFormat:@"%@",globalGroupId];
        groupHexID = strSentGroupHexID;
        int groupTblID;
        NSString * strGrpTblID;
        if (isfromEdit)
        {
            NSString * strUpdateGroup = [NSString stringWithFormat:@"Update GroupsTable set group_name =  \"%@\", is_sync = '0' where local_group_id = '%@'",txtGroupName.text, strGroupID];
            [[DataBaseManager dataBaseManager] execute:strUpdateGroup];
            strGrpTblID = [detailDict valueForKey:@"id"];
        }
        else
        {
            NSString * strGroup = [NSString stringWithFormat:@"insert into 'GroupsTable'('group_name','user_id','local_group_id','local_group_hex_id','status','switch_status','is_sync','is_favourite','is_added_firsttime') values( \"%@\",'%@','%@','%@',\"%@\",\"%@\",'%@','%@','%@')",txtGroupName.text,CURRENT_USER_ID,strGroupID,groupHexID,@"1",@"1",@"0",@"2",@"1"];
            groupTblID =  [[DataBaseManager dataBaseManager] executeSw:strGroup];
            strGrpTblID = [NSString stringWithFormat:@"%d",groupTblID];
        }
        
        int checkSyncedCount = 0;
        for (int i = 0; i<[groupDeviceSelectedArr count]; i++)
        {
            checkSyncedCount = checkSyncedCount + 1;
            NSString * strGroupID = [NSString stringWithFormat:@"%@",globalGroupId];
            NSString * strHex = [[groupDeviceSelectedArr objectAtIndex:i] valueForKey:@"hex_device_id"];
            NSString * strDeviceId = [[groupDeviceSelectedArr objectAtIndex:i] valueForKey:@"device_id"];
            NSString * strDeviceName = [[groupDeviceSelectedArr objectAtIndex:i] valueForKey:@"device_name"];
            NSString * strBleAddress = [[[groupDeviceSelectedArr objectAtIndex:i] valueForKey:@"ble_address"] uppercaseString];
            NSString * strDeviceTypes = [[groupDeviceSelectedArr objectAtIndex:i] valueForKey:@"device_type"];
            NSString * strDeviceTypeName = [[groupDeviceSelectedArr objectAtIndex:i] valueForKey:@"device_type_name"];
            NSString * strServerDeviceID = [[groupDeviceSelectedArr objectAtIndex:i] valueForKey:@"server_device_id"];

            NSString * insrtStr = [NSString stringWithFormat:@"insert into 'Group_Details_Table'('group_table_id','group_id','device_id','hex_device_id','ble_address','device_type','device_type_name','user_id','status','device_name','is_sync','server_device_id') values('%@','%@','%@','%@',\"%@\",\"%@\",'%@','%@','%@','%@','0','%@')",strGrpTblID,strGroupID,strDeviceId,strHex,strBleAddress,strDeviceTypes, strDeviceTypeName,CURRENT_USER_ID,@"1",strDeviceName,strServerDeviceID];
            [[DataBaseManager dataBaseManager] execute:insrtStr];
        }
        if ([IS_USER_SKIPPED isEqualToString:@"NO"])
        {
            [self SaveGroupWebservice:globalGroupId hexId:groupHexID devName:strGroupTxt withCommandName:@"SaveGroup"];
        }
        else
        {
            [APP_DELEGATE hideScannerView];
            [APP_DELEGATE endHudProcess];
            
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeSuccess];
            alert.tag = 222;
            alert.delegate = self;
            [alert showAlertInView:self
                         withTitle:@"Smart Light"
                      withSubtitle:@"Room has been created successfully."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
    
}
-(void)removeGroupwithAlldevices
{
    for (int i=0; i<[deviceListArray count]; i++)
    {
        NSString * strSingleDevice = [[deviceListArray objectAtIndex:i] valueForKey:@"device_id"];
        
        NSInteger int1 = [@"50" integerValue];
        NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];
        
        globalCount = globalCount + 1;
        NSInteger int2 = globalCount;
        NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2];
        
        NSInteger int3 = [@"9000" integerValue];
        NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2];
        
        NSInteger int4 = [strSingleDevice integerValue];// Device ID
        NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2];
        
        NSInteger int5 = [@"0" integerValue];
        NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2];
        
        NSInteger int6 = [@"10" integerValue];
        NSData * data6 = [[NSData alloc] initWithBytes:&int6 length:2];
        
        NSInteger int7 = [@"1" integerValue];
        NSData * data7 = [[NSData alloc] initWithBytes:&int7 length:1];
        
        NSInteger int8 = [globalGroupId integerValue]; // Group ID
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
        [completeData appendData:checksumData]; //Updated CRC
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

        [APP_DELEGATE sendSignalViaScan:@"DeleteGroupUUID" withDeviceID:strSingleDevice withValue:globalGroupId]; //KalpeshScanCode
        if (globalPeripheral.state == CBPeripheralStateConnected)
        {
            [[BLEService sharedInstance] writeValuetoDeviceMsg:requestData with:globalPeripheral];
            [[NSUserDefaults standardUserDefaults] setInteger:globalCount forKey:@"GlobalCount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

-(void)askPermissiontoDeleteGroup
{
    NSString * deviceName = [selectedDict valueForKey:@"device_name"];
    NSString * msgStr = [NSString stringWithFormat:@"Are you sure want to delete %@ from this Room ?",deviceName];
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    [alert addButton:@"Yes" withActionBlock:^{
        NSString * strGroup = [selectedDict valueForKey:@"local_group_id"];
        NSString * strDeviceID = [selectedDict valueForKey:@"device_id"];
        NSString * strHexID = [selectedDict valueForKey:@"hex_device_id"];
        [self removeGroupWithGroupID:strGroup withDeviceID:strDeviceID withHexID:strHexID];

    }];
    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSizes];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:msgStr
           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
       withDoneButtonTitle:@"No" andButtons:nil];
}
-(void)removeGroupWithGroupID:(NSString *)strGroupID withDeviceID:(NSString *)strDeviceID withHexID:(NSString *)haxID
{
    isOnAddGroup = YES;
    NSString * strSingleDevice = strDeviceID;
    [APP_DELEGATE sendSignalViaScan:@"DeleteGroupUUID" withDeviceID:strSingleDevice withValue:globalGroupId]; //KalpeshScanCode

    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        NSInteger int1 = [@"50" integerValue];
        NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];
        
        globalCount = globalCount + 1;
        NSInteger int2 = globalCount;
        NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:2];
        
        NSInteger int3 = [@"9000" integerValue];
        NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:2];
        
        NSInteger int4 = [strSingleDevice integerValue];
        NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:2];
        
        NSInteger int5 = [@"0" integerValue];
        NSData * data5 = [[NSData alloc] initWithBytes:&int5 length:2];
        
        NSInteger int6 = [@"10" integerValue];
        NSData * data6 = [[NSData alloc] initWithBytes:&int6 length:2];
        
        NSInteger int7 = [@"1" integerValue];
        NSData * data7 = [[NSData alloc] initWithBytes:&int7 length:1];
        
        NSInteger int8 = [globalGroupId integerValue];
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
        [completeData appendData:checksumData]; //Updated CRC
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
        globalDeviceHexId = haxID;
        [[BLEService sharedInstance] writeValuetoDeviceMsg:requestData with:globalPeripheral];
        [[NSUserDefaults standardUserDefaults] setInteger:globalCount forKey:@"GlobalCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(void)TimeoutForDeleteDevice
{
    [APP_DELEGATE endHudProcess];
    if (isDeviceResponsed == YES)
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
    isDeviceResponsed = NO;
}
-(void)ConnectionValidationPopup
{
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeCaution];
    [alert showAlertInView:self
                 withTitle:@"Smart Light"
              withSubtitle:@"Your IOS device is not connected with SmartLight device. Please connect first with device."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
    
}
#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 222)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
}
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
