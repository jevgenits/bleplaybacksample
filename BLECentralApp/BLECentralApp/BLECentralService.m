//
//  BLECentralService.m
//  BLECentralApp
//
//  Created by Jevgeni Tsaikin on 2019-08-09.
//  Copyright © 2019 Jevgeni Tsaikin. All rights reserved.
//

#import "BLECentralService.h"
#import "BLEPeripheralHandler.h"
#import "BLEConstants.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface BLECentralService () <CBCentralManagerDelegate>

@property (nonatomic, strong, readonly) CBUUID *peritheralServiceUUID;
@property (nonatomic, strong, readonly) CBUUID *peritheralCharacteristicUUID;
@property (nonatomic, strong, readonly) CBCentralManager *centralManager;
@property (nonatomic, strong, readwrite) CBPeripheral *discoveredPeripheral;
@property (nonatomic, strong, readwrite) BLEPeripheralHandler *peripheralHandler;

@property (nonatomic, readwrite) CentralServiceState state;

@end

@implementation BLECentralService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        _centralManager.delegate = self;
        _peritheralServiceUUID = [CBUUID UUIDWithString:BLEPeripheralServiceUUIDString];
        _peritheralCharacteristicUUID = [CBUUID UUIDWithString:BLEPeripheralCharacteristicUUIDString];
    }
    return self;
}

- (void)stop
{
    [self stopScanning];
    [self disconnectPeritheral];
}

- (void)setState:(CentralServiceState)state
{
    _state = state;
    [self.delegate stateChanged:state];
}

- (void)dealloc
{
    [self stop];
}

- (void)startScanningForPeritherals
{
    NSLog(@"BLE: start scanning for peripherals");
    if (self.centralManager.state == CBManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:@[self.peritheralServiceUUID] options:nil];
        self.state = CentralServiceStateConnecting;
    }
}

- (void)disconnectPeritheral
{
    if (self.peripheralHandler != nil) {
        [self.peripheralHandler disconnect];
        self.peripheralHandler = nil;
    }
    
    if (self.discoveredPeripheral != nil) {
        if (self.discoveredPeripheral.state == CBPeripheralStateConnected) {
            [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
        }
        self.discoveredPeripheral = nil;
    }
}

- (void)stopScanning
{
    if (self.centralManager.isScanning) {
        NSLog(@"BLE: stop scanning for peripherals");
        [self.centralManager stopScan];
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@"BLE: Central manager state update to: Unknown");
            self.state = CentralServiceStateOffline;
            break;
        case CBManagerStateResetting:
            NSLog(@"BLE: Central manager state update to: Resetting");
            self.state = CentralServiceStateOffline;
            break;
        case CBManagerStateUnsupported:
            NSLog(@"BLE: Central manager state update to: Unsupported");
            self.state = CentralServiceStateOffline;
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"BLE: Central manager state update to: Unauthorized");
            self.state = CentralServiceStateOffline;
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"BLE: Central manager state update to: PoweredOff");
            self.state = CentralServiceStateOffline;
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"BLE: Central manager state update to: PoweredOn");
            self.state = CentralServiceStateOnline;
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    NSLog(@"BLE: discovered with name %@", peripheral.name);
    self.discoveredPeripheral = peripheral;
    [self.centralManager connectPeripheral:peripheral options:nil];
    [self stopScanning];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"BLE: peripheral connected %@", peripheral.name);
    self.peripheralHandler = [[BLEPeripheralHandler alloc] initWithPeritheral:peripheral];
    [self.peripheralHandler startDiscoveringServices];
    self.state = CentralServiceStateConnected;
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error) {
        NSLog(@"BLE: error while disconnecting peripheral: %@", [error localizedDescription]);
    }
    NSLog(@"BLE: peripheral did disconnect %@", peripheral.name);
    [self disconnectPeritheral];
    if (self.centralManager.state == CBManagerStatePoweredOn) {
        self.state = CentralServiceStateOnline;
    } else {
        self.state = CentralServiceStateOffline;
    }
}

@end
