//
//  Profile.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/20/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import "Profile.h"

@implementation Profile

@synthesize id			      = _id;
@synthesize serviceId	      = _serviceId;
@synthesize comments          = _comments;
@synthesize description       = _description;
@synthesize favorites         = _favorites;
@synthesize firstName         = _firstName;
@synthesize friends           = _friends;
@synthesize homepage          = _homepage;
@synthesize mapTypeForProfile = _mapTypeForProfile;
@synthesize photos			  = _photos;
@synthesize profileImage	  = _profileImage;
@synthesize profileImageData  = _profileImageData;
@synthesize screenName        = _screenName;
@synthesize settings		  = _settings;
@synthesize views   		  = _views;

-(id)init {
	if (self = [super init]) {
	}
	return self;
}

-(NSString*)description {
	return [NSString 
			stringWithFormat:@"\r\nProfile:\r\n---\r\nid=%qi, serviceId=%qi, comments=%@, description=%@, favorites=%@, firstName=%@, friends=%@, homepage=%@, mapTypeForProfile=%@, photos=%@, profileImage=%@, screenName=%@, settings=%@, views=%@\r\n---\r\n\n", 
			_id, _serviceId, _comments, _description, _favorites, _firstName, _friends, _homepage, _mapTypeForProfile, _photos, _profileImage, _screenName, _settings, _views];
}

-(void)dealloc {
	[_comments release];
	[_description release];
	[_favorites release];
	[_firstName release];
	[_friends release];
	[_homepage release];
	[_mapTypeForProfile release];
	[_photos release];
	[_profileImage release];
	[_profileImageData release];
	[_screenName release];
	[_settings release];
	[_views release];
	[super dealloc];
}

@end
