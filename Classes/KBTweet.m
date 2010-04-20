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
@synthesize fullName;
@synthesize createDate;
@synthesize profileImageUrl;
@synthesize tweetText;
@synthesize tweetId;


// init with dictionary
- (id) initWithDictionary:(NSDictionary*)statusDictionary {		
    if (self = [super init]) {
        screenName = [[statusDictionary objectForKey:@"user"] objectForKey:@"screen_name"];
        fullName = [[statusDictionary objectForKey:@"user"] objectForKey:@"name"];
        profileImageUrl = [[statusDictionary objectForKey:@"user"] objectForKey:@"profile_image_url"];
        tweetText = [statusDictionary objectForKey:@"text"];
        createDate = [statusDictionary objectForKey:@"created_at"];
        NSLog(@"tweet id: %@", [statusDictionary objectForKey:@"id"]);
        tweetId = [statusDictionary objectForKey:@"id"];
        NSLog(@"tweet id: %@", tweetId);
        NSLog(@"tweet id: %qu", [tweetId longLongValue]);
    }
    return self;
}

@end
