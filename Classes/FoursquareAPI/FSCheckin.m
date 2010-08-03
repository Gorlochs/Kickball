//
//  FSCheckin.m
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "FSCheckin.h"
#import "Utilities.h"


@implementation FSCheckin
@synthesize message, venue, badges, specials, created, checkinId, shout, display, user, scoring, mayor, isMayor, truncatedTimeUnits, truncatedTimeNumeral, distanceFromLoggedInUser, checkedInUserGetsPings;

- (NSDate*) convertUTCCheckinDateToLocal {
    NSDate *gmtDate = [[[Utilities sharedInstance] foursquareCheckinDateFormatter] dateFromString:self.created];
    DLog(@"checkin created on: %@", self.created);
    NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
    NSTimeInterval localTimeInterval = [gmtDate timeIntervalSinceReferenceDate] + timeZoneOffset;
    NSDate *localDate = [NSDate dateWithTimeIntervalSinceReferenceDate:localTimeInterval];
    return localDate;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"(CHECKIN : message=%@ ; venue=%@ ; created=%@ ; user=%@ ; checkinId=%@ ; badges=%@ ; mayor=%@; isMayor=%d)", message, venue, created, user, checkinId, badges, mayor, isMayor];
}


- (void) encodeWithCoder: (NSCoder *)coder { 
    [coder encodeObject: message forKey:@"message"]; 
    [coder encodeObject: venue forKey:@"venue"]; 
    [coder encodeObject: badges forKey:@"badges"]; 
    [coder encodeObject: specials forKey:@"specials"]; 
    [coder encodeObject: created forKey:@"created"]; 
    [coder encodeObject: checkinId forKey:@"checkinId"]; 
    [coder encodeObject: shout forKey:@"shout"]; 
    [coder encodeObject: display forKey:@"display"]; 
    [coder encodeObject: user forKey:@"user"]; 
    [coder encodeObject: scoring forKey:@"scoring"]; 
    [coder encodeObject: mayor forKey:@"mayor"]; 
    [coder encodeObject: truncatedTimeUnits forKey:@"truncatedTimeUnits"]; 
    [coder encodeObject: truncatedTimeNumeral forKey:@"truncatedTimeNumeral"]; 
} 

- (id) initWithCoder: (NSCoder *)coder { 
    if (self = [super init]) { 
        [self setMessage: [coder decodeObjectForKey:@"message"]]; 
        [self setVenue: [coder decodeObjectForKey:@"venue"]];  
        [self setBadges: [coder decodeObjectForKey:@"badges"]];  
        [self setSpecials: [coder decodeObjectForKey:@"specials"]]; 
        [self setCreated: [coder decodeObjectForKey:@"created"]]; 
        [self setCheckinId: [coder decodeObjectForKey:@"checkinId"]]; 
        [self setShout: [coder decodeObjectForKey:@"shout"]]; 
        [self setDisplay: [coder decodeObjectForKey:@"display"]]; 
        [self setUser: [coder decodeObjectForKey:@"user"]]; 
        [self setScoring: [coder decodeObjectForKey:@"scoring"]]; 
        [self setMayor: [coder decodeObjectForKey:@"mayor"]]; 
        [self setMayor: [coder decodeObjectForKey:@"truncatedTimeUnits"]]; 
        [self setMayor: [coder decodeObjectForKey:@"truncatedTimeNumeral"]]; 
    } 
    return self; 
} 

-(void)dealloc{
	
	[message release];
	[venue release];
	[badges release];
	[specials release];
	[created release];
	[checkinId release];
	[shout release];
	[display release];
	[user release];
	[scoring release];
	[mayor release];
	[truncatedTimeUnits	release];
	[truncatedTimeNumeral release];
	[super dealloc];
}

@end
