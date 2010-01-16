//
//  FSCheckin.m
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "FSCheckin.h"


@implementation FSCheckin
@synthesize message, venue, badges, specials, created, checkinId, shout, display, user, scoring, mayor, isMayor;


- (NSString*) description {
    return [NSString stringWithFormat:@"(CHECKIN : message=%@ ; venue=%@ ; created=%@ ; user=%@ ; checkinId=%@ ; badges=%@ ; mayor=%@)", message, venue, created, user, checkinId, badges, mayor];
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
    } 
    return self; 
} 

@end
