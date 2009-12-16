//
//  FSCheckin.m
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FSCheckin.h"


@implementation FSCheckin
@synthesize message, venue, badges, specials, created, checkinId, shout, display, user, scoring, mayor;


- (NSString*) description {
    return [NSString stringWithFormat:@"(CHECKIN : message=%@ ; venue=%@ ; created=%@ ; user=%@ ; checkinId=%@ ; badges=%@ ; mayor=%@)", message, venue, created, user, checkinId, badges, mayor];
}

@end
