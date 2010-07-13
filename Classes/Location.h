//
//  Location.h
//  TPAPITest
//
//  Created by David J. Hinson on 1/20/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject {
	float _latitude;
	float _longitude;
}

@property float latitude;
@property float longitude;

@end
