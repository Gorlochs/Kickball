//
//  Favorite.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/20/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import "Favorite.h"

@implementation Favorite

@synthesize favoriteDate       = _favoriteDate;
@synthesize favoriteDateString = _favoriteDateString;
@synthesize imageId            = _imageId;
@synthesize photo              = _photo;
@synthesize userId			   = _userId;

-(id)init {
	if (self = [super init]) {
		}
	return self;
}

-(NSString*)description {
	return [NSString stringWithFormat:@"\r\nFavorite\r\n---\r\nfavoriteDate=%qi, favoriteDateString=%@, imageId=%qi, photo=%@\r\n",
			_favoriteDate, _favoriteDateString, _imageId, _photo];
}

-(void)dealloc {
	[_favoriteDateString release];
	[_photo release];
	[super dealloc];
}

@end
