//
//  Comments.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/24/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import "Comments.h"

@implementation Comments

@synthesize count		= _count;
@synthesize list		= _list;
@synthesize startIndex	= _startIndex;
@synthesize photoId		= _photoId;

-(id)init {
	if (self=[super init]) {
		}
	return self;
}

-(NSString*)description {
	return [NSString stringWithFormat:@"\r\nComments\r\n___\r\ncount=%d, list=%@, startIndex=%d, photoId=%qi\r\n", _count, _list, _startIndex, _photoId];
}

-(void)dealloc {
	[_list release];
	[super dealloc];
}

@end
