//
//  FSVenue.m
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FSVenue.h"


@implementation FSVenue
@synthesize name, geolat, geolong, venueAddress, 
				zip, city, venueState, venueid, 
				phone, crossStreet, twitter, mayorCount, 
				mayor, tips, peopleHere, friendsHaveBeenHere, 
				userHasBeenHere, userCheckinCount;


- (id) init{
	self = [super init];
	return self;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"name=%@ ; venueid=%@ ; mayor=%@ ; mayorCount = %d", name, venueid, mayor, mayorCount];
}

@end
