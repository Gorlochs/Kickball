//  Copyright 2009 MixerLabs. All rights reserved.

#import "GAParent.h"
#import "JSON.h"

@implementation GAParent


@synthesize guid = guid_;
@synthesize type = type_;
@synthesize name = name_;
@synthesize dict = dict_;

+ (NSArray *)parentsWithJSON:(NSString *)jsonString {
  NSDictionary *responseDict = [jsonString JSONValue];
  NSArray *results = [[responseDict objectForKey:@"result"] objectForKey:@"parents"];
  if (results == nil) {
    return nil;
  }
  NSMutableArray *parents = [[NSMutableArray alloc] init];
  for (id obj in results) {
    [parents addObject:[GAParent parentWithDict:obj]];
  }
  return [parents autorelease];
}

+ (GAParent *)parentWithDict:(NSDictionary *)parentDict {
  return [[[GAParent alloc] initWithDict:parentDict] autorelease];
}

- (GAParent *)initWithDict:(NSDictionary *)parentDict {
  self = [super init];
  if (self != nil) {
    self.dict = parentDict;
    NSDictionary *meta = [parentDict objectForKey:@"meta"];
    self.guid = [meta objectForKey:@"guid"];
    self.type = [meta objectForKey:@"type"];
    self.name = [meta objectForKey:@"name"];
  }
  return self;
}

- (void)dealloc {
  [guid_ release];
  [type_ release];
  [name_ release];
  [dict_ release];
  [super dealloc];
}

@end
