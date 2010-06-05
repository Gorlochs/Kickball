//
//  FSSpecial.m
//  Kickball
//
//  Created by Shawn Bernard on 12/19/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "FSSpecial.h"


@implementation FSSpecial

@synthesize specialId, type, messageText, venue;

- (NSString*) description {
    return [NSString stringWithFormat:@"(SPECIAL : specialId=%@ ; type=%@ ; messageText=%@ ; venue=%@)", specialId, type, messageText, venue];
}

- (void) encodeWithCoder: (NSCoder *)coder { 
    [coder encodeObject: specialId forKey:@"specialId"]; 
    [coder encodeObject: type forKey:@"type"]; 
    [coder encodeObject: messageText forKey:@"messageText"]; 
    [coder encodeObject: venue forKey:@"venue"]; 
} 

- (id) initWithCoder: (NSCoder *)coder { 
    if (self = [super init]) { 
        [self setSpecialId: [coder decodeObjectForKey:@"specialId"]]; 
        [self setType: [coder decodeObjectForKey:@"type"]];  
        [self setMessageText: [coder decodeObjectForKey:@"messageText"]];  
        [self setVenue: [coder decodeObjectForKey:@"venue"]]; 
    } 
    return self; 
} 
@end
