//
//  GetBeaconManager.m
//  AirLocateDemo
//
//  Created by Kalpesh Panchasara on 12/3/14.
//  Copyright (c) 2014 Kalpesh Panchasara. All rights reserved.
//

#import "GetBeaconManager.h"
#import "Constant.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


GetBeaconManager * sharedGetInstance = nil;

@implementation GetBeaconManager

-(id)init
{
    self = [super init];
    
    if (self) {
        [self initializeGetDeviceService];
    }
    return self;
}

+(GetBeaconManager*)sharedManager
{
    if (sharedGetInstance==nil)
    {
        sharedGetInstance = [[GetBeaconManager alloc] init];
    }
    return sharedGetInstance;
}

-(void)initializeGetDeviceService
{
    self.beacons = [[NSMutableDictionary alloc] init];
    
    [locationManager stopUpdatingLocation];
    
    // This location manager will be used to demonstrate how to range beacons.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
        //        [locationManager1 requestWhenInUseAuthorization];
    }
    else
    {
        [self.locationManager startUpdatingLocation];
    }
    [self.locationManager startUpdatingLocation];
    
    
    // Populate the regions we will range once.
    self.rangedRegions = [[NSMutableDictionary alloc] init];
    
    
    // Start ranging when the view appears.
    for (CLBeaconRegion *region in self.rangedRegions)
    {
        [self.locationManager startRangingBeaconsInRegion:region];
        if(IS_OS_8_OR_LATER)
        {
            [self.locationManager requestAlwaysAuthorization];
            //        [locationManager1 requestWhenInUseAuthorization];
        }
    }
    
    
//    NSUUID * uuid = [[NSUUID alloc] initWithUUIDString:@"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"];
//    
//    CLBeaconRegion * beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.example.apple-samplecode.AirLocate"];
//    [self.locationManager startRangingBeaconsInRegion:beaconRegion];
    
}

-(void)stopService
{
    // Stop ranging when the view goes away.
    
    for (CLBeaconRegion *region in self.rangedRegions)
    {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
    
    sharedGetInstance =nil;

}

#pragma mark - Location manager delegate
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    /*
     CoreLocation will call this delegate method at 1 Hz with updated range information.
     Beacons will be categorized and displayed by proximity.  A beacon can belong to multiple
     regions.  It will be displayed multiple times if that is the case.  If that is not desired,
     use a set instead of an array.
     */
    
    if ([beacons count]==0)
    {
        
    }
    else
    {
//        [self stopService];
    }
    
    self.rangedRegions[region] = beacons;
    [self.beacons removeAllObjects];
    
    NSMutableArray *allBeacons = [NSMutableArray array];
    
    for (NSArray *regionResult in [self.rangedRegions allValues])
    {
        [allBeacons addObjectsFromArray:regionResult];
    }
    
    self.mybeaconArr=[[NSMutableArray alloc] init];//kp612
    self.mybeaconArr=allBeacons;
    
    if ([self.mybeaconArr count]==0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UUIDChanged" object:nil];
        
    }
    else
    {
        NSInteger totalUser =[self.mybeaconArr count];
        NSInteger previousTotal =[[NSUserDefaults standardUserDefaults] integerForKey:@"previousoTotal"];
        
        if (totalUser<previousTotal)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UUIDChanged" object:nil];
        }
        else if (totalUser>previousTotal)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UUIDChanged" object:nil];
            
        }
        else
        {
            
        }
        [[NSUserDefaults standardUserDefaults] setInteger:totalUser forKey:@"previousoTotal"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
    }

    
    for (NSNumber *range in @[@(CLProximityUnknown), @(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar)])
    {
        NSArray *proximityBeacons = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", [range intValue]]];
        if([proximityBeacons count])
        {
            self.beacons[range] = proximityBeacons;
        }
    }
}

@end
