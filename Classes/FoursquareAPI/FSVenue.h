//
//  FSVenue.h
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "FSUser.h"
#import "FSCategory.h"

@interface FSVenue : NSObject <NSCoding> {
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
	NSString * twitter;
	NSInteger mayorCount;
	FSUser * mayor;
	NSArray * tips;
	NSArray * currentCheckins;
	NSArray * specials;
	BOOL friendsHaveBeenHere;
	BOOL userHasBeenHere;
	NSInteger userCheckinCount;
	NSInteger hereNow;
    NSString * addressWithCrossstreet;
    FSCategory *primaryCategory;
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
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic) NSInteger mayorCount;
@property (nonatomic, retain) FSUser * mayor;
@property (nonatomic, retain) NSArray * tips;
@property (nonatomic, retain) NSArray * currentCheckins;
@property (nonatomic, retain) NSArray * specials;
@property (nonatomic) BOOL friendsHaveBeenHere;
@property (nonatomic) BOOL userHasBeenHere;
@property (nonatomic) NSInteger userCheckinCount;
@property (nonatomic) NSInteger hereNow;
@property (nonatomic, retain) NSString * addressWithCrossstreet;
@property (nonatomic, retain) FSCategory *primaryCategory;
@property (nonatomic, readonly) CLLocationCoordinate2D location;

@end
