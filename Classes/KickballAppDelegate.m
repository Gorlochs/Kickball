//
//  KickballAppDelegate.m
//  Kickball
//
//  Created by Shawn Bernard on 10/25/09.
//  Copyright Gorloch Interactive, LLC 2009. All rights reserved.
//

#import "KickballAppDelegate.h"
#import "FriendsListViewController.h"
#import "Beacon.h"
#import <CoreLocation/CoreLocation.h>

@implementation KickballAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    //[window addSubview:viewController.view];
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
    
    // Pinch Analytics
    NSString *applicationCode = @"51512b37fa78552a6981778e1e652682";
    [Beacon initAndStartBeaconWithApplicationCode:applicationCode
                                  useCoreLocation:YES useOnlyWiFi:NO];    
    
    // this is just a sample. this should be removed eventually.
    [[Beacon shared] startSubBeaconWithName:@"App launched!" timeSession:NO];
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    if (manager.locationServicesEnabled == NO) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
        [servicesDisabledAlert release];
    }
    [manager release];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [Beacon endBeacon];
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
