//
//  Favorites.h
//  TPAPITest
//
//  Created by David J. Hinson on 1/24/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Favorite.h"

@interface Favorites : NSObject {
	int					_count;
	int					_startIndex;
	NSMutableArray	*	_list;
}

@property int count;
@property int startIndex;
@property (retain, nonatomic) NSMutableArray * list;

@end
