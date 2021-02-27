//
//  GetBeaconManager.h
//  AirLocateDemo
//
//  Created by Kalpesh Panchasara on 12/3/14.
//  Copyright (c) 2014 Kalpesh Panchasara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APLDefaults.h"
@import CoreLocation;

#import "AppDelegate.h"
@interface GetBeaconManager : NSObject<CLLocationManagerDelegate>
{
}

+(GetBeaconManager*)sharedManager;

-(void)initializeGetDeviceService;
-(void)stopService;

@property NSMutableDictionary *beacons;
@property CLLocationManager *locationManager;
@property NSMutableDictionary *rangedRegions;
@property NSMutableArray * mybeaconArr;//kp612



@end
