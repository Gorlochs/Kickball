//
//  SocialFeed.h
//  TPAPITest
//
//  Created by David J. Hinson on 1/22/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocialFeed : NSObject {
	int					_count;
	int					_startIndex;
	NSString		*	_filter;
	NSMutableArray	*	_list;		// Array of SocialFeedEvent
}

@property int count;
@property int startIndex;
@property (nonatomic,retain) NSString * filter;
@property (nonatomic,retain) NSMutableArray * list;

@end
