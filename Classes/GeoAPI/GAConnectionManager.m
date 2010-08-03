//  Copyright 2009 MixerLabs. All rights reserved.

#import "GAConnectionManager.h"
#import <CoreLocation/CoreLocation.h>
#import "JSON.h"
#import "GAConnectionDelegate.h"

// Uncomment the following line to enable debug output.
// #define GA_DEBUG

#ifdef GA_DEBUG
#define DebugLog(s, ...) \
NSLog(@"[%p %@:%d] %@", \
self, \
[[NSString stringWithUTF8String:__FILE__] lastPathComponent], \
__LINE__, \
[NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define DebugLog(s, ...)
#endif

@implementation GAConnectionManager

NSString *const kGAQueryFormat =
  @"http://api.geoapi.com/v1/q?apikey=%@&q=%@";
NSString *const kGASearchFormat = @"http://api.geoapi.com/v1/search?apikey=%@&"
  "lat=%f&lon=%f&radius=%dm&limit=%d";
NSString *const kGAUserViewFormat =
  @"http://api.geoapi.com/v1/e/%@/userview/%@?apikey=%@";
NSString *const kGAListingFormat =
  @"http://api.geoapi.com/v1/e/%@/view/listing?apikey=%@";
NSString *const kGAParentsFormat =
  @"http://api.geoapi.com/v1/parents?apikey=%@&lat=%f&lon=%f";
NSString *const kGAPlaceParentsFormat =
  @"http://api.geoapi.com/v1/e/%@/parents?apikey=%@";

- (GAConnectionManager *)initWithAPIKey:(NSString *)apiKey
                             delegate:(id)delegate {
  self = [super init];
  if (self != nil) {
    apiKey_ = [apiKey copy];
    delegate_ = delegate;
    responseData_ = [[NSMutableData data] retain];
  }
  return self;
}

- (void)requestBusinessesNearCoords:(CLLocationCoordinate2D)coords
                       withinRadius:(int)radiusInMeters 
                         maxResults:(int)maxResults {
  NSMutableDictionary *entityDict =
  [[[NSMutableDictionary alloc] init] autorelease];
  [entityDict setValue:[NSNull null] forKey:@"guid"];
  [entityDict setValue:@"business" forKey:@"type"];
  [entityDict setValue:[NSNull null] forKey:@"distance-from-center"];
  NSMutableDictionary *listingDict =
  [[[NSMutableDictionary alloc] init] autorelease];
  [listingDict setValue:[NSNull null] forKey:@"name"];
  [listingDict setValue:[[[NSArray alloc] init] autorelease]
                 forKey:@"address"];
  [entityDict setValue:listingDict forKey:@"view.listing"];
  [self requestPlacesNearCoords:coords
                   withinRadius:radiusInMeters
                     maxResults:maxResults
                 withEntityDict:entityDict];
}

// Example query:
//{"lat":37.7563,
//  "lon":-122.421,
//  "radius":".2km",
//  "entity": [{
//    "guid": null,
//    "type": "business",
//    "distance-from-center": null,
//    "view.listing": {
//      "verticals": "restaurants",
//      "name": null,
//      "address": []
//    }
//  }]
//}
- (void)requestPlacesNearCoords:(CLLocationCoordinate2D)coords
                   withinRadius:(int)radiusInMeters 
                     maxResults:(int)maxResults
                 withEntityDict:(NSDictionary *)entityDict {
  NSMutableDictionary *queryDict =
    [[[NSMutableDictionary alloc] init] autorelease];
  [queryDict setValue:[NSNumber numberWithDouble:coords.latitude]
               forKey:@"lat"];
  [queryDict setValue:[NSNumber numberWithDouble:coords.longitude]
               forKey:@"lon"];
  [queryDict setValue:[NSString stringWithFormat:@"%dm", radiusInMeters]
               forKey:@"radius"];
  [queryDict setValue:[NSNumber numberWithInt:maxResults]
               forKey:@"limit"];
  [queryDict setValue:[NSArray arrayWithObject:entityDict] forKey:@"entity"];

  NSString *queryString = [queryDict JSONRepresentation];
  DebugLog(@"Making query: %@", queryString);
  [self executeQuery:queryString];
}

- (void)writeString:(NSString *)data
             toView:(NSString *)viewName
           forPlace:(NSString *)guid {
  NSString *url = [NSString stringWithFormat:kGAUserViewFormat,
                   guid,
                   viewName,
                   apiKey_];
  [self requestURL:url withData:data];
}

- (void)requestParentsForPlace:(NSString *)guid {
  NSString *url =
    [NSString stringWithFormat:kGAPlaceParentsFormat, guid, apiKey_];
  [self requestURL:url];
}

- (void)requestParentsForCoords:(CLLocationCoordinate2D)coords {
  NSString *url = [NSString stringWithFormat:kGAParentsFormat,
                   apiKey_,
                   coords.latitude,
                   coords.longitude];
  [self requestURL:url];
}

- (void)requestListingForPlace:(NSString *)guid {
  NSString *url = [NSString stringWithFormat:kGAListingFormat, guid, apiKey_];
  [self requestURL:url];
}

- (void)requestStringFromView:(NSString *)viewName
                     forPlace:(NSString *)guid {
  NSString *url = [NSString stringWithFormat:kGAUserViewFormat,
                   guid,
                   viewName,
                   apiKey_];
  [self requestURL:url];
}

- (void)executeQuery:(NSString *)mqlQuery {
  NSString *escapedQuery =
    [mqlQuery stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  [self requestURL:[NSString 
                    stringWithFormat:kGAQueryFormat, apiKey_, escapedQuery]];
}

- (void)requestURL:(NSString *)url {
  NSURLRequest *request = [NSURLRequest
                           requestWithURL:[NSURL URLWithString:url]];
  // Connection is released in connectionDidFinishLoading
  [[NSURLConnection alloc] initWithRequest:request delegate:self];  
  DebugLog(@"Requesting URL %@", url);
}

- (void)requestURL:(NSString *)url withData:(NSString *)data {
  NSMutableURLRequest *request = [NSMutableURLRequest
                                  requestWithURL:[NSURL URLWithString:url]];
  [request setHTTPMethod:@"POST"];
  [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
  // Connection is released in connectionDidFinishLoading
  [[NSURLConnection alloc] initWithRequest:request delegate:self];  
  DebugLog(@"Requesting URL %@ with data %@", url, data);
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {
  [responseData_ setLength:0];
#if GA_DEBUG
  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
  DebugLog(@"httpResponse: %d", [httpResponse statusCode]);
  DebugLog(@"Content-Type: %@", [httpResponse.allHeaderFields
                                 objectForKey:@"Content-Type"]);
  DebugLog(@"Content-Length: %@", [httpResponse.allHeaderFields
                                   objectForKey:@"Content-Length"]);
#endif
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *) data {
  [responseData_ appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
  DebugLog(@"Error: %@", [error description]);
  [delegate_ requestFailed:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  [connection release];
  DebugLog(@"Received %d bytes of data", [responseData_ length]);
  NSString *responseString = [[NSString alloc]
                              initWithData:responseData_
                                  encoding:NSUTF8StringEncoding];
  [responseData_ setLength:0];
  [delegate_ receivedResponseString:responseString];
  [responseString release];
}

- (void)dealloc {
  [responseData_ release];
  [delegate_ release];
  [apiKey_ release];
  [super dealloc];
}

@end
