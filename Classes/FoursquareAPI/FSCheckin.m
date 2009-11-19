//
//  FSCheckin.m
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FSCheckin.h"


@implementation FSCheckin
@synthesize message, venue, badges, specials, created, checkinId, shout, display, user, scoring;


- (NSString*) description {
    return [NSString stringWithFormat:@"message=%@ ; venue=%@ ; created=%@ ; user=%@ ; checkinId=%@", message, venue, created, user, checkinId];
}

@end
