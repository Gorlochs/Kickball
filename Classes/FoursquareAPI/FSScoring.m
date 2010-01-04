//
//  FSScoring.m
//  Kickball
//
//  Created by David Evans on 11/08/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "FSScoring.h"


@implementation FSScoring

@synthesize scores, total, message;

- (NSString*) description {
    return [NSString stringWithFormat:@"(FSScoring: scores = %@, total = %d, message = %@)", scores, total, message];
}

- (void) encodeWithCoder: (NSCoder *)coder { 
    [coder encodeObject: scores forKey:@"scores"]; 
    [coder encodeInteger: total forKey:@"total"]; 
    [coder encodeObject: message forKey:@"message"]; 
} 

- (id) initWithCoder: (NSCoder *)coder { 
    if (self = [super init]) { 
        [self setScores: [coder decodeObjectForKey:@"scores"]]; 
        [self setTotal:[coder decodeIntegerForKey:@"total"]];  
        [self setMessage: [coder decodeObjectForKey:@"message"]];  
    } 
    return self; 
} 

@end
