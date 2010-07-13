//
//  Photo.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/6/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@synthesize photoId          = _photoId;
@synthesize bigImage         = _bigImage;
@synthesize bigImageURL      = _bigImageURL;
@synthesize detailsURL       = _detailsURL;
@synthesize gdAlias          = _gdAlias;
@synthesize largeImageURL   = _largeImageURL;
@synthesize location		 = _location;
@synthesize mediumImage      = _mediumImage;
@synthesize mediumImageURL   = _mediumImageURL;
@synthesize commentCount     = _commentCount;
@synthesize likedVotes       = _likedVotes;
@synthesize message          = _message;
@synthesize name             = _name;
@synthesize next             = _next;
@synthesize previous         = _previous;
@synthesize thumbnailURL     = _thumbnailURL;
@synthesize thumbnailImage   = _thumbnailImage;
@synthesize tinyAlias        = _tinyAlias;
@synthesize uploadDate		 = _uploadDate;
@synthesize uploadDateString = _uploadDateString;
@synthesize unlikedVotes     = _unlikedVotes;
@synthesize user			 = _user;
@synthesize userId           = _userId;
@synthesize views			 = _views;
@synthesize photoComments	 = _photoComments;

-(id)init {
	self = [super init];
	return self;
}

-(NSString*)description {
	return [NSString stringWithFormat:@"\r\nPhoto\r\n___\r\nphotoId=%qi, bigImageURL=%@, detailsURL=%@, largeImageUrl=%@, mediumImageURL=%@, message=%@, name=%@, next=%@, previous=%@, photoComments=%@ uploadDateString=%@\r\n", 
			_photoId, _bigImageURL, _detailsURL, 
			_largeImageURL, _mediumImageURL, _message, _name, _next, _previous, _photoComments, _uploadDateString
	];
}

-(void)dealloc {
	[_bigImageURL release];
	[_largeImageURL release];
	[_location release];
	[_message release];
	[_name release];
	[_next release];
	[_previous release];
	[_mediumImageURL release];
	[_detailsURL release];
	[_thumbnailURL release];
	[_uploadDateString release];
	[_mediumImage release];
	[_thumbnailImage release];
	[_user release];
	[_photoComments release];
	
	[super dealloc];
}

@end
