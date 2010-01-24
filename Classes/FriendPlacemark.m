//
//  FriendPlacemark.h
//  Kickball
//
//  Created by David Evans on 11/18/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "FriendPlacemark.h"

@implementation FriendPlacemark

@synthesize coordinate, url, userId, title, subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	return self;
}

- (void) dealloc {
    [url release];
    [userId release];
    [title release];
    [subtitle release];
    [super dealloc];
}

@end