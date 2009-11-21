//  Copyright 2009 MixerLabs. All rights reserved.

//! A protocol for handling Geo API connection events.  See GAConnectionManager.
//! If a request completes successfully, GAConnectionManager calls
//! receivedResponseString:.  If the request failed, it calls requestFailed:.
//!
//! @see http://api.geoapi.com/ for full API documentation.
@protocol GAConnectionDelegate<NSObject>

//! Called after an API request completes successfully.
//!
//! @param responseString: the contents of the API response, typically a JSON
//!   string.  GAPlace and GAParent provide JSON parsing functions.
- (void)receivedResponseString:(NSString *)responseString;

//! Called if a connection error occurs.
//!
//! @param error: the error returned by the underlying NSURLConnection.
- (void)requestFailed:(NSError *)error;

@end
