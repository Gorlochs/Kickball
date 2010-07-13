//
//  Settings.h
//  TPAPITest
//
//  Created by David J. Hinson on 1/20/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject {
	BOOL		_doNotTweetFavoritePhoto;
	NSString *	_email;
	BOOL		_hideViewingPatterns;
	BOOL		_hideVotes;
	NSString *	_mapType;
	long long	_pin;
	BOOL		_shortenUrl;
}

@property long long pin;
@property BOOL doNotTweetFavoritePhoto;
@property BOOL hideViewingPatterns;
@property BOOL hideVotes;
@property BOOL shortenUrl;
@property (retain, nonatomic) NSString * email;
@property (retain, nonatomic) NSString * mapType;

@end
