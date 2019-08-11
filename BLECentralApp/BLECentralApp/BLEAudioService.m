//
//  BLEAudioService.m
//  BLECentralApp
//
//  Created by Jevgeni Tsaikin on 2019-08-09.
//  Copyright © 2019 Jevgeni Tsaikin. All rights reserved.
//

#import "BLEAudioService.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface BLEAudioService () <AVAudioPlayerDelegate>

@property (nullable, nonatomic, strong, readwrite) AVAudioPlayer *player;

@end

@implementation BLEAudioService

+ (instancetype)sharedInstance
{
    static BLEAudioService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BLEAudioService alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
        __weak BLEAudioService *weakSelf = self;
        
        [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
            if (weakSelf.player != nil && weakSelf.player.rate == 1.0) {
                [self.player pause];
                return MPRemoteCommandHandlerStatusSuccess;
            }
            return MPRemoteCommandHandlerStatusCommandFailed;
        }];
        
        [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
            if (weakSelf.player != nil && weakSelf.player.rate == 0.0) {
                [self.player play];
                return MPRemoteCommandHandlerStatusSuccess;
            }
            return MPRemoteCommandHandlerStatusCommandFailed;
        }];
    }
    
    return self;
}

- (void)dealloc
{
    [self stopPlayback];
}

- (void)startPlayback
{
    NSLog(@"BLE Audio: Starting playback");
    NSError *categoryError = nil;
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&categoryError];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:0 error:&categoryError];
    
    if (categoryError) {
        NSLog(@"%@", [NSString stringWithFormat:@"BLE: Failed to set category: %@", categoryError.localizedDescription]);
        return;
    }
    
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&activationError];
    if (activationError) {
        NSLog(@"%@", [NSString stringWithFormat:@"BLE: Failed to activate category: %@", activationError.localizedDescription]);
        return;
    }
    
    NSString *audioPath = [[NSBundle mainBundle] pathForResource: @"sample" ofType:@"mp3"];
    NSURL *playbackUrl = [NSURL fileURLWithPath:audioPath];
    NSError *playbackError = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:playbackUrl error:&playbackError];
    if (playbackError) {
        NSLog(@"%@", [NSString stringWithFormat:@"BLE Audio: Failed to start playback: %@", playbackError.localizedDescription]);
        return;
    }
    
    [self.player play];
}

- (void)stopPlayback
{
    NSLog(@"BLE Audio: Stopping playback");
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:&error];
    if (error) {
        NSLog(@"%@", [NSString stringWithFormat:@"BLE Audio: Failed to stop playback: %@", error.localizedDescription]);
        return;
    }
    
    [self.player stop];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"Audio Player Did Finish Playing");
}

#pragma mark - Private

- (void)setupNowPlaying
{
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
    
    [songInfo setObject:@"Test Title" forKey:MPMediaItemPropertyTitle];
    [songInfo setObject:@"Test Artist" forKey:MPMediaItemPropertyArtist];
    [songInfo setObject:@"Test Album" forKey:MPMediaItemPropertyAlbumTitle];

    MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(300, 300) requestHandler:^UIImage * _Nonnull(CGSize size) {
        UIImage *dummyArt = [UIImage imageNamed:@"lockscreen"];
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [dummyArt drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }];
    [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
    
    [playingInfoCenter setNowPlayingInfo:songInfo];
}

@end

