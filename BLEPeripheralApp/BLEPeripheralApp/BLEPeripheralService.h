//
//  BLEPeripheralService.h
//  BLEPeripheralApp
//
//  Created by Jevgeni Tsaikin on 2019-08-09.
//  Copyright © 2019 Jevgeni Tsaikin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PeripheralServiceState) {
    PeripheralServiceStateOffline,
    PeripheralServiceStateOnline,
    PeripheralServiceStateAdvertising,
    PeripheralServiceStateConnected
};

@protocol PeripheralServiceDelegate

- (void)stateChanged:(PeripheralServiceState)state;

@end

@interface BLEPeripheralService : NSObject

@property (nonatomic, weak) id<PeripheralServiceDelegate> delegate;

@property (nonatomic, readonly) PeripheralServiceState state;

- (void)startService;
- (void)stopService;

- (void)sendPlay;
- (void)sendStop;

@end

NS_ASSUME_NONNULL_END
