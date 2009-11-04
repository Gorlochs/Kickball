//
//  FSVenue.m
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FSVenue.h"


@implementation FSVenue
@synthesize name, geolat, geolong, venueAddress, zip, city, venueState, venueid, phone, crossStreet;

- (id) init{
	self = [super init];
	return self;
}

@end
