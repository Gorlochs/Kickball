//
//  Favorite.h
//  TPAPITest
//
//  Created by David J. Hinson on 1/20/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"

@interface Favorite : NSObject {
	long long	_favoriteDate;
	NSString *	_favoriteDateString;
	long long	_imageId;
	long long	_userId;
	Photo *		_photo;
}

@property long long favoriteDate;
@property long long imageId;
@property long long userId;
@property (retain, nonatomic) NSString * favoriteDateString;
@property (retain, nonatomic) Photo * photo;

@end
