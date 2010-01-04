//
//  FSSpecial.m
//  Kickball
//
//  Created by Shawn Bernard on 12/19/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "FSSpecial.h"


@implementation FSSpecial

@synthesize specialId, type, message, venue;

- (NSString*) description {
    return [NSString stringWithFormat:@"(SPECIAL : specialId=%@ ; type=%@ ; message=%@ ; venue=%@)", specialId, type, message, venue];
}

- (void) encodeWithCoder: (NSCoder *)coder { 
    [coder encodeObject: specialId forKey:@"specialId"]; 
    [coder encodeObject: type forKey:@"type"]; 
    [coder encodeObject: message forKey:@"message"]; 
    [coder encodeObject: venue forKey:@"venue"]; 
} 

- (id) initWithCoder: (NSCoder *)coder { 
    if (self = [super init]) { 
        [self setSpecialId: [coder decodeObjectForKey:@"specialId"]]; 
        [self setType: [coder decodeObjectForKey:@"type"]];  
        [self setMessage: [coder decodeObjectForKey:@"message"]];  
        [self setVenue: [coder decodeObjectForKey:@"venue"]]; 
    } 
    return self; 
} 
@end
