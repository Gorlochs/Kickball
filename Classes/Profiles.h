//
//  Profiles.h
//  TPAPITest
//
//  Created by David J. Hinson on 1/24/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Profile.h"

@interface Profiles : NSObject {
	int					_count;
	int					_startIndex;
	NSMutableArray	*	_list;
	NSString		*	_filter;
	NSString		*	_linkedServices;
}

@property int count;
@property int startIndex;
@property (retain, nonatomic) NSMutableArray * list;
@property (retain, nonatomic) NSString * filter;
@property (retain, nonatomic) NSString * linkedServices;

@end
