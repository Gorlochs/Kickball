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

@implementation KickballAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
    
    // Pinch Analytics
    NSString *applicationCode = @"51512b37fa78552a6981778e1e652682";
    [Beacon initAndStartBeaconWithApplicationCode:applicationCode
                                  useCoreLocation:YES useOnlyWiFi:NO];    
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
