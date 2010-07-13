//
//  TweetPhotoDate.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/22/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import "TweetPhotoDate.h"

@implementation TweetPhotoDate

@synthesize uploadDate			= _uploadDate;
@synthesize uploadDateString	= _uploadDateString;

-(id)init {
	if (self=[super init]) {
		}
	return self;
}

-(NSString*)description {
	return [NSString stringWithFormat:@"\r\nTweetPhotoDate\r\n___\r\nupdateDate=%qi, updateDateString=%@\r\n",
			_uploadDate, _uploadDateString
			];
}

-(void)dealloc {
	[_uploadDateString release];
	[super dealloc];
}

@end
