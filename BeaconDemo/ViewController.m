//
//  ViewController.m
//  BeaconDemo
//
//  Created by Oleksandr Skrypnyk on 10/19/13.
//  Copyright (c) 2013 Unteleported. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "CoreBluetoothController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>

static NSString *const uuid = @"E4C8A4FC-F68B-470D-959F-29382AF72CE7";
static NSString *const characeristicUuid = @"90AE8741-FFA4-48AA-831F-52A96F424614";
static NSString *const beaconIdentifier = @"beaconId";

@interface ViewController () <CBPeripheralManagerDelegate, CLLocationManagerDelegate, CoreBluetoothDelegate>

@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) NSNumber *power;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CoreBluetoothController *bluetoothController;

@property (nonatomic, weak) IBOutlet UILabel *proximityLabel;

@end

@implementation ViewController

@synthesize serviceUUID;
@synthesize characteristicUUID;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.uuid = [[NSUUID alloc] initWithUUIDString:uuid];

  if ([AppDelegate IOS7]) {
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.uuid identifier:beaconIdentifier];
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    self.beaconRegion.notifyOnEntry = YES;
    self.beaconRegion.notifyOnExit = YES;

    if ([AppDelegate iPhone5]) {
      self.proximityLabel.text = @"I am a beacon. Do not close me!";
      self.power = @-59;
      NSDictionary *peripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:self.power];
      self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
      [self.peripheralManager startAdvertising:peripheralData];
    } else {
      self.locationManager = [CLLocationManager new];
      self.locationManager.delegate = self;
      [self.locationManager startMonitoringForRegion:self.beaconRegion];
      [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
  } else {
    self.bluetoothController = [CoreBluetoothController sharedInstance];
    self.bluetoothController.delegate = self;
    self.serviceUUID = uuid;
    self.characteristicUUID = characteristicUUID;
    [self.bluetoothController startReadingRSSI];
  }
}

#pragma mark - CoreBluetoothDelegate (iOS 6)

- (void)didUpdateRSSI:(NSInteger)RSSI {
  CLProximity proximity = CLProximityUnknown;

  if (RSSI < 0 && RSSI > -50) {
    proximity = CLProximityImmediate;
  } else if (RSSI <= -50 && RSSI >= -80) {
    proximity = CLProximityNear;
  } else if (RSSI < -80) {
    proximity = CLProximityFar;
  }

  [self handleProximityChange:proximity];
}

#pragma mark - CBPeripheralManagerDelegate (iOS 7)

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
  NSLog(@"Peripheral manager did update state");
}

#pragma mark - CLLocationManagerDelegate (iOS 7)

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
  if ([region.identifier isEqualToString:beaconIdentifier]) {
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = @"There's a beacon nearby!";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
  }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
  if ([region.identifier isEqualToString:beaconIdentifier]) {
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = @"There was a beacon nearby!";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
  }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
  if ([beacons count] > 0) {
    CLBeacon *beacon = beacons[0];
    [self handleProximityChange:beacon.proximity];
  }
}

#pragma mark - Private Methods

- (void)handleProximityChange:(NSInteger)proximity {
  NSString *message = @"";

  switch (proximity) {
    case CLProximityImmediate: {
      message = @"You found the beacon!";
      UILocalNotification *notification = [UILocalNotification new];
      notification.alertBody = message;
      [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
      break;
    }

    case CLProximityNear:
      message = @"You're getting warmer";
      break;

    case CLProximityFar:
      message = @"You're freezing cold";
      break;

    case CLProximityUnknown:
      message = @"I'm not sure where you're";
      break;

    default:
      break;
  }

  self.proximityLabel.text = message;
}

@end
