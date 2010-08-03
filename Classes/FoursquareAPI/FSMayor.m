//
//  FSMayor.m
//  Kickball
//
//  Created by Shawn Bernard on 12/15/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "FSMayor.h"


@implementation FSMayor

@synthesize user, mayorCheckinMessage, numCheckins, mayorTransitionType;

- (NSString*) description {
    return [NSString stringWithFormat:@"(MAYOR : user=%@ ; mayorCheckinMessage=%@ ; numCheckins=%d ; mayorTransitionType=%@)", user, mayorCheckinMessage, numCheckins, mayorTransitionType];
}

- (void) encodeWithCoder: (NSCoder *)coder { 
    [coder encodeObject: user forKey:@"user"]; 
    [coder encodeObject: mayorCheckinMessage forKey:@"mayorCheckinMessage"]; 
    [coder encodeInteger:numCheckins forKey:@"numCheckins"]; 
    [coder encodeObject: mayorTransitionType forKey:@"mayorTransitionType"]; 
} 

- (id) initWithCoder: (NSCoder *)coder { 
    if (self = [super init]) { 
        [self setUser: [coder decodeObjectForKey:@"user"]]; 
        [self setMayorCheckinMessage: [coder decodeObjectForKey:@"mayorCheckinMessage"]];  
        [self setNumCheckins: [coder decodeIntegerForKey:@"numCheckins"]];  
        [self setMayorTransitionType: [coder decodeObjectForKey:@"mayorTransitionType"]]; 
    } 
    return self; 
}

-(void)dealloc{
	[user release];
	[mayorCheckinMessage release];
	[mayorTransitionType release];
	[super dealloc];
}
@end
