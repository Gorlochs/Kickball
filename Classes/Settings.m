//
//  Settings.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/20/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import "Settings.h"

@implementation Settings

@synthesize doNotTweetFavoritePhoto = _doNotTweetFavoritePhoto;
@synthesize hideViewingPatterns     = _hideViewingPatterns;
@synthesize hideVotes               = _hideVotes;
@synthesize pin                     = _pin;
@synthesize shortenUrl              = _shortenUrl;
@synthesize email                   = _email;
@synthesize mapType                 = _mapType;

-(id)init {
	if (self = [super init]) {
		}
	return self;
}

-(NSString*)description {
	return [NSString stringWithFormat:@"\r\nSettings\r\n---\r\ndoNotTweetFavoritePhoto=%@, email=%@, hideViewingPatterns=%@, hideVotes=%@, mapType=%@, pin=%qi, shortenURL=%@\r\n\n", 
			_doNotTweetFavoritePhoto ? @"True" : @"False",
			_email,
			_hideViewingPatterns     ? @"True" : @"False",
			_hideVotes				 ? @"True" : @"False",
			_mapType,
			_pin,
			_shortenUrl				 ? @"True" : @"False"
	];
}

-(void)dealloc {
	[_email release];
	[_mapType release];
	[super dealloc];
}

@end
