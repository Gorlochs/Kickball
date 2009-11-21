//  Copyright 2009 MixerLabs. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

//! A class representing a Geo API place, aka entity.
//! @see http://code.google.com/p/geo-api/wiki/KeyConcepts 
@interface GAPlace : NSObject {
 @private
  NSString *guid_;
  NSString *name_;
  NSString *address_;
  CLLocationCoordinate2D coords_;
  NSDictionary *listing_;
}

//! A unique identifier for the place.
//! e.g. ritual-coffee-roasters-san-francisco-ca-94110
@property (nonatomic, copy) NSString *guid;

//! A descriptive name for the place.
//! e.g. Ritual Coffee Roasters
@property (nonatomic, copy) NSString *name;

//! An address string.
//! e.g. 1026 Valencia St, San Francisco CA 94110
@property (nonatomic, copy) NSString *address;

/*! Latitude and longitude of a place. */
@property (nonatomic) CLLocationCoordinate2D coords;

//! The full dictionary of the entity's listing data.
//! @see http://code.google.com/p/geo-api/wiki/KeyConcepts
@property (nonatomic, copy) NSDictionary *listing;

//! Given a JSON string returned from a /q API call, returns an array of places.
//!
//! @param jsonString a JSON string returned from the API.
+ (NSArray *)placesWithJSON:(NSString *)jsonString;

//! Returns a place given a dict parsed from JSON.
//!
//! @param placeDict a dict parsed from an MQL query API JSON call.
+ (GAPlace *)placeWithDict:(NSDictionary *)placeDict;

//* @see placeWithDict: */
- (GAPlace *)initWithDict:(NSDictionary *)placeDict;

//! Returns a place given a JSON string returned from a listing view request
//! e.g. /v1/e/[GUID]/view/listing?apikey=demo
+ (GAPlace *)placeWithListingJSON:(NSString *)listingJSON;

//! Initializes a place from a dict parsed from a listing view JSON response.
//! @see placeWithListingJSON:
- (GAPlace *)initWithListingDict:(NSDictionary *)listingDict;

@end
