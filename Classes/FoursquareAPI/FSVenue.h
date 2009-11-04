//
//  FSVenue.h
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSVenue : NSObject {
	NSString * name;
	NSString * geolat;
	NSString * geolong;
	NSString * venueAddress;
	NSString * zip;
	NSString * city;
	NSString * venueState;
	NSString * venueid;
	NSString * phone;
	NSString * crossStreet;
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * geolat;
@property (nonatomic, retain) NSString * geolong;
@property (nonatomic, retain) NSString * venueAddress;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * venueState;
@property (nonatomic, retain) NSString * venueid;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * crossStreet;

@end
