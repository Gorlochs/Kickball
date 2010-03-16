//
//  FSVenue.m
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "FSVenue.h"


@implementation FSVenue

@synthesize name, geolat, geolong, venueAddress, 
				zip, city, venueState, venueid, 
				phone, crossStreet, twitter, mayorCount, 
				mayor, tips, currentCheckins, friendsHaveBeenHere, 
                userHasBeenHere, userCheckinCount, addressWithCrossstreet, 
                specials, primaryCategory, hereNow;


- (id) init{
	self = [super init];
	return self;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"(VENUE : name=%@ ; venueid=%@ ; city=%@ ; state=%@ ; mayor=%@ ; mayorCount = %d ; phone = %@ ; lat = %@ ; long = %@; currentCheckins: %@)", name, venueid, city, venueState, mayor, mayorCount, phone, geolat, geolong, currentCheckins];
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

- (void) encodeWithCoder: (NSCoder *)coder { 
    [coder encodeObject: name forKey:@"name"]; 
    [coder encodeObject: geolat forKey:@"geolat"]; 
    [coder encodeObject: geolong forKey:@"geolong"];
    [coder encodeObject: venueAddress forKey:@"venueAddress"];
    [coder encodeObject: zip forKey:@"zip"];
    [coder encodeObject: city forKey:@"city"];
    [coder encodeObject: venueState forKey:@"venueState"];
    [coder encodeObject: venueid forKey:@"venueid"];
    [coder encodeObject: phone forKey:@"phone"];
    [coder encodeObject: crossStreet forKey:@"crossStreet"];
    [coder encodeObject: twitter forKey:@"twitter"];
    [coder encodeInteger: mayorCount forKey:@"mayorCount"];
    [coder encodeObject: mayor forKey:@"mayor"];
    [coder encodeObject: tips forKey:@"tips"];
    [coder encodeObject: currentCheckins forKey:@"currentCheckins"];
    [coder encodeBool: friendsHaveBeenHere forKey:@"friendsHaveBeenHere"];
    [coder encodeBool: userHasBeenHere forKey:@"userHasBeenHere"];
    [coder encodeInteger: userCheckinCount forKey:@"userCheckinCount"];
    [coder encodeObject: specials forKey:@"specials"];
} 

- (id) initWithCoder: (NSCoder *)coder { 
    if (self = [super init]) { 
        [self setName: [coder decodeObjectForKey:@"name"]]; 
        [self setGeolat:[coder decodeObjectForKey:@"geolat"]];  
        [self setGeolong: [coder decodeObjectForKey:@"geolong"]];  
        [self setVenueAddress: [coder decodeObjectForKey:@"venueAddress"]];  
        [self setZip: [coder decodeObjectForKey:@"zip"]];  
        [self setCity: [coder decodeObjectForKey:@"city"]];  
        [self setVenueState: [coder decodeObjectForKey:@"venueState"]];  
        [self setVenueid: [coder decodeObjectForKey:@"venueid"]];  
        [self setPhone: [coder decodeObjectForKey:@"phone"]];  
        [self setCrossStreet: [coder decodeObjectForKey:@"crossStreet"]];  
        [self setTwitter: [coder decodeObjectForKey:@"twitter"]];  
        [self setMayorCount: [coder decodeIntegerForKey:@"mayorCount"]];  
        [self setMayor: [coder decodeObjectForKey:@"mayor"]];     
        [self setTips: [coder decodeObjectForKey:@"tips"]];   
        [self setCurrentCheckins: [coder decodeObjectForKey:@"currentCheckins"]];   
        [self setFriendsHaveBeenHere: [coder decodeBoolForKey:@"friendsHaveBeenHere"]];   
        [self setUserHasBeenHere: [coder decodeBoolForKey:@"userHasBeenHere"]];   
        [self setUserCheckinCount: [coder decodeIntegerForKey:@"userCheckinCount"]]; 
        [self setSpecials: [coder decodeObjectForKey:@"specials"]]; 
    } 
    return self; 
} 

@end
