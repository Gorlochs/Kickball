//
//  GeoTweetAnnotation.m
//  Kickball
//
//  Created by Shawn Bernard on 5/11/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "GeoTweetAnnotation.h"


@implementation GeoTweetAnnotation

@synthesize coordinate, title, subtitle, searchResult, iconUrl;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c {
	coordinate = c;
	return self;
}

- (void) dealloc {
    [title release];
    [subtitle release];
    [searchResult release];
    [iconUrl release];
    [super dealloc];
}

@end
