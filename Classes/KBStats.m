//
//  KBStats.m
//  Kickball
//
//  Created by Shawn Bernard on 3/26/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBStats.h"
#import "ASIFormDataRequest.h"
#import "LocationManager.h"
#import "FoursquareAPI.h"

#define CHECKIN_URL @"http://kickball.gorlochs.com/kickball/checkin_stats.xml"
//#define CHECKIN_URL @"http://gorlochs.literalshore.com:3000/kickball/checkin_stats.xml"

static KBStats* _stats = nil;

@implementation KBStats


- (void) checkinStat:(FSCheckin*)checkin {
    NSLog(@"stat checkin: %@", checkin);
    ASIFormDataRequest *statRequest = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:CHECKIN_URL]] autorelease];
    
    [statRequest setRequestMethod:@"POST"];
    [statRequest setPostValue:[[FoursquareAPI sharedInstance] currentUser].userId forKey:@"checkin_stat[userId]"];
    [statRequest setPostValue:checkin.venue.venueid forKey:@"checkin_stat[venueId]"];
    [statRequest setPostValue:checkin.venue.city forKey:@"checkin_stat[city]"];
    [statRequest setPostValue:checkin.venue.venueState forKey:@"checkin_stat[state]"];
    [statRequest setPostValue:[NSString stringWithFormat:@"%f", [[LocationManager locationManager] latitude]] forKey:@"checkin_stat[latitude]"];
    [statRequest setPostValue:[NSString stringWithFormat:@"%f", [[LocationManager locationManager] longitude]] forKey:@"checkin_stat[longitude]"];
    [statRequest setDidFailSelector:@selector(statWentWrong:)];
    [statRequest setDidFinishSelector:@selector(statDidFinish:)];
    [statRequest setTimeOutSeconds:100];
    [statRequest setDelegate:self];
    [statRequest startAsynchronous];
}

     
- (void) statWentWrong:(ASIHTTPRequest *) request {
    NSLog(@"BOOOOOOOOOOOO!");
    NSLog(@"response msg: %@", request.responseStatusMessage);
}

- (void) statDidFinish:(ASIHTTPRequest *) request {
    NSLog(@"YAAAAAAAAAAAY!");
    NSLog(@"response msg: %@", request.responseStatusMessage);
}
         
#pragma mark singleton stuff

+ (KBStats*) stats {
	@synchronized([KBStats class])
	{
		if (!_stats)
			[[self alloc] init];
        
		return _stats;
	}
    
	return nil;
}


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (_stats == nil) {
            _stats = [super allocWithZone:zone];
            return _stats;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

+ (id) alloc {
	@synchronized([KBStats class])
	{
		NSAssert(_stats == nil, @"Attempted to allocate a second instance of a singleton.");
		_stats = [super alloc];
		return _stats;
	}
    
	return nil;
}

-(id)init {
	self = [super init];
	if (self != nil) {
		// initialize stuff here
	}
    
	return self;
}

@end
