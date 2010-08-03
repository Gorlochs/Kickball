//
//  KBTweet.m
//  Kickball
//
//  Created by Shawn Bernard on 4/18/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTweet.h"
#import "KickballAPI.h"
#import "RegexKitLite.h"


@implementation KBTweet

@synthesize screenName;
@synthesize fullName;
@synthesize createDate;
@synthesize profileImageUrl;
@synthesize tweetText;
@synthesize tweetId;
@synthesize isFavorited;
@synthesize clientName;

// init with dictionary
- (id) initWithDictionary:(NSDictionary*)statusDictionary {		
    if (self = [super init]) {
        dict = [[NSDictionary alloc] initWithDictionary:statusDictionary];
        screenName = [[statusDictionary objectForKey:@"user"] objectForKey:@"screen_name"];
        fullName = [[statusDictionary objectForKey:@"user"] objectForKey:@"name"];
        profileImageUrl = [[statusDictionary objectForKey:@"user"] objectForKey:@"profile_image_url"];
        tweetText = [statusDictionary objectForKey:@"text"];
        tweetId = [statusDictionary objectForKey:@"id"];
		//clientName = [statusDictionary objectForKey:@"source"];
		
		//NSRange   matchedRange = NSMakeRange(NSNotFound, 0);
		NSString *clientWithLink = [statusDictionary objectForKey:@"source"];
		DLog("************** client with link: %@", clientWithLink);
		NSRange matchedRange = [clientWithLink rangeOfRegex:@">(.*)<"];
		clientName = @"";
		if (matchedRange.location != NSNotFound) {
			NSRange reducedRange = NSMakeRange(matchedRange.location + 1, matchedRange.length - 2);
			clientName = [[clientWithLink substringWithRange:reducedRange] retain];
			DLog(@"********************************* clientName: %@", clientName);
		} else if ([statusDictionary objectForKey:@"source"]) {
			clientName = [statusDictionary objectForKey:@"source"];
		}
		
//		NSString * searchString = [statusDictionary objectForKey:@"text"];
//		NSString *regexString = @">(.*)<";
//		NSArray  *matchArray   = nil;
//		matchArray = [searchString componentsMatchedByRegex:regexString];
		
		
		
        
        createDate = [[[[KickballAPI kickballApi] twitterDateFormatter] dateFromString:[statusDictionary objectForKey:@"created_at"]] retain];
        isFavorited = [[statusDictionary objectForKey:@"favorited"] boolValue];
    }
    return self;
}

- (NSString*) description {
	return [NSString stringWithFormat:@"(TWEET : screenName=%@ ; fullName=%@ ; profileImageUrl=%@ ; tweetText=%@ ; tweetId=%qu)", screenName, fullName, profileImageUrl, tweetText, [tweetId longLongValue]];
}

- (void) encodeWithCoder: (NSCoder *)coder { 
    [coder encodeObject: screenName forKey:@"screenName"]; 
    [coder encodeObject: fullName forKey:@"fullName"]; 
    [coder encodeObject: createDate forKey:@"createDate"]; 
    [coder encodeObject: profileImageUrl forKey:@"profileImageUrl"]; 
    [coder encodeObject: tweetText forKey:@"tweetText"]; 
    [coder encodeObject: clientName forKey:@"clientName"]; 
    [coder encodeObject: tweetId forKey:@"tweetId"]; 
    [coder encodeObject: [NSNumber numberWithBool:isFavorited] forKey:@"favorited"]; 
} 

- (id) initWithCoder: (NSCoder *)coder { 
    if (self = [super init]) {
        [self setScreenName: [coder decodeObjectForKey:@"screenName"]]; 
        [self setFullName: [coder decodeObjectForKey:@"fullName"]];  
        [self setCreateDate: [coder decodeObjectForKey:@"createDate"]];  
        [self setProfileImageUrl: [coder decodeObjectForKey:@"profileImageUrl"]]; 
        [self setTweetText: [coder decodeObjectForKey:@"tweetText"]]; 
        [self setClientName: [coder decodeObjectForKey:@"clientName"]]; 
        [self setTweetId: [coder decodeObjectForKey:@"tweetId"]]; 
        [self setIsFavorited: [[coder decodeObjectForKey:@"favorited"] boolValue]]; 
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
	[clientName release];
    [super dealloc];
}

@end
