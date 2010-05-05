//
//  KBLocationManager.h
//  Kickball
//
//  Created by Shawn Bernard on 12/12/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface KBLocationManager : NSObject <CLLocationManagerDelegate> {
    CLLocationManager* locationManager;
    BOOL locationDefined;
    float latitude;
    float longitude;
    
    BOOL locationDenied;
    
    // stuff from Apple's LocateMe app
    NSMutableArray *locationMeasurements;
    CLLocation *bestEffortAtLocation;
}

@property (nonatomic, retain) NSMutableArray *locationMeasurements;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;

+ (KBLocationManager*)locationManager;

- (void) startUpdates;
- (void) stopUpdates;
- (BOOL) locationDefined;
- (BOOL) locationDenied;
- (float) latitude;
- (float) longitude;

- (BOOL) locationServicesEnabled;
+ (void) stopAllUpdates:(NSString *)state;

- (CLLocationDistance) distanceFromCoordinate:(CLLocation*)coordinate;

@end
