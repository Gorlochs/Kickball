//
//  KBSearchResult.m
//  Kickball
//
//  Created by Shawn Bernard on 4/20/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBSearchResult.h"


@implementation KBSearchResult

- (id) initWithDictionary:(NSDictionary*)statusDictionary {		
    if (self = [super init]) {
        screenName = [statusDictionary objectForKey:@"from_user"];
        profileImageUrl = [statusDictionary objectForKey:@"profile_image_url"];
        tweetText = [statusDictionary objectForKey:@"text"];
        createDate = [[NSDate dateWithTimeIntervalSince1970:[[statusDictionary objectForKey:@"created_at"] doubleValue]] retain];
        tweetId = [statusDictionary objectForKey:@"id"];
    }
    return self;
}

@end
