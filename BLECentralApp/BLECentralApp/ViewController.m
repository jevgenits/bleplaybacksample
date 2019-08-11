//
//  ViewController.m
//  BLECentralApp
//
//  Created by Jevgeni Tsaikin on 2019-08-09.
//  Copyright © 2019 Jevgeni Tsaikin. All rights reserved.
//

#import "ViewController.h"
#import "BLECentralService.h"

@interface ViewController () <CentralServiceDelegate>

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;

@property (strong, nonatomic) BLECentralService *centralService;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.centralService = [BLECentralService new];
    self.centralService.delegate = self;
}

- (IBAction)connectTapped:(id)sender
{
    [self.centralService startScanningForPeritherals];
}

- (IBAction)disconnectTapped:(id)sender
{
    [self.centralService stop];
}

- (void)updateButtons:(CentralServiceState)state
{
    switch (state) {
        case CentralServiceStateOffline:
            [self.connectButton setEnabled:NO];
            [self.disconnectButton setEnabled:NO];
            
            [self.stateLabel setText:@"Offline"];
            break;
        case CentralServiceStateOnline:
            [self.connectButton setEnabled:YES];
            [self.disconnectButton setEnabled:NO];
            
            [self.stateLabel setText:@"Online"];
            break;
        case CentralServiceStateConnecting:
            [self.connectButton setEnabled:NO];
            [self.disconnectButton setEnabled:NO];
            
            [self.stateLabel setText:@"Connecting"];
            break;
        case CentralServiceStateConnected:
            [self.connectButton setEnabled:NO];
            [self.disconnectButton setEnabled:YES];
            
            [self.stateLabel setText:@"Connected"];
            break;
    }
}

#pragma MARK : - CentralServiceDelegate

- (void)stateChanged:(CentralServiceState)state
{
    [self updateButtons:state];
}

@end
