//
//  Comment.h
//  TPAPITest
//
//  Created by David J. Hinson on 1/20/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Comment : NSObject {
	long long	_date;
	NSString	*_dateString;
	long long	_id;
	long long	_imageId;
	NSString	*_message;
	long long	_profileId;
	NSString	*_profileImage;
	NSString	*_screenName;
}

@property long long date;
@property long long id;
@property long long imageId;
@property long long profileId;
@property (retain, nonatomic) NSString * dateString;
@property (retain, nonatomic) NSString * message;
@property (retain, nonatomic) NSString * profileImage;
@property (retain, nonatomic) NSString * screenName;

@end
