//
//  SetBeaconManager.h
//  AirLocateDemo
//
//  Created by Kalpesh Panchasara on 12/3/14.
//  Copyright (c) 2014 Kalpesh Panchasara. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
@import CoreBluetooth;

#import "APLDefaults.h"

@interface SetBeaconManager : NSObject<CBPeripheralManagerDelegate>
{
    NSTimer * tmr;
}

@property BOOL enabled;
@property NSUUID *uuid;
@property NSNumber *major;
@property NSNumber *minor;
@property CLBeaconRegion *region;

+(SetBeaconManager*)sharedManager;

- (void)updateAdvertisedRegion;

-(void)initializeDeviceAsBeaconService;

-(void)stopService;

-(void)stopAdv;

@end
