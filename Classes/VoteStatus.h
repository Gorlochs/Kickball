//
//  VoteStatus.h
//  TPAPITest
//
//  Created by David J. Hinson on 1/24/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoteStatus : NSObject {
	long long		_photoId;
	long long		_userId;
	NSString	*	_status;
}

@property long long photoId;
@property long long userId;
@property (retain,nonatomic) NSString * status;

@end
