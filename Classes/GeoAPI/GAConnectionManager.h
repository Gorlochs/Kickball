//  Copyright 2009 MixerLabs. All rights reserved.

//! @mainpage Geo API iPhone Documentation
//!
//! The Geo API for iPhone library makes it easy for developers to create iPhone
//! applications that use local information.  For example, you can request a
//! list of restaurant names and addresses within 500 meters of a given latitude
//! and longitude.  You can also read and write custom data to a place to build
//! your own location aware application.
//! @see http://api.geoapi.com/

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol GAConnectionDelegate;

//! A class for communicating with Geo API servers.  This is not thread-safe.
//! If you want to send multiple API requests in parallel, you should
//! instantiate a separate GAConnectionManager for each parallel request.
//!
//! To get data from the GeoAPI, implement the GAConnectionDelegate protocol to
//! handle the data returned from the GAConnectionManager request methods.
//!
//! @see GAConnectionDelegate.
//! @see http://api.geoapi.com/ for full API details.
@interface GAConnectionManager : NSObject
{
 @private
  NSString *apiKey_;
  NSMutableData *responseData_;
  id<GAConnectionDelegate> delegate_;
}

//! Initializes a ConnectionManager with the given API key and delegate.
//!
//! @param apiKey the API key to use for requests.  Go to http://api.geoapi.com
//!   to get an API key.
//! @param delegate a ConnectionDelegate for handling responses.
- (GAConnectionManager *)initWithAPIKey:(NSString *)apiKey
                             delegate:(id)delegate;

//! Executes an arbitrary MQL query.
//! @see http://geoapi.com/ for example queries.
//! @param mqlQuery an MQL query for the API request.  See
//!   http://mql.freebaseapps.com/ch03.html for the query format specification.
- (void)executeQuery:(NSString *)mqlQuery;

//! Requests guids, names, addresses, and distances of nearby businesses.
//! Calls [delegate receivedResponseString] on success and
//! [delegate requestFailed] on failure.
//!
//! @param coords coordinates to use for the API request.
//! @param radiusInMeters only places within radiusInMeters meters of coords
//!   be returned.
//! @param maxResults no more than maxResults will be returned.
- (void)requestBusinessesNearCoords:(CLLocationCoordinate2D)coords
                       withinRadius:(int)radiusInMeters 
                         maxResults:(int)maxResults;

//! Requests places near coords using a MQL query.
//! Calls [delegate receivedResponseString] on success and
//! [delegate requestFailed] on failure.
//!
//! @param coords coordinates to use for the API request.
//! @param radiusInMeters only places within radiusInMeters meters of coords
//!   be returned.
//! @param maxResults no more than maxResults will be returned.
//! @param entityDict an MQL query for the API request.  See
//!   http://mql.freebaseapps.com/ch03.html for the query format specification.
- (void)requestPlacesNearCoords:(CLLocationCoordinate2D)coords
                   withinRadius:(int)radiusInMeters 
                     maxResults:(int)maxResults
                 withEntityDict:(NSDictionary *)entityDict;

//! Requests a list of parents for the given coordinates.  Parents include
//! neighborhoods, cities, and states.
//! Calls [delegate receivedResponseString] on success and
//! [delegate requestFailed] on failure.
//! @see http://code.google.com/p/geo-api/wiki/MethodParents
//!
//! @param coords coordinates to use for the API request.
- (void)requestParentsForCoords:(CLLocationCoordinate2D)coords;

//! Requests a list of parents for the place with the given guid.
//! Calls [delegate receivedResponseString] on success and
//! [delegate requestFailed] on failure.
//! @see http://code.google.com/p/geo-api/wiki/MethodParents
//!
//! @param guid the GUID of the place to use in the API request.
- (void)requestParentsForPlace:(NSString *)guid;

//! Requests the listing details for the place with the given guid.
//! Calls [delegate receivedResponseString] on success and
//! [delegate requestFailed] on failure.
//! @see http://code.google.com/p/geo-api/wiki/MethodView
//!
//! @param guid the GUID of the place to use in the API request.
- (void)requestListingForPlace:(NSString *)guid;

//! Requests string data from a user view for a place.
//! Calls [delegate receivedResponseString] on success and
//! [delegate requestFailed] on failure.
//! @see http://code.google.com/p/geo-api/wiki/MethodView
//!
//! @param viewName the name of a user view to request.
//! @param guid the GUID of a place.
- (void)requestStringFromView:(NSString *)viewName
                     forPlace:(NSString *)guid;

//! Writes string data to a user view for a place.
//! Calls [delegate receivedResponseString] on success and
//! [delegate requestFailed] on failure.
//! @see http://code.google.com/p/geo-api/wiki/MethodView
//!
//! @param data a string of data to write.
//! @param viewName the name of the user view to which to write.
//! @param guid the GUID of the place for which to write.
- (void)writeString:(NSString *)data
             toView:(NSString *)viewName
           forPlace:(NSString *)guid;
  
//! Initiates an HTTP request to the given URL.
//!
//! @param url the url to which to send the request.
- (void)requestURL:(NSString *)url;

//! Initiates an HTTP request to the given URL with the given POST data.
//!
//! @param url the url to which to send the request.
//! @param data POST data to send with the request.
- (void)requestURL:(NSString *)url withData:(NSString *)data;

@end
