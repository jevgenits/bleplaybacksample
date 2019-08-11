//
//  BLEPeripheralService.m
//  BLEPeripheralApp
//
//  Created by Jevgeni Tsaikin on 2019-08-09.
//  Copyright © 2019 Jevgeni Tsaikin. All rights reserved.
//

#import "BLEPeripheralService.h"

#import <CoreBluetooth/CoreBluetooth.h>

static NSString * const BLEPeripheralServiceUUIDString = @"017EFB0B-3ED7-4794-B55E-B711CEE7164C";
static NSString * const BLEPeripheralCharacteristicUUIDString = @"C8C6F2F4-CB6C-4797-9098-19830853F0FE";

@interface BLEPeripheralService () <CBPeripheralManagerDelegate>

@property (nonatomic, strong, readonly) CBUUID *peripheralServiceUUID;
@property (nonatomic, strong, readonly) CBUUID *peripheralCharacteristicUUID;
@property (nonatomic, strong, readonly) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong, readonly) CBMutableService *peripheralService;
@property (nonatomic, strong, readwrite) CBMutableCharacteristic *peripheralCharacteristic;
@property (nonatomic, readwrite) PeripheralServiceState state;

@end

@implementation BLEPeripheralService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        _peripheralManager.delegate = self;
        _peripheralServiceUUID = [CBUUID UUIDWithString:BLEPeripheralServiceUUIDString];
        _peripheralCharacteristicUUID = [CBUUID UUIDWithString:BLEPeripheralCharacteristicUUIDString];
        _peripheralService = [[CBMutableService alloc] initWithType:_peripheralServiceUUID primary:YES];
        _state = PeripheralServiceStateOffline;
    }
    return self;
}

- (void)setState:(PeripheralServiceState)state
{
    _state = state;
    [self.delegate stateChanged:state];
}

- (void)startService
{
    NSLog(@"BLE: starting service");
    self.peripheralCharacteristic = [[CBMutableCharacteristic alloc] initWithType:self.peripheralCharacteristicUUID
                                                                       properties:CBCharacteristicPropertyRead+CBCharacteristicPropertyNotify value:nil
                                                                      permissions:CBAttributePermissionsReadable];
    self.peripheralService.characteristics = @[self.peripheralCharacteristic];
    [self.peripheralManager addService:self.peripheralService];
}

- (void)stopService
{
    NSLog(@"BLE: stopping service");
    if (self.peripheralManager.isAdvertising) {
        [self.peripheralManager stopAdvertising];
    }
    [self.peripheralManager removeService:self.peripheralService];
    if (self.peripheralManager.state == CBManagerStatePoweredOn) {
        self.state = PeripheralServiceStateOnline;
    } else {
        self.state = PeripheralServiceStateOffline;
    }
}

- (void)sendPlay
{
    NSLog(@"BLE: sending play message");
    if (self.peripheralManager.state == CBManagerStatePoweredOn) {
        [self updateCharacteristicWithCommand:@"play"];
    }
}

- (void)sendStop
{
    NSLog(@"BLE: sending stop message");
    if (self.peripheralManager.state == CBManagerStatePoweredOn) {
        [self updateCharacteristicWithCommand:@"stop"];
    }
}

- (void)updateCharacteristicWithCommand:(nonnull NSString *)command
{
    if (!command) {
        return;
    }
    
    NSData * const data = [command dataUsingEncoding:NSUTF8StringEncoding];
    BOOL didSendValue = [self.peripheralManager updateValue:data
                                          forCharacteristic:self.peripheralCharacteristic
                                       onSubscribedCentrals:nil];
    if (!didSendValue) {
        NSLog(@"BLE: failed to send updated value for characteristic");
    }
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(nonnull CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBManagerStateUnknown:
            NSLog(@"BLE: peripheralManagerDidUpdateState to Unknown");
            self.state = PeripheralServiceStateOffline;
            break;
        case CBManagerStateResetting:
            NSLog(@"BLE: peripheralManagerDidUpdateState to Resetting");
            self.state = PeripheralServiceStateOffline;
            break;
        case CBManagerStateUnsupported:
            NSLog(@"BLE: peripheralManagerDidUpdateState to Unsupported");
            self.state = PeripheralServiceStateOffline;
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"BLE: peripheralManagerDidUpdateState to Unauthorized");
            self.state = PeripheralServiceStateOffline;
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"BLE: peripheralManagerDidUpdateState to PoweredOff");
            self.state = PeripheralServiceStateOffline;
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"BLE: peripheralManagerDidUpdateState to PoweredOn");
            self.state = PeripheralServiceStateOnline;
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"BLE: Error publishing service: %@", [error localizedDescription]);
        return;
    }
    
    NSLog(@"BLE: service added, start advertising");
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[self.peripheralService.UUID]}];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
        NSLog(@"BLE: Error advertising: %@", [error localizedDescription]);
        return;
    }
    NSLog(@"BLE: started advertising peripheral");
    self.state = PeripheralServiceStateAdvertising;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"BLE: central subscribed to characteristic %@", characteristic);
    self.state = PeripheralServiceStateConnected;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"BLE: central unsubscribed from characteristic %@", characteristic);
    if (self.peripheralManager.isAdvertising) {
        self.state = PeripheralServiceStateAdvertising;
    } else if (self.peripheralManager.state == CBManagerStatePoweredOn) {
        self.state = PeripheralServiceStateOnline;
    } else {
        self.state = PeripheralServiceStateOffline;
    }
}

@end
