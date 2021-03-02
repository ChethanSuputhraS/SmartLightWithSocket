//
//  BLEService.m
//
//
//  Created by Kalpesh Panchasara on 7/11/14.
//  Copyright (c) 2014 Kalpesh Panchasara, Ind. All rights reserved.
//

#import "BLEService.h"
#import "BLEManager.h"

#import "AppDelegate.h"

#import "DataBaseManager.h"

#define TI_KEYFOB_LEVEL_SERVICE_UUID                        0x2A19
#define TI_KEYFOB_BATT_SERVICE_UUID                         0x180F
#define TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN                 1
#define TI_KEYFOB_PROXIMITY_ALERT_UUID                      0x1802
#define TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID             0x2a06


/*-----kp--------*/
#define CPTD_SERVICE_UUID_STRING                              @"0000AB00-0100-0800-0008-05F9B34FB000"
#define CPTD_CHARACTERISTIC_COMM_CHAR                         @"0505A101-D102-11E1-9B23-00025B002B2B"
#define CPTD_CHARACTERISTICS_DATA_CHAR                        @"0000AB01-0100-0800-0008-05F9B34FB000"

// socket
#define CPTD_SERVICE_UUID_SKT                              @"0000AB01-2687-4433-2208-ABF9B34FB000"
#define CPTD_CHARACTERISTIC_SKT                            @"0000AB00-2687-4433-2208-ABF9B34FB000"
//0001D100AB0011E19B2300025B00A5A5

#define CKPTD_SERVICE_UUID_STRING                             @"0000D100-AB00-11E1-9B23-00025B00A5A5"
#define CKPTD_CHARACTERISTICS_DATA_CHAR                       @"0001D100-AB00-11E1-9B23-00025B00A5A5"
#define CKPTD_CHARACTERISTICS_DATA_CHAR1                      @"0002D100-AB00-11E1-9B23-00025B00A5A5"
#define CKPTD_CHARACTERISTICS_DATAAUTH                        @"0002D200-AB00-11E1-9B23-00025B00A5A5"
#define UUID_SMART_MESH_FACTORY_RESET_CHAR                    @"0003D100-AB00-11E1-9B23-00025B00A5A5" //0x0002D100AB0011E19B2300025B00A5A5

//#define CKPTD_SERVICE_UUID_STRING1                             @"0000AB00-0100-0800-0008-05F9B34FB000"
//#define CKPTD_CHARACTERISTICS_DATA_CHAR1                       @"0000AB02-0100-0800-0008-05F9B34FB000"
//
//#define CKPTD_SERVICE_UUID_STRING3                             @"0000AB00-0100-0800-0008-05F9B34FB000"
//#define CKPTD_CHARACTERISTICS_DATA_CHAR3                       @"0000AB03-0100-0800-0008-05F9B34FB000"
//
//#define CKPTD_SERVICE_UUID_STRING4                             @"0000AB00-0100-0800-0008-05F9B34FB000"
//#define CKPTD_CHARACTERISTICS_DATA_CHAR4                       @"0000ab04-0100-0800-0008-05F9B34FB000"

static BLEService    *sharedInstance    = nil;

@interface BLEService ()<CBPeripheralDelegate,AVAudioPlayerDelegate>
{
    NSMutableArray *assignedDevices;
    AVAudioPlayer *songAlarmPlayer1;
    BOOL isCannedMsg,isforAuth;
    NSTimer * timerForwifi;
    NSMutableArray * arrWifiList;
    NSInteger wifiPasswordTotalPackets;

}
@property (nonatomic, strong) CBPeripheral *servicePeripheral;
@property (nonatomic,strong) NSMutableArray *servicesArray;
@end

@implementation BLEService
@synthesize servicePeripheral, addSocketdelegate;

#pragma mark- Self Class Methods
-(id)init{
    self = [super init];
    if (self) {
        //do additional work
        arrWifiList = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    if (!sharedInstance)
        sharedInstance = [[BLEService alloc] init];
    
    return sharedInstance;
}

-(id)initWithDevice:(CBPeripheral*)device andDelegate:(id /*<BLEServiceDelegate>*/)delegate{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
        [device setDelegate:self];
        //        [servicePeripheral setDelegate:self];
        servicePeripheral = device;
    }
    return self;
}

-(void)startDeviceService:(CBPeripheral *)kpb
{
    [servicePeripheral discoverServices:@[[CBUUID UUIDWithString:@"0000AB00-0100-0800-0008-05F9B34FB000"]]];
    
    //    [servicePeripheral discoverServices:[CBUUID UUIDWithString:@"0000AB00-0100-0800-0008-05F9B34FB000"]];
}

-(void) readDeviceBattery:(CBPeripheral *)device
{
    
    if (device.state != CBPeripheralStateConnected)
    {
        return;
    }
    else
    {
        [self notification:TI_KEYFOB_BATT_SERVICE_UUID characteristicUUID:TI_KEYFOB_LEVEL_SERVICE_UUID p:device on:YES];
    }
}

-(void)readDeviceRSSI:(CBPeripheral *)device
{
    if (device.state == CBPeripheralStateConnected)
    {
        [device readRSSI];
    }
    else
    {
        return;
    }
}

-(void)startBuzzer:(CBPeripheral*)device
{
//    NSLog(@"startBuzzer called");
//    NSLog(@"startBuzzer called with device ==%@",device);
    if (device == nil || device.state != CBPeripheralStateConnected)
    {
        return;
    }
    else
    {
//        NSLog(@"startBuzzer==0x10");
        [self soundBuzzer:0x06 peripheral:device];
        //to know, from which OS the device has been connected i.e., iOS/Android
        //        [self soundBuzzer:0x0D peripheral:device];
    }
}

-(void)stopBuzzer:(CBPeripheral*)device{
    if (device == nil || device.state != CBPeripheralStateConnected)
    {
        return;
    }
    else
    {
        [self soundBuzzer:0x07 peripheral:device];
    }
}


#pragma mark- CBPeripheralDelegate
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSArray        *services    = nil;
    if (peripheral != servicePeripheral)
    {
//        NSLog(@"Wrong Peripheral.\n");
        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEConnectionErrorPopup" object:nil];
        return ;
    }
    
    if (error != nil)
    {
//        NSLog(@"Error %@\n", error);
        return ;
    }
    
    services = [peripheral services];
    
    if (!services || ![services count])
    {
        return ;
    }
    
    if (!error)
    {
        [self getAllCharacteristicsFromKeyfob:peripheral];
    }
    else
    {
//        printf("Service discovery was unsuccessfull !\r\n");
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    NSArray        *characteristics    = [service characteristics];
//    NSLog(@"didDiscoverCharacteristicsForService %@",characteristics);
    CBCharacteristic *characteristic;
    
    if (peripheral != servicePeripheral) {
        //NSLog(@"didDiscoverCharacteristicsForService Wrong Peripheral.\n");
        return ;
    }
    
    if (error != nil) {
        //NSLog(@"didDiscoverCharacteristicsForService Error %@\n", error);
        return ;
    }
    
    for (characteristic in characteristics)
    {
        UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
        
        switch(characteristicUUID){
            case TI_KEYFOB_LEVEL_SERVICE_UUID:
            {
                char batlevel;
                [characteristic.value getBytes:&batlevel length:1];
                if (_delegate) {
                    [_delegate activeDevice:peripheral];
                    NSString *battervalStr = [NSString stringWithFormat:@"%f",(float)batlevel];
//                    NSLog(@"battervalStr=====%@",battervalStr);
                    [_delegate batterySignalValueUpdated:peripheral withBattLevel:battervalStr];
                }
                //sending code to identify the from which app it has benn connected i.e, either Find App/others....
                [self soundBuzzer:0x0E peripheral:peripheral];
                
                //to know, from which OS the device has been connected i.e., iOS/Android
                [self soundBuzzer:0x0D peripheral:peripheral];
                break;
            }
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //Kalpesh here notification will come
//    NSLog(@"Kalpesh ====>>>>  didUpdateValueForCharacteristic==%@",characteristic);
    
    NSString * checkNameStr = [NSString stringWithFormat:@"%@",peripheral.name];
    if ([checkNameStr rangeOfString:@"Vithamas"].location != NSNotFound)
    {
        NSString * strUUID = [NSString stringWithFormat:@"%@",characteristic.UUID];
        if ([strUUID isEqualToString:@"0001D100-AB00-11E1-9B23-00025B00A5A5"])//For Authentication 0002D100-AB00-11E1-9B23-00025B00A5A5
        {
            NSData * valData = characteristic.value;

            NSString * valueStr = [NSString stringWithFormat:@"%@",valData.debugDescription];
            valueStr = [valueStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            valueStr = [valueStr stringByReplacingOccurrencesOfString:@">" withString:@""];
            valueStr = [valueStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
            
            NSLog(@"Key Value=%@/n",valueStr);
            NSString * strinfromHex = [self stringFroHex:valueStr];
            NSLog(@"String from Hex Value=%@/n",strinfromHex);
            
            NSInteger  valuInt = [self convertAlgo:[strinfromHex integerValue]];
            NSLog(@"Final Int Value=%ld/n",(long)valuInt);
            
            [self sendBackAuth:peripheral withValue:[NSString stringWithFormat:@"%ld",(long)valuInt]];
            isforAuth = NO;
        }
        else // For Factory Reset
        {
            NSData * valData = characteristic.value;
            NSString * valueStr = [NSString stringWithFormat:@"%@",valData.debugDescription];
            valueStr = [valueStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            valueStr = [valueStr stringByReplacingOccurrencesOfString:@">" withString:@""];
            valueStr = [valueStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
            NSString * strinfromHex = [self stringFroHex:valueStr];
            NSInteger  valuInt = [self AlgorithmforFactoryReset:[strinfromHex integerValue]];
            [self sendFactoryResetCommand:peripheral withValue:[NSString stringWithFormat:@"%ld",(long)valuInt]];
            isforAuth = NO;
        }
    }
    else if ([checkNameStr rangeOfString:@"V"].location != NSNotFound)
    {
        [self Socket_peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    }
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
//    NSLog(@"didUpdateNotificationStateForCharacteristic =%@",characteristic);
    //    [self readValue:TI_KEYFOB_BATT_SERVICE_UUID characteristicUUID:TI_KEYFOB_LEVEL_SERVICE_UUID p:peripheral];
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
//    NSLog(@"peripheralDidUpdateRSSI peripheral.name ==%@ ::RSSI ==%f, error==%@",peripheral.name,[peripheral.RSSI doubleValue],error);
    
    if (error == nil)
    {
        if(peripheral == nil)
            return;
        
        if (peripheral != servicePeripheral)
        {
//            NSLog(@"Wrong peripheral\n");
            return ;
        }
        
        if (peripheral==servicePeripheral)
        {
            if (_delegate) {
                //            [_delegate updateSignalImage:[[peripheral RSSI] intValue] forDevice:peripheral];
                [_delegate updateSignalImage:[peripheral.RSSI doubleValue] forDevice:peripheral];
            }
            
            //            rssiValue = [peripheral.RSSI doubleValue];
            //            NSLog(@"rssiValue peripheralDidUpdateRSSI =====================================================>>%f",rssiValue);
            
            if (peripheral.state == CBPeripheralStateConnected)
            {
                /*  if (rssiValue !=0)
                 {
                 if ([Range_Alert_Value integerValue]<40)
                 {
                 if (rssiValue < -55)
                 {
                 [self playSoundWhenDeviceRSSIisLow];
                 }
                 }
                 else if ([Range_Alert_Value integerValue]>=40 && [Range_Alert_Value integerValue]<90)
                 {
                 if (rssiValue < -80)
                 {
                 [self playSoundWhenDeviceRSSIisLow];
                 }
                 }
                 else if([Range_Alert_Value integerValue]>90)
                 {
                 if (rssiValue < -96)
                 {
                 //                            [self stopPlaySound];
                 [self playSoundWhenDeviceRSSIisLow];
                 }
                 }
                 }
                 else
                 {
                 // [self playSoundWhenDeviceRSSIisLow]; //comment due to app is randomly beep when rssi is 0
                 }*/
                
                
                
                /* if (rssiValue !=0)
                 {
                 if (rssiValue >= -74)
                 {
                 [self stopPlaySound];
                 }
                 else if(rssiValue <=-75 && rssiValue >=-84 )
                 {
                 [self stopPlaySound];
                 }
                 else if(rssiValue <=-84 && rssiValue >=-89)
                 {
                 [self stopPlaySound];
                 //                        [self playSoundWhenDeviceRSSIisLow];
                 }
                 else if(rssiValue <=-90 && rssiValue >=-95)
                 {
                 [self stopPlaySound];
                 //                        [self playSoundWhenDeviceRSSIisLow];
                 }
                 else if(rssiValue < -95)
                 {
                 [self playSoundWhenDeviceRSSIisLow];
                 }
                 }
                 else
                 {
                 [self playSoundWhenDeviceRSSIisLow];
                 }*/
            }
        }
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
//    NSLog(@"didReadRSSI peripheral.name ==%@ ::RSSI ==%f, error==%@",peripheral.name,[RSSI doubleValue],error);
    
    if(peripheral == nil)
        return;
    
    if (peripheral != servicePeripheral)
    {
        //NSLog(@"Wrong peripheral\n");
        return ;
    }
    
    if (peripheral==servicePeripheral)
    {
        /*  if (tempRSSI == 0) {
         tempRSSI = [RSSI doubleValue];
         }else{
         tempRSSI = rssiValue;
         }
         
         rssiValue = [RSSI doubleValue];
         
         if (tempRSSI != 0) {
         rssiValue = tempRSSI+rssiValue;
         rssiValue = rssiValue/2;
         }else{
         rssiValue = [RSSI doubleValue];
         }
         
         if (peripheral.state == CBPeripheralStateConnected)
         {
         if (rssiValue !=0)
         {
         if ([Range_Alert_Value integerValue]<40)
         {
         if (rssiValue < -55)
         {
         [self playSoundWhenDeviceRSSIisLow];
         }
         }
         else if ([Range_Alert_Value integerValue]>=40 && [Range_Alert_Value integerValue]<90)
         {
         if (rssiValue < -80)
         {
         [self playSoundWhenDeviceRSSIisLow];
         }
         }
         else if([Range_Alert_Value integerValue]>90)
         {
         if (rssiValue < -96)
         {
         [self playSoundWhenDeviceRSSIisLow];
         }
         }
         }
         else
         {
         // [self playSoundWhenDeviceRSSIisLow]; //comment due to app is randomly beep when rssi is 0
         }
         }*/
    }
}

#pragma mark- Helper Methods
-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2
{
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

-(const char *) CBUUIDToString:(CBUUID *) UUID
{
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}

-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p
{
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++)
    {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}

-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service)
    {
//        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
//        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}
-(void) getAllCharacteristicsFromKeyfob:(CBPeripheral *)p
{
    for (int i=0; i < p.services.count; i++)
    {
        CBService *s = [p.services objectAtIndex:i];
        
        if ( self.servicesArray )
        {
            if ( ! [self.servicesArray containsObject:s.UUID] )
                [self.servicesArray addObject:s.UUID];
        }
        else
            self.servicesArray = [[NSMutableArray alloc] initWithObjects:s.UUID, nil];
        
        [p discoverCharacteristics:nil forService:s];
    }
//    NSLog(@" services array is %@",self.servicesArray);
}

-(UInt16) CBUUIDToInt:(CBUUID *) UUID
{
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}

#pragma mark - SoundBuzzer (Sending signals)
-(void) soundBuzzer:(Byte)buzzerValue peripheral:(CBPeripheral *)peripheral
{
    
}
#pragma mark - Sounder buzzer for notify device
-(void)soundBuzzerforNotifydevice:(Byte)buzzerValue peripheral:(CBPeripheral *)peripheral
{
//    NSLog(@"buzzerValue==%d",buzzerValue);
    //    buzzerValue = 01;
    NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
    //    NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
    
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:d];
}
-(void)soundBuzzerforNotifydevice1:(NSString *)buzzerValue peripheral:(CBPeripheral *)peripheral
{
//    NSLog(@"buzzerValue==%@",buzzerValue);
    NSInteger test = [buzzerValue integerValue];
    
    //    buzzerValue = 01;
    NSData *d = [[NSData alloc] initWithBytes:&test length:2];
    //    NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
    
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:d];
}
#pragma mark - send Battery to device
-(void) soundbatteryToDevice:(long long)buzzerValue peripheral:(CBPeripheral *)peripheral
{
    //    NSInteger test = [buzzerValue integerValue];
//    NSLog(@"test ==> %ld",(long)buzzerValue);
    NSData *d = [NSData dataWithBytes:&buzzerValue length:6];
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTICS_DATA_CHAR];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:d];
}
-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p {
    
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service)
    {
//        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic)
    {
//        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    [p readValueForCharacteristic:characteristic];
}

-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data
{
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
//        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic)
    {
//        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    
//    NSLog(@" ***** find data *****%@",data);
//    NSLog(@" ***** find data *****%@",characteristic);
    //    NSLog(@" ***** find data *****%@",data);
    
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

#pragma mark play Sound
-(void)playSoundWhenDeviceRSSIisLow
{
    // NSLog(@"IS_Range_Alert_ON==%@",IS_Range_Alert_ON);
    //if ([IS_Range_Alert_ON isEqualToString:@"YES"])
    {
        NSURL *songUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/beep.wav", [[NSBundle mainBundle] resourcePath]]];
        
        songAlarmPlayer1=[[AVAudioPlayer alloc]initWithContentsOfURL:songUrl error:nil];
        songAlarmPlayer1.delegate=self;
        
        AVAudioSession *audioSession1 = [AVAudioSession sharedInstance];
        NSError *err = nil;
        [audioSession1 setCategory :AVAudioSessionCategoryPlayback error:&err];
        [audioSession1 setActive:YES error:&err];
        
        [songAlarmPlayer1 prepareToPlay];
        [songAlarmPlayer1 play];
    }
}
-(void)stopPlaySound
{
    [songAlarmPlayer1 stop];
}
#pragma mark - Sending Notification
-(void)sendSignals
{
    CBPeripheral * p;
    CBUUID * sUUID = [CBUUID UUIDWithString:@"0505A000D10211E19B2300025B002B2B"];
    CBUUID * cUUID = [CBUUID UUIDWithString:@"0505A001D10211E19B2300025B002B2B"];
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:p on:YES];
}
#pragma mark - Sending notifications
-(void)CBUUIDnotification:(CBUUID*)su characteristicUUID:(CBUUID*)cu p:(CBPeripheral *)p on:(BOOL)on
{
    
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
//        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic)
    {
        
//        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}

#pragma mark - Write value
-(void) CBUUIDwriteValue:(CBUUID *)su characteristicUUID:(CBUUID *)cu p:(CBPeripheral *)p data:(NSData *)data
{
    CBService *service = [self findServiceFromUUID:su p:p];
    
    
    if (!service) {
//        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic)
    {
//        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    
//    NSLog(@" ***** find data *****%@",data);
//    NSLog(@" ***** find data *****%@",characteristic);
    
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}
#pragma mark  - send signal before Before
-(void)sendSignalBeforeBattery:(CBPeripheral *)kp withValue:(NSString *)dataStr
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
//            NSLog(@"continuousSendSignalToConnectedDevice %@ : 0x01",kp); // For battery
            [self soundBuzzerforNotifydevice1:dataStr peripheral:kp];
        }
    }
}
#pragma mark  - send signals to device
-(void)sendBatterySignal:(CBPeripheral *)kp
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            double secsUtc1970 = [[NSDate date]timeIntervalSince1970];
            
            long long mills = (long long)([[NSDate date]timeIntervalSince1970]*1000.0);
//            NSLog(@"continuousSendSignalToConnectedDevice %lld : real time-%@",mills,[NSDate date]); // For battery
            
            NSString * setUTCTime = [NSString stringWithFormat:@"%f",secsUtc1970];
            [self soundbatteryToDevice:mills peripheral:kp];
        }
    }
}
-(void)sendDeviceType:(CBPeripheral *)kp withValue:(NSString *)dataStr
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
//            NSLog(@"continuousSendSignalToConnectedDevice %@ : 0x01",kp); // For battery
            //[self soundBuzzerforNotifydevice1:dataStr peripheral:kp];
            
            NSInteger test = [dataStr integerValue];
            
            //    buzzerValue = 01;
            NSData *d = [[NSData alloc] initWithBytes:&test length:2];
            //    NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
            
            CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
        }
    }
}
//15C8B50CF60
-(void)sendHandleString:(CBPeripheral *)peripheral
{
    Byte *bt =0x1F;
    NSData *d = [[NSData alloc] initWithBytes:&bt length:1];
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:d];
}
-(void)sendingTestToDevice:(NSString *)message with:(CBPeripheral *)peripheral withIndex:(NSString *)strIndex
{
    NSString * str = [self hexFromStr:message];
    NSData * msgData = [self dataFromHexString:str];
    
    NSMutableData * midData = [[NSMutableData alloc] init];
    if ([strIndex length]>1)
    {
        for (int i=0; i<[strIndex length]; i++)
        {
            NSString * str = [strIndex substringWithRange:NSMakeRange(i,1)];
            NSString * string = [self hexFromStr:str];
            NSData * strData = [self dataFromHexString:string];
            [midData appendData:strData];
//            NSLog(@"strings===>>>%@",strData);
        }
    }
    else
    {
        NSString * str = [strIndex substringWithRange:NSMakeRange(0,1)];
        NSString * string = [self hexFromStr:str];
        NSData * strData = [self dataFromHexString:string];
        [midData appendData:strData];
        
    }
    NSString * dotStr = [self hexFromStr:@"."];
    NSData * dotData = [self dataFromHexString:dotStr];
    [midData appendData:dotData];
    
    NSInteger indexInt = [strIndex integerValue];
    NSData * indexData = [[NSData alloc] initWithBytes:&indexInt length:1];
    
    NSMutableData *completeData = [indexData mutableCopy];
    [completeData appendData:midData];
    [completeData appendData:msgData];
    
    //    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING1];
    //    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR1];
    //    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
    
    /*NSString * str = [self hexFromStr:message];
     NSLog(@"%@", str);
     
     NSData *bytes = [self dataFromHexString:str];
     NSLog(@"This is sent data===>>>%@",bytes);
     
     NSInteger test = [strIndex integerValue];
     NSData *d = [[NSData alloc] initWithBytes:&test length:1];
     
     NSMutableData *completeData = [d mutableCopy];
     [completeData appendData:bytes];
     NSLog(@"This is sent data===>>>%@",completeData);
     
     //    NSData *d = [[NSData alloc] initWithBytes:0x1F length:1];
     CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING1];
     CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR1];
     [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];*/
    
}
-(void)sendingTestToDeviceCanned:(NSString *)message with:(CBPeripheral *)peripheral withIndex:(NSString *)strIndex
{
    
    NSString * str = [self hexFromStr:message];
    NSData * msgData = [self dataFromHexString:str];
    
    NSMutableData * midData = [[NSMutableData alloc] init];
    if ([strIndex length]>1)
    {
        for (int i=0; i<[strIndex length]; i++)
        {
            NSString * str = [strIndex substringWithRange:NSMakeRange(i,1)];
            NSString * string = [self hexFromStr:str];
            NSData * strData = [self dataFromHexString:string];
            [midData appendData:strData];
        }
    }
    else
    {
        NSString * str = [strIndex substringWithRange:NSMakeRange(0,1)];
        NSString * string = [self hexFromStr:str];
        NSData * strData = [self dataFromHexString:string];
        [midData appendData:strData];
        
    }
    NSString * dotStr = [self hexFromStr:@"."];
    NSData * dotData = [self dataFromHexString:dotStr];
    [midData appendData:dotData];
    
    NSInteger indexInt = [strIndex integerValue];
    NSData * indexData = [[NSData alloc] initWithBytes:&indexInt length:1];
    
    NSMutableData *completeData = [indexData mutableCopy];
    [completeData appendData:midData];
    [completeData appendData:msgData];
    
//    NSLog(@"data===>>>%@  and Msg =%@",completeData, message);
    
    /*NSString * str = [self hexFromStr:message];
     NSLog(@"%@", str);
     
     NSData *bytes = [self dataFromHexString:str];
     NSLog(@"This is sent data===>>>%@",bytes);
     
     NSInteger test = [strIndex integerValue];
     NSData *d = [[NSData alloc] initWithBytes:&test length:1];
     
     NSMutableData *completeData = [d mutableCopy];
     [completeData appendData:bytes];
     NSLog(@"This is sent data===>>>%@",bytes);*/
    
    //    NSData *d = [[NSData alloc] initWithBytes:0x1F length:1];
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
    
}
-(void)syncDiverMessage:(NSString *)message with:(CBPeripheral *)peripheral withIndex:(NSString *)strIndex
{
    NSString * str = [self hexFromStr:message];
    NSData * msgData = [self dataFromHexString:str];
    
    NSMutableData * midData = [[NSMutableData alloc] init];
    if ([strIndex length]>1)
    {
        for (int i=0; i<[strIndex length]; i++)
        {
            NSString * str = [strIndex substringWithRange:NSMakeRange(i,1)];
            NSString * string = [self hexFromStr:str];
            NSData * strData = [self dataFromHexString:string];
            [midData appendData:strData];
        }
    }
    else
    {
        NSString * str = [strIndex substringWithRange:NSMakeRange(0,1)];
        NSString * string = [self hexFromStr:str];
        NSData * strData = [self dataFromHexString:string];
        [midData appendData:strData];
        
    }
    NSString * dotStr = [self hexFromStr:@"."];
    NSData * dotData = [self dataFromHexString:dotStr];
    [midData appendData:dotData];
    
    NSInteger indexInt = [strIndex integerValue];
    NSData * indexData = [[NSData alloc] initWithBytes:&indexInt length:1];
    
    NSMutableData *completeData = [indexData mutableCopy];
    [completeData appendData:midData];
    [completeData appendData:msgData];
    
//    NSLog(@"data===>>>%@  and Msg =%@",completeData, message);
    
    
    /*NSString * str = [self hexFromStr:message];
     NSData * msgData = [self dataFromHexString:str];
     
     NSLog(@"%@", str);
     
     NSMutableData * midData = [[NSMutableData alloc] init];
     if ([strIndex length]>1)
     {
     for (int i=0; i<[strIndex length]; i++)
     {
     NSString * str = [strIndex substringWithRange:NSMakeRange(i,i+1)];
     NSString * string = [self hexFromStr:str];
     NSData * strData = [self dataFromHexString:string];
     [midData appendData:strData];
     NSLog(@"strings===>>>%@",str);
     }
     }
     else
     {
     
     }
     NSString * dotStr = [self hexFromStr:@"."];
     NSData * dotData = [self dataFromHexString:dotStr];
     [midData appendData:dotData];
     
     NSInteger indexInt = [strIndex integerValue];
     NSData * indexData = [[NSData alloc] initWithBytes:&indexInt length:1];
     
     NSMutableData *completeData = [indexData mutableCopy];
     [completeData appendData:midData];
     [completeData appendData:msgData];*/
    
    //    NSData *d = [[NSData alloc] initWithBytes:0x1F length:1];
    //    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING4];
    //    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR4];
    //    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
    
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
-(void)writeColortoDevice:(NSData *)message with:(CBPeripheral *)peripheral withDestID:(NSString *)destID;
{
    //      NSData *d = [[NSData alloc] initWithBytes:0x1F length:1];
    
    NSInteger first = [@"100" integerValue];
    NSData *dTTL = [[NSData alloc] initWithBytes:&first length:1];
    
    globalCount = globalCount + 1;
    NSInteger second = globalCount;
    NSData *dSqnce = [[NSData alloc] initWithBytes:&second length:2];
    
    NSInteger third = [@"9000" integerValue];
    NSData * dDeviceID = [[NSData alloc] initWithBytes:&third length:2];
    
    NSInteger fourth = [destID integerValue];
    NSData * dDestID = [[NSData alloc] initWithBytes:&fourth length:2];
    
    NSInteger fifth = [@"0000" integerValue];
    NSData * dCRC = [[NSData alloc] initWithBytes:&fifth length:2];
    
    
    NSMutableData *completeData = [dSqnce mutableCopy];
    [completeData appendData:dDeviceID];
    [completeData appendData:dDestID];
    [completeData appendData:dCRC];
    [completeData appendData:message];
    
//    NSLog(@"CHECKSUM DATA=%@",completeData);
    
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR1];
    
    
    NSData * checkSumData = [APP_DELEGATE GetCountedCheckSumData:completeData];
    
//    NSLog(@"Got CheckSumt=%@",checkSumData);
    
    NSMutableData * finalData = [dTTL mutableCopy];
    [finalData appendData:dSqnce];
    [finalData appendData:dDeviceID];
    [finalData appendData:dDestID];
    [finalData appendData:checkSumData];
    [finalData appendData:message];
    
    NSString * StrData = [NSString stringWithFormat:@"%@",finalData.debugDescription];
    StrData = [StrData stringByReplacingOccurrencesOfString:@" " withString:@""];
    StrData = [StrData stringByReplacingOccurrencesOfString:@"<" withString:@""];
    StrData = [StrData stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    for (int i=0; i<40-[StrData length]; i++)
    {
        StrData = [StrData stringByAppendingString:@"00"];
    }
//    NSLog(@"RAW DATA=%@",StrData);
    
    NSString * strVal = [self getStringConvertedinUnsigned:StrData];
    NSString * strPassKey = [[NSUserDefaults standardUserDefaults] valueForKey:@"passKey"];
    NSString * strEncryptKey = [self getStringConvertedinUnsigned:strPassKey];
    NSData *data = [APP_DELEGATE GetEncryptedKeyforData:strVal withKey:strEncryptKey withLength:finalData.length];
    
    [[NSUserDefaults standardUserDefaults] setInteger:globalCount forKey:@"GlobalCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:data];
    
}
-(void)writeValuetoDeviceMsg:(NSData *)message with:(CBPeripheral *)peripheral
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR1];
    
    NSString * StrData = [NSString stringWithFormat:@"%@",message.debugDescription];
    StrData = [StrData stringByReplacingOccurrencesOfString:@" " withString:@""];
    StrData = [StrData stringByReplacingOccurrencesOfString:@"<" withString:@""];
    StrData = [StrData stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    //    for (int i=0; i<40-[StrData length]; i++)
    //    {
    //        StrData = [StrData stringByAppendingString:@"00"];
    //    }
    ////    NSLog(@"Final o/p=%@",StrData);
    //
    //    NSString * strVal = [self getStringConvertedinUnsigned:StrData];
    //    NSString * strPassKey = [[NSUserDefaults standardUserDefaults] valueForKey:@"passKey"];
    //    NSString * strEncryptKey = [self getStringConvertedinUnsigned:strPassKey];
    //    NSData *data = [APP_DELEGATE GetEncryptedKeyforData:strVal withKey:strEncryptKey];
//    NSLog(@"SENDING   ....  Data=%@",StrData);
    
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:message];
}

-(void)sendTimeToDevice:(CBPeripheral *)kp
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            long long mills = (long long)([[NSDate date]timeIntervalSince1970]);
            NSData *dates = [NSData dataWithBytes:&mills length:4];
            
            NSInteger first = [@"01" integerValue];
            NSData *dfirst = [[NSData alloc] initWithBytes:&first length:1];
            
            NSInteger four = [@"04" integerValue];
            NSData *dfour = [[NSData alloc] initWithBytes:&four length:1];
            
            NSMutableData *completeData = [dfirst mutableCopy];
            [completeData appendData:dfour];
            [completeData appendData:dates];
            
//            NSLog(@"Final data%@ and RTC=%lld",completeData,mills); // For battery
            
            //            CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING3];
            //            CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR3];
            //            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:completeData];
        }
    }
}

-(void)sendMessagetoother:(NSString *)strAll with:(CBPeripheral *)peripheral withIndex:(NSString *)strIndex
{
    NSInteger int1 = [@"05" integerValue];
    NSData * data1 = [[NSData alloc] initWithBytes:&int1 length:1];
    
    NSInteger int2 = [@"02" integerValue];
    NSData * data2 = [[NSData alloc] initWithBytes:&int2 length:1];
    
    NSInteger int3 = [strAll integerValue];
    NSData * data3 = [[NSData alloc] initWithBytes:&int3 length:1];
    
    NSInteger int4 = [strIndex integerValue];
    NSData * data4 = [[NSData alloc] initWithBytes:&int4 length:1];
    
    NSMutableData *completeData = [data1 mutableCopy];
    [completeData appendData:data2];
    [completeData appendData:data3];
    [completeData appendData:data4];
    
//    NSLog(@"This is sent data===>>>%@",completeData);
    
    //    NSData *d = [[NSData alloc] initWithBytes:0x1F length:1];
    //    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING3];
    //    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR3];
    //    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
    
}
-(void)sendNotifications:(CBPeripheral*)kp withType:(BOOL)isMulti withUUID:(NSString *)strUUID
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:strUUID];
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}

-(void)sendNotificationsForOff:(CBPeripheral*)kp withType:(BOOL)isMulti
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR1];
    
    //    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:NO];
}
-(void)ConnectOtherDevice:(NSData *)message with:(CBPeripheral *)peripheral
{
    NSInteger first = [@"100" integerValue];
    NSData *dTTL = [[NSData alloc] initWithBytes:&first length:1];
    
    globalCount = globalCount + 1;
    NSInteger second = globalCount;
    NSData *dSqnce = [[NSData alloc] initWithBytes:&second length:2];
    
    NSInteger third = [@"9000" integerValue];
    NSData * dDeviceID = [[NSData alloc] initWithBytes:&third length:2];
    
    NSInteger fourth = [@"00" integerValue];
    NSData * dDestID = [[NSData alloc] initWithBytes:&fourth length:2];
    
    NSInteger fifth = [@"92" integerValue];
    NSData * dCRC = [[NSData alloc] initWithBytes:&fifth length:2];
    
    NSMutableData *completeData = [dTTL mutableCopy];
    [completeData appendData:dSqnce];
    [completeData appendData:dDeviceID];
    [completeData appendData:dDestID];
    [completeData appendData:dCRC];
    [completeData appendData:message];
    
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR1];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
    
}
-(void)moveToBridegeView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBridgeScreen" object:nil];
}
-(NSString *)getStringConvertedinUnsigned:(NSString *)strNormal
{
    NSString * strKey = strNormal;
    long ketLength = [strKey length]/2;
    NSString * strVal;
    for (int i=0; i<ketLength; i++)
    {
        NSRange range73 = NSMakeRange(i*2, 2);
        NSString * str3 = [strKey substringWithRange:range73];
        if ([strVal length]==0)
        {
            strVal = [NSString stringWithFormat:@" 0x%@",str3];
        }
        else
        {
            strVal = [strVal stringByAppendingString:[NSString stringWithFormat:@" 0x%@",str3]];
        }
    }
    return strVal;
}

-(void)sentAuthentication:(CBPeripheral *)kp withValue:(NSString *)dataStr // This is the method in which we can send value of Command like FF04 or 0004 sending as command before sending actual value
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            
            NSInteger test = [dataStr integerValue];
            NSData *d = [[NSData alloc] initWithBytes:&test length:2];
            CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATAAUTH];
            isforAuth=YES;
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
            
        }
    }
}
#pragma mark  - Method to send Command Values like FF04, 0004, 0001
-(void)sendCommandbeforeSendingValue:(CBPeripheral *)kp withValue:(NSString *)dataStr // This is the method in which we can send value of Command like FF04 or 0004 sending as command before sending actual value
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            
            NSInteger test = [dataStr integerValue];
            NSData *d = [[NSData alloc] initWithBytes:&test length:2];
            CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATAAUTH];
            isforAuth=NO;
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
            
        }
    }
}
#pragma mark  - Method to send values and not command
-(void)sendBackAuth:(CBPeripheral *)kp withValue:(NSString *)dataStr //This method is using for writting value to ble device with data characteristics (Not Comman characteristics)
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
//            NSLog(@"continuousSendSignalToConnectedDevice %@ : 0x01",kp); // For battery
            NSInteger test = [dataStr integerValue];
            NSData *d = [[NSData alloc] initWithBytes:&test length:2];//Lenght is 2 Bytes
            CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationCompleted" object:nil];
        }
    }
}
-(void)sendFactoryResetCommand:(CBPeripheral *)kp withValue:(NSString *)dataStr //This method is using for writting value to ble device with data characteristics (Not Comman characteristics)
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
//            NSLog(@"continuousSendSignalToConnectedDevice %@ : 0x01",kp); // For battery
            NSInteger test = [dataStr integerValue];
            NSData *d = [[NSData alloc] initWithBytes:&test length:2];//Lenght is 2 Bytes
            CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:UUID_SMART_MESH_FACTORY_RESET_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationCompleted" object:nil];
        }
    }
}
-(NSString*)stringFroHex:(NSString *)hexStr
{
    unsigned long long startlong;
    NSScanner* scanner1 = [NSScanner scannerWithString:hexStr];
    [scanner1 scanHexLongLong:&startlong];
    double unixStart = startlong;
    NSNumber * startNumber = [[NSNumber alloc] initWithDouble:unixStart];
    return [startNumber stringValue];
}
-(NSInteger)convertAlgo:(NSInteger)originValue
{
    NSInteger final = ((((originValue * 7) + 19) * 12) -((4*originValue) + 13));//
    return final;
    //       key_value_gen = ((((auth_key * 7) + 19) * 12) - (4*auth_key + 13));
}
-(NSInteger)AlgorithmforFactoryReset:(NSInteger)originValue
{
    NSInteger final = ((((originValue * 9) + 17) * 23) -((9*originValue) + 55));
    return final;
}

-(void) readAuthValuefromManager:(CBPeripheral *)peripherals;
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR];
    
    CBService *service = [self findServiceFromUUID:sUUID p:peripherals];
    
    if (!service) {
//        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:sUUID],peripherals.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cUUID service:service];
    if (!characteristic)
    {
//        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cUUID],[self CBUUIDToString:sUUID],peripherals.identifier.UUIDString);
        return;
    }
    [peripherals readValueForCharacteristic:characteristic];
}

-(void)readFactoryResetValue:(CBPeripheral *)peripherals;
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:UUID_SMART_MESH_FACTORY_RESET_CHAR];
    
    CBService *service = [self findServiceFromUUID:sUUID p:peripherals];
    
    if (!service) {
//        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:sUUID],peripherals.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cUUID service:service];
    if (!characteristic)
    {
//        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cUUID],[self CBUUIDToString:sUUID],peripherals.identifier.UUIDString);
        return;
    }
    [peripherals readValueForCharacteristic:characteristic];
}
-(void)KPReadMethod:(CBUUID *)su characteristicUUID:(CBUUID *)cu p:(CBPeripheral *)p
{
    
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
    strValid = [strValid stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    return strValid;
}
#pragma mark - All SOCKET METHODS
-(void)Socket_peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //here notification will come
//    NSLog(@"========SOCKET_RECIEVED_DATA========%@",characteristic);
    NSString * strUUID = [NSString stringWithFormat:@"%@",characteristic.UUID];
    if ([strUUID isEqualToString:@"0000AB00-2687-4433-2208-ABF9B34FB000"])//For Authentication 0000AB01-0143-0800-0008-E5F9B34FB000
    {
        NSData * valData = characteristic.value;
        NSString * valueCharStr = [NSString stringWithFormat:@"%@",valData.debugDescription];
        valueCharStr = [valueCharStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        valueCharStr = [valueCharStr stringByReplacingOccurrencesOfString:@">" withString:@""];
        valueCharStr = [valueCharStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
        
        if (![[self checkforValidString:valueCharStr] isEqualToString:@"NA"])
        {
            if ([valueCharStr length]>=36)
            {
                NSString * strOpcode = [valueCharStr substringWithRange:NSMakeRange(0, 2)];

                dispatch_async(dispatch_get_main_queue(), ^(void)
                {
                    NSString * defaultKey = [[NSUserDefaults standardUserDefaults]valueForKey:@"VDK"];
                    if ([strOpcode isEqualToString:@"01"] || [strOpcode isEqualToString:@"02"])
                    {
                        if ([[arrPeripheralsCheck valueForKey:@"identifier"] containsObject:peripheral.identifier])
                        {
                            NSInteger foundIndex = [[arrPeripheralsCheck valueForKey:@"identifier"] indexOfObject:peripheral.identifier];
                            if (foundIndex != NSNotFound)
                            {
                                if ([arrPeripheralsCheck count] > foundIndex)
                                {
                                    if ([[[arrPeripheralsCheck objectAtIndex:foundIndex] valueForKey:@"status"] isEqualToString:@"1700"])
                                    {
                                        defaultKey = [[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"];
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        defaultKey = [[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"];
                    }
                    
                    NSString * strKeyUnsigned = [self getStringConvertedinUnsigned:defaultKey];
                    NSString * strPacket = [self getStringConvertedinUnsigned:[valueCharStr substringWithRange:NSMakeRange(4, 32)]];
                    NSString * strPactLength = [self stringFroHex:[valueCharStr substringWithRange:NSMakeRange(2, 2)]];
                    
                    NSString * strDecrypted = [APP_DELEGATE GetSocketDecrypedData:strPacket withKey:strKeyUnsigned withLength:defaultKey.length / 2];
//                    NSLog(@"=====DefaultKey=%@     \n Encrypted Packet=%@",defaultKey, strPacket);

                    NSLog(@"====SOCKET_FULL_DECRYPTED_PACKET========%@%@%@",strOpcode,[valueCharStr substringWithRange:NSMakeRange(2, 2)],strDecrypted);

                    if ([strDecrypted length]>=6)
                    {
                        if ([strOpcode isEqualToString:@"01"])
                        {
                            NSString * strCode = [strDecrypted substringWithRange:NSMakeRange(0, 2)];
                            [self WriteSockethAuthenticationCode:strCode withPeripheral:peripheral];
                        }
                        else if ([strOpcode isEqualToString:@"02"])
                        {
                            if ([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"])
                            {
                                [addSocketdelegate AuthenticationCompleted:peripheral];
                            }
                            
                            NSInteger intPacket = [@"0" integerValue];
                            NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
                            [self WriteSocketData:dataPacket withOpcode:@"16" withLength:@"00" withPeripheral:peripheral];

                        }
                        else if ([strOpcode isEqualToString:@"03"])
                        {
                            if ([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"])
                            {
                                NSLog(@"Wrote Time to Device Successfully.");
                            }
                        }
                        else if ([strOpcode isEqualToString:@"04"]) // 0404
                        {
                            if ([strDecrypted length]>=12)
                            {
                                if ([[strDecrypted substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"0404"])
                                {
//                                    NSString * strtimeStamp = [valueCharStr substringWithRange:NSMakeRange(4, 8)];
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"05"])
                        {
                            if ([strDecrypted length]>=16)
                                {
                                    if ([[valueCharStr substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"0506"])
                                    {
                                        NSMutableDictionary * dictSwitcState = [[NSMutableDictionary alloc] init];
                                        NSString * strSW1 = [strDecrypted substringWithRange:NSMakeRange(0, 2)];
                                        NSString * strSW2 = [strDecrypted substringWithRange:NSMakeRange(2, 2)];
                                        NSString * strSW3 = [strDecrypted substringWithRange:NSMakeRange(4, 2)];
                                        NSString * strSW4 = [strDecrypted substringWithRange:NSMakeRange(6, 2)];
                                        NSString * strSW5 = [strDecrypted substringWithRange:NSMakeRange(8, 2)];
                                        NSString * strSW6 = [strDecrypted substringWithRange:NSMakeRange(10, 2)];
                                    
                                        [dictSwitcState setValue:strSW1 forKey:@"Switch1"];
                                        [dictSwitcState setValue:strSW2 forKey:@"Switch2"];
                                        [dictSwitcState setValue:strSW3 forKey:@"Switch3"];
                                        [dictSwitcState setValue:strSW4 forKey:@"Switch4"];
                                        [dictSwitcState setValue:strSW5 forKey:@"Switch5"];
                                        [dictSwitcState setValue:strSW6 forKey:@"Switch6"];
                                    
                                        if (globalSocketDetailVC)
                                        {
                                            [globalSocketDetailVC ReceivedSwitchStatusfromDevice:dictSwitcState];
                                        }
                                    }
                                }
                        }
                        else if ([strOpcode isEqualToString:@"06"]) // Device registration Confirm
                        {
                            if ([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"])
                            {
                                if ([[arrPeripheralsCheck valueForKey:@"identifier"] containsObject:peripheral.identifier])
                                {
                                    NSInteger foundIndex = [[arrPeripheralsCheck valueForKey:@"identifier"] indexOfObject:peripheral.identifier];
                                    if (foundIndex != NSNotFound)
                                    {
                                        if ([arrPeripheralsCheck count] > foundIndex)
                                        {
                                            NSMutableDictionary * dict = [[arrPeripheralsCheck objectAtIndex:foundIndex] mutableCopy];
                                            [dict setValue:@"1700" forKey:@"status"];
                                            [arrPeripheralsCheck replaceObjectAtIndex:foundIndex withObject:dict];
                                        }
                                    }
                                }
                                [addSocketdelegate AssociationCompleted:YES];
                            }
                            else
                            {
                                [addSocketdelegate AssociationCompleted:NO];
                            }
                        }
                        else if ([strOpcode isEqualToString:@"07"]) // DELETE DEVICE
                        {
                            [[BLEManager sharedManager] disconnectDevice:peripheral];
                            if ([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"])
                            {
                                
                            }
                            else
                            {
                                
                            }
                        }
                        else if ([strOpcode isEqualToString:@"08"]) //
                        {
                            if ([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"])
                            {
                            }
                            else
                            {
                            }
                        }
                        else if ([strOpcode isEqualToString:@"09"])
                        {
                            if ([strDecrypted length]>=6)
                            {
                                if ([[strDecrypted substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"01"])
                                {
                                }
                                else
                                {
                                    //Send Error and Undo Switch Status
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"10"]) // Check WIFI Configured or not...
                        {
                            if ([strDecrypted length]>=8)
                            {
                                [_delegate RecievedWifiConfiguredStatus:[strDecrypted substringWithRange:NSMakeRange(0, 4)]];
                            }
                        }
                        else if ([strOpcode isEqualToString:@"0a"])
                        {
                            if ([strDecrypted length]>=6)
                            {
                                [globalSocketDetailVC ReceiveAllSoketONOFFState:[strDecrypted substringWithRange:NSMakeRange(2, 4)]];
                                if ([[strDecrypted substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"01"])
                                {
                                    NSInteger intData = [@"00" integerValue];
                                    NSData * requestData = [[NSData alloc] initWithBytes:&intData length:1];
                                    [self WriteSocketData:requestData withOpcode:@"05" withLength:@"0" withPeripheral:peripheral];
                                }
                                else
                                {
                                    //Send Error and Undo Switch Status
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"0b"]) //
                        {
                            if ([strDecrypted length]>=4)
                            {
                                if ([[strDecrypted substringWithRange:NSMakeRange(2, 6)] isEqualToString:@"020101"])
                                {
                                    [globalSocketAlarmVC ALaramSuccessResponseFromDevie];
                                }
                                else
                                {
                                    [globalSocketAlarmVC ALaramSuccessResponseFromDevie];
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"0d"]) //
                        {
                            if ([strDecrypted length]>=4)
                            {
                                if ([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"0d01"])
                                {
                                    [_delegate WifiSSIDIndexAcknowlegement:@"01"];
                                }
                                else
                                {
                                    [_delegate WifiSSIDIndexAcknowlegement:@"00"];
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"0e"]) //
                        {
                            if ([strDecrypted length]>=4)
                            {
                                if ([[strDecrypted substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"01"])
                                {
                                    NSInteger intPacket = [@"0" integerValue];
                                    NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
                                    [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"16" withLength:@"00" withPeripheral:peripheral];

                                    NSInteger indexPacket = [[strDecrypted substringWithRange:NSMakeRange(0, 2)] intValue];
                                    if (indexPacket + 1 == wifiPasswordTotalPackets)
                                    {
                                        [_delegate WifiPasswordAcknowledgement:@"01"];
                                    }
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"0c"]) //
                        {
                            if ([strDecrypted length]>=4)
                            {
                                NSMutableDictionary * dictAlaramDelete = [[NSMutableDictionary alloc] init];
                                NSString * strAlarmID = [strDecrypted substringWithRange:NSMakeRange(0, 2)];
                                NSString * strAlarmdeletConfirm = [strDecrypted substringWithRange:NSMakeRange(2, 2)];
                                
                                [dictAlaramDelete setValue:strAlarmID forKey:@"alarm_id"];
                                [dictAlaramDelete setValue:strAlarmdeletConfirm forKey:@"deleteSate"];
                                
                                if (globalSocketDetailVC)
                                {
                                    [globalSocketAlarmVC DeleteAlarmConfirmFromDevice:dictAlaramDelete];
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"15"]) //
                        {
                            if ([strDecrypted length]>=16)
                            {
                                if ([[valueCharStr substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"1501"])
                                {
                                    
                                }
                                else
                                {
                                    NSMutableDictionary * dictAlarmID = [[NSMutableDictionary alloc] init];
                                            
                                    NSString * strALID = [NSString stringWithFormat:@"%d",[[strDecrypted substringWithRange:NSMakeRange(0, 2)] intValue]];
                                    NSString * strSocketID = [strDecrypted substringWithRange:NSMakeRange(2, 2)];
                                    NSString * strDayVal = [strDecrypted substringWithRange:NSMakeRange(4, 2)];
                                    NSString * strONTime = [strDecrypted substringWithRange:NSMakeRange(6, 8)];
                                    NSString * strOffTime = [strDecrypted substringWithRange:NSMakeRange(14, 8)];
                                    NSString * strAlarmSate = [strDecrypted substringWithRange:NSMakeRange(22, 2)];
                                        
                                    [dictAlarmID setValue:strALID forKey:@"alaramID"];
                                    [dictAlarmID setValue:strSocketID forKey:@"socketID"];
                                    [dictAlarmID setValue:strDayVal forKey:@"dayValue"];
                                    [dictAlarmID setValue:strONTime forKey:@"onTime"];
                                    [dictAlarmID setValue:strOffTime forKey:@"offTime"];
                                    [dictAlarmID setValue:strAlarmSate forKey:@"alarmState"];
                                            
                                        
                                    if (globalSocketDetailVC)
                                    {
                                        [globalSocketDetailVC AlarmListStoredinDevice:dictAlarmID];
                                    }
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"16"]) //
                        {
                            if ([strDecrypted length]>=4)
                            {
                                if ([[strDecrypted substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"01"])
                                {
//                                    NSInteger indexPacket = [[strDecrypted substringWithRange:NSMakeRange(0, 2)] intValue];
                                    
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"19"]) // Firmaware version
                        {
                            if ([strDecrypted length]>=4)
                            {
                                if ([[strDecrypted substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"01"])
                                {
                                    
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"12"]) // css add this
                        {
                            if ([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"] && [[valueCharStr substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"01"])
                            {
                            }
                            else if ([[strDecrypted substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"ffff"])
                            {
                                [addSocketdelegate ShowNowifiAvailablePopUP];
                                [_delegate NoWIIFoundNearby];
                            }
                            else if ([[strDecrypted substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"eeee"])
                            {
                                [_delegate FoundNumberofWIFI:arrWifiList];
                            }
                            else
                            {
                                NSMutableDictionary * dictWifiList = [[NSMutableDictionary alloc] init];

                                NSString * strIndex = [strDecrypted substringWithRange:NSMakeRange(0, 2)];
                                NSString * strpacketNo = [strDecrypted substringWithRange:NSMakeRange(4, 2)];
                                int packetLength = [strPactLength intValue];

                                if ([strpacketNo isEqualToString:@"00"])
                                {
                                    NSString * strRSSI = [strDecrypted substringWithRange:NSMakeRange(6, 2)];
                                    NSScanner *scanner = [NSScanner scannerWithString:strRSSI];
                                    unsigned int temp;
                                    [scanner scanHexInt:&temp];
                                    int rssiInt = (char)temp;
                                    NSString * strRSSISigned = [[NSNumber numberWithInt:rssiInt] stringValue];

                                    NSLog(@"PacketLenght=%d",packetLength);
                                    NSLog(@"Packet NO=%@",strpacketNo);
                                    NSLog(@"Data NO=%@",strDecrypted);

                                    NSString * strSSIDdata = [strDecrypted substringWithRange:NSMakeRange(8, (packetLength*2) - 8)];
                                    NSMutableString * strWifiName = [[NSMutableString alloc] init];
                                    int i = 0;
                                    while (i < [strSSIDdata length])
                                    {
                                        NSString * hexChar = [strSSIDdata substringWithRange: NSMakeRange(i, 2)];
                                        int value = 0;
                                        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
                                        [strWifiName appendFormat:@"%c", (char)value];
                                        i+=2;
                                    }
                                    [dictWifiList setValue:strIndex forKey:@"Index"];
                                    [dictWifiList setValue:strRSSISigned forKey:@"RSSI"];
                                    [dictWifiList setValue:strWifiName forKey:@"SSIDdata"];
                                    [arrWifiList addObject:dictWifiList];
                                }
                                else
                                {
                                    NSLog(@"PacketLenght=%d",packetLength);
                                    NSLog(@"Packet NO=%@",strpacketNo);
                                    NSLog(@"Data NO=%@",strDecrypted);
                                    
                                    NSInteger fullPacketLength = [[self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(2, 2)]] integerValue];
                                    
                                    NSInteger remainingLength = fullPacketLength - 12;
                                    
                                    NSString * strSSIDdata;
                                    if (remainingLength < 0)
                                    {
                                        strSSIDdata = [strDecrypted substringWithRange:NSMakeRange(6, (packetLength*2) - 6)];
                                    }
                                    else
                                    {
                                        strSSIDdata = [strDecrypted substringWithRange:NSMakeRange(6, remainingLength * 2)];
                                    }
                                    NSMutableString * strWifiName = [[NSMutableString alloc] init];
                                    int i = 0;
                                    while (i < [strSSIDdata length])
                                    {
                                        NSString * hexChar = [strSSIDdata substringWithRange: NSMakeRange(i, 2)];
                                        int value = 0;
                                        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
                                        [strWifiName appendFormat:@"%c", (char)value];
                                        i+=2;
                                    }
                                    if ([[arrWifiList valueForKey:@"Index"] containsObject:strIndex])
                                    {
                                        NSInteger foundIndex = [[arrWifiList valueForKey:@"Index"] indexOfObject:strIndex];
                                        if (foundIndex != NSNotFound)
                                        {
                                            if ([arrWifiList count] > foundIndex)
                                            {
                                                NSString * strPacket1 = [[arrWifiList objectAtIndex:foundIndex] valueForKey:@"SSIDdata"];
                                                strPacket1 = [strPacket1 stringByAppendingString:strWifiName];
                                                NSMutableDictionary * dictWifiList = [arrWifiList objectAtIndex:foundIndex];
                                                [dictWifiList setValue:strPacket1 forKey:@"SSIDdata"];
                                                [arrWifiList replaceObjectAtIndex:foundIndex withObject:dictWifiList];
                                            }
                                        }
                                    }
                                }
                                NSLog(@"Wifi Available====>>>>>%@",arrWifiList);
                            }
                        }
                        else if ([strOpcode isEqualToString:@"1a"]) // Firmaware version
                        {
                            if ([strDecrypted length]>=4)
                            {
                                if ([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"])
                                {
                                    [_delegate RecievedRemoveWifiConfiguration];
                                }
                            }
                        }
                    }
                });
            }
        }
    }
}
-(void)EnableNotificationsForCommandSKT:(CBPeripheral*)kp withType:(BOOL)isMulti
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_SKT];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_SKT];
    
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}
-(void)EnableNotificationsForDATASKT:(CBPeripheral*)kp withType:(BOOL)isMulti
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_SKT];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_SKT];
    
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}
-(void)sendNotificationsSKT:(CBPeripheral*)kp withType:(BOOL)isMulti withUUID:(NSString *)strUUID
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_SKT];
    CBUUID * cUUID = [CBUUID UUIDWithString:strUUID];
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}
-(void)GetAuthcodeforSocket:(CBPeripheral *)peripheral withValue:(NSString *)strValue
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        
        NSString * defaultKey = [[NSUserDefaults standardUserDefaults]valueForKey:@"VDK"];
        if ([[arrPeripheralsCheck valueForKey:@"identifier"] containsObject:peripheral.identifier])
        {
            NSInteger foundIndex = [[arrPeripheralsCheck valueForKey:@"identifier"] indexOfObject:peripheral.identifier];
            if (foundIndex != NSNotFound)
            {
                if ([arrPeripheralsCheck count] > foundIndex)
                {
                    if ([[[arrPeripheralsCheck objectAtIndex:foundIndex] valueForKey:@"status"] isEqualToString:@"1700"])
                    {
                        defaultKey = [[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"];
                    }
                }
            }
        }
        NSString * strKey  =  [APP_DELEGATE getStringConvertedinUnsigned:defaultKey];
        NSString * strKeyUnsigned = [self getStringConvertedinUnsigned:defaultKey];
    
        NSInteger intPacket = [@"0" integerValue];
        NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];

        NSString * strData = [NSString stringWithFormat:@"%@",dataPacket.debugDescription];
        if ([strData length] < 16)
        {
            strData = [NSString stringWithFormat:@"%@",dataPacket.debugDescription];
            strData = [strData stringByReplacingOccurrencesOfString:@" " withString:@""];
            strData = [strData stringByReplacingOccurrencesOfString:@"<" withString:@""];
            strData = [strData stringByReplacingOccurrencesOfString:@">" withString:@""];

            for (int i = 0; i < 16 - ([strData length] / 2); i ++)
            {
                strData = [strData stringByAppendingString:@"00"];
            }
        }

            NSInteger opInt = 1;
            NSData * opCodeData = [[NSData alloc] initWithBytes:&opInt length:1];
            
            NSInteger lengths = 0;
            NSData * lengthData = [[NSData alloc] initWithBytes:&lengths length:1];
            
            NSString * strPacket = [self getStringConvertedinUnsigned:strData];
            NSData * strEncrypted = [APP_DELEGATE GetSocketEncryptedKeyforData:strPacket withKey:strKeyUnsigned withLength:strKey.length / 2];

            NSMutableData *completeData = [opCodeData mutableCopy];
            [completeData appendData:lengthData];
            [completeData appendData:strEncrypted];

            CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_SKT];
            CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_SKT];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
    });
}
-(void)CheckforWifiStatus:(CBPeripheral *)peripheral
{
    NSLog(@"Sent Opcode 10 after delay");
    
    NSInteger intPacket = [@"0" integerValue];
    NSData * dataPacket = [[NSData alloc] initWithBytes:&intPacket length:1];
    [[BLEService sharedInstance] WriteSocketData:dataPacket withOpcode:@"16" withLength:@"00" withPeripheral:peripheral];

}
-(NSInteger)convertAlgorithmforSocket:(NSInteger)m_auth_key
{
    NSInteger final = ((((m_auth_key * 49) + 1239) * 99) - (129 * m_auth_key + 779));
    return final;
    //       key_value_gen = ((((auth_key * 7) + 19) * 12) - (4*auth_key + 13));
}

#pragma mark - SEND COMMAND NSDATA WITH TOTAL BYTES
-(void)WriteSockethAuthenticationCode:(NSString *)strCode withPeripheral:(CBPeripheral *)peripheral
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSString * defaultKey = [[NSUserDefaults standardUserDefaults]valueForKey:@"VDK"];
        if ([[arrPeripheralsCheck valueForKey:@"identifier"] containsObject:peripheral.identifier])
        {
            NSInteger foundIndex = [[arrPeripheralsCheck valueForKey:@"identifier"] indexOfObject:peripheral.identifier];
            if (foundIndex != NSNotFound)
            {
                if ([arrPeripheralsCheck count] > foundIndex)
                {
                    if ([[[arrPeripheralsCheck objectAtIndex:foundIndex] valueForKey:@"status"] isEqualToString:@"1700"])
                    {
                        defaultKey = [[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"];
                    }
                }
            }
        }
        NSString * strKey  =  [APP_DELEGATE getStringConvertedinUnsigned:defaultKey];
        NSString * strKeyUnsigned = [self getStringConvertedinUnsigned:defaultKey];

        NSString * strinfromHex = [self stringFroHex:strCode];
        NSInteger  valuInt = [self convertAlgorithmforSocket:[strinfromHex integerValue]];
        
        NSData * authData = [[NSData alloc] initWithBytes:&valuInt length:4];
        
        NSString * strData = [NSString stringWithFormat:@"%@",authData.debugDescription];
        if ([strData length] < 16)
        {
            strData = [NSString stringWithFormat:@"%@",authData.debugDescription];
            strData = [strData stringByReplacingOccurrencesOfString:@" " withString:@""];
            strData = [strData stringByReplacingOccurrencesOfString:@"<" withString:@""];
            strData = [strData stringByReplacingOccurrencesOfString:@">" withString:@""];

            for (int i = 0; i < 16 - ([strData length] / 2); i ++)
            {
                strData = [strData stringByAppendingString:@"00"];
            }
        }

        NSInteger opInt = 2;
        NSData * opCodeData = [[NSData alloc] initWithBytes:&opInt length:1];
        
        NSInteger lengths = 4;
        NSData * lengthData = [[NSData alloc] initWithBytes:&lengths length:1];
        
        NSString * strPacket = [self getStringConvertedinUnsigned:strData];
        NSData * strEncrypted = [APP_DELEGATE GetSocketEncryptedKeyforData:strPacket withKey:strKeyUnsigned withLength:strKey.length / 2];

        NSMutableData *completeData = [opCodeData mutableCopy];
        [completeData appendData:lengthData];
        [completeData appendData:strEncrypted];

        CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_SKT];
        CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_SKT];
        [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
        NSLog(@"Wrote Authentication Code back Value==%ld and Data packet=%@",(long)valuInt,authData);

    });

}
-(void)WriteSocketData:(NSData *)socketData withOpcode:(NSString *)strOpcode withLength:(NSString *)strLength withPeripheral:(CBPeripheral *)peripheral;
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        
        NSString * strEncryptKey = [[NSUserDefaults standardUserDefaults]valueForKey:@"VDK"];
        if ([[arrPeripheralsCheck valueForKey:@"identifier"] containsObject:peripheral.identifier])
        {
            NSInteger foundIndex = [[arrPeripheralsCheck valueForKey:@"identifier"] indexOfObject:peripheral.identifier];
            if (foundIndex != NSNotFound)
            {
                if ([arrPeripheralsCheck count] > foundIndex)
                {
                    if ([[[arrPeripheralsCheck objectAtIndex:foundIndex] valueForKey:@"status"] isEqualToString:@"1700"])
                    {
                        strEncryptKey = [[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"];
                    }
                }
            }
        }
        
//        NSString * strEncryptKey  = [[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"];
//        if ([strOpcode isEqualToString:@"06"])
//        {
//             strEncryptKey = [[NSUserDefaults standardUserDefaults]valueForKey:@"VDK"];
//        }

        if ([strOpcode isEqualToString:@"18"]) //Wifi Scan Opcode...Clear Wifi List Array
        {
            [arrWifiList removeAllObjects];
            arrWifiList = [[NSMutableArray alloc] init];
        }
        
        NSString * strKey  =  [APP_DELEGATE getStringConvertedinUnsigned:strEncryptKey];
        NSString * strKeyUnsigned = [self getStringConvertedinUnsigned:strEncryptKey];

        NSInteger intOpCode = [strOpcode integerValue];
        NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpCode length:1];
            
        NSInteger intLength = [strLength integerValue];
        NSData * dataLength = [[NSData alloc] initWithBytes:&intLength length:1];

        NSString * strData = [NSString stringWithFormat:@"%@",socketData.debugDescription];
        if (intLength < 16)
        {
            strData = [NSString stringWithFormat:@"%@",socketData.debugDescription];
            strData = [strData stringByReplacingOccurrencesOfString:@" " withString:@""];
            strData = [strData stringByReplacingOccurrencesOfString:@"<" withString:@""];
            strData = [strData stringByReplacingOccurrencesOfString:@">" withString:@""];

            for (int i = 0; i < 16 - ([strData length] / 2); i ++)
            {
                strData = [strData stringByAppendingString:@"00"];
            }
        }
        NSString * StrData = [NSString stringWithFormat:@"%@",strData];
        StrData = [StrData stringByReplacingOccurrencesOfString:@" " withString:@""];
        StrData = [StrData stringByReplacingOccurrencesOfString:@"<" withString:@""];
        StrData = [StrData stringByReplacingOccurrencesOfString:@">" withString:@""];
            
        NSString * strPacket = [self getStringConvertedinUnsigned:StrData];
        NSData * strEncrypted = [APP_DELEGATE GetSocketEncryptedKeyforData:strPacket withKey:strKeyUnsigned withLength:strKey.length / 2];

        NSMutableData *completeData = [dataOpcode mutableCopy];
        [completeData appendData:dataLength];
        [completeData appendData:strEncrypted];

        CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_SKT];
        CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_SKT];
        [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
        NSLog(@"wrote SOCKET DATA ====>>%@",completeData);
    });
}
-(void)WriteWifiPassword:(NSString *)strPassword
{
    float lenghtFloat = [strPassword length];
    NSString * strLength = [NSString stringWithFormat:@"%f",lenghtFloat / 14];
    NSArray * tmpArr = [strLength componentsSeparatedByString:@"."];
    NSInteger totalPackets = 0;
    if ([tmpArr count]>1)
    {
        NSInteger afterPoint = [[tmpArr objectAtIndex:1] integerValue];
        if (afterPoint == 0)
        {
            totalPackets = [[tmpArr objectAtIndex:0] integerValue];
        }
        else
        {
            totalPackets = [[tmpArr objectAtIndex:0] integerValue] + 1;
        }
        NSLog(@"its TotalPackets=%ld",(long)totalPackets);
    }
    
    NSInteger totallength = [strPassword length];
    NSData * dataTotalLength = [[NSData alloc] initWithBytes:&totallength length:1];

    wifiPasswordTotalPackets = totalPackets;
    
    NSString * strFullMsg = strPassword;
    for (int i = 0; i < totalPackets; i++)
    {
        if (totallength >= (i * 14) + 14)
        {
            NSString * strMsg = [strFullMsg substringWithRange:NSMakeRange(i * 14, 14)];
            NSData * msgData = [self dataFromHexString:[self hexFromStr:strMsg]];

            NSData * dataPacketNo = [[NSData alloc] initWithBytes:&i length:1];

            NSMutableData *completeData = [dataTotalLength mutableCopy];
            [completeData appendData:dataPacketNo];
            [completeData appendData:msgData];

            [self WriteSocketData:completeData withOpcode:@"14" withLength:@"16" withPeripheral:globalSocketPeripheral];

            NSLog(@"Pass=%@   TotalLength=%@    PacketNo=%d    MsgData=%@",strMsg, dataTotalLength, i, msgData);
        }
        else
        {
            if ((totallength >= (i * 14)))
            {
                NSString * strMsg = [strFullMsg substringWithRange:NSMakeRange(i * 14, totallength - (i * 14))];
                NSData * msgData = [self dataFromHexString:[self hexFromStr:strMsg]];
                NSData * dataPacketNo = [[NSData alloc] initWithBytes:&i length:1];

                NSMutableData *completeData = [dataTotalLength mutableCopy];
                [completeData appendData:dataPacketNo];
                [completeData appendData:msgData];
                NSString * strRemainLength = [NSString stringWithFormat:@"%d",totallength - (i * 14) + 2];

                [self WriteSocketData:completeData withOpcode:@"14" withLength:strRemainLength withPeripheral:globalSocketPeripheral];
                NSLog(@"Pass=%@   TotalLength=%@   PacketLength=%@ PacketNo=%d    MsgData=%@",strMsg, dataTotalLength, strRemainLength, i, msgData);
            }
        }
    }
}
-(void)WriteAuthenticationKeytoDevice:(CBPeripheral *)peripheral
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
    
    NSString * strKey = [[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"];

    });
    
}

-(void)SendDatatoPeripheral:(NSData *)completeData withPeripheral:(CBPeripheral *)Peripheral
{
     CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_SKT];
     CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_SKT];
     [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:Peripheral data:completeData];
     NSLog(@"wrote for Alarm setting ====>>%@",completeData);
}
-(void)wifiScanTimeoutMethod
{
    [timerForwifi invalidate];
    [APP_DELEGATE endHudProcess];
}


@end
/*         Index   Length     PartIndex    RSSI/data    Data
 12  01      01      00          00          0000 0000000000000000000000
 
 
 12  10      00      0c          00         c756697468616d617354656368
 12  10      01      16          00         b84449524543542d39432d4550
 12  0c      01      16          01         50534f4e2d3941363431420000
 12  0d      02      07          00         b54f7074696d75730000000000
 12  10      03      16          00         a4426c756520526f636b7a2046
 12  0c      03      16          01         4669746e6573732047796d0000
 12  10      04      0f          00         a05468616c617373657279204d
 12  05      04      0f          01         4d657373000000000000000000
 12  0c      05      06          00         9e4b697368616e000000000000
 
 
 12eeeeee0000000000000000000000000000

 */

/*
 2021-01-20 10:28:17.211959+0530 SmartLightApp[2977:455409] wrote SOCKET DATA ====>><1200732e 74071e7b d55b56ca 432bad85 4f4f>
 2021-01-20 10:28:17.329806+0530 SmartLightApp[2977:455409] <<<<<SOCKET>>>>Recieved_from_Device>><CBCharacteristic: 0x282ee8420, UUID = 0000AB00-2687-4433-2208-ABF9B34FB000, properties = 0x1A, value = <12016f8d 234c93b7 dad9e561 abcf2b24 350a>, notifying = YES>
 2021-01-20 10:28:26.930729+0530 SmartLightApp[2977:455409] <<<<<SOCKET>>>>Recieved_from_Device>><CBCharacteristic: 0x282ee8420, UUID = 0000AB00-2687-4433-2208-ABF9B34FB000, properties = 0x1A, value = <1210a5ad acb8ba47 9b6f32bd 899eb09a feb5>, notifying = YES>
 2021-01-20 10:28:26.990272+0530 SmartLightApp[2977:455409] <<<<<SOCKET>>>>Recieved_from_Device>><CBCharacteristic: 0x282ee8420, UUID = 0000AB00-2687-4433-2208-ABF9B34FB000, properties = 0x1A, value = <1210fd13 8f112c08 a3562bad cccd834c d6aa>, notifying = YES>
 2021-01-20 10:28:26.991146+0530 SmartLightApp[2977:455409] <<<<<SOCKET>>>>Recieved_from_Device>><CBCharacteristic: 0x282ee8420, UUID = 0000AB00-2687-4433-2208-ABF9B34FB000, properties = 0x1A, value = <120cdafa 645f52d7 4a395104 c419dee1 b236>, notifying = YES>
 2021-01-20 10:28:26.996374+0530 SmartLightApp[2977:455409] <<<<<SOCKET>>>>Recieved_from_Device>><CBCharacteristic: 0x282ee8420, UUID = 0000AB00-2687-4433-2208-ABF9B34FB000, properties = 0x1A, value = <120d03d6 c64567c0 1f21ca0a ef611dcf 3194>, notifying = YES>
 2021-01-20 10:28:27.028182+0530 SmartLightApp[2977:455409] <<<<<SOCKET>>>>Recieved_from_Device>><CBCharacteristic: 0x282ee8420, UUID = 0000AB00-2687-4433-2208-ABF9B34FB000, properties = 0x1A, value = <12107617 69019c6d 481b691f c5402c5e 4269>, notifying = YES>
 2021-01-20 10:28:27.029045+0530 SmartLightApp[2977:455409] <<<<<SOCKET>>>>Recieved_from_Device>><CBCharacteristic: 0x282ee8420, UUID = 0000AB00-2687-4433-2208-ABF9B34FB000, properties = 0x1A, value = <120c9b3e d47c16cb aac7514d cde868c7 da7a>, notifying = YES>
 2021-01-20 10:28:27.051602+0530 SmartLightApp[2977:455409] <<<<<SOCKET>>>>Recieved_from_Device>><CBCharacteristic: 0x282ee8420, UUID = 0000AB00-2687-4433-2208-ABF9B34FB000, properties = 0x1A, value = <1210c6de c7e7373c 431cf803 9a9d0a52 cf4e>, notifying = YES>
 2021-01-20 10:28:27.078453+0530 SmartLightApp[2977:455409] <<<<<SOCKET>>>>Recieved_from_Device>><CBCharacteristic: 0x282ee8420, UUID = 0000AB00-2687-4433-2208-ABF9B34FB000, properties = 0x1A, value = <1205fb52 f65d9660 5c84cad7 8e70864e a67b>, notifying = YES>
 2021-01-20 10:28:27.080626+0530 SmartLightApp[2977:455409] <<<<<SOCKET>>>>Recieved_from_Device>><CBCharacteristic: 0x282ee8420, UUID = 0000AB00-2687-4433-2208-ABF9B34FB000, properties = 0x1A, value = <120c715e 097658cd 26e09a8d 122f0683 81df>, notifying = YES>
 2021-01-20 10:28:27.109072+0530 SmartLightApp[2977:455409] <<<<<SOCKET>>>>Recieved_from_Device>><CBCharacteristic: 0x282ee8420, UUID = 0000AB00-2687-4433-2208-ABF9B34FB000, properties = 0x1A, value = <12ee6ea3 17c452b8 081c936b 5b81d794 7189>, notifying = YES>
 **/
