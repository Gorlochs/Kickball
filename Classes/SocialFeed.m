//
//  SocialFeed.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/22/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import "SocialFeed.h"

@implementation SocialFeed

@synthesize count		= _count;
@synthesize startIndex  = _startIndex;
@synthesize filter		= _filter;
@synthesize list		= _list;

-(id)init {
	if (self=[super init]) {
		}
	return self;
}

-(NSString*)description {
	return [NSString stringWithFormat:@"\r\nSocialFeed\r\n___\r\ncount=%d, startIndex=%d, filter=%@, list=%@\r\n",
			_count, _startIndex, _filter, _list
			];
}

-(void)dealloc {
	[_filter release];
	[_list release];
	[super dealloc];
}

@end
