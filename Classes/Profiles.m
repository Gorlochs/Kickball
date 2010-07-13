//
//  Profiles.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/24/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import "Profiles.h"

@implementation Profiles

@synthesize count				= _count;
@synthesize list				= _list;
@synthesize startIndex			= _startIndex;
@synthesize filter				= _filter;
@synthesize linkedServices		= _linkedServices;

-(id)init {
	if (self=[super init]) {
	}
	return self;
}

-(NSString*)description {
	return [NSString stringWithFormat:@"\r\nProfiles\r\n___\r\ncount=%d, list=%@, startIndex=%d, filter=%@, linkedServices=%@\r\n", _count, _list, _startIndex, _filter, _linkedServices];
}

-(void)dealloc {
	[_linkedServices release];
	[_filter release];
	[_list release];
	[super dealloc];
}

@end
