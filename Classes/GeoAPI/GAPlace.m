//  Copyright 2009 MixerLabs. All rights reserved.

#import "GAPlace.h"
#import "JSON.h"

@implementation GAPlace

@synthesize guid = guid_;
@synthesize name = name_;
@synthesize address = address_;
@synthesize coords = coords_;
@synthesize listing = listing_;

+ (NSArray *)placesWithJSON:(NSString *)jsonString {
  NSDictionary *responseDict = [jsonString JSONValue];
  NSArray *results = [responseDict objectForKey:@"entity"];
  if (results == nil) {
    return nil;
  }
  NSMutableArray *places = [[NSMutableArray alloc] init];
  for (id obj in results) {
    [places addObject:[GAPlace placeWithDict:obj]];
  }
  return [places autorelease];
}

+ (GAPlace *)placeWithDict:(NSDictionary *)placeDict {
  return [[[GAPlace alloc] initWithDict:placeDict] autorelease];
}

+ (GAPlace *)placeWithListingJSON:(NSString *)jsonString {
  NSDictionary *listingDict = [jsonString JSONValue];
  return [[[GAPlace alloc] initWithListingDict:listingDict] autorelease];
}

- (GAPlace *)initWithDict:(NSDictionary *)placeDict {
  self = [super init];
  if (self != nil) {
    self.listing = [placeDict objectForKey:@"view.listing"];
    self.name = [self.listing objectForKey:@"name"];
    self.guid = [placeDict objectForKey:@"guid"];
    self.address =
      [[self.listing objectForKey:@"address"] componentsJoinedByString:@", "];
    NSArray *geomCoords = [[placeDict objectForKey:@"geom"]
                           objectForKey:@"coordinates"];
    coords_.latitude = [[geomCoords objectAtIndex:1] doubleValue];
    coords_.longitude = [[geomCoords objectAtIndex:0] doubleValue];    
  }
  return self;
}

- (GAPlace *)initWithListingDict:(NSDictionary *)listingDict {
  self = [super init];
  if (self != nil) {
    NSDictionary *result = 
    self.listing = [listingDict objectForKey:@"result"];
    self.name = [result objectForKey:@"name"];
    self.guid = [[[listingDict objectForKey:@"query"]
                  objectForKey:@"params"]
                 objectForKey:@"guid"];
    self.address =
      [[result objectForKey:@"address"] componentsJoinedByString:@", "];
  }
  return self;
}

- (void)dealloc {
  [guid_ release];
  [name_ release];
  [address_ release];
  [listing_ release];
  [super dealloc];
}

@end
