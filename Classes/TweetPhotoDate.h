//
//  TweetPhotoDate.h
//  TPAPITest
//
//  Created by David J. Hinson on 1/22/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetPhotoDate : NSObject {
	long long	_uploadDate;
	NSString *	_uploadDateString;
}

@property long long uploadDate;
@property (retain,nonatomic) NSString * uploadDateString;

@end
