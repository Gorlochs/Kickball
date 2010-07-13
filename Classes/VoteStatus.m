//
//  VoteStatus.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/24/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import "VoteStatus.h"

@implementation VoteStatus

@synthesize photoId = _photoId;
@synthesize userId  = _userId;
@synthesize status  = _status;

-(id)init {
	if (self=[super init]) {
	}
	return self;
}

-(NSString*)description {
	return [NSString stringWithFormat:@"\r\nVoteStatus\r\n___\r\nphotoId=%qi, userId=%qi, status=%@\r\n", _photoId, _userId, _status];
}

-(void)dealloc {
	[_status release];
	[super dealloc];
}

@end
