//
//  Location.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/20/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import "Location.h"

@implementation Location

@synthesize latitude  = _latitude;
@synthesize longitude = _longitude;

-(id)init {
	if (self =[super init]) {
		}
	return self;
}

-(NSString*)description {
	return [NSString stringWithFormat:@"\r\nLocation\r\n---\r\nlatitude=%.6f, longitude=%.6f", _latitude, _longitude];
}

-(void)dealloc {
	[super dealloc];
}

@end
