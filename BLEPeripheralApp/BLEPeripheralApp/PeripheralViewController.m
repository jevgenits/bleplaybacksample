//
//  ViewController.m
//  BLEPeripheralApp
//
//  Created by Jevgeni Tsaikin on 2019-08-09.
//  Copyright © 2019 Jevgeni Tsaikin. All rights reserved.
//

#import "PeripheralViewController.h"
#import "BLEPeripheralService.h"

@interface PeripheralViewController () <PeripheralServiceDelegate>

@property (weak, nonatomic) IBOutlet UIButton *startServiceButton;
@property (weak, nonatomic) IBOutlet UIButton *sendStartPlaybackButton;
@property (weak, nonatomic) IBOutlet UIButton *sendStartMixinPlaybackButton;
@property (weak, nonatomic) IBOutlet UIButton *sendStopPlaybackButton;
@property (weak, nonatomic) IBOutlet UIButton *stopServiceButton;

@property (strong, nonatomic) BLEPeripheralService *peripheralService;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@end

@implementation PeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.peripheralService = [BLEPeripheralService new];
    self.peripheralService.delegate = self;
    [self updateButtons:self.peripheralService.state];
}

- (IBAction)startServiceTapped:(id)sender
{
    [self.peripheralService startService];
}

- (IBAction)sendStartPlaybackTapped:(id)sender
{
    [self.peripheralService sendPlay];
}

- (IBAction)sendStartMixinPlaybackTapped:(id)sender
{
    [self.peripheralService sendMixinPlay];
}

- (IBAction)sendStopPlaybackTapped:(id)sender
{
    [self.peripheralService sendStop];
}

- (IBAction)stopServiceTapped:(id)sender
{
    [self.peripheralService stopService];
}

- (void)updateButtons:(PeripheralServiceState)state
{
    switch (state) {
        case PeripheralServiceStateOffline:
            [self.startServiceButton setEnabled:YES];
            [self.sendStartPlaybackButton setEnabled:NO];
            [self.sendStartMixinPlaybackButton setEnabled:NO];
            [self.sendStopPlaybackButton setEnabled:NO];
            [self.stopServiceButton setEnabled:NO];
            
            [self.stateLabel setText:@"Offline"];
            break;
        case PeripheralServiceStateConnected:
            [self.startServiceButton setEnabled:NO];
            [self.sendStartPlaybackButton setEnabled:YES];
            [self.sendStartMixinPlaybackButton setEnabled:YES];
            [self.sendStopPlaybackButton setEnabled:YES];
            [self.stopServiceButton setEnabled:YES];
            
            [self.stateLabel setText:@"Connected"];
            break;
        case PeripheralServiceStateAdvertising:
            [self.startServiceButton setEnabled:NO];
            [self.sendStartPlaybackButton setEnabled:NO];
            [self.sendStartMixinPlaybackButton setEnabled:NO];
            [self.sendStopPlaybackButton setEnabled:NO];
            [self.stopServiceButton setEnabled:YES];
            
            [self.stateLabel setText:@"Advertising"];
            break;
        case PeripheralServiceStateOnline:
            [self.startServiceButton setEnabled:YES];
            [self.sendStartPlaybackButton setEnabled:NO];
            [self.sendStartMixinPlaybackButton setEnabled:NO];
            [self.sendStopPlaybackButton setEnabled:NO];
            [self.stopServiceButton setEnabled:NO];
            
            [self.stateLabel setText:@"Online"];
            break;
    }
}

#pragma MARK : - PeripheralServiceDelegate

- (void)stateChanged:(PeripheralServiceState)state
{
    [self updateButtons:state];
}

@end
