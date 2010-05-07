//
//  KBLocationManager.m
//  Kickball
//
//  Created by Shawn Bernard on 12/12/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBLocationManager.h"
#import "Utilities.h"


static KBLocationManager *globalLocationManager = nil;
static BOOL initialized = NO;

@implementation KBLocationManager

@synthesize locationMeasurements;
@synthesize bestEffortAtLocation;

+ (KBLocationManager*)locationManager {
	if(!globalLocationManager)  {
        globalLocationManager = [[KBLocationManager allocWithZone:nil] init];
        //kCLLocationAccuracyBest
    }
		
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
    [self performSelector:@selector(stopUpdates) withObject:@"Timed Out" afterDelay:[[NSNumber numberWithDouble:60] doubleValue]];
    return self;
}

-(void)dealloc {
	if(locationManager)
		[locationManager release];
	[super dealloc];
}

- (CLLocationDistance) distanceFromCoordinate:(CLLocation*)coordinate {
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    return [currentLocation getDistanceFrom:coordinate];
}

//+ (void) - (void) stopUpdates:(NSString *)state {
//	[locationManager stopUpdatingLocation];
//}

- (void) stopUpdates {
	if (locationManager) {
        NSLog(@"stopping updates!");
		[locationManager stopUpdatingLocation];
        NSLog(@"***** STOPPING LOCATION MANAGER UPDATES ******");
	}
	//[self reset];
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
//		locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
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
    
    // store all of the measurements, just so we can see what kind of data we might receive
    [locationMeasurements addObject:newLocation];
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
//    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
//    if (locationAge > 5.0) return;
//    // test that the horizontal accuracy does not indicate an invalid measurement
//    if (newLocation.horizontalAccuracy < 0) return;
//    // test the measurement to see if it is more accurate than the previous measurement
//    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy < newLocation.horizontalAccuracy) {
//        // store the location as the "best effort"
//        self.bestEffortAtLocation = newLocation;
        
        latitude = newLocation.coordinate.latitude;
        longitude = newLocation.coordinate.longitude;
        NSLog(@"latitude: %f", latitude);
        NSLog(@"longitude: %f", longitude);
        NSLog(@"bestEffortAtLocation: %@", bestEffortAtLocation);
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:latitude forKey:kLastLatitudeKey];
    [userDefaults setFloat:longitude forKey:kLastLongitudeKey];
        
		locationDefined = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateLocationNotification" object: nil];
        
//        // test the measurement to see if it meets the desired accuracy
//        //
//        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue 
//        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of 
//        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
//        //
////        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
////            // we have a measurement that meets our requirements, so we can stop updating the location
////            // 
////            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
////            //
////            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
////            NSLog(@"***** STOPPING LOCATION MANAGER UPDATES ******");
////            [self stopUpdates];
////            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdates) object:nil];
////        }
//    }
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
