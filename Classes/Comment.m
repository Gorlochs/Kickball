//
//  Comment.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/20/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import "Comment.h"

@implementation Comment

@synthesize date			= _date;
@synthesize id				= _id;
@synthesize imageId			= _imageId;
@synthesize profileId		= _profileId;
@synthesize profileImage	= _profileImage;
@synthesize dateString		= _dateString;
@synthesize message			= _message;
@synthesize screenName		= _screenName;

-(id)init {
	if (self=[super init]) {
		}
	return self;
}

-(NSString*)description {
	return [NSString stringWithFormat:@"\r\nComment\r\n___\r\ndate=%qi, dateString=%@, id=%qi, imageId=%qi, message=%@, profileId=%qi, profileImage=%@, screenName=%@\r\n",
			_date, _dateString, _id, _imageId, _message, _profileId, _profileImage, _screenName
	];
}

-(void)dealloc {
	[_profileImage release];
	[_screenName release];
	[_message release];
	[_dateString release];
	[super dealloc];
}

@end
