//
//  KBSearchResult.m
//  Kickball
//
//  Created by Shawn Bernard on 4/20/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//


#import "KBSearchResult.h"


@implementation KBSearchResult

@synthesize latitude;
@synthesize longitude;

- (id) initWithDictionary:(NSDictionary*)statusDictionary {		
    if (self = [super init]) {
        screenName = [statusDictionary objectForKey:@"from_user"];
        profileImageUrl = [statusDictionary objectForKey:@"profile_image_url"];
        tweetText = [statusDictionary objectForKey:@"text"];
        createDate = [[NSDate dateWithTimeIntervalSince1970:[[statusDictionary objectForKey:@"created_at"] doubleValue]] retain];
        tweetId = [statusDictionary objectForKey:@"id"];
        // the nil check doesn't work by itself. I must be missing something
        if ([statusDictionary objectForKey:@"geo"] != nil && ![[statusDictionary objectForKey:@"geo"] isKindOfClass:[NSNull class]]) {
            NSArray *coordinates = [[statusDictionary objectForKey:@"geo"] objectForKey:@"coordinates"];
            self.latitude = [[coordinates objectAtIndex:0] floatValue];
            self.longitude = [[coordinates objectAtIndex:1] floatValue];
            NSLog(@"search result lat/long: %f : %f", latitude, longitude);
        }
    }
    return self;
}

@end
