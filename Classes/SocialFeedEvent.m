//
//  SocialFeedEvent.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/22/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import "SocialFeedEvent.h"

@implementation SocialFeedEvent

@synthesize content			= _content;
@synthesize date			= _date;
@synthesize eventType		= _eventType;
@synthesize imageThumbnail	= _imageThumbnail;
@synthesize photoId			= _photoId;
@synthesize user			= _user;

-(id)init {
	if (self=[super init]) {
		}
	return self;
}

-(NSString*)description {
	return [NSString stringWithFormat:@"\r\nSocialFeedEvent\r\n___\r\ncontent=%@, date=%@, eventType=%@, imageThumbnail=%@, photoId=%qi, user=%@\r\n",
			_content, _date, _eventType, _imageThumbnail, _photoId, _user
			];
}

-(void)dealloc {
	[_content release];
	[_date release];
	[_eventType release];
	[_imageThumbnail release];
	[_user release];
	[super dealloc];
}

@end
