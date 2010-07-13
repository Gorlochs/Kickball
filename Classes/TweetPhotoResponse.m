//
//  TweetPhotoResponse.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/22/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import "TweetPhotoResponse.h"

@implementation TweetPhotoResponse

@synthesize large				= _large;
@synthesize mediaId				= _mediaId;
@synthesize mediaUrl			= _mediaUrl;
@synthesize medium				= _medium;
@synthesize original			= _original;
@synthesize photoId				= _photoId;
@synthesize sessionKeyResponse	= _sessionKeyResponse;
@synthesize thumbnail			= _thumbnail;
@synthesize status				= _status;
@synthesize userId				= _userId;

-(id)init {
	if (self=[super init]) {
		}
	return self;
}

-(NSString*)description {
	return [NSString stringWithFormat:@"\r\nTweetPhotoResponse\r\n___\r\nlarge=%@, mediaId=%qi, mediaUrl=%@, medium=%@, original=%@, photoId=%qi, sessionKeyResponse=%@, thumbnail=%@, status=%@, userId=%qi\r\n",
			_large, _mediaId, _mediaUrl, _medium, _original, _photoId, _sessionKeyResponse, _thumbnail, _status, _userId
			];
}

-(void)dealloc {
	[_large release];
	[_mediaUrl release];
	[_medium release];
	[_original release];
	[_sessionKeyResponse release];
	[_thumbnail release];
	[_status release];
	[super dealloc];
}

@end
