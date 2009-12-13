//
//  LocationManager.h
//  Kickball
//
//  Created by Shawn Bernard on 12/12/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface LocationManager : NSObject <CLLocationManagerDelegate> {
    CLLocationManager* locationManager;
    BOOL locationDefined;
    float latitude;
    float longitude;
    
    BOOL locationDenied;
}

+ (LocationManager*)locationManager;

- (void) startUpdates;
- (void) stopUpdates;
- (BOOL) locationDefined;
- (BOOL) locationDenied;
- (float) latitude;
- (float) longitude;

- (BOOL) locationServicesEnabled;

@end
