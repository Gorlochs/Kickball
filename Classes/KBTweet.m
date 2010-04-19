//
//  KBTweet.m
//  Kickball
//
//  Created by Shawn Bernard on 4/18/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTweet.h"
#import "KickballAPI.h"


@implementation KBTweet

@synthesize screenName;
@synthesize createDate;
@synthesize profileImageUrl;
@synthesize tweetText;


// init with dictionary
- (id) initWithDictionary:(NSDictionary*)statusDictionary {		
    if (self = [super init]) {
        screenName = [[statusDictionary objectForKey:@"user"] objectForKey:@"screen_name"];
        profileImageUrl = [[statusDictionary objectForKey:@"user"] objectForKey:@"profile_image_url"];
        tweetText = [statusDictionary objectForKey:@"text"];
        createDate = [statusDictionary objectForKey:@"created_at"];
    }
    return self;
}

@end
