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
        dict = [[NSDictionary alloc] initWithDictionary:statusDictionary];
        screenName = [[statusDictionary objectForKey:@"user"] objectForKey:@"screen_name"];
        fullName = [[statusDictionary objectForKey:@"user"] objectForKey:@"name"];
        profileImageUrl = [[statusDictionary objectForKey:@"user"] objectForKey:@"profile_image_url"];
        tweetText = [statusDictionary objectForKey:@"text"];
        tweetId = [statusDictionary objectForKey:@"id"];
        createDate = [[[[KickballAPI kickballApi] twitterDateFormatter] dateFromString:[statusDictionary objectForKey:@"created_at"]] retain];
        
        //DLog(@"tweet created at: %@", createDate);
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder { 
    [coder encodeObject: screenName forKey:@"screenName"]; 
    [coder encodeObject: fullName forKey:@"fullName"]; 
    [coder encodeObject: createDate forKey:@"createDate"]; 
    [coder encodeObject: profileImageUrl forKey:@"profileImageUrl"]; 
    [coder encodeObject: tweetText forKey:@"tweetText"]; 
    [coder encodeObject: tweetId forKey:@"tweetId"]; 
} 

- (id) initWithCoder: (NSCoder *)coder { 
    if (self = [super init]) {
        [self setScreenName: [coder decodeObjectForKey:@"screenName"]]; 
        [self setFullName: [coder decodeObjectForKey:@"fullName"]];  
        [self setCreateDate: [coder decodeObjectForKey:@"createDate"]];  
        [self setProfileImageUrl: [coder decodeObjectForKey:@"profileImageUrl"]]; 
        [self setTweetText: [coder decodeObjectForKey:@"tweetText"]]; 
        [self setTweetId: [coder decodeObjectForKey:@"tweetId"]]; 
    } 
    return self; 
}

- (void) dealloc {
    [dict release];
    [screenName release];
    [fullName release];
    [createDate release];
    [profileImageUrl release];
    [tweetText release];
    [tweetId release];
    [super dealloc];
}

@end
