//
//  BLEPeripheralHandler.h
//  BLECentralApp
//
//  Created by Jevgeni Tsaikin on 2019-08-09.
//  Copyright © 2019 Jevgeni Tsaikin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;

NS_ASSUME_NONNULL_BEGIN

@interface BLEPeripheralHandler : NSObject

- (instancetype)initWithPeritheral:(CBPeripheral *)peripheral NS_DESIGNATED_INITIALIZER;
- (void)startDiscoveringServices;
- (void)disconnect;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
