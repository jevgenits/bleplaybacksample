//
//  BLEPeripheralHandler.m
//  BLECentralApp
//
//  Created by Jevgeni Tsaikin on 2019-08-09.
//  Copyright © 2019 Jevgeni Tsaikin. All rights reserved.
//

#import "BLEPeripheralHandler.h"
#import "BLEConstants.h"
#import "BLEAudioService.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEPeripheralHandler () <CBPeripheralDelegate>

@property (nullable, nonatomic, strong, readwrite) CBPeripheral *peripheral;
@property (nullable, nonatomic, strong, readwrite) CBService *discoveredService;
@property (nullable, nonatomic, strong, readwrite) CBCharacteristic *discoveredCharacteristic;

@end

@implementation BLEPeripheralHandler

- (instancetype)initWithPeritheral:(CBPeripheral *)peripheral
{
    self = [super init];
    
    if (self) {
        _peripheral = peripheral;
        _peripheral.delegate = self;
    }
    
    return self;
}

- (void)startDiscoveringServices
{
    [self.peripheral discoverServices:nil];
}

- (void)disconnect
{
    if (self.discoveredCharacteristic != nil) {
        [self.peripheral setNotifyValue:NO forCharacteristic:self.discoveredCharacteristic];
    }
    self.discoveredCharacteristic = nil;
    self.discoveredService = nil;
    self.peripheral = nil;
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    if (error) {
        NSLog(@"BLE: error while discovering services: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    for (CBService *service in peripheral.services) {
        NSLog(@"BLE: discovered service %@", service);
        if ([service.UUID.UUIDString isEqualToString:BLEPeripheralServiceUUIDString]) {
            self.discoveredService = service;
            [self.peripheral discoverCharacteristics:nil forService:self.discoveredService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
    if (error) {
        NSLog(@"BLE: error while discovering characteristics %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"BLE: discovered characteristic %@", characteristic);
        if ([characteristic.UUID.UUIDString isEqualToString:BLEPeripheralCharacteristicUUIDString]) {
            self.discoveredCharacteristic = characteristic;
            [self.peripheral readValueForCharacteristic:self.discoveredCharacteristic];
            [self.peripheral setNotifyValue:YES forCharacteristic:self.discoveredCharacteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (error) {
        NSLog(@"BLE: error while updating value for characteristic %@", [error localizedDescription]);
        return;
    }
    NSLog(@"BLE: did update value for characteristic %@", characteristic);
    NSData * const data = characteristic.value;
    if (data && data.length > 0) {
        NSString * const value = [NSString stringWithUTF8String:[data bytes]];
        if ([value isEqual: @"play"]) {
            [[BLEAudioService sharedInstance] startPlayback];
        } else if ([value isEqual: @"stop"])  {
            [[BLEAudioService sharedInstance] stopPlayback];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (error) {
        NSLog(@"BLE: failed to update notification state: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
}

- (void)cleanup
{
    if (self.peripheral.state != CBPeripheralStateConnected) {
        return;
    }
    
    if (self.discoveredCharacteristic.isNotifying) {
        [self.peripheral setNotifyValue:NO forCharacteristic:self.discoveredCharacteristic];
    }
}

@end
