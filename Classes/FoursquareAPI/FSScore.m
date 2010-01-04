//
//  FSScore.m
//  Kickball
//
//  Created by David Evans on 11/08/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "FSScore.h"


@implementation FSScore

@synthesize points, message, icon;

- (void) encodeWithCoder: (NSCoder *)coder { 
    [coder encodeInteger: points forKey:@"points"]; 
    [coder encodeObject: message forKey:@"message"]; 
    [coder encodeObject: icon forKey:@"icon"]; 
} 

- (id) initWithCoder: (NSCoder *)coder { 
    if (self = [super init]) { 
        [self setPoints: [coder decodeIntegerForKey:@"points"]]; 
        [self setMessage: [coder decodeObjectForKey:@"message"]];  
        [self setIcon: [coder decodeObjectForKey:@"icon"]];  
    } 
    return self; 
}

@end
