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
				mayor, tips, currentCheckins, friendsHaveBeenHere, 
                userHasBeenHere, userCheckinCount, addressWithCrossstreet;


- (id) init{
	self = [super init];
	return self;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"(VENUE : name=%@ ; venueid=%@ ; city=%@ ; state=%@ ; mayor=%@ ; mayorCount = %d ; lat = %@ ; long = %@; currentCheckins: %@)", name, venueid, city, venueState, mayor, mayorCount, geolat, geolong, currentCheckins];
}

- (NSString*) addressWithCrossstreet {
    if (self.crossStreet != nil) {
        return [NSString stringWithFormat:@"%@ (%@)", self.venueAddress, self.crossStreet];
    } else {
        return self.venueAddress;
    }
}

- (CLLocationCoordinate2D) location
{
	CLLocationCoordinate2D loc;
	if (geolat && geolong)
	{
		loc.latitude = geolat.doubleValue;
		loc.longitude = geolong.doubleValue;
	}
	return loc;	
}

@end
