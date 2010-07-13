//
//  Photos.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/24/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import "Photos.h"

@implementation Photos

@synthesize count		=	_count;
@synthesize startIndex	=	_startIndex;
@synthesize list		=	_list;

-(id)init {
	if (self=[super init]) {
		}
	return self;
}

-(NSString*)description {
	return [NSString stringWithFormat:@"\r\nPhotos\r\n___\r\ncount=%d, list=%@, startIndex=%d\r\n", _count, _list, _startIndex];
}

-(void)dealloc {
	[_list release];
	[super dealloc];
}


@end
