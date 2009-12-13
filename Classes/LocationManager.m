//
//  LocationManager.m
//  Kickball
//
//  Created by Shawn Bernard on 12/12/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "LocationManager.h"

static LocationManager *globalLocationManager = nil;
static BOOL initialized = NO;

@implementation LocationManager

+ (LocationManager*)locationManager {
	if(!globalLocationManager) 
		globalLocationManager = [[LocationManager allocWithZone:nil] init];
	return globalLocationManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
		if (globalLocationManager == nil) 
			globalLocationManager = [super allocWithZone:zone];
    }
	
    return globalLocationManager;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

-(void)reset {
	locationDefined = NO;
	latitude = 0.f;
	longitude = 0.f;
}

- (id)init {
	if(initialized)
		return globalLocationManager;
	
	self = [super init];
    if (!self)
	{
		if(globalLocationManager)
			[globalLocationManager release];
		return nil;
	}
    
	
	locationManager = nil;
	initialized = YES;
	locationDenied = NO;
	[self reset];
    return self;
}

-(void)dealloc {
	if(locationManager)
		[locationManager release];
	[super dealloc];
}

- (void) stopUpdates {
	if (locationManager) {
        NSLog(@"stopping updates!");
		[locationManager stopUpdatingLocation];
	}
	[self reset];
}

- (void) startUpdates {
    NSLog(@"starting updates");
//	if(![[NSUserDefaults standardUserDefaults] boolForKey:@"UseLocations"]) {
//        NSLog(@"stopping updates - user doesn't want to detect location");
//		[self stopUpdates];
//		return;
//	}
    
	if (locationManager) {
        NSLog(@"stopping updates - location manager already started");
		[locationManager stopUpdatingLocation];
	} else {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.distanceFilter = 100;
		locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        NSLog(@"starting updateslocationmanager: %@", locationManager);
	}
	
	locationDefined = NO;
	[locationManager startUpdatingLocation];
}


// FIXME: stop location updates at a certain point
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation  fromLocation:(CLLocation *)oldLocation {
	locationDenied = NO;
//	if(![[NSUserDefaults standardUserDefaults] boolForKey:@"UseLocations"]) {
//		[self stopUpdates];
//		return;
//	}
    
//	if(![self longURL] || ![[self longURL] isEqualToString:[self longURLWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude]])
//	{
		latitude = newLocation.coordinate.latitude;
    longitude = newLocation.coordinate.longitude;
    NSLog(@"latitude: %f", latitude);
    NSLog(@"longitude: %f", longitude);
		locationDefined = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateLocationNotification" object: nil];
//	}
}

- (BOOL) locationDenied {
	return locationDenied;
}

- (BOOL) locationServicesEnabled {
	CLLocationManager* lm = locationManager;
	if(!lm)
		lm = [[[CLLocationManager alloc] init] autorelease];
	return lm.locationServicesEnabled;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	[self reset];
    
    if ([error domain] == kCLErrorDomain) {
        switch ([error code]) {
            case kCLErrorDenied:
				locationDenied = YES;
				[self stopUpdates];
                break;
            case kCLErrorLocationUnknown:
                break;
            default:
                break;
        }
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateLocationNotification" object: nil];
}

- (BOOL) locationDefined {
	return locationDefined;
}

- (float) latitude {
	return latitude;
}

- (float) longitude {
	return longitude;
}


@end
