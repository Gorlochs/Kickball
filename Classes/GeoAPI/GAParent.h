//  Copyright 2009 MixerLabs. All rights reserved.

#import <Foundation/Foundation.h>

//!  A class representing Geo API parents.  Parents include neighborhoods and
//!  cities.
//!
//!  @see http://code.google.com/p/geo-api/wiki/MethodParents
@interface GAParent : NSObject {
 @private
  NSString *guid_;
  NSString *type_;
  NSString *name_;
  NSDictionary *dict_;
}

/*! A unique identifier for the parent.  e.g. "downtown-san-mateo-ca". */
@property (nonatomic, copy) NSString *guid;

/*! The type of parent.  e.g. "neighborhood". */
@property (nonatomic, copy) NSString *type;

/*! A descriptive name for the parent.  e.g. "Downtown". */
@property (nonatomic, copy) NSString *name;

//! The full dictionary of parent data.
//! @see http://code.google.com/p/geo-api/wiki/MethodParents
@property (nonatomic, copy) NSDictionary *dict;

//! Returns an array of GAParents given a JSON string returned by a parents API
//! call.
//!
//! @param jsonString a JSON string returned by the Geo API.
+ (NSArray *)parentsWithJSON:(NSString *)jsonString;

//! Returns a GAParent given a dictionary parsed from a JSON string returned by
//! a parents API call.
//!
//! @param parentDict a dictionary parsed from a JSON string returned by the
//!   Geo API.
+ (GAParent *)parentWithDict:(NSDictionary *)parentDict;

//! @see parentWithDict:
- (GAParent *)initWithDict:(NSDictionary *)parentDict;

@end
