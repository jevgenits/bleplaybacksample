//
//  BLECentralService.h
//  BLECentralApp
//
//  Created by Jevgeni Tsaikin on 2019-08-09.
//  Copyright © 2019 Jevgeni Tsaikin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CentralServiceState) {
    CentralServiceStateOffline,
    CentralServiceStateOnline,
    CentralServiceStateConnecting,
    CentralServiceStateConnected
};

@protocol CentralServiceDelegate

- (void)stateChanged:(CentralServiceState)state;

@end

@interface BLECentralService : NSObject

@property (nonatomic, weak) id<CentralServiceDelegate> delegate;

@property (nonatomic, readonly) CentralServiceState state;

- (void)startScanningForPeritherals;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
