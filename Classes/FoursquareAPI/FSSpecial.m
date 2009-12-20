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

@end
