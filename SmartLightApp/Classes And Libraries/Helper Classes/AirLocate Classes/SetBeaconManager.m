//
//  SetBeaconManager.m
//  AirLocateDemo
//
//  Created by Kalpesh Panchasara on 12/3/14.
//  Copyright (c) 2014 Kalpesh Panchasara. All rights reserved.
//

#import "SetBeaconManager.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

SetBeaconManager * sharedInstance = nil;

CBPeripheralManager *peripheralManager = nil;
NSNumber *power = nil;


@implementation SetBeaconManager
@synthesize region;
-(id)init
{
    self = [super init];
    
    if (self) {
        [self initializeDeviceAsBeaconService];
    }
    return self;
}

+(SetBeaconManager*)sharedManager
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[SetBeaconManager alloc] init];
    }
    return sharedInstance;
}

-(void)initializeDeviceAsBeaconService
{
//    if(region)
//    {
//        self.uuid = region.proximityUUID;
//        self.major = region.major;
//        self.minor = region.minor;
//    }
//    else
//    {
//        self.uuid = [[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"globalUUID"]];
//        self.major = [NSNumber numberWithShort:0];
//        self.minor = [NSNumber numberWithShort:10];
//    }
    
    if(!power)
    {
        power = [APLDefaults sharedDefaults].defaultPower;
    }

    if (!peripheralManager)
    {
//        NSLog(@"Here its Initialzed once");
        peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        peripheralManager.delegate = self;
    }
    else
    {
        peripheralManager.delegate = self;
    }
    
    // Refresh the enabled switch.
    self.enabled = YES;
}

-(void)stopService
{
    [peripheralManager stopAdvertising];
    peripheralManager.delegate = nil;
    peripheralManager=nil;
    region=nil;
    
//    NSLog(@"Beacon Stopped here =%@",peripheralManager);
}

#pragma mark Peripheral manager delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
    // Opt out from any other state
    if (peripheralManager.state != CBPeripheralManagerStatePoweredOn)
    {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
//    NSLog(@"self.peripheralManager powered on.");
//    NSLog(@"peripheralManager.state=>%ld",(long)peripheralManager.state);
    // ... so build our service.
    
    [self updateAdvertisedRegion];
}

- (void)updateAdvertisedRegion
{
//    NSLog(@"BEACON UPDATING HERE =%@",peripheralManager);
//    NSLog(@"peripheralManager.state==%ld",(long)peripheralManager.state);
//    NSLog(@"CBPeripheralManagerStatePoweredOn==%ld",(long)CBPeripheralManagerStatePoweredOn);
    
    if (peripheralManager == nil)
    {
        [self initializeDeviceAsBeaconService];
    }
    if(peripheralManager.state < CBPeripheralManagerStatePoweredOn)
    {
//        NSString *title = NSLocalizedString(@"Bluetooth must be enabled", @"");
//        NSString *message = NSLocalizedString(@"To configure your device as a beacon", @"");
//        NSString *cancelButtonTitle = NSLocalizedString(@"OK", @"Cancel button title in configuration Save Changes");
//        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
//        [errorAlert show];
        return;
    }
    
    [peripheralManager stopAdvertising];
    
    if(self.enabled)
    {
        // We must construct a CLBeaconRegion that represents the payload we want the device to beacon.
        NSDictionary *peripheralData = nil;
        
//        NSLog(@"Sent UUID =%@",self.uuid);

        region = [[CLBeaconRegion alloc] initWithProximityUUID:self.uuid major:[self.major shortValue] minor:[self.minor shortValue] identifier:@"Kp's iPad"];
        peripheralData = [region peripheralDataWithMeasuredPower:power];
        
        // The region's peripheral data contains the CoreBluetooth-specific data we need to advertise.
        if(peripheralData)
        {
            [peripheralManager startAdvertising:peripheralData];
//            tmr = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(stopAdv) userInfo:nil repeats:YES];
//            [self performSelector:@selector(stopAdv) withObject:nil afterDelay:.5];
            [self performSelector:@selector(stopAdv) withObject:nil afterDelay:5];

        }
    }
}
-(void)stopAdv
{
    if (isChanged)
    {
        
    }
    else
    {
        [peripheralManager stopAdvertising];
    }
}

@end
