//
//  Favorites.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/24/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import "Favorites.h"

@implementation Favorites

@synthesize count		= _count;
@synthesize list		= _list;
@synthesize startIndex	= _startIndex;

-(id)init {
	if (self=[super init]) {
		}
	return self;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"\r\nFavorites\r\n___\r\ncount=%d, list=%@, startIndex=%d\r\n",
			_count, _list, _startIndex];
}

-(void)dealloc {
	[_list dealloc];
	[super dealloc];
}


@end
