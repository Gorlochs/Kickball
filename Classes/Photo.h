//
//  Photo.h
//  TPAPITest
//
//  Created by David J. Hinson on 1/6/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "Profile.h"
#import "Comments.h"

@interface Photo : NSObject {
	NSData				*_bigImage;
	NSString			*_bigImageURL;
	int					_commentCount;
	NSString			*_detailsURL;
	int					_unlikedVotes;
	long long			_gdAlias;
	int					_likedVotes;
	NSString			*_largeImageURL;
	Location *			_location;
	NSData				*_mediumImage;
	NSString			*_mediumImageURL;
	NSString			*_message;
	NSString			*_name;
	NSString			*_next;
	NSString			*_previous;
	NSString			*_thumbnailURL;
	NSData				*_thumbnailImage;
	long long			_tinyAlias;
	long long			_photoId;
	long long			_uploadDate;
	NSString			*_uploadDateString;
	Profile				*_user;
	long long			_userId;
	int					_views;
	Comments			*_photoComments;
}

@property (nonatomic,retain) NSData				*bigImage;
@property (nonatomic,retain) NSString			*bigImageURL;
@property int									commentCount;
@property (nonatomic,retain) NSString			*detailsURL;
@property long long								gdAlias;
@property int									likedVotes;
@property (nonatomic,retain) NSString			*largeImageURL;
@property (nonatomic, retain) Location			*location;
@property (nonatomic,retain) NSData				*mediumImage;
@property (nonatomic,retain) NSString			*mediumImageURL;
@property (nonatomic,retain) NSString			*message;
@property (nonatomic,retain) NSString			*name;
@property (nonatomic,retain) NSString			*next;
@property (nonatomic,retain) NSString			*previous;
@property (nonatomic,retain) NSString			*thumbnailURL;
@property long long								tinyAlias;
@property (nonatomic,retain) NSData				*thumbnailImage;
@property long long								photoId;
@property int									unlikedVotes;
@property long long								uploadDate;
@property (nonatomic,retain) NSString			*uploadDateString;
@property (nonatomic, retain) Profile			*user;
@property long long								userId;
@property int									views;
@property (nonatomic,retain) Comments			*photoComments;

@end
