//
//  FSBadge.m
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "FSBadge.h"


@implementation FSBadge
@synthesize	badgeId, badgeName, icon, badgeDescription;


- (NSString*) description {
    return [NSString stringWithFormat:@"(BADGE : name=%@ ; id=%@ ; icon=%@ ; description=%@)", badgeName, badgeId, icon, badgeDescription];
}

- (void) encodeWithCoder: (NSCoder *)coder { 
    [coder encodeObject: badgeId forKey:@"badgeId"]; 
    [coder encodeObject: badgeName forKey:@"badgeName"]; 
    [coder encodeObject: icon forKey:@"icon"]; 
    [coder encodeObject: badgeDescription forKey:@"badgeDescription"]; 
} 

- (id) initWithCoder: (NSCoder *)coder { 
    if (self = [super init]) { 
        [self setBadgeId: [coder decodeObjectForKey:@"badgeId"]]; 
        [self setBadgeName: [coder decodeObjectForKey:@"badgeName"]];  
        [self setIcon: [coder decodeObjectForKey:@"icon"]];  
        [self setBadgeDescription: [coder decodeObjectForKey:@"badgeDescription"]]; 
    } 
    return self; 
} 

@end
