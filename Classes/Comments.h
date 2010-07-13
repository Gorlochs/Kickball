//
//  Comments.h
//  TPAPITest
//
//  Created by David J. Hinson on 1/24/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"

@interface Comments : NSObject {
	int					_count;
	int					_startIndex;
	long long			_photoId;
	NSMutableArray	*	_list;
}

@property int count;
@property int startIndex;
@property long long photoId;
@property (retain,nonatomic) NSMutableArray * list;

@end
