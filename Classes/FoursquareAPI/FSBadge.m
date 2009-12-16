//
//  FSBadge.m
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FSBadge.h"


@implementation FSBadge
@synthesize	badgeId, badgeName, icon, description;


- (NSString*) description {
    return [NSString stringWithFormat:@"(BADGE : name=%@ ; id=%@ ; icon=%@ ; description=%@)", badgeName, badgeId, icon, description];
}

@end
