//
//  TweetPhotoResponse.h
//  TPAPITest
//
//  Created by David J. Hinson on 1/22/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetPhotoResponse : NSObject {
	NSString	* _large;
	long long	  _mediaId;
	NSString	* _mediaUrl;
	NSString	* _medium;
	NSString	* _original;
	long long	_photoId;
	NSString	*_sessionKeyResponse;
	NSString	*_thumbnail;
	NSString	*_status;
	long long	_userId;
}

@property long long mediaId;
@property long long photoId;
@property long long userId;
@property (retain,nonatomic) NSString * large;
@property (retain,nonatomic) NSString * mediaUrl;
@property (retain,nonatomic) NSString * medium;
@property (retain,nonatomic) NSString * original;
@property (retain,nonatomic) NSString * sessionKeyResponse;
@property (retain,nonatomic) NSString * thumbnail;
@property (retain,nonatomic) NSString * status;

@end
