//
//  SocialFeedEvent.h
//  TPAPITest
//
//  Created by David J. Hinson on 1/22/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TweetPhotoDate.h"
#import "Profile.h"

@interface SocialFeedEvent : NSObject {
	NSString		*	_content;
	TweetPhotoDate	*	_date;
	NSString		*	_eventType;
	NSString		*	_imageThumbnail;
	long long			_photoId;
	Profile			*	_user;
}

@property long long photoId;
@property (retain, nonatomic) NSString * content;
@property (retain, nonatomic) NSString * eventType;
@property (retain, nonatomic) NSString * imageThumbnail;
@property (retain, nonatomic) TweetPhotoDate * date;
@property (retain, nonatomic) Profile * user;

@end
