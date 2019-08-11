//
//  BLEAudioService.h
//  BLECentralApp
//
//  Created by Jevgeni Tsaikin on 2019-08-09.
//  Copyright © 2019 Jevgeni Tsaikin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLEAudioService : NSObject

+ (instancetype)sharedInstance;

- (void)startPlayback;
- (void)stopPlayback;

@end

NS_ASSUME_NONNULL_END


