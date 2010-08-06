//
//  KBDirectMessage.m
//  Kickball
//
//  Created by Shawn Bernard on 4/21/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBDirectMessage.h"
#import "KickballAPI.h"


@implementation KBDirectMessage

- (id) initWithDictionary:(NSDictionary*)statusDictionary {		
    if (self = [super init]) {
        screenName = [[statusDictionary objectForKey:@"sender"] objectForKey:@"screen_name"];
        profileImageUrl = [[statusDictionary objectForKey:@"sender"] objectForKey:@"profile_image_url"];
        tweetText = [statusDictionary objectForKey:@"text"];
        createDate = [[[[KickballAPI kickballApi] twitterDateFormatter] dateFromString:[statusDictionary objectForKey:@"created_at"]] retain];
        tweetId = [statusDictionary objectForKey:@"id"];
    }
    return self;
}

-(void)dealloc{
	[super dealloc];
}

@end
