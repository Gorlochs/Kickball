//
//  KBDirectMessage.m
//  Kickball
//
//  Created by Shawn Bernard on 4/21/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBDirectMessage.h"
#import "KickballAPI.h"
#import "RegexKitLite.h"


@implementation KBDirectMessage

- (id) initWithDictionary:(NSDictionary*)statusDictionary {		
    if (self = [super init]) {
        screenName = [[[statusDictionary objectForKey:@"sender"] objectForKey:@"screen_name"] copy];
        profileImageUrl = [[[statusDictionary objectForKey:@"sender"] objectForKey:@"profile_image_url"] copy];
        tweetText = [[statusDictionary objectForKey:@"text"] copy];
        createDate = [[[[KickballAPI kickballApi] twitterDateFormatter] dateFromString:[statusDictionary objectForKey:@"created_at"]] retain];
        tweetId = [[statusDictionary objectForKey:@"id"] copy];
		fullName = nil;
		
		NSString *clientWithLink = [statusDictionary objectForKey:@"source"];
		DLog("************** client with link: %@", clientWithLink);
		NSRange matchedRange = [clientWithLink rangeOfRegex:@">(.*)<"];
		
		if (matchedRange.location != NSNotFound) {
			NSRange reducedRange = NSMakeRange(matchedRange.location + 1, matchedRange.length - 2);
			clientName = [[clientWithLink substringWithRange:reducedRange] copy];
			DLog(@"********************************* clientName: %@", clientName);
		} else if ([statusDictionary objectForKey:@"source"]) {
			clientName = [[statusDictionary objectForKey:@"source"] copy];
		} else {
			clientName = @"";
		}
    }
    return self;
}

-(void)dealloc{
	[super dealloc];
}

@end
