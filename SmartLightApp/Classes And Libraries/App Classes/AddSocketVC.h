//
//  AddSocketVC.h
//  SmartLightApp
//
//  Created by Kalpesh Panchasara on 06/01/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMPullToRefreshManager.h"
#import <CocoaMQTT/CocoaMQTT.h>


@import CocoaMQTT;

NS_ASSUME_NONNULL_BEGIN

@interface AddSocketVC : UIViewController
{
        NSTimer * connectionTimer, * advertiseTimer, * disconnectionTimer;
        CBCentralManager * centralManager;
        CBPeripheral * classPeripheral;
        NSMutableDictionary * dictSwState;
        
//        MQTTSession *session;
//        MQTTCFSocketTransport *transport;
//        MQTTCFSocketDecoderState * state;
        
        UIView * viewForTxtBg,*viewTxtfld,*viewSSIDback,*viewSSIDList;
        UITextField * txtDeviceName,* txtRouterName,* txtRouterPassword;
        NSString * strSSID;
        
        UIImageView *imgNotConnected;
        UITableView *tblSSIDList;
        NSMutableArray * arrayWifiavl;
        
        CocoaMQTT * mqttObj;
        NSString * strCurrentTopic;
        NSString * strMckAddress;
        int globalStatusHeight;

        UITableView * tblDeviceList;
         UILabel *lblNoDevice,*lblError ,* lblScanning;
        MNMPullToRefreshManager * topPullToRefreshManager;


}

-(void)AuthenticationCompleted:(CBPeripheral *)peripheral;
-(void)ReceivedSwitchStatusfromDevice:(NSMutableDictionary *)dictSwitch;
-(void)ShowNowifiAvailablePopUP;
-(void)AssociationCompleted:(BOOL)isSucess;
-(void)ConfirmDeviceRecievedWifiConfiguredStatus:(NSString *)strStatus;

@end

NS_ASSUME_NONNULL_END
