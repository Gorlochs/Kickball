//
//  FriendPlacemark.h
//  Kickball
//
//  Created by David Evans on 11/18/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "FriendPlacemark.h"

@implementation FriendPlacemark

@synthesize coordinate, checkin, title, subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c {
	coordinate = c;
//    subtitle = checkin.venue.addressWithCrossstreet;
//    title = checkin.display;
	return self;
}

- (void) dealloc {
//    [url release];
//    [userId release];
    [checkin release];
    [title release];
    [subtitle release];
    [super dealloc];
}

@end